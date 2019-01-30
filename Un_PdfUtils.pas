Unit Un_PdfUtils;

Interface

Uses Classes,
     SysUtils,
     ZLib;

Const LF=#10;  // \n
      CR=#13;  // \r
      HT=#09;  // \t
      BS=#08;  // \b
      FF=#12;  // \f

Function _EhStringNumerica(str_Dado:AnsiString):Boolean;
Function _EhCaractereBranco(chr_Dado:AnsiChar):Boolean;
Function _EhCaractereDelimitador(chr_Dado:AnsiChar):Boolean;
Function _EhCaractereRegular(chr_Dado:AnsiChar):Boolean;
Function _BuscaLinha(Var stm_Conteudo:TStringStream):AnsiString;
Function _LeParHexa(Var stm_Dados:TStringStream):Integer;
Function _ProximoItem(Var stm_Dados:TStringStream;str_Busca:AnsiString):Boolean;
Function _DecodificaZLib(stm_Conteudo:TStringStream):TStringStream;

Implementation

//-----------------------------------------------------------------------------
Function _EhStringNumerica(str_Dado:AnsiString):Boolean;
Var I:Integer;
    int_ContPonto,
    int_ContSinal:Byte;
Begin
 If Length(str_Dado)>0 Then
    Begin
     Result:=True;
     I:=1;
     int_ContPonto:=0;
     int_ContSinal:=0;
     Repeat
           If str_Dado[I]='.'  Then
              Inc(int_ContPonto)
           Else If str_Dado[I]='-'  Then
              Inc(int_ContSinal);

           Result:=Result And (int_ContPonto<=1) And (int_ContSinal<=1) And (str_Dado[I] In ['.','-','0'..'9']);
           Inc(I);
     Until (Not Result) Or (I>Length(str_Dado))
    End
 Else
    Result:=False;
End;
//-----------------------------------------------------------------------------
Function _EhCaractereBranco(chr_Dado:AnsiChar):Boolean;
Begin
 Result:=(chr_Dado In [#0,HT,LF,FF,CR,#32]);
End;
//-----------------------------------------------------------------------------
Function _EhCaractereDelimitador(chr_Dado:AnsiChar):Boolean;
Begin
 Result:=(chr_Dado) In ['(',')','<','>','[',']','(',')','/','%'];
End;
//-----------------------------------------------------------------------------
Function _EhCaractereRegular(chr_Dado:AnsiChar):Boolean;
Begin
 Result:=(Not _EhCaractereDelimitador(chr_Dado)) And (Not _EhCaractereBranco(chr_Dado));
End;
//-----------------------------------------------------------------------------
Function _BuscaLinha(Var stm_Conteudo:TStringStream):AnsiString;
Var bol_Continua:Boolean;
    chr_Dado1,
    chr_Dado2:AnsiChar;
Begin
 Result:='';
 bol_Continua:=stm_Conteudo.Size-stm_Conteudo.Position-1>0;
 //Enquanto tem dados para ler...
 While bol_Continua Do
       Begin
        //... obtém o caractere.
        stm_Conteudo.Read(chr_Dado1,1);
        //É "carriage return"? (\r)
        If chr_Dado1=CR Then
           Begin
            //Sim, mas ainda tem dados para ler?
            bol_Continua:=stm_Conteudo.Size-stm_Conteudo.Position-1>0;
            If bol_Continua Then
               Begin
                //Sim, então pega!
                stm_Conteudo.Read(chr_Dado2,1);
                //É "new line"? (\n)

                If chr_Dado2<>LF Then
                   //Não, volta uma posição
                   stm_Conteudo.Position:=stm_Conteudo.Position-1;
               End;
            bol_Continua:=False;
           End
        //Não, mas é "new line"? (\n)
        Else If chr_Dado1=LF Then
           //Sim, então pára!
           bol_Continua:=False;
        //Monta a string da linha a ser lida.
        If bol_Continua Then
           Result:=Result+chr_Dado1;
       End;
End;
//-----------------------------------------------------------------------------
Function _LeParHexa(Var stm_Dados:TStringStream):Integer;
Var int_1oByte,
    int_2oByte:Integer;
//------------------------------------
  Function _LeDigitoHexa:Integer;
  Var chr_Dado:AnsiChar;
      str_ValHex:AnsiString;
  Begin
   //Lê o primeiro dígito hexadecimal
   stm_Dados.ReadBuffer(chr_Dado,1);
   While _EhCaractereBranco(chr_Dado) Do
         stm_Dados.ReadBuffer(chr_Dado,1);
   //O dígito é válido?
   If chr_Dado In ['0'..'9','A'..'F','a'..'f'] Then
      //Sim, inclui na string;
      Result:=StrToInt('$'+chr_Dado)
   Else
      Result:=-1;
  End;
//------------------------------------
Begin
 int_1oByte:=_LeDigitoHexa;
 If int_1oByte<0 Then
    Begin
     stm_Dados.Position:=stm_Dados.Position-1;
     Result:=-1;
    End
 Else
    Begin
     int_2oByte:=_LeDigitoHexa;
     If int_2oByte<0 Then
        Begin
         stm_Dados.Position:=stm_Dados.Position-1;
         Result:=int_1oByte Shl 4;
        End
     Else
        Result:=(int_1oByte Shl 4)+int_2oByte;
    End;
End;
//-----------------------------------------------------------------------------
Function _ProximoItem(Var stm_Dados:TStringStream;str_Busca:AnsiString):Boolean;
Var chr_Dado:AnsiChar;
    I:Integer;
Begin
 stm_Dados.ReadBuffer(chr_Dado,1);
 //Achou espaço em branco?
 If _EhCaractereBranco(chr_Dado) Then
    Begin
     //Sim, e continua lendo até não encontrar
     While _EhCaractereBranco(chr_Dado) Do
           stm_Dados.ReadBuffer(chr_Dado,1);
    End;
 //Volta uma posição
 stm_Dados.Position:=stm_Dados.Position-1;

 For I:=1 To Length(str_Busca) Do
     Begin
      If I>0 Then
         stm_Dados.ReadBuffer(chr_Dado,1);
      If chr_Dado<>str_Busca[I] Then
         Begin
          //stm_Pdf.Position:=int_PosAnt;
          Result:=False;
          Exit;
         End;
     End;
 Result:=True;
End;
//-----------------------------------------------------------------------------
Function _DecodificaZLib(stm_Conteudo:TStringStream):TStringStream;
Var stm_DadoFlatDecode:TDecompressionStream;
Begin
 Result:=TStringStream.Create;
 stm_Conteudo.Seek(0,soFromBeginning);
 stm_DadoFlatDecode:=TDecompressionStream.Create(stm_Conteudo);

 Result.LoadFromStream(stm_DadoFlatDecode);
End;

End.
