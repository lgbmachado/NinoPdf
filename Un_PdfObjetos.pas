Unit Un_PdfObjetos;

Interface

Uses Classes,
     Un_PdfXRef;

Type //------------------------------------------------------------------------
     TPdfTipoObjeto=(obj_boolean,obj_numero,obj_indireto,obj_string,obj_nome,obj_array,obj_dicionario,obj_stream,obj_nulo,obj_keyword,obj_embedded);
     //------------------------------------------------------------------------
     TPdfObjeto=Class(TObject)
                 Private
                    stm_Dados:TStringStream;
                    int_IdObj:Integer;
                    obj_Tipo:TPdfTipoObjeto;
                    obj_Conteudo:TObject;
                    obj_XRef:TXRef;
                 Public
                    Constructor Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef;int_IdObj,int_GemObj:Integer;bol_TestaNumero:Boolean);
                    Function ObtemValorString:String;
                    Property Tipo:TPdfTipoObjeto Read obj_Tipo;
                    Property Conteudo:TObject Read obj_Conteudo;
                    Property Id:Integer Read int_IdObj;
                 End;
     //------------------------------------------------------------------------
     //Objetos do tipo numéricos
     TPdfObjNumerico=Class(TObject)
                    Private
                       flt_Valor:Extended;
                    Public
                       Constructor Create(Var stm_Dados:TStringStream;chr_Dado:AnsiChar);
                       Function ObtemValorReal:Extended;
                       Function ObtemValorInteiro:Int64;
                    End;
     //------------------------------------------------------------------------
     //Objetos do tipo string
     TPdfObjString=Class(TObject)
                    Private
                       str_Valor:String;
                    Public
                       Constructor Create(Var stm_Dados:TStringStream;bol_Hex:Boolean);
                       Function ObtemValor:String;
                    End;
     //------------------------------------------------------------------------
     //Objetos do tipo palavra chave
     TPdfObjKeyword=Class(TObject)
                    Private
                       str_Valor:String;
                    Public
                       Constructor Create(Var stm_Dados:TStringStream;chr_Dado:AnsiChar);
                       Function ObtemValor:String;
                    End;
     //------------------------------------------------------------------------
     //Objetos do tipo nome
     TPdfObjNome=Class(TObject)
                 Private
                    str_Valor:String;
                 Public
                    Constructor Create(Var stm_Dados:TStringStream);
                    Function ObtemValor:String;
                 End;
     //------------------------------------------------------------------------
     //Objetos do tipo array
     TPdfObjArray=Class(TObject)
                  Private
                     lst_Valores:TList;
                     int_Tam:Integer;
                  Public
                     Constructor Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef);
                     Function ObtemValorItem(int_Indice:Integer):TPdfObjeto;
                     Property Tamanho:Integer Read int_Tam;
                  End;
     //------------------------------------------------------------------------
     //Objetos do tipo dicionário
     TPdfObjDicionario=Class(TObject)
                    Private
                       stl_Conteudo:TStringList;
                       int_Tam:Integer;
                    Public
                       Constructor Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef);
                       Function ObtemValorChave(str_Chave:String):TPdfObjeto;
                       Function ObtemValorItem(int_Indice:Integer):TPdfObjeto;
                       Function ObtemNomeChave(int_Indice:Integer):String;
                       Function ExisteChave(str_Chave:String):Boolean;
                       Property Tamanho:Integer Read int_Tam;
                    End;
     //------------------------------------------------------------------------
     //Objeto stream
     TPdfObjStream=Class(TObject)
                    Private
                       obj_Metadados:TPdfObjDicionario;
                       stm_Conteudo:TStringStream;
                       int_TamStream:Int64;
                    Public
                       Constructor Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef;obj_Metadados:TPdfObjDicionario);
                       Function ObtemValor:TStringStream;
                       Function ObtemValorMetadado(str_Chave:String):TPdfObjeto;
                       Property Tamanho:Int64 Read int_TamStream;
                    End;
     //------------------------------------------------------------------------
     //Objetos indiretos
     TPdfObjIndireto=Class(TObject)
                    Private
                       int_Id,
                       int_Gen:Integer;
                    Public
                       Constructor Create(int_Id,int_Gen:Integer);
                       Function ObtemId:Integer;
                       Function ObtemGen:Integer;
                       Function ObtemValorRef(Var obj_XRef:TXRef):TPdfObjeto;
                     End;

Implementation

Uses Math,
     System.SysUtils,

     Un_PdfUtils;

//-----------------------------------------------------------------------------
// TPdfObjeto
//-----------------------------------------------------------------------------
Constructor TPdfObjeto.Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef;int_IdObj,int_GemObj:Integer;bol_TestaNumero:Boolean);
Var bol_Terminou:Boolean;
    chr_Dado:AnsiChar;
    int_PosAnterior:Int64;
    obj_TestaNumero,
    obj_TestaR,
    obj_TestaObj,
    obj_TestaEnd:TPdfObjeto;
    int_Id,
    int_Gen:Integer;
Begin
 Inherited Create;

 Self.int_IdObj:=int_IdObj;

 Self.stm_Dados:=stm_Dados;
 Self.obj_XRef:=obj_XRef;

 bol_Terminou:=False;
 //Enquanto tem dados para ler ...
 While Not bol_Terminou Do
       Begin
        stm_Dados.ReadBuffer(chr_Dado,1);
        If _EhCaractereBranco(chr_Dado) Then
           Begin
            While _EhCaractereBranco(chr_Dado) Do
                  stm_Dados.ReadBuffer(chr_Dado,1);
           End;
        If chr_Dado='<' Then
           Begin
            //Lê de novo...
            stm_Dados.ReadBuffer(chr_Dado,1);
            //Achou outro "<"?
            If chr_Dado='<' Then
               Begin
                //Sim, então é dicionário
                Self.obj_Tipo:=obj_dicionario;
                Self.obj_Conteudo:=TPdfObjDicionario.Create(Self.stm_Dados,Self.obj_XRef);
                bol_Terminou:=True;
               End
            Else
               Begin
                //Não, então é um texto hexadecimal
                Self.obj_Tipo:=obj_string;
                stm_Dados.Position:=stm_Dados.Position-1;
                Self.obj_Conteudo:=TPdfObjString.Create(Self.stm_Dados,True);
                bol_Terminou:=True;
               End
           End
        Else If chr_Dado='(' Then
           Begin
            //É um texto literal
            Self.obj_Tipo:=obj_string;
            Self.obj_Conteudo:=TPdfObjString.Create(Self.stm_Dados,False);
            bol_Terminou:=True;
           End
        Else If chr_Dado='[' Then
           Begin
            //É um array
            Self.obj_Tipo:=obj_array;
            Self.obj_Conteudo:=TPdfObjArray.Create(Self.stm_Dados,Self.obj_XRef);
            bol_Terminou:=True;
           End
        Else If chr_Dado='/' Then
           Begin
            //É um nome
            Self.obj_Tipo:=obj_nome;
            Self.obj_Conteudo:=TPdfObjNome.Create(Self.stm_Dados);
            bol_Terminou:=True;
           End
        Else If chr_Dado='%' Then
           //É um comentário
           _BuscaLinha(stm_Dados)
        Else If (((chr_Dado>='0') And (chr_Dado<='9')) Or (chr_Dado='-') Or (chr_Dado='+') Or (chr_Dado='.')) Then
           Begin
            //É um número
            Self.obj_Tipo:=obj_numero;
            Self.obj_Conteudo:=TPdfObjNumerico.Create(Self.stm_Dados,chr_Dado);
            If Not bol_TestaNumero Then
               Begin
                //Pode ser o início de uma referência.
                int_PosAnterior:=stm_Dados.Position;
                //Busca o próximo objeto
		            obj_TestaNumero:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,True);
                //É objeto numérico?
                If (obj_TestaNumero<>Nil) And (obj_TestaNumero.Tipo=obj_numero) Then
                   Begin
                    //Sim, vamos buscar o próximo objeto
                    obj_TestaR:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,True);
                    //É objeto palavra chave e seu conteúdo é "R"
                    If (obj_TestaR<>Nil) And (obj_TestaR.Tipo=obj_keyword) And (obj_TestaR.ObtemValorString='R') Then
                       Begin
                        //Sim, então o objeto é indireto
                        Self.obj_Tipo:=obj_indireto;
                        //Obtém o conteúdo obtido
                        int_Id:=TPdfObjNumerico(Self.obj_Conteudo).ObtemValorInteiro;
                        int_Gen:=TPdfObjNumerico(obj_TestaNumero.obj_Conteudo).ObtemValorInteiro;
                        //Limpa o conteúdo atual (não é mais numérico)
                        Self.obj_Conteudo.Free;
                        Self.obj_Conteudo:=TPdfObjIndireto.Create(int_Id,int_Gen);
                        bol_Terminou:=True;
                       End
                    //É objeto palavra chave e seu conteúdo é "obj"
                    Else If (obj_TestaR<>Nil) And (obj_TestaR.Tipo=obj_keyword) And (obj_TestaR.ObtemValorString='obj') Then
                       Begin
                        //Sim, então é um "obj", mas vamos verifica o próximo objeto...
                        obj_TestaObj:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,True);
                        //... e o próximo...
                        obj_TestaEnd:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,True);
                        //É palavra chave?
                        If obj_TestaEnd.Tipo<>obj_keyword Then
                           //Não, tá errado, é esperado as palavras chaves "stream" ou "endobj".
                           Raise Exception.Create('Não foi encontrado "stream" ou "endobj"')
                        Else
                           Begin
                            //O primeiro objeto é dicionário e o segundo é a palavra chave "stream"?
                            If (obj_TestaObj.Tipo=obj_dicionario) And (obj_TestaEnd.ObtemValorString='stream') Then
                               Begin
                                //Sim, pula uma linha...
                                _BuscaLinha(stm_Dados);
                                //O objeto é stream
                                Self.obj_Tipo:=obj_stream;
                                //Carrega o conteúdo da stream
                                Self.obj_Conteudo:=TPdfObjStream.Create(Self.stm_Dados,Self.obj_XRef,TPdfObjDicionario(obj_TestaObj.Conteudo));
                                //Limpa a variável "obj_TestaEnd".
                                obj_TestaEnd.Free;
                                //Busca o próximo objeto.
                                obj_TestaEnd:=TPdfObjeto.Create(Self.stm_Dados,Self.obj_XRef,-1,-1,True);
                               End
                            Else
                               Begin
                                //Não, então é outro objeto, cujo conteúdo já foi lido na variável "obj_TestaObj".
                                Self.obj_Tipo:=obj_TestaObj.Tipo;
                                Self.obj_Conteudo:=obj_TestaObj.Conteudo;
                               End;
                            bol_Terminou:=True;
                           End;
                        If (obj_TestaEnd=Nil) Or (obj_TestaEnd.ObtemValorString<>'endobj') Then
                           Raise Exception.Create('O objeto deve terminar com "endobj"');
                       End
                    Else
                       Begin
                        stm_Dados.position:=int_PosAnterior;
                        bol_Terminou:=True;
                       End;
                   End
                Else
                   Begin
                    stm_Dados.Position:=int_PosAnterior;
                    bol_Terminou:=True;
                   End;
               End
            Else
               bol_Terminou:=True;
           End
        Else If ((chr_Dado>='a') And (chr_Dado<='z')) Or ((chr_Dado>='A') And (chr_Dado<='Z')) Then
           Begin
            Self.obj_Tipo:=obj_keyword;
            Self.obj_Conteudo:=TPdfObjKeyword.Create(stm_Dados,chr_Dado);
            bol_Terminou:=True;
           End
        Else
           Begin
            // it's probably a closing character.
            // throwback
            Self.obj_Tipo:=obj_nulo;
            Self.obj_Conteudo:=Nil;
            stm_Dados.Position:=stm_Dados.Position-1;
            bol_Terminou:=True;
           End
       End;
End;
//-----------------------------------------------------------------------------
Function TPdfObjeto.ObtemValorString:String;
Var str_Result:String;
    I:Integer;
Begin
 If Self.obj_Tipo=obj_boolean Then
    Begin
    End
 Else If Self.obj_Tipo=obj_numero Then
    Begin
     //Tem valores decimais?
     If TPdfObjNumerico(Self.obj_Conteudo).ObtemValorReal<>Int(TPdfObjNumerico(Self.obj_Conteudo).ObtemValorReal) Then
        Result:=FormatFloat('#.#',TPdfObjNumerico(Self.obj_Conteudo).ObtemValorInteiro)
     Else
        Result:=IntToStr(TPdfObjNumerico(Self.obj_Conteudo).ObtemValorInteiro);
    End
 Else If Self.obj_Tipo=obj_indireto Then
    Result:=IntToStr(TPdfObjIndireto(Self.Conteudo).int_Id)+' '+IntToStr(TPdfObjIndireto(Self.Conteudo).int_Gen)+' R'
 Else If Self.obj_Tipo=obj_string Then
    Result:=TPdfObjString(Self.Conteudo).str_Valor
 Else If Self.obj_Tipo=obj_nome Then
    Result:=TPdfObjString(Self.Conteudo).str_Valor
 Else If Self.obj_Tipo=obj_array Then
    Begin
     Result:='[ ';
     For I:=0 To TPdfObjArray(Self.Conteudo).int_Tam-1 Do
         Result:=Result+' '+TPdfObjArray(Self.Conteudo).ObtemValorItem(I).ObtemValorString;
     Result:=Result+' ]';
    End
 Else If Self.obj_Tipo=obj_dicionario Then
    Begin
     Result:='<< ';
     For I:=0 To TPdfObjDicionario(Self.Conteudo).int_Tam-1 Do
         Begin
          Result:=Result+' /'+TPdfObjDicionario(Self.Conteudo).ObtemNomeChave(I);
          Result:=Result+' '+TPdfObjDicionario(Self.Conteudo).ObtemValorItem(I).ObtemValorString;
         End;
     Result:=Result+' >>';
    End
 Else If Self.obj_Tipo=obj_stream Then
    Result:=TPdfObjStream(Self.Conteudo).stm_Conteudo.DataString
 Else If Self.obj_Tipo=obj_nulo Then
    Result:=''
 Else If Self.obj_Tipo=obj_keyword Then
    Result:=TPdfObjNome(Self.Conteudo).str_Valor
 Else If Self.obj_Tipo=obj_embedded Then
    Result:='';
End;
//-----------------------------------------------------------------------------
// TPdfObjNumerico
//-----------------------------------------------------------------------------
Constructor TPdfObjNumerico.Create(Var stm_Dados:TStringStream;chr_Dado:AnsiChar);
Var bol_Negativo,
    bol_TemPonto:Boolean;
    flt_MultiploDecimal:Extended;
    chr_Valor:Char;
Begin
 Inherited Create;

 //Verifica o primeiro caracter
 bol_Negativo:=chr_Dado='-';
 bol_TemPonto:=chr_Dado='.';

 flt_MultiploDecimal:=IfThen(bol_TemPonto,0.1,1);
 Self.flt_Valor:=IfThen((chr_Dado>='0') And (chr_Dado<='9'),Ord(chr_Dado)-Ord('0'),0);
 While True Do
       Begin
        stm_Dados.ReadBuffer(chr_Dado,1);
        If chr_Dado='.' Then
           Begin
            If bol_TemPonto Then
               Raise Exception.Create('Encontrado segundo "." no valor numérico');
            bol_TemPonto:=True;
            flt_MultiploDecimal:=0.1;
           End
        Else If (chr_Dado>='0') And (chr_Dado<='9') Then
           Begin
            chr_Valor:=Chr(Ord(chr_Dado)-Ord('0'));
            If bol_TemPonto Then
               Begin
                Self.flt_Valor:=flt_Valor+Ord(chr_Valor)*flt_MultiploDecimal;
                flt_MultiploDecimal:=flt_MultiploDecimal*0.1;
               End
            Else
               flt_Valor:=Self.flt_Valor*10+Ord(chr_Valor);
           End
        Else
           Begin
            stm_Dados.position:=stm_Dados.position-1;
            Break;
           End;
       End;
 If bol_Negativo Then
    Self.flt_Valor:=-Self.flt_Valor;
End;
//-----------------------------------------------------------------------------
Function TPdfObjNumerico.ObtemValorReal:Extended;
Begin
 Try
    Result:=flt_Valor;
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
Function TPdfObjNumerico.ObtemValorInteiro:Int64;
Begin
 Try
    Result:=Trunc(flt_Valor);
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
// TPdfObjString
//-----------------------------------------------------------------------------
Constructor TPdfObjString.Create(Var stm_Dados:TStringStream;bol_Hex:Boolean);
Var int_ValHex:Integer;
    int_ContPar,
    int_ContDigOctal:Byte;
    chr_Dado,
    chr_DigOctal:AnsiChar;
    bol_Valido:Boolean;
Begin
 Inherited Create;
 //É string hexadecimal?
 If bol_Hex Then
    Begin
     Repeat
           //Sim, lê os caracteres hexadecimais
           int_ValHex:=_LeParHexa(stm_Dados);
           If int_ValHex>=0 Then
              //Monta a string
              Self.str_Valor:=Self.str_Valor+Chr(int_ValHex);
     Until int_ValHex<0;
     stm_Dados.ReadBuffer(chr_Dado,1);
    End
 Else
    Begin
     //Como a estrutura string começa com "(", então já existe um parêntese.
     int_ContPar:=1;
     While int_ContPar>0 Do
           Begin
            //A princípio os caracteres lidos são válidos
            bol_Valido:=True;
            //Lê caractere
            stm_Dados.ReadBuffer(chr_Dado,1);
            //É abre parêntese?
            If chr_Dado='(' Then
               //Sim, incrementa contador
               Inc(int_ContPar)
            //É fecha parêntese?
            Else If chr_Dado=')' Then
               Begin
                //Sim, decrementa contador
                Dec(int_ContPar);
                //Já fechou todos os parênteses?
                If int_ContPar=0 Then
                  Begin
                   //Sim, então tem algo errado
                   bol_Valido:=False;
                   Break;
                  End
               End
            //Quando encontra o caractere "\" tem que tratar de modo especial
            Else If chr_Dado='\' Then
               Begin
                //Obtém o próximo caractere...
                stm_Dados.ReadBuffer(chr_Dado,1);
                //É algum algarismo?
                If (chr_Dado>='0') And (chr_Dado<='9') Then
                   Begin
                    //Sim então deve ser um caractere no formato \ddd com 3 dígitos octais
                    int_ContDigOctal:=0;
                    chr_DigOctal:=#0;
                    While (chr_Dado>='0') And (chr_Dado<='8') And (int_ContDigOctal<3) Do
                          Begin
                           chr_DigOctal:=AnsiChar(Chr(Ord(chr_DigOctal)*8+Ord(chr_Dado)-Ord('0')));
                           stm_Dados.ReadBuffer(chr_Dado,1);
                           Inc(int_ContDigOctal);
                          End;
                    stm_Dados.Position:=stm_Dados.Position-1;
                    //Obtém o caractere correspondente ao valor octal
                    chr_Dado:=chr_DigOctal;
                   End
                //É \r?
                Else If chr_Dado='r' Then
                   //Insere o caractere line feed
                   chr_Dado:=LF
                //É \n?
                Else If chr_Dado='n' Then
                   //Insere o caractere line feed também
                   chr_Dado:=LF
                //É \t
                Else If chr_Dado='t' Then
                   //Insere tabulação horizontal
                   chr_Dado:=HT
                //É \b?
                Else If chr_Dado='b' Then
                   //Insere backspace
                   chr_Dado:=BS
                Else If chr_Dado='f' Then
                   chr_Dado:=FF
                Else If chr_Dado='\r' Then
                   Begin
                    stm_Dados.ReadBuffer(chr_Dado,1);
                    If chr_Dado<>LF Then
                       stm_Dados.Position:=stm_Dados.Position-1;
                    bol_Valido:=False;
                   End
                Else If chr_Dado='\n' Then
                   bol_Valido:=False;
               End;
            If bol_Valido Then
               Self.str_Valor:=Self.str_Valor+chr_Dado;
           End;
    End;
End;
//-----------------------------------------------------------------------------
Function TPdfObjString.ObtemValor:String;
Begin
 Result:=Self.str_Valor
End;
//-----------------------------------------------------------------------------
// TPdfObjKeyword
//-----------------------------------------------------------------------------
Constructor TPdfObjKeyword.Create(Var stm_Dados:TStringStream;chr_Dado:AnsiChar);
Begin
 Inherited Create;

 stm_Dados:=stm_Dados;
 Self.str_Valor:='';
 While _EhCaractereRegular(chr_Dado) Do
       Begin
        Self.str_Valor:= Self.str_Valor+chr_Dado;
        stm_Dados.ReadBuffer(chr_Dado,1);
       End;
 stm_Dados.Position:=stm_Dados.Position-1;
End;
//-----------------------------------------------------------------------------
Function TPdfObjKeyword.ObtemValor:String;
Begin
 Try
    Result:=str_Valor;
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
// TPdfObjNome
//-----------------------------------------------------------------------------
Constructor TPdfObjNome.Create(Var stm_Dados:TStringStream);
Var chr_Dado:AnsiChar;
    int_ValHex:Integer;
Begin
 Inherited Create;

 //Lê o primeiro caractere
 stm_Dados.ReadBuffer(chr_Dado,1);
 While _EhCaractereRegular(chr_Dado) Do
       Begin
        If (chr_Dado<'!') And (chr_Dado>'~') Then
           Break;
        //A versão 1.1 do de Pdf não permite caracteres hexadecimais nos objetos nome
        //If (chr_Dado='#') And (int_VersaoMaior<>1) And (int_VersaoMenor<>1) Then
        //   Begin
        //    int_ValHex:=_LeParHexa(stm_Dados);
        //    If (int_ValHex>=0) Then
        //       chr_Dado:=AnsiChar(Chr(int_ValHex))
        //    Else
        //       _ExibeErro('Valor inválido no objeto nome.');
        //   End;
        Self.str_Valor:=Self.str_Valor+chr_Dado;
        stm_Dados.ReadBuffer(chr_Dado,1);
       End;
 stm_Dados.Position:=stm_Dados.Position-1;
End;
//-----------------------------------------------------------------------------
Function TPdfObjNome.ObtemValor:String;
Begin
 Try
    Result:=str_Valor;
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
// TPdfObjArray
//-----------------------------------------------------------------------------
Constructor TPdfObjArray.Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef);
Var str_ValorItem:String;
    I:Byte;
    obj_Item:TPdfObjeto;
    chr_Dado:AnsiChar;
Begin
 Inherited Create;

 int_Tam:=0;
 Self.lst_Valores:=TList.Create;

 Repeat
       obj_Item:=TPdfObjeto.Create(stm_Dados,obj_XRef,-1,-1,False);
       If obj_Item.Tipo<>obj_nulo Then
          Self.lst_Valores.Add(obj_Item);
 Until obj_Item.Tipo=obj_nulo;
 stm_Dados.ReadBuffer(chr_Dado,1);
 If chr_Dado<>']' Then
    Raise Exception.Create('Não foi encontrado "]" no final do objeto array.');
 Self.int_Tam:=Self.lst_Valores.Count;
End;
//-----------------------------------------------------------------------------
Function TPdfObjArray.ObtemValorItem(int_Indice:Integer):TPdfObjeto;
Begin
 Try
    If int_Indice<lst_Valores.Count then
       Result:=TPdfObjeto(lst_Valores[int_Indice])
    Else
       Result:=Nil;
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
// TPdfObjDicionario
//-----------------------------------------------------------------------------
Constructor TPdfObjDicionario.Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef);
Var obj_NomeItem,
    obj_ValorItem:TPdfObjeto;
    bol_Termina:Boolean;
Begin
 Inherited Create;

 Self.stl_Conteudo:=TStringList.Create;
 Self.int_Tam:=0;

 bol_Termina:=False;

 Repeat
       obj_NomeItem:=TPdfObjeto.Create(stm_Dados,obj_XRef,-1,-1,False);
       If obj_NomeItem.Tipo<>obj_nulo Then
          Begin
           If obj_NomeItem.Tipo<>obj_nome Then
              Raise Exception.Create('O primeiro item no dicionário deve ser um nome.');
           obj_ValorItem:=TPdfObjeto.Create(stm_Dados,obj_XRef,-1,-1,False);
           If (obj_ValorItem<>Nil) And (obj_NomeItem<>Nil) Then
              Self.stl_Conteudo.AddObject(TPdfObjNome(obj_NomeItem.Conteudo).ObtemValor,obj_ValorItem);
          End;
 Until obj_NomeItem.Tipo=obj_nulo;

 Self.int_Tam:=Self.stl_Conteudo.Count;

 If Not _ProximoItem(stm_Dados,'>>') Then
    Raise Exception.Create('Não foi encontrado ">>" no final do dicionário');

End;
//-----------------------------------------------------------------------------
Function TPdfObjDicionario.ObtemValorChave(str_Chave:String):TPdfObjeto;
Var I:Word;
    bol_Achou:Boolean;
Begin
 Try
     Result:=Nil;
     If stl_Conteudo.IndexOf(str_Chave)>=0 Then
        Result:=TPdfObjeto(stl_Conteudo.Objects[stl_Conteudo.IndexOf(str_Chave)])
     Else
        Result:=Nil;
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
Function TPdfObjDicionario.ObtemValorItem(int_Indice:Integer):TPdfObjeto;
Var I:Word;
    bol_Achou:Boolean;
Begin
 Try
    Result:=Nil;
    If int_Indice<=stl_Conteudo.Count Then
       Result:=TPdfObjeto(stl_Conteudo.Objects[int_Indice]);
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
Function TPdfObjDicionario.ObtemNomeChave(int_Indice:Integer):String;
Var I:Word;
    bol_Achou:Boolean;
Begin
 Try
    Result:='';
    If int_Indice<=stl_Conteudo.Count Then
       Result:=stl_Conteudo[int_Indice];
 Except
    On err_PdfObjeto:Exception Do
       Raise Exception.Create('Erro ao obter dado do objeto objeto '+Self.ClassName+': '+err_PdfObjeto.Message);
 End;
End;
//-----------------------------------------------------------------------------
Function TPdfObjDicionario.ExisteChave(str_Chave:String):Boolean;
Begin
 Result:=stl_Conteudo.IndexOf(str_Chave)>=0;
End;
//-----------------------------------------------------------------------------
// TPdfObjStream
//-----------------------------------------------------------------------------
Constructor TPdfObjStream.Create(Var stm_Dados:TStringStream;Var obj_XRef:TXRef;obj_Metadados:TPdfObjDicionario);
Var obj_TamStream:TPdfObjeto;
    int_TamStream:Int64;
    int_Id:Integer;
Begin
 Inherited Create;

 Self.stm_Conteudo:=TStringStream.Create;
 Self.obj_Metadados:=obj_Metadados;
 obj_TamStream:=Self.obj_Metadados.ObtemValorChave('Length');
 If obj_TamStream.Tipo=obj_indireto Then
    obj_TamStream:=TPdfObjIndireto(obj_TamStream.Conteudo).ObtemValorRef(obj_XRef);
 If obj_TamStream.Tipo=obj_numero Then
    Begin
     int_TamStream:=TPdfObjNumerico(obj_TamStream.Conteudo).ObtemValorInteiro;
     If int_TamStream>0 Then
        Begin
         Self.stm_Conteudo.CopyFrom(stm_Dados,int_TamStream);
         If Not _ProximoItem(stm_Dados,'endstream') Then
            Raise Exception.Create('Final inesperado do stream.')
         Else
            _BuscaLinha(stm_Dados);
        End;
    End
 Else
    Raise Exception.Create('Não foi possível obter o tamanho do stream');
End;
//-----------------------------------------------------------------------------
Function TPdfObjStream.ObtemValor:TStringStream;
Begin
 //Result:=TStringStream.Create;
 Result:=Self.stm_Conteudo;
End;
//-----------------------------------------------------------------------------
Function TPdfObjStream.ObtemValorMetadado(str_Chave:String):TPdfObjeto;
Begin
 If Self.obj_Metadados<>Nil Then
    Begin
     If Self.obj_Metadados.ExisteChave(str_Chave) Then
        Result:=Self.obj_Metadados.ObtemValorChave(str_Chave)
     Else
        Result:=Nil
    End
 Else
    Result:=Nil;
End;
//-----------------------------------------------------------------------------
// TPdfObjIndireto
//-----------------------------------------------------------------------------
Constructor TPdfObjIndireto.Create(int_Id,int_Gen:Integer);
Begin
 Inherited Create;

 Self.int_Id:=int_Id;
 Self.int_Gen:=int_Gen;
End;
//-----------------------------------------------------------------------------
Function TPdfObjIndireto.ObtemGen:Integer;
begin
 Result:=Self.int_Gen;
End;
//-----------------------------------------------------------------------------
Function TPdfObjIndireto.ObtemId: Integer;
Begin
 Result:=Self.int_Id;
End;
//-----------------------------------------------------------------------------
Function TPdfObjIndireto.ObtemValorRef(Var obj_XRef:TXRef):TPdfObjeto;
Begin
 Result:=TPdfObjeto(obj_XRef.BuscaObjetoPorId(Self.int_Id));
End;

End.
