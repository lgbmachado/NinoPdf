Unit Un_PdfRenderiza;

Interface

Uses Classes,
     System.Types,

     FMX.Objects,

     Un_PdfObjetos,
     Un_PdfXRef,
     Un_PdfGrafico,
     Un_PdfTexto;

Const NUL_CHAR=#0;
      FF_CHAR=#12;

     //------------------------------------------------------------------------
Type TPdfTipoComando=(com_array,com_numero,com_string,com_colchete,com_nome,com_comando,com_dicionario,com_fim);
     //------------------------------------------------------------------------
     TPdfCategoriaComando=(cat_grafico,cat_texto,cat_cont_marc,cat_compat);
     //------------------------------------------------------------------------
     TPdfComando=Class(TObject)
                 Private
                    obj_TipoComando:TPdfTipoComando;
                    obj_CategComando:TPdfCategoriaComando;
                    str_Comando:String;
                 Public
                    Constructor Create(Var stm_Conteudo:TStringStream);
                    Property Comando:String Read str_Comando;
                    Property Tipo:TPdfTipoComando Read obj_TipoComando;
                    Property Categoria:TPdfCategoriaComando Read obj_CategComando;
                 End;
     //------------------------------------------------------------------------
     TParam=Class(TObject)
            Private
               lst_Dados:TList;
               int_Tamanho:Integer;
            Public
               Constructor Create;
               Procedure Insere(obj_Dado:TPdfComando);
               Function TipoParam:TPdfTipoComando;
               Function BuscaReal:Extended;
               Function BuscaInteiro:Integer;
               Function BuscaString:String;
               Function BuscaArrayReal:TList;
               Function BuscaArrayString:TStringList;
               Procedure LimpaParam;
               Property Tamanho:Integer Read int_Tamanho;
            End;
     //------------------------------------------------------------------------
     TPdfRenderiza=Class(TObject)
                    Private
                       stl_Comandos:TStringList;
                       obj_Param:TParam;

                       obj_Grafico:TPdfGrafico;
                       obj_Texto:TPdfTexto;

                       Procedure Comando_W(str_Comando:String);
                       Procedure Comando_J(str_Comando:String);
                       Procedure Comando_M(str_Comando:String);
                       Procedure Comando_D(str_Comando:String);
                       Procedure Comando_RI;
                       Procedure Comando_I;
                       Procedure Comando_GS;
                       Procedure Comando_Q(str_Comando:String);
                       Procedure Comando_CM;
                       Procedure Comando_L;
                       Procedure Comando_C;
                       Procedure Comando_V;
                       Procedure Comando_Y;
                       Procedure Comando_H;
                       Procedure Comando_RE;
                       Procedure Comando_S(str_Comando:String);
                       Procedure Comando_F(str_Comando:String);
                       Procedure Comando_B(str_Comando:String);
                       Procedure Comando_N;
                       Procedure Comando_CS(str_Comando:String);
                       Procedure Comando_SC(str_Comando:String);
                       Procedure Comando_SCN(str_Comando:String);
                       Procedure Comando_G(str_Comando:String);
                       Procedure Comando_RG(str_Comando:String);
                       Procedure Comando_K(str_Comando:String);
                       Procedure Comando_SH;
                       Procedure Comando_BI;
                       Procedure Comando_ID;
                       Procedure Comando_EI;
                       Procedure Comando_DO;

                       Procedure Comando_BT;
                       Procedure Comando_ET;
                       Procedure Comando_TC;
                       Procedure Comando_TW;
                       Procedure Comando_TZ;
                       Procedure Comando_TL;
                       Procedure Comando_TF;
                       Procedure Comando_TR;
                       Procedure Comando_TS;
                       Procedure Comando_TD(str_Comando:String);
                       Procedure Comando_TM;
                       Procedure Comando_T;
                       Procedure Comando_TJ(str_Comando:String);
                       Procedure Comando_Aspas(str_Comando:String);
                       Procedure Comando_D0;
                       Procedure Comando_D1;

                       Procedure Comando_MP;
                       Procedure Comando_DP;
                       Procedure Comando_BMC;
                       Procedure Comando_BDC;
                       Procedure Comando_EMC;

                       Procedure Comando_BX;
                       Procedure Comando_EX;
                    Public
                       Constructor Create(Var obj_Grafico:TPdfGrafico;Var obj_Texto:TPdfTexto);
                       Procedure TrataConteudo(stm_Conteudo:TStringStream);
                    End;

Implementation

Uses System.SysUtils,
     System.Math,
     System.StrUtils,
     System.ZLib,
     System.UITypes,

     FMX.Types,

     Un_PdfUtils;

//-----------------------------------------------------------------------------
// TPdfComando
//-----------------------------------------------------------------------------
Constructor TPdfComando.Create(Var stm_Conteudo:TStringStream);
Var chr_Dado:AnsiChar;
    int_ContPonto,
    int_ContSinal,
    int_ContPar:Byte;
Begin
 Inherited Create;

 Self.str_Comando:='';

 If stm_Conteudo.Size-stm_Conteudo.Position-2>0 Then
    Begin
     Repeat
           stm_Conteudo.Read(chr_Dado,1);
           If chr_Dado='%' Then
              Begin
               _BuscaLinha(stm_Conteudo);
               stm_Conteudo.Read(chr_Dado,1);
              End;
     Until ((Not _EhCaractereBranco(chr_Dado)) Or (stm_Conteudo.Size-stm_Conteudo.Position-2<=0));


     If (stm_Conteudo.Size-stm_Conteudo.Position-2>0) Or (chr_Dado In ['[','(','{','<','/','.','-','a'..'z','A'..'Z','0'..'9']) Then
        Begin
         If chr_Dado='[' Then
            Begin
             Self.obj_TipoComando:=com_array;

             int_ContPar:=0;
             Repeat
                   If chr_Dado='[' Then
                      Inc(int_ContPar);
                   If chr_Dado=']' Then
                      Dec(int_ContPar);
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until int_ContPar=0;
             stm_Conteudo.Position:=stm_Conteudo.Position-1;
            End
         Else If chr_Dado='(' Then
            Begin
             Self.obj_TipoComando:=com_string;

             int_ContPar:=0;
             Repeat
                   If chr_Dado='(' Then
                      Inc(int_ContPar);
                   If chr_Dado=')' Then
                      Dec(int_ContPar);
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until int_ContPar=0;
             stm_Conteudo.Position:=stm_Conteudo.Position-1;
            End
         Else If chr_Dado='{' then
            Begin
             Self.obj_TipoComando:=com_colchete;

             int_ContPar:=0;
             Repeat
                   If chr_Dado='}' Then
                      Inc(int_ContPar);
                   If chr_Dado='{' Then
                      Dec(int_ContPar);
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until int_ContPar=0;
             stm_Conteudo.Position:=stm_Conteudo.Position-1;
            End
         Else If chr_Dado='<' then
            Begin
             int_ContPar:=0;
             Repeat
                   If chr_Dado='>' Then
                      Inc(int_ContPar);
                   If chr_Dado='<' Then
                      Dec(int_ContPar);
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until int_ContPar=0;
             If Pos('<<',Self.str_Comando)>0 Then
                Self.obj_TipoComando:=com_dicionario
             Else
                Self.obj_TipoComando:=com_array;
             stm_Conteudo.Position:=stm_Conteudo.Position-1;
            End
         Else If chr_Dado='/' then
            Begin
             Self.obj_TipoComando:=com_nome;

             Repeat
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until ((chr_Dado<='a') Or (chr_Dado>'z')) And ((chr_Dado<'A') Or (chr_Dado>'Z')) And ((chr_Dado<'0') Or (chr_Dado>'9'));
             stm_Conteudo.Position:=stm_Conteudo.Position-1;
            End
         Else If (chr_Dado='.') Or (chr_Dado='-') Or ((chr_Dado>='0') And (chr_Dado<='9')) Then
            Begin
             Self.obj_TipoComando:=com_numero;

             int_ContPonto:=0;
             int_ContSinal:=0;
             Repeat
                   If chr_Dado='.' Then
                      Inc(int_ContPonto);
                   If chr_Dado='-' Then
                      Inc(int_ContSinal);
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until (chr_Dado<>'.') And (chr_Dado<>'-') And ((chr_Dado<'0') Or (chr_Dado>'9'));
             stm_Conteudo.Position:=stm_Conteudo.Position-1;

             If (int_ContPonto>1) Or (int_ContSinal>1) Then
                Raise Exception.Create('Valor inválido:"'+Self.str_Comando+'".')
            End
         Else If ((chr_Dado>='a') And (chr_Dado<='z'))  Or ((chr_Dado>='A') And (chr_Dado<='Z')) Or (chr_Dado='\') Or (chr_Dado>='"') Then
            Begin
             Self.obj_TipoComando:=com_comando;

             Repeat
                   Self.str_Comando:=Self.str_Comando+chr_Dado;
                   stm_Conteudo.Read(chr_Dado,1);
                   If chr_Dado='%' Then
                      Begin
                       _BuscaLinha(stm_Conteudo);
                       stm_Conteudo.Read(chr_Dado,1);
                      End;
             Until ((chr_Dado<='a') Or (chr_Dado>'z')) And ((chr_Dado<'A') Or (chr_Dado>'Z')) And (chr_Dado<>'\') And (chr_Dado<>'"') And (chr_Dado<>'*');
             stm_Conteudo.Position:=stm_Conteudo.Position-1;
            End;
        End
     Else
        Self.obj_TipoComando:=com_fim;
    End
 Else
    Self.obj_TipoComando:=com_fim;

 //É comando?
 If Self.obj_TipoComando=com_comando Then
    //Sim, vmos definir a categoria dele...
    Begin
     //É comando para manipulação de gráficos?
     If (Self.str_Comando='w') Or (Self.str_Comando='J') Or (Self.str_Comando='j') Or (Self.str_Comando='M') Or (Self.str_Comando='d') Or (Self.str_Comando='ri') Or
        (Self.str_Comando='i') Or (Self.str_Comando='gs') Or (Self.str_Comando='q') Or (Self.str_Comando='Q') Or (Self.str_Comando='cm') Or (Self.str_Comando='m') Or
        (Self.str_Comando='l') Or (Self.str_Comando='c') Or (Self.str_Comando='v') Or (Self.str_Comando='y') Or (Self.str_Comando='h') Or (Self.str_Comando='re') Or
        (Self.str_Comando='S') Or (Self.str_Comando='s') Or (Self.str_Comando='f') Or (Self.str_Comando='F') Or (Self.str_Comando='f*') Or (Self.str_Comando='B') Or
        (Self.str_Comando='B*') Or (Self.str_Comando='b') Or (Self.str_Comando='b*') Or (Self.str_Comando='n') Or (Self.str_Comando='W') Or (Self.str_Comando='W*') Or
        (Self.str_Comando='CS') Or (Self.str_Comando='cs') Or (Self.str_Comando='SC') Or (Self.str_Comando='SCN') Or (Self.str_Comando='sc') Or (Self.str_Comando='scn') Or
        (Self.str_Comando='G') Or (Self.str_Comando='g') Or (Self.str_Comando='RG') Or (Self.str_Comando='rg') Or (Self.str_Comando='K') Or (Self.str_Comando='k') Or
        (Self.str_Comando='sh') Or (Self.str_Comando='BI') Or (Self.str_Comando='ID') Or (Self.str_Comando='EI') Or (Self.str_Comando='Do')Then
        Self.obj_CategComando:=cat_grafico
     //É comando para manipulação de textos?
     Else If (Self.str_Comando='BT') Or (Self.str_Comando='ET') Or (Self.str_Comando='Tc') Or (Self.str_Comando='Tw') Or (Self.str_Comando='Tz') Or (Self.str_comando='TL') Or
        (Self.str_Comando='Tf') Or (Self.str_Comando='Tr') Or (Self.str_Comando='Ts') Or (Self.str_Comando='Td') Or (Self.str_Comando='TD') Or (Self.str_Comando='Tm') Or
        (Self.str_Comando='T*') Or (Self.str_Comando='Tj') Or (Self.str_Comando='TJ') Or (Self.str_Comando='''') Or (Self.str_Comando='"') Or (Self.str_Comando='d0') Or
        (Self.str_Comando='d1') Then
        Self.obj_CategComando:=cat_texto
     //É comando para manipulação de conteúdo marcado?
     Else If (Self.str_Comando='MP') Or (Self.str_Comando='DP') Or (Self.str_Comando='BMC') Or (Self.str_Comando='BDC') Or (Self.str_Comando='EMC') Then
        Self.obj_CategComando:=cat_cont_marc
     //É comando para compatibilidade?
     Else If (Self.str_Comando='BX') Or (Self.str_Comando='EX') Then
        Self.obj_CategComando:=cat_compat
    End;
End;
//-----------------------------------------------------------------------------
// TParam
//-----------------------------------------------------------------------------
Constructor TParam.Create;
Begin
 Inherited Create;

 lst_Dados:=TList.Create;
End;
//-----------------------------------------------------------------------------
Procedure TParam.Insere(obj_Dado:TPdfComando);
Begin
 If obj_Dado<>Nil Then
    Begin
     Self.lst_Dados.Add(obj_Dado);
     Self.int_Tamanho:=Self.lst_Dados.Count;
    End;
End;
//-----------------------------------------------------------------------------
Function TParam.TipoParam:TPdfTipoComando;
Begin
 Result:=TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Tipo;
End;
//-----------------------------------------------------------------------------
Function TParam.BuscaReal:Extended;
Var obj_Formatos:TFormatSettings;
Begin
 If Self.lst_Dados.Count>0 Then
    Begin
     obj_Formatos:=TFormatSettings.Create;
     If TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Tipo=com_numero Then
        Result:=StrToFloat(StringReplace(TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando,'.',obj_Formatos.DecimalSeparator,[rfReplaceAll]))
     Else
        Raise Exception.Create('Valor inválido:"'+TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando+'".');
     Self.lst_Dados.Delete(Self.lst_Dados.Count-1);
     Self.int_Tamanho:=Self.lst_Dados.Count;
    End
 Else
    Raise Exception.Create('Pilha vazia.');
End;
//-----------------------------------------------------------------------------
Function TParam.BuscaInteiro:Integer;
Var obj_Formatos:TFormatSettings;
Begin
 If Self.lst_Dados.Count>0 Then
    Begin
     If TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Tipo=com_numero Then
        Begin
         If Pos('.',TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando)>0 Then
            Result:=Trunc(StrToFloatDef(StringReplace(TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando,'.',obj_Formatos.DecimalSeparator,[rfReplaceAll]),0))
         Else
            Result:=StrToIntDef(TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando,0);
        End
     Else
        Raise Exception.Create('Valor inválido:"'+TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando+'".');
     Self.lst_Dados.Delete(Self.lst_Dados.Count-1);
     Self.int_Tamanho:=Self.lst_Dados.Count;
    End
 Else
    Raise Exception.Create('Pilha vazia.');
End;
//-----------------------------------------------------------------------------
Function TParam.BuscaString:String;
Begin
 If Self.lst_Dados.Count>0 Then
    Begin
     Result:=TPdfComando(Self.lst_Dados[Self.lst_Dados.Count-1]).Comando;
     Self.lst_Dados.Delete(Self.lst_Dados.Count-1);
     Self.int_Tamanho:=Self.lst_Dados.Count;
    End
 Else
    Raise Exception.Create('Pilha vazia.');
End;
//-----------------------------------------------------------------------------
Function TParam.BuscaArrayReal:TList;
Var ptr_Valor:^Real;
    str_Conteudo:String;
    int_PosIni,
    int_PosFim:Integer;
    I:Byte;
    stl_Result:TStringList;
Begin
 Result:=TList.Create;
 str_Conteudo:=Trim(Self.BuscaString);
 If Length(str_Conteudo)>0 Then
    Begin
     int_PosIni:=Pos('[',str_Conteudo);
     int_PosFim:=Pos(']',str_Conteudo);
     If int_PosIni<int_PosFim Then
        Begin
         str_Conteudo:=Copy(str_Conteudo,1,int_PosFim-1);
         str_Conteudo:=Copy(str_Conteudo,int_PosIni+1,Length(str_Conteudo));
         str_Conteudo:=Trim(str_Conteudo);
         While Pos('  ',str_Conteudo)>0 Do
               str_Conteudo:=StringReplace(str_Conteudo,'  ',' ',[rfReplaceAll]);

         str_Conteudo:='"'+StringReplace(str_Conteudo,' ','","',[rfReplaceAll])+'"';
         stl_Result:=TStringList.Create;
         stl_Result.CommaText:=str_Conteudo;
         If stl_Result.Count>0 Then
            Begin
             For I:=0 To stl_Result.Count-1 Do
                 Begin
                  New(ptr_Valor);
                  ptr_Valor^:=StrToFloatDef(stl_Result[I],0);
                  Result.Add(ptr_Valor);
                 End;
            End;
        End;
    End;
End;
//-----------------------------------------------------------------------------
Function TParam.BuscaArrayString:TStringList;
Var ptr_Valor:^Real;
    str_Conteudo:String;
    int_PosIni,
    int_PosFim:Integer;
    I:Byte;
Begin
 Result:=TStringList.Create;
 str_Conteudo:=Trim(Self.BuscaString);
 If Length(str_Conteudo)>0 Then
    Begin
     int_PosIni:=Pos('(',str_Conteudo);
     int_PosFim:=Pos(')',str_Conteudo);
     If int_PosIni<int_PosFim Then
        Begin
         str_Conteudo:=Copy(str_Conteudo,1,int_PosFim-1);
         str_Conteudo:=Copy(str_Conteudo,int_PosIni+1,Length(str_Conteudo));
         str_Conteudo:=Trim(str_Conteudo);
         While Pos('  ',str_Conteudo)>0 Do
               str_Conteudo:=StringReplace(str_Conteudo,'  ',' ',[rfReplaceAll]);

         str_Conteudo:='"'+StringReplace(str_Conteudo,' ','","',[rfReplaceAll])+'"';
         Result.CommaText:=str_Conteudo;
        End;
    End;
End;
//------------------------------------------------------------------------
Procedure TParam.LimpaParam;
Begin
 Self.lst_Dados.Clear;
 Self.int_Tamanho:=Self.lst_Dados.Count;
End;
//-----------------------------------------------------------------------------
// TPdfRenderiza
//-----------------------------------------------------------------------------
Constructor TPdfRenderiza.Create(Var obj_Grafico:TPdfGrafico;Var obj_Texto:TPdfTexto);
Begin
 Inherited Create;

 Self.obj_Grafico:=obj_Grafico;
End;
//-----------------------------------------------------------------------------
//Comando para manipulação de gráficos.
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_W(str_Comando:String);
Var flt_Valor:Real;
Begin
 If str_Comando='w' Then
    Begin
     If Self.obj_Param.Tamanho>=1 then
        Self.obj_Grafico.DefineLarguraLinha(Self.obj_Param.BuscaReal);
    End
Else If str_Comando='W' Then
    Begin

    End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_J(str_Comando:String);
Begin
 If Self.obj_Param.Tamanho>=1 Then
    Begin
     If str_Comando='J' Then
        Self.obj_Grafico.DefineBordaLinha(Self.obj_Param.BuscaInteiro)
     Else If str_Comando='j' Then
        Self.obj_Grafico.DefineJuncaoLinha(Self.obj_Param.BuscaInteiro);

     End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_M(str_Comando:String);
Var flt_X,
    flt_Y:Real;
Begin
 //Inicia um novo caminho
 If str_Comando='m' Then
    Begin
     If Self.obj_Param.Tamanho>=2 then
        Begin
         flt_Y:=Self.obj_Param.BuscaReal;
         flt_X:=Self.obj_Param.BuscaReal;

         Self.obj_Grafico.NovoCaminho(flt_X,flt_Y);
        End;
    End;

 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_D;
Var int_Inicio:Integer;
    lst_Array:TList;
    arr_Traco:Array Of Single;
    I:Byte;
Begin
If Self.obj_Param.Tamanho>=2 Then
   Begin
    int_Inicio:=Self.obj_Param.BuscaInteiro;
    lst_Array:=Self.obj_Param.BuscaArrayReal;
    SetLength(arr_Traco,lst_Array.Count);
    For I:=0 To lst_Array.Count-1 Do
        arr_Traco[I+1]:=Real(lst_Array[I]^);
    Self.obj_Grafico.DefineArrayTracejado(int_Inicio,arr_Traco);
   End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_RI;
Begin
 Self.obj_Grafico.PropositoRederizacao;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_I;
Begin
 Self.obj_Grafico.DefineMaximoNivelamento;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_GS;
Begin
 Self.obj_Grafico.DefineEstadoGrafico;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_Q(str_Comando:String);
Begin
 If str_Comando='Q' Then
     Self.obj_Grafico.RestauraEstadoGrafico
 Else If str_Comando='q' Then
     Self.obj_Grafico.SalvaEstadoGrafico;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_CM;
Var flt_A,
    flt_B,
    flt_C,
    flt_D,
    flt_E,
    flt_F:Double;
Begin
 If Self.obj_Param.Tamanho>=6 then
    Begin
     flt_F:=Self.obj_Param.BuscaReal;
     flt_E:=Self.obj_Param.BuscaReal;
     flt_D:=Self.obj_Param.BuscaReal;
     flt_C:=Self.obj_Param.BuscaReal;
     flt_B:=Self.obj_Param.BuscaReal;
     flt_A:=Self.obj_Param.BuscaReal;
     Self.obj_Grafico.ConcatMatriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F);
    End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_L;
Var flt_X,
    flt_Y:Double;
Begin
 If Self.obj_Param.Tamanho>=2 then
    Begin
     flt_Y:=Self.obj_Param.BuscaReal;
     flt_X:=Self.obj_Param.BuscaReal;

     Self.obj_Grafico.Linha(flt_X,flt_Y);
    End;

 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_C;
Var flt_X1,
    flt_Y1,
    flt_X2,
    flt_Y2,
    flt_X3,
    flt_Y3:Double;
Begin
 If Self.obj_Param.Tamanho>=6 then
    Begin
     flt_X1:=Self.obj_Param.BuscaReal;
     flt_Y1:=Self.obj_Param.BuscaReal;
     flt_X2:=Self.obj_Param.BuscaReal;
     flt_Y2:=Self.obj_Param.BuscaReal;
     flt_X3:=Self.obj_Param.BuscaReal;
     flt_Y3:=Self.obj_Param.BuscaReal;
     Self.obj_Grafico.Curva(flt_X1,flt_Y1,flt_X2,flt_Y2,flt_X3,flt_Y3);
     Self.obj_Param.LimpaParam;
    End;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_V;
Begin
 Self.obj_Grafico.IncluiCurvaInicio;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_Y;
Begin
 Self.obj_Grafico.IncluiCurvaFinal;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_H;
Begin
 Self.obj_Grafico.FechaSubCaminho;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_RE;
Var flt_X,
    flt_Y,
    flt_Largura,
    flt_Altura:Double;
Begin
 If Self.obj_Param.Tamanho>=4 Then
    Begin
     flt_Altura:=Self.obj_Param.BuscaReal;
     flt_Largura:=Self.obj_Param.BuscaReal;

     flt_Y:=Self.obj_Param.BuscaReal;
     flt_X:=Self.obj_Param.BuscaReal;

     Self.obj_Grafico.Retangulo(flt_X,flt_Y,flt_Altura,flt_Largura);;
    End;

 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_S(str_Comando:String);
Begin
 If str_Comando='s' Then
    Self.obj_Grafico.FechaQuebraCaminho
 Else If str_Comando='S' Then
    Self.obj_Grafico.QuebraCaminho;

 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_F(str_Comando:String);
Begin
 If str_Comando='f' Then
    Self.obj_Grafico.Preenche
 Else If str_Comando='F' Then
    Self.obj_Grafico.Preenche
 Else If str_Comando='f*' Then
    Self.obj_Grafico.Preenche;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_B(str_Comando:String);
Begin
 If str_Comando='b' Then
    Begin
     Self.obj_Grafico.Preenche;
    End
 Else If str_Comando='B' Then
    Begin
     Self.obj_Grafico.Preenche;
    End
 Else If str_Comando='b*' Then
    Begin
     Self.obj_Grafico.Preenche;
    End
 Else If str_Comando='B*' Then
    Begin
     Self.obj_Grafico.Preenche;
    End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_N;
Begin
 Self.obj_Grafico.FechaCaminho;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_CS(str_Comando:String);
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_SC(str_Comando:String);
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_SCN(str_Comando:String);
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_G(str_Comando:String);
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_RG(str_Comando:String);
Var flt_R,
    flt_G,
    flt_B:Double;
Begin
 If Self.obj_Param.Tamanho>=3 Then
    Begin
     flt_B:=Self.obj_Param.BuscaReal;
     flt_G:=Self.obj_Param.BuscaReal;
     flt_R:=Self.obj_Param.BuscaReal;
     If str_Comando='RG' Then
        Self.obj_Grafico.DefineCorLinhaRGB(flt_R,flt_G,flt_B)
     Else If str_Comando='rg' Then
        Self.obj_Grafico.DefineCorFundoRGB(flt_R,flt_G,flt_B);
    End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_K(str_Comando:String);
Var int_C,
    int_M,
    int_Y,
    int_K:Integer;
Begin
 If Self.obj_Param.Tamanho>=4 Then
    Begin
     int_K:=Self.obj_Param.BuscaInteiro;
     int_Y:=Self.obj_Param.BuscaInteiro;
     int_M:=Self.obj_Param.BuscaInteiro;
     int_C:=Self.obj_Param.BuscaInteiro;
     If str_Comando='K' Then
        Self.obj_Grafico.DefineCorLinhaCMYK(int_C,int_M,int_Y,int_K)
     Else If str_Comando='k' Then
        Self.obj_Grafico.DefineCorFundoCMYK(int_C,int_M,int_Y,int_K);
     Self.obj_Param.LimpaParam;
    End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_SH;
Begin
 Self.obj_Grafico.Preenche;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_BI;
Begin
 Self.obj_Grafico.InicioObjetoInterno;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_ID;
Begin
 Self.obj_Grafico.InicioDadoInterno;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_EI;
Begin
 Self.obj_Grafico.FimImagemInterna;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_DO;
Begin
 Self.obj_Grafico.InvocaObjeto;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
//Comandos para manipulação de textos.
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_BT;
Begin
 Self.obj_Texto.InicioTexto;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_ET;
Begin
 Self.obj_Texto.FimTexto;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TC;
Begin
 Self.obj_Texto.EspacoCarac;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TW;
Begin
 Self.obj_Texto.EspacoPalavra;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TZ;
Begin
 Self.obj_Texto.EscalaHorizontal;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TL;
Begin
 Self.obj_Texto.EspacoEntreLinhas;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TF;
Begin
 Self.obj_Texto.DefineFonte;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TR;
Begin
 Self.obj_Texto.DefineTipoRederizacao;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TS;
Begin
 Self.obj_Texto.DefinePosVertical;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TD(str_Comando:String);
Begin
 Self.obj_Texto.MoveParaPosicao;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TM;
Var flt_A,
    flt_B,
    flt_C,
    flt_D,
    flt_E,
    flt_F:Double;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_T;
Begin
 Self.obj_Texto.ProximaLinha;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_TJ(str_Comando:String);
Var stl_Texto:TStringList;
    str_Texto:String;
    I:Integer;
    flt_Val:Real;
Begin
 If str_Comando='Tj' Then
    Begin
     str_Texto:=Self.obj_Param.BuscaString;
     Self.obj_Texto.ProcessaTexto(str_Texto);
    End
 Else If str_Comando='TJ' Then
    Begin
     stl_Texto:=Self.obj_Param.BuscaArrayString;
     Self.obj_Texto.ProcessaArrayTexto(stl_Texto);
     stl_Texto.Free;
    End;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_Aspas(str_Comando:String);
Begin
If str_Comando='''' Then
   Self.obj_Texto.ProcessaApostrofe
 Else If str_Comando='"' Then
   Self.obj_Texto.ProcessaAspas;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_D0;
Begin
 Self.obj_Texto.DefineFonteTipo3;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_D1;
Begin
 Self.obj_Texto.DefineFonteTipo3;
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
//Comandos para manipulação de conteúdo marcado.
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_MP;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_DP;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_BMC;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_BDC;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_EMC;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
//Comandos compatibilidade.
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_BX;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.Comando_EX;
Begin
 Self.obj_Param.LimpaParam;
End;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
Procedure TPdfRenderiza.TrataConteudo(stm_Conteudo:TStringStream);
Var obj_Comando:TPdfComando;
    chr_Dado:AnsiChar;
    int_ContPar:Byte;
    flt_X,
    flt_Y:Extended;

    stl_Comando:TStringList;
    str_Linha:String;
Begin
 Self.obj_Param:=TParam.Create;
 stm_Conteudo.Position:=0;

 stl_Comando:=TStringList.Create;
 str_Linha:='';
 Repeat
       obj_Comando:=TPdfComando.Create(stm_Conteudo);
       If obj_Comando.Tipo=com_comando Then
          Begin
           stl_Comando.Add(str_Linha+' '+obj_Comando.Comando);
           str_Linha:='';
           Case obj_Comando.Categoria Of
                cat_grafico:
                   Begin
                    //Comandos para manipulação de gráficos.
                    If (obj_Comando.Comando='w') Or (obj_Comando.Comando='W') Or (obj_Comando.Comando='W*')Then
                       Self.Comando_W(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='J') Or (obj_Comando.Comando='j') Then
                       Self.Comando_J(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='M') Or (obj_Comando.Comando='m') Then
                       Self.Comando_M(obj_Comando.Comando)
                    Else If obj_Comando.Comando='d' Then
                       Self.Comando_D(obj_Comando.Comando)
                    Else If obj_Comando.Comando='ri' Then
                       Self.Comando_RI
                    Else If obj_Comando.Comando='i' Then
                       Self.Comando_I
                    Else If obj_Comando.Comando='gs' Then
                       Self.Comando_GS
                    Else If (obj_Comando.Comando='q') Or (obj_Comando.Comando='Q') Then
                       Self.Comando_Q(obj_Comando.Comando)
                    Else if obj_Comando.Comando='cm' Then
                       Self.Comando_CM
                    Else If obj_Comando.Comando='l' Then
                       Self.Comando_L
                    Else If obj_Comando.Comando='c' Then
                       Self.Comando_C
                    Else If obj_Comando.Comando='v' Then
                       Self.Comando_V
                    Else If obj_Comando.Comando='y' Then
                       Self.Comando_Y
                    Else If obj_Comando.Comando='h' Then
                       Self.Comando_H
                    Else If obj_Comando.Comando='re' Then
                       Self.Comando_RE
                    Else If (obj_Comando.Comando='S') Or (obj_Comando.Comando='s') Then
                       Self.Comando_S(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='f') Or (obj_Comando.Comando='f*') Or (obj_Comando.Comando='F') Then
                       Self.Comando_F(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='b') Or (obj_Comando.Comando='B') Or (obj_Comando.Comando='b*') Then
                       Self.Comando_B(obj_Comando.Comando)
                    Else If obj_Comando.Comando='n' Then
                       Self.Comando_N
                    Else If (obj_Comando.Comando='CS') Or (obj_Comando.Comando='cs') Then
                       Self.Comando_CS(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='SC') Or (obj_Comando.Comando='sc') Then
                       Self.Comando_SC(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='SCN') Or (obj_Comando.Comando='scn') Then
                       Self.Comando_SCN(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='G') Or (obj_Comando.Comando='g') Then
                       Self.Comando_G(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='RG') Or (obj_Comando.Comando='rg') Then
                       Self.Comando_RG(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='K') Or (obj_Comando.Comando='k') Then
                       Self.Comando_K(obj_Comando.Comando)
                    Else If obj_Comando.Comando='sh' Then
                       Self.Comando_SH
                    Else If obj_Comando.Comando='BI' Then
                       Self.Comando_BI
                    Else If obj_Comando.Comando='ID' Then
                       Self.Comando_ID
                    Else If obj_Comando.Comando='EI' Then
                       Self.Comando_EI
                    Else If obj_Comando.Comando='Do' Then
                       Self.Comando_DO;
                   End;
                cat_texto:
                   Begin
                    //Comando para manipulação de textos.
                    If obj_Comando.Comando='BT' Then
                       Comando_BT
                    Else If obj_Comando.Comando='ET' Then
                       Comando_ET
                    Else If obj_Comando.Comando='Tc' Then
                       Comando_TC
                    Else If obj_Comando.Comando='Tw' Then
                       Comando_TW
                    Else If obj_Comando.Comando='Tz' Then
                       Comando_TZ
                    Else If obj_Comando.Comando='TL' Then
                       Comando_TL
                    Else If obj_Comando.Comando='Tf' Then
                       Comando_TF
                    Else If obj_Comando.Comando='Tr' Then
                       Comando_TR
                    Else If obj_Comando.Comando='Ts' Then
                        Comando_TS
                    Else If (obj_Comando.Comando='Td') Or (obj_Comando.Comando='TD') Then
                        Comando_TD(obj_Comando.Comando)
                    Else If obj_Comando.Comando='Tm' Then
                        Comando_TM
                    Else If obj_Comando.Comando='T*' Then
                        Comando_T
                    Else If (obj_Comando.Comando='Tj') Or (obj_Comando.Comando='TJ') Then
                        Comando_TJ(obj_Comando.Comando)
                    Else If (obj_Comando.Comando='''') Or (obj_Comando.Comando='"') Then
                        Comando_Aspas(obj_Comando.Comando)
                    Else If obj_Comando.Comando='d0' Then
                        Comando_D0
                    Else If obj_Comando.Comando='d1' Then
                        Comando_D1
                   End;
                cat_cont_marc:
                   Begin
                    //Comandos para manipulação de conteúdo marcado.
                    If obj_Comando.Comando='MP' Then
                       Comando_MP
                    Else If obj_Comando.Comando='DP' Then
                       Comando_DP
                    Else If obj_Comando.Comando='BMC' Then
                       Comando_BMC
                    Else If obj_Comando.Comando='BDC' Then
                       Comando_BDC
                    Else If obj_Comando.Comando='EMC' Then
                       Comando_EMC
                   End;
                cat_compat:
                   Begin
                    //Comandos compatibilidade.
                    If obj_Comando.Comando='BX'Then
                       Comando_BX
                    Else If obj_Comando.Comando='EX'Then
                       Comando_EX
                   End;
           End
          End
       Else If obj_Comando.Tipo<>com_fim Then
          Begin
           Self.obj_Param.Insere(obj_Comando);
           str_Linha:=str_Linha+' '+obj_Comando.Comando;
          End;
 Until obj_Comando.Tipo=com_fim;

 //Self.obj_Grafico.Desenha;

 stl_Comando.SaveToFile('c:\Temp\'+FormatDateTime('yyyymmddhhnn',Now)+'.txt');
End;

End.
