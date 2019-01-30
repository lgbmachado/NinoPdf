Unit Un_PdfGrafico;

Interface

Uses Classes,
     System.Types,
     System.UITypes,

     FMX.Objects,
     FMX.Types;

     //------------------------------------------------------------------------
Type TPdfGrafico=Class(TObject)
                 Private
                    img_Pagina:TImage;

                    //obj_EstadoCanvas:TCanvasSaveState;

                    //obj_Caminho:TPathData;

                    flt_Largura,
                    flt_Zoom,
                    flt_Inicio:Single;

                    int_TipoBorda,
                    int_TipoJuncao:Integer;

                    arr_Tracos:Array Of Single;

                    Function ObtemQtdComandosCaminho:Integer;
                    Function ConverteCoordenada_X(flt_X,flt_Y:Double):Double;
                    Function ConverteCoordenada_Y(flt_X,flt_Y:Double):Double;

                 Public
                    Procedure DefineLarguraLinha(flt_Largura:Double);
                    Procedure DefineBordaLinha(int_TipoBorda:Integer);
                    Procedure DefineJuncaoLinha(int_TipoJuncao:Integer);
                    Procedure NovoCaminho(flt_X,flt_Y:Double);
                    Procedure IncluiPontoCaminho(flt_X,flt_Y:Double);
                    Procedure DefineArrayTracejado(flt_Inicio:Single;arr_Tracos:Array Of Single);
                    Procedure PropositoRederizacao;
                    Procedure DefineMaximoNivelamento;
                    Procedure DefineEstadoGrafico;
                    Procedure RestauraEstadoGrafico;
                    Procedure SalvaEstadoGrafico;
                    Procedure Matriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F:Double);
                    Procedure ConcatMatriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F:Double);
                    Procedure Linha(flt_X,flt_Y:Double);
                    Procedure Curva(flt_X1,flt_Y1,flt_X2,flt_Y2,flt_X3,flt_Y3:Double);
                    Procedure IncluiCurvaInicio;
                    Procedure IncluiCurvaFinal;
                    Procedure FechaSubCaminho;
                    Procedure Retangulo(flt_X,flt_Y,flt_Altura,flt_Largura:Double);
                    Procedure FechaQuebraCaminho;
                    Procedure QuebraCaminho;
                    Procedure Preenche;
                    Procedure FechaCaminho;
                    Procedure DefineCorLinhaCMYK(int_C,int_M,int_Y,int_K:Integer);
                    Procedure DefineCorFundoCMYK(int_C,int_M,int_Y,int_K:Integer);
                    Procedure DefineCorLinhaRGB(flt_R,flt_G,flt_B:Double);
                    Procedure DefineCorFundoRGB(flt_R,flt_G,flt_B:Double);
                    Procedure InicioObjetoInterno;
                    Procedure InicioDadoInterno;
                    Procedure FimImagemInterna;
                    Procedure LimpaParam;
                    Procedure InvocaObjeto;

                    Constructor Create(Var img_Pagina:TImage;flt_Zoom:Double);
                    Procedure Desenha;
                    Property QtdComandosCaminho:Integer Read ObtemQtdComandosCaminho;
                 End;

Implementation

Uses System.SysUtils,
     System.Math,
     System.StrUtils;

//-----------------------------------------------------------------------------
// TPdfGrafico
//-----------------------------------------------------------------------------
Function TPdfGrafico.ObtemQtdComandosCaminho:Integer;
Begin
// Result:=Self.obj_Caminho.Count;
End;
//-----------------------------------------------------------------------------
Function TPdfGrafico.ConverteCoordenada_X(flt_X,flt_Y:Double):Double;
Begin
 flt_X:=Self.flt_Zoom*flt_X;
 flt_Y:=Self.flt_Zoom*flt_Y;

 Result:=Self.img_Pagina.Bitmap.Canvas.Matrix.m11*flt_X+Self.img_Pagina.Bitmap.Canvas.Matrix.m21*flt_y+Self.img_Pagina.Bitmap.Canvas.Matrix.m31;
End;
//-----------------------------------------------------------------------------
Function TPdfGrafico.ConverteCoordenada_Y(flt_X,flt_Y:Double):Double;
Begin
 flt_X:=Self.flt_Zoom*flt_X;
 flt_Y:=Self.flt_Zoom*flt_Y;

 Result:=Self.img_Pagina.Bitmap.Canvas.Matrix.m12*flt_X+Self.img_Pagina.Bitmap.Canvas.Matrix.m22*flt_y+Self.img_Pagina.Bitmap.Canvas.Matrix.m32;
 Result:=Self.img_Pagina.Height-Result;
End;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineLarguraLinha(flt_Largura:Double);
Begin
 Self.flt_Largura:=flt_Largura;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineBordaLinha(int_TipoBorda:Integer);
Begin
 Self.int_TipoBorda:=int_TipoBorda;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineJuncaoLinha(int_TipoJuncao:Integer);
Begin
 Self.int_TipoJuncao:=int_TipoJuncao;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.NovoCaminho(flt_X,flt_Y:Double);
Begin
// Self.obj_Caminho.MoveTo(TPointF.Create(ConverteCoordenada_X(flt_X,flt_Y),ConverteCoordenada_Y(flt_X,flt_Y)));
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.IncluiPontoCaminho(flt_X,flt_Y:Double);
Begin
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineArrayTracejado(flt_Inicio:Single;arr_Tracos:Array Of Single);
Var I:Integer;
Begin
 SetLength(Self.arr_Tracos,Length(arr_Tracos));
 For I:=1 To Length(arr_Tracos) Do
     Self.arr_Tracos[I]:=arr_Tracos[I];

 Self.flt_Inicio:=flt_Inicio;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.PropositoRederizacao;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineMaximoNivelamento;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineEstadoGrafico;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.RestauraEstadoGrafico;
//Var obj_Matriz:TMatrix;
Begin
 {obj_Matriz.m11:=1;   //A
 obj_Matriz.m12:=0;   //B
 obj_Matriz.m13:=0;

 obj_Matriz.m21:=0;   //C
 obj_Matriz.m22:=1;   //D
 obj_Matriz.m23:=0;

 obj_Matriz.m31:=0;   //E
 obj_Matriz.m32:=0;   //F
 obj_Matriz.m33:=1;

 Self.img_Pagina.Bitmap.Canvas.SetMatrix(obj_Matriz);}
// Self.img_Pagina.Bitmap.Canvas.RestoreState(obj_EstadoCanvas);
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.SalvaEstadoGrafico;
Begin
 //obj_EstadoCanvas:=Self.img_Pagina.Bitmap.Canvas.SaveState;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.Matriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F:Double);
//Var obj_Matriz:TMatrix;
Begin
{ obj_Matriz.m11:=flt_A;
 obj_Matriz.m12:=flt_B;
 obj_Matriz.m13:=0;

 obj_Matriz.m21:=flt_C;
 obj_Matriz.m22:=flt_D;
 obj_Matriz.m23:=0;

 obj_Matriz.m31:=flt_E;
 obj_Matriz.m32:=flt_F;
 obj_Matriz.m33:=1;

 Self.img_Pagina.Bitmap.Canvas.SetMatrix(obj_Matriz);}
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.ConcatMatriz(flt_A,flt_B,flt_C,flt_D,flt_E,flt_F:Double);
//Var obj_MatrizParam,
//    obj_MatrizResult:TMatrix;
Begin
{ obj_MatrizParam.m11:=flt_A;
 obj_MatrizParam.m12:=flt_B;
 obj_MatrizParam.m13:=0;

 obj_MatrizParam.m21:=flt_C;
 obj_MatrizParam.m22:=flt_D;
 obj_MatrizParam.m23:=0;

 obj_MatrizParam.m31:=flt_E;
 obj_MatrizParam.m32:=flt_F;
 obj_MatrizParam.m33:=1;

 obj_MatrizResult.m11:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m11*obj_MatrizParam.m11)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m12*obj_MatrizParam.m21)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m13*obj_MatrizParam.m31);
 obj_MatrizResult.m12:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m11*obj_MatrizParam.m12)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m12*obj_MatrizParam.m22)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m13*obj_MatrizParam.m32);
 obj_MatrizResult.m13:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m11*obj_MatrizParam.m13)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m12*obj_MatrizParam.m23)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m13*obj_MatrizParam.m33);

 obj_MatrizResult.m21:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m21*obj_MatrizParam.m11)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m22*obj_MatrizParam.m21)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m23*obj_MatrizParam.m31);
 obj_MatrizResult.m22:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m21*obj_MatrizParam.m12)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m22*obj_MatrizParam.m22)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m23*obj_MatrizParam.m32);
 obj_MatrizResult.m23:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m21*obj_MatrizParam.m13)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m22*obj_MatrizParam.m23)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m23*obj_MatrizParam.m33);

 obj_MatrizResult.m31:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m31*obj_MatrizParam.m11)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m32*obj_MatrizParam.m21)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m33*obj_MatrizParam.m31);
 obj_MatrizResult.m32:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m31*obj_MatrizParam.m12)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m32*obj_MatrizParam.m22)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m33*obj_MatrizParam.m32);
 obj_MatrizResult.m33:=(Self.img_Pagina.Bitmap.Canvas.Matrix.m31*obj_MatrizParam.m13)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m32*obj_MatrizParam.m23)+(Self.img_Pagina.Bitmap.Canvas.Matrix.m33*obj_MatrizParam.m33);

 Self.img_Pagina.Bitmap.Canvas.SetMatrix(obj_MatrizResult); }
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.Linha(flt_X,flt_Y:Double);
Begin
 //Self.obj_Caminho.LineTo(TPointF.Create(ConverteCoordenada_X(flt_X,flt_Y),ConverteCoordenada_Y(flt_X,flt_Y)));
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.Curva(flt_X1,flt_Y1,flt_X2,flt_Y2,flt_X3,flt_Y3:Double);
Begin
 //Self.obj_Caminho.CurveTo(TPointF.Create(ConverteCoordenada_X(flt_X1,flt_Y1),ConverteCoordenada_Y(flt_X1,flt_Y1)),
 //                         TPointF.Create(ConverteCoordenada_X(flt_X2,flt_Y2),ConverteCoordenada_Y(flt_X2,flt_Y2)),
 //                         TPointF.Create(ConverteCoordenada_X(flt_X3,flt_Y3),ConverteCoordenada_Y(flt_X3,flt_Y3)));
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.IncluiCurvaInicio;
Begin
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.IncluiCurvaFinal;
Begin
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.FechaSubCaminho;
Begin
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.Retangulo(flt_X,flt_Y,flt_Altura,flt_Largura:Double);
Var obj_PotoAnt:TPointF;
Begin
// obj_PotoAnt:=Self.obj_Caminho.LastPoint;

// Self.obj_Caminho.MoveTo(TPointF.Create(ConverteCoordenada_X(flt_X,flt_Y),ConverteCoordenada_Y(flt_X,flt_Y)));

// Self.obj_Caminho.LineTo(TPointF.Create(ConverteCoordenada_X(flt_X+flt_Largura,flt_Y),ConverteCoordenada_Y(flt_X+flt_Largura,flt_Y)));
// Self.obj_Caminho.LineTo(TPointF.Create(ConverteCoordenada_X(flt_X+flt_Largura,flt_Y+flt_Altura),ConverteCoordenada_Y(flt_X+flt_Largura,flt_Y+flt_Altura)));
// Self.obj_Caminho.LineTo(TPointF.Create(ConverteCoordenada_X(flt_X,flt_Y+flt_Altura),ConverteCoordenada_Y(flt_X,flt_Y+flt_Altura)));
// Self.obj_Caminho.LineTo(TPointF.Create(ConverteCoordenada_X(flt_X,flt_Y),ConverteCoordenada_Y(flt_X,flt_Y)));

// Self.obj_Caminho.MoveTo(obj_PotoAnt);
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.FechaQuebraCaminho;
Begin
// Self.obj_Caminho.ClosePath;

 Self.Desenha;
// Self.obj_Caminho.Clear;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.QuebraCaminho;
Begin
 Self.Desenha;
// Self.obj_Caminho.Clear;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.Preenche;
Begin
// Self.img_Pagina.Bitmap.Canvas.FillPath(Self.obj_Caminho,200);
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.FechaCaminho;
Begin
// Self.obj_Caminho.ClosePath;
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineCorLinhaCMYK(int_C,int_M,int_Y,int_K:Integer);
Var int_R,
    int_G,
    int_B:Integer;
Begin
 int_R:=1-int_C-int_K;
 int_G:=1-int_M-int_K;
 int_B:=1-int_Y-int_K;

 Self.img_Pagina.Bitmap.Canvas.Stroke.Color:=StrToInt('$FF'+IntToHex(int_B,2)+IntToHex(int_G,2)+IntToHex(int_R,2));
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineCorFundoCMYK(int_C,int_M,int_Y,int_K:Integer);
Var int_R,
    int_G,
    int_B:Integer;
Begin
 int_R:=1-int_C-int_K;
 int_G:=1-int_M-int_K;
 int_B:=1-int_Y-int_K;

 Self.img_Pagina.Bitmap.Canvas.Fill.Color:=StrToInt('$FF'+IntToHex(int_B,2)+IntToHex(int_G,2)+IntToHex(int_R,2));
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineCorLinhaRGB(flt_R,flt_G,flt_B:Double);
Var str_R,
    str_G,
    str_B:String;
Begin
 str_R:=IfThen(flt_R<=1,IntToHex(Trunc(0.5+flt_R*$FF),2),IntToHex(Trunc(0.5+flt_R),2));
 str_G:=IfThen(flt_G<=1,IntToHex(Trunc(0.5+flt_G*$FF),2),IntToHex(Trunc(0.5+flt_G),2));
 str_B:=IfThen(flt_B<=1,IntToHex(Trunc(0.5+flt_B*$FF),2),IntToHex(Trunc(0.5+flt_B),2));

 Self.img_Pagina.Bitmap.Canvas.Stroke.Color:=StrToInt('$FF'+str_B+str_G+str_R);
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.DefineCorFundoRGB(flt_R,flt_G,flt_B:Double);
Var str_R,
    str_G,
    str_B:String;
Begin
 str_R:=IfThen(flt_R<=1,IntToHex(Trunc(0.5+flt_R*$FF),2),IntToHex(Trunc(0.5+flt_R),2));
 str_G:=IfThen(flt_G<=1,IntToHex(Trunc(0.5+flt_G*$FF),2),IntToHex(Trunc(0.5+flt_G),2));
 str_B:=IfThen(flt_B<=1,IntToHex(Trunc(0.5+flt_B*$FF),2),IntToHex(Trunc(0.5+flt_B),2));

 Self.img_Pagina.Bitmap.Canvas.Fill.Color:=StrToInt('$FF'+str_B+str_G+str_R);
End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.InicioObjetoInterno;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.InicioDadoInterno;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.FimImagemInterna;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.LimpaParam;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.InvocaObjeto;
Begin

End;
//-----------------------------------------------------------------------------
Procedure TPdfGrafico.Desenha;
Begin
 Self.img_Pagina.Bitmap.Canvas.BeginScene;

// Case Self.int_TipoJuncao Of
//      0:Self.img_Pagina.Bitmap.Canvas.StrokeJoin:=TStrokeJoin.sjMiter;
//      1:Self.img_Pagina.Bitmap.Canvas.StrokeJoin:=TStrokeJoin.sjRound;
//      2:Self.img_Pagina.Bitmap.Canvas.StrokeJoin:=TStrokeJoin.sjBevel;
// End;

// Case Self.int_TipoBorda Of
//      0:Self.img_Pagina.Bitmap.Canvas.StrokeCap:=TStrokeCap.scFlat;
//      1:Self.img_Pagina.Bitmap.Canvas.StrokeCap:=TStrokeCap.scRound;
//      2:Self.img_Pagina.Bitmap.Canvas.StrokeCap:=TStrokeCap.scFlat;
// End;

 If Length(Self.arr_Tracos)>0 Then
    Begin
//     Self.img_Pagina.Bitmap.Canvas.StrokeDash:=TStrokeDash.sdCustom;
     Self.img_Pagina.Bitmap.Canvas.SetCustomDash(Self.arr_Tracos,Self.flt_Inicio);
    End;

 Self.img_Pagina.Bitmap.Canvas.StrokeThickness:=Self.flt_Largura;

// Self.img_Pagina.Bitmap.Canvas.DrawPath(Self.obj_Caminho,200);

 Self.img_Pagina.Bitmap.Canvas.EndScene;
// Self.img_Pagina.Bitmap.BitmapChanged;
End;
//-----------------------------------------------------------------------------
Constructor TPdfGrafico.Create(Var img_Pagina:TImage;flt_Zoom:Double);
Var chr_Dado:AnsiChar;
    int_ContPonto,
    int_ContSinal,
    int_ContPar:Byte;
Begin
 Inherited Create;

 Self.img_Pagina:=img_Pagina;

 Self.RestauraEstadoGrafico;

// Self.obj_Caminho:=TPathData.Create;

 Self.flt_Zoom:=flt_Zoom;

// Self.img_Pagina.Bitmap.Canvas.Fill.Color:=claWhite;
// Self.img_Pagina.Bitmap.Canvas.Stroke.Color:=claBlack;

// Self.img_Pagina.Bitmap.Canvas.StrokeJoin:=TStrokeJoin.sjMiter;
// Self.img_Pagina.Bitmap.Canvas.StrokeCap:=TStrokeCap.scFlat;
End;
//-----------------------------------------------------------------------------

End.
