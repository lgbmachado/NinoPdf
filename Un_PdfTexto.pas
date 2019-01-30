Unit Un_PdfTexto;

Interface

Uses Classes,
     System.Types,

     FMX.Objects;

//-----------------------------------------------------------------------------
Type TPdfTexto=Class(TObject)
               Private
                  img_Pagina:TImage;

                  Function ConverteCoordenada_X(flt_X,flt_Y:Double):Double;
                  Function ConverteCoordenada_Y(flt_X,flt_Y:Double):Double;

               Public
                  Procedure InicioTexto;
                  Procedure FimTexto;
                  Procedure EspacoCarac;
                  Procedure EspacoPalavra;
                  Procedure EscalaHorizontal;
                  Procedure EspacoEntreLinhas;
                  Procedure DefineFonte;
                  Procedure DefineTipoRederizacao;
                  Procedure DefinePosVertical;
                  Procedure MoveParaPosicao;
                  Procedure Matriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F:Double);
                  Procedure ProximaLinha;
                  Procedure ProcessaTexto(str_Texto:String);
                  Procedure ProcessaArrayTexto(stl_Texto:TStringList);
                  Procedure ProcessaApostrofe;
                  Procedure ProcessaAspas;
                  Procedure DefineFonteTipo3;
                  Constructor Create(Var img_Pagina:TImage);
               End;
//-----------------------------------------------------------------------------

Implementation

Uses System.SysUtils,
     System.Math,
     System.StrUtils,
     System.UITypes,

     FMX.Types;

//-----------------------------------------------------------------------------
// TPdfTexto
//-----------------------------------------------------------------------------
Function TPdfTexto.ConverteCoordenada_X(flt_X,flt_Y:Double):Double;
Begin
 Result:=flt_X;
End;
//-----------------------------------------------------------------------------
Function TPdfTexto.ConverteCoordenada_Y(flt_X,flt_Y:Double):Double;
Begin
 Result:=Self.img_Pagina.Height-flt_y;
End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.InicioTexto;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.FimTexto;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.EspacoCarac;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.EspacoPalavra;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.EscalaHorizontal;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.EspacoEntreLinhas;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.DefineFonte;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.DefineTipoRederizacao;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.DefinePosVertical;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.MoveParaPosicao;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.Matriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F:Double);
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.ProximaLinha;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.ProcessaTexto(str_Texto:String);
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.ProcessaArrayTexto(stl_Texto:TStringList);
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.ProcessaApostrofe;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.ProcessaAspas;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfTexto.DefineFonteTipo3;
Begin

End;
//-----------------------------------------------------------------------------
Constructor TPdfTexto.Create(Var img_Pagina:TImage);
Var chr_Dado:AnsiChar;
    int_ContPonto,
    int_ContSinal,
    int_ContPar:Byte;
Begin
 Inherited Create;

 Self.img_Pagina:=img_Pagina;
End;
//-----------------------------------------------------------------------------

End.
