Unit Un_PdfNino;

Interface

Uses System.SysUtils,
     System.Classes,
     System.Math,

     FMX.Objects,

     Un_PdfObjetos,
     Un_PdfXRef,
     Un_PdfPagina;

Const VERSION_COMMENT='%PDF-';

     //------------------------------------------------------------------------
Type TRegInfoPdf=Record
                  Titulo,
                  Autor,
                  Assunto,
                  PalavrasChave,
                  Criador,
                  Produtor,
                  DataCriacao,
                  DataModif:String;
                 End;
     //------------------------------------------------------------------------
     //Objeto Pdf
     TPdf=Class(TObject)
          Private
             img_Pagina:TImage;

             int_VersaoMaior,
             int_VersaoMenor,
             int_QtdPaginas:Integer;

             str_Versao:AnsiString;

             int_PagAtual,
             int_Zoom:Word;

             obj_Raiz,
             obj_Codifica,
             obj_Paginas:TPdfObjeto;

             bol_PodeImprimir,
             bol_PodeGravar:Boolean;

             reg_InfoPdf:TRegInfoPdf;
             obj_XRef:TXRef;
             stm_Dados:TStringStream;

             lst_Paginas:TList;

             flt_Zoom:Real;

             Procedure TrataVersao(str_LinhaVersao:String);
             Function BuscaStartXRef:Int64;
             Procedure CarregaXRef(int_PosXRef:Int64);
             Procedure CarregaPaginas(obj_DicPagina:TPdfObjeto);
             Procedure TrataPagina(int_PagAtual:Word);
             Procedure TrataZoom(int_Zoom:Word);
          Public
             Constructor Create(str_ArqPdf:String;Var img_Pagina:TImage);
             Procedure RenderizaPagina;
             Property QtdPaginas:Integer Read int_QtdPaginas;
             Property PagAtual:Word Read int_PagAtual Write TrataPagina;
             Property Info:TRegInfoPdf Read reg_InfoPdf;
             Property Zoom:Word Read int_Zoom Write TrataZoom Default 100;
          End;

Implementation

Uses System.Types,
     FMX.Dialogs,

     Un_PdfUtils;
//-----------------------------------------------------------------------------
// TPdf
//-----------------------------------------------------------------------------
Constructor TPdf.Create(str_ArqPdf:String;Var img_Pagina:TImage);
Var str_Busca:String;
    int_IdObjPaginas:Integer;
Begin
 int_QtdPaginas:=0;

 If FileExists(str_ArqPdf) Then
    Begin
     Inherited Create;
     Self.img_Pagina:=img_Pagina;

     Self.int_Zoom:=100;
     Self.flt_Zoom:=1;

     Self.stm_Dados:=TStringStream.Create;
     Self.stm_Dados.LoadFromFile(str_ArqPdf);
     //Posiciona no começo do arquivo.
     Self.stm_Dados.Position:=0;
     //Obtém a primeira linha.
     str_Busca:=_BuscaLinha(Self.stm_Dados);
     //A linha está correta?
     If Pos(VERSION_COMMENT,str_Busca)=1 Then
        TrataVersao(Copy(str_Busca,Length(VERSION_COMMENT)+1,Length(str_Busca)-Length(VERSION_COMMENT)+1));

     //Cria a estrutura que vai receber o conteúdo da tabela XRef
     Self.obj_XRef:=TXRef.Create(Self.stm_Dados);
     CarregaXRef(BuscaStartXRef);
     Self.lst_Paginas:=TList.Create;
     CarregaPaginas(Self.obj_Paginas);
     Self.RenderizaPagina;
    End
 Else
    Raise Exception.Create('Arquivo "'+str_ArqPdf+'" não encontrado.');
End;
//-----------------------------------------------------------------------------
Procedure TPdf.TrataVersao(str_LinhaVersao: String);
Begin
 Self.int_VersaoMaior:=StrToIntDef(Copy(str_LinhaVersao,1,Pos('.',str_LinhaVersao)-1),0);
 Self.int_VersaoMenor:=StrToIntDef(Copy(str_LinhaVersao,Pos('.',str_LinhaVersao)+1,Length(str_LinhaVersao)-Pos('.',str_LinhaVersao)),0);
 Self.str_Versao:=str_LinhaVersao;
End;
//-----------------------------------------------------------------------------
Function TPdf.BuscaStartXRef:Int64;
Var arr_Busca:Array[1..32] Of AnsiChar;
    int_PosXRef,
    int_Pos,
    int_PosIni:Int64;
    str_Busca:AnsiString;
Begin
 //Vai para 32 posições antes do fim do arquivo para encontrar o texto "startxref"
 int_PosXRef:=Self.stm_Dados.Size-SizeOf(arr_Busca);
 int_Pos:=0;

 While int_PosXRef>=0 Do
       Begin
        Self.stm_Dados.Position:=int_PosXRef;
        Self.stm_Dados.Read(arr_Busca,SizeOf(arr_Busca));
        //Verifica se encontrou "startxref"
        int_Pos:=Pos('startxref',String(arr_Busca));
        //Encontrou?
        If int_Pos>0 Then
           Begin
            //Sim, mas a posição encontrada não passa do tamanho da stream?
            If int_PosXRef+int_Pos+SizeOf(arr_Busca)<=stm_Dados.Size Then
               Begin
                //Não, obtém a posição
                int_PosXRef:=int_PosXRef+int_Pos;
                int_Pos:=0;
               End;
            Break;
           End;
        //Volta mais 32 posições...
        int_PosXRef:=int_PosXRef-SizeOf(arr_Busca)-10;
       End;
 //Encontrou?
 If int_PosXRef<0 Then
    //Não gera o erro!
    Raise Exception.Create('Este não é um arquivo Pdf válido.');

 Self.stm_Dados.position:=int_PosXRef;
 Self.stm_Dados.Read(arr_Busca,SizeOf(arr_Busca));
 str_Busca:=String(arr_Busca);

 //Pula "startxref" e o caractere EOL
 Inc(int_Pos,10);
 //Pula possível 2o. caractere EOL
 If Ord(str_Busca[int_Pos])<32 Then
    Inc(int_Pos);
 //Pula possíveis caracteres branco
 While Ord(str_Busca[int_Pos])=32 Do
       Inc(int_Pos);

 //Lê a posição
 int_PosIni:=int_Pos;
 While (int_Pos<Length(str_Busca)) And (str_Busca[int_Pos]>='0') And (str_Busca[int_Pos]<='9') Do
       Inc(int_Pos);

 Result:=StrToIntDef(Copy(str_Busca,int_PosIni,int_Pos-int_PosIni),0);
End;
//-----------------------------------------------------------------------------
Procedure TPdf.CarregaXRef(int_PosXRef:Int64);
Var bol_TemTabelaXRef,
    bol_AchouTrailer:Boolean;
    obj_Lido,
    obj_DicTrailer,
    obj_PosPrevXRef,
    obj_Permissoes,
    obj_QtdPaginas,
    obj_Info:TPdfObjeto;
    int_IncioRef,
    int_TamRef,
    int_IdRef,
    int_Permissoes,
    int_IdObjInfo,
    int_IdObjPaginas:Integer;
    str_LinhaRef,
    str_Aux:String;
Begin
 //Posiciona no início da tabela XRef
 Self.stm_Dados.Position:=int_PosXRef;

 bol_TemTabelaXRef:=True;
 //Enquanto tem tabela XRef...
 While bol_TemTabelaXRef Do
       Begin
        //O próximo ítem é o texto "xref"?
        If Not _ProximoItem(Self.stm_Dados,'xref') Then
           //Não, tem coisa errada!
           Raise Exception.Create('Não foi encontrado "xref" no início da tabela')
        Else
           Begin
            //Sim, enquanto não achou o texto "trailer"...
            bol_AchouTrailer:=False;
            While Not bol_AchouTrailer Do
                  Begin
                   //Lê o objeto...
                   obj_Lido:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,False);
                   //Achou o texto trailer?
                   If (obj_Lido.Tipo=obj_keyword) And (obj_Lido.ObtemValorString='trailer') Then
                      //Sim, para a leitura do XRef
                      bol_AchouTrailer:=True
                   //Não, mas o objeto lido é numérico?
                   Else If obj_Lido.Tipo=obj_numero Then
                      Begin
                       //Sim, obtém o início da tabela XRef
                       int_IncioRef:=TPdfObjNumerico(obj_Lido.Conteudo).ObtemValorInteiro;
                       obj_Lido.Free;
                       //Lê o próximo objeto...
                       obj_Lido:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,False);
                       //É numérico também?
                       If obj_Lido.Tipo=obj_numero Then
                          Begin
                           //Sim, obtém o tabanho da tabela XRef
                           int_TamRef:=TPdfObjNumerico(obj_Lido.Conteudo).ObtemValorInteiro;
                           //Pula uma linha...
                           _BuscaLinha(Self.stm_Dados);
                           For int_IdRef:=int_IncioRef To int_IncioRef+int_TamRef-1 Do
                               Begin
                                //Cada referência da tabela XRef tem 20 posições
                                str_LinhaRef:=Self.stm_Dados.ReadString(20);
                                //Insere na estrutura
                                Self.obj_XRef.Insere(int_IdRef,str_LinhaRef)
                               End;
                          End
                       Else
                          Raise Exception.Create('Não foi encontrado um número com o tamanho da tabela xref.');
                      End
                   Else
                      Raise Exception.Create('Não foi encontrado um número como primeiro ítem da linha da tabela xref.');
                  End;
            //Agora que já leu a tabela XRef, busca o próximo objeto (dicionário do trailer)...
            obj_DicTrailer:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,False);
            //É dicionário?
            If obj_DicTrailer.Tipo=obj_dicionario Then
               Begin
                //Já leu o objeto raiz?
                If obj_Raiz=Nil Then
                   Begin
                    //Não, mas ele existe no dicionário?
                    If TPdfObjDicionario(obj_DicTrailer.Conteudo).ExisteChave('Root') Then
                       Begin
                        //Sim, mas é objeto indireto?
                        If TPdfObjDicionario(obj_DicTrailer.Conteudo).ObtemValorChave('Root').Tipo=obj_indireto Then
                           obj_Raiz:=TPdfObjIndireto(TPdfObjDicionario(obj_DicTrailer.Conteudo).ObtemValorChave('Root').Conteudo).ObtemValorRef(Self.obj_XRef)
                        Else
                           obj_Raiz:=TPdfObjDicionario(obj_DicTrailer.Conteudo).ObtemValorChave('Root');
                       End;
                   End;

                //Já leu o objeto de codificação do documento?
                If obj_Codifica=Nil Then
                   //Não, obtém ele (conteúdo da chave "/Encrypt")
                   obj_Codifica:=TPdfObjDicionario(obj_DicTrailer.Conteudo).ObtemValorChave('Encrypt');

                //Já leu o objeto com as metadados do documento?
                If obj_Info=Nil Then
                   //Não, obtém ele (conteúdo da chave "/Info")
                   obj_Info:=TPdfObjDicionario(obj_DicTrailer.Conteudo).ObtemValorChave('Info');

                //Busca a localização da próxima tabela XRef
                obj_PosPrevXRef:=TPdfObjDicionario(obj_DicTrailer.Conteudo).ObtemValorChave('Prev');
                 //Encontrou?
                If obj_PosPrevXRef<>Nil Then
                   //Sim, posiciona nela
                   Self.stm_Dados.Position:=TPdfObjNumerico(obj_PosPrevXRef.Conteudo).ObtemValorInteiro
                 Else
                   bol_TemTabelaXRef:=False;
               End
            Else
               Raise Exception.Create('Não foi encontrado um objeto dicionário após "trailer".');
           End;
       End;
 //Achou o objeto raiz?
 If obj_Raiz<>Nil Then
    Begin
     //Sim, obtém os metadados do documento
     If obj_Info<>Nil Then
        Begin
         If obj_Info.Tipo=obj_indireto Then
            Begin
             int_IdObjInfo:=TPdfObjIndireto(obj_Info.Conteudo).ObtemId;
             obj_Info.Free;
             obj_Info:=TPdfObjeto(Self.obj_XRef.BuscaObjetoPorId(int_IdObjInfo));
            End;
         If obj_Info.Tipo=obj_dicionario Then
            Begin
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('Title') Then
                reg_InfoPdf.Titulo:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('Title').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('Author') Then
                reg_InfoPdf.Autor:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('Author').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('Subject') Then
                reg_InfoPdf.Assunto:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('Subject').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('Keywords') Then
                 reg_InfoPdf.PalavrasChave:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('Keywords').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('Creator') Then
                reg_InfoPdf.Criador:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('Creator').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('Producer') Then
                reg_InfoPdf.Produtor:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('Producer').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('CreationDate') Then
                reg_InfoPdf.DataCriacao:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('CreationDate').ObtemValorString;
             If TPdfObjDicionario(obj_Info.Conteudo).ExisteChave('ModDate') Then
                reg_InfoPdf.DataModif:=TPdfObjDicionario(obj_Info.Conteudo).ObtemValorChave('ModDate').ObtemValorString;
            End;
        End;

     //Busca a quantidade de páginas do documento
     obj_Paginas:=TPdfObjDicionario(obj_Raiz.Conteudo).ObtemValorChave('Pages');
     If obj_Paginas<>Nil Then
        Begin
         If obj_Paginas.Tipo=obj_indireto Then
            Begin
             int_IdObjPaginas:=TPdfObjIndireto(obj_Paginas.Conteudo).ObtemId;
             obj_Paginas.Free;
             obj_Paginas:=TPdfObjeto(Self.obj_XRef.BuscaObjetoPorId(int_IdObjPaginas));
            End;
         If obj_Paginas.Tipo=obj_dicionario Then
            Begin
             obj_QtdPaginas:=TPdfObjDicionario(obj_Paginas.Conteudo).ObtemValorChave('Count');
             If obj_QtdPaginas.Tipo=obj_numero Then
                Self.int_QtdPaginas:=TPdfObjNumerico(obj_QtdPaginas.Conteudo).ObtemValorInteiro;
            End;
        End;

     //Tem dados opcionais da versão?
     If TPdfObjDicionario(obj_Raiz.Conteudo).ObtemValorChave('Version')<>Nil Then
        //Sim, redefine a versão do documento
        TrataVersao(TPdfObjString(TPdfObjDicionario(obj_Raiz).ObtemValorChave('Version').Conteudo).ObtemValor);

     //Sim, mas tembém leu o objeto de codificação?
     If obj_Codifica<>Nil Then
        Begin
         //Sim, obtém as permissões
         obj_Permissoes:=TPdfObjDicionario(obj_Codifica.Conteudo).ObtemValorChave('P');
         //Conseguiu?
         If obj_Permissoes<>Nil  Then
            Begin
             //Sim, mas é numérico?
             If obj_Permissoes.Tipo=obj_numero Then
                Begin
                 //Sim
                 int_Permissoes:=TPdfObjNumerico(obj_Permissoes.Conteudo).ObtemValorInteiro;
                 bol_PodeImprimir:=(int_Permissoes And 4)<>0;
                 bol_PodeGravar:=(int_Permissoes And 16)<>0;
                End;
            End;
        End;
      If int_QtdPaginas>0 Then
         int_PagAtual:=1
      Else
         int_PagAtual:=0;
    End
 Else
    Raise Exception.Create('Não foi encontrada a entrada "/Root" no dicionário trailer.');
End;
//-----------------------------------------------------------------------------
Procedure TPdf.CarregaPaginas(obj_DicPagina:TPdfObjeto);
Var I:Integer;
Begin
 If obj_DicPagina.Tipo=obj_indireto Then
    obj_DicPagina:=TPdfObjeto(Self.obj_XRef.BuscaObjetoPorId(TPdfObjIndireto(obj_DicPagina.Conteudo).ObtemId));
 //Existe a chave "Type" e seu conteúdo é "Page"?
 If (TPdfObjDicionario(obj_DicPagina.Conteudo).ExisteChave('Type')) And (TPdfObjDicionario(obj_DicPagina.Conteudo).ObtemValorChave('Type').ObtemValorString='Pages') Then
    Begin
     If (TPdfObjDicionario(obj_DicPagina.Conteudo).ExisteChave('Kids')) And (TPdfObjDicionario(obj_DicPagina.Conteudo).ObtemValorChave('Kids').Tipo=obj_array) Then
        Begin
         For I:=0 To TPdfObjArray(TPdfObjDicionario(obj_DicPagina.Conteudo).ObtemValorChave('Kids').Conteudo).Tamanho-1 Do
             CarregaPaginas(TPdfObjArray(TPdfObjDicionario(obj_DicPagina.Conteudo).ObtemValorChave('Kids').Conteudo).ObtemValorItem(I));
        End;
    End
 Else If (TPdfObjDicionario(obj_DicPagina.Conteudo).ExisteChave('Type')) And (TPdfObjDicionario(obj_DicPagina.Conteudo).ObtemValorChave('Type').ObtemValorString='Page') Then
    Begin
     Self.lst_Paginas.Add(obj_DicPagina);
    End;
End;
//-----------------------------------------------------------------------------
Procedure TPdf.TrataPagina(int_PagAtual:Word);
Begin
 If int_PagAtual<>Self.int_PagAtual Then
    Begin
     Self.int_PagAtual:=int_PagAtual;
     Self.RenderizaPagina;
    End;
End;
//-----------------------------------------------------------------------------
Procedure TPdf.TrataZoom(int_Zoom:Word);
Begin
 If int_Zoom>=10 Then
    Begin
     Self.int_Zoom:=int_Zoom;
     Self.flt_Zoom:=Self.int_Zoom/100;
     Self.RenderizaPagina;
    End;
End;
//-----------------------------------------------------------------------------
Procedure TPdf.RenderizaPagina;
Var obj_Pagina:TPdfPagina;
Begin
  If img_Pagina=Nil Then
    img_Pagina:=TImage.Create(Nil);

 obj_Pagina:=TPdfPagina.Create(Self.img_Pagina,Self.obj_XRef,Self.int_PagAtual,TPdfObjeto(Self.lst_Paginas[Self.int_PagAtual-1]),Self.flt_Zoom);
End;
//-----------------------------------------------------------------------------

End.


