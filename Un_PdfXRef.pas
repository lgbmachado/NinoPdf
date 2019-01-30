Unit Un_PdfXRef;

Interface

Uses Classes;

Type //------------------------------------------------------------------------
     TXRefItem=Class(TObject)
                int_Id,
                int_Gen:Integer;
                int_Pos:Int64;
                chr_Status:Char;
               End;
     //------------------------------------------------------------------------
     TXRef=Class(TObject)
           Private
              lst_Conteudo:TList;
              int_Tam:Integer;
              stm_Dados:TStringStream;
           Public
              Constructor Create(Var stm_Dados:TStringStream);
              Procedure Insere(int_Id:Integer;str_Dado:String);
              Function BuscaObjetoPorId(int_IdObj:Integer):TObject;
              Function BuscaObjetoPorIndice(int_Indice:Word):TObject;
              Property Tamanho:Integer Read int_Tam;
           End;

Implementation

Uses SysUtils,

     Un_PdfNino,
     Un_PdfObjetos;

//-----------------------------------------------------------------------------
// TXRef
//-----------------------------------------------------------------------------
Constructor TXRef.Create(Var stm_Dados:TStringStream);
Begin
 Inherited Create;
 Self.stm_Dados:=stm_Dados;
 lst_Conteudo:=TList.Create;
End;
//-----------------------------------------------------------------------------
Procedure TXRef.Insere(int_Id:Integer;str_Dado:String);
Var obj_ItemXref:TXRefItem;
Begin
 obj_ItemXref:=TXRefItem.Create;
 obj_ItemXref.int_Id:=int_Id;
 obj_ItemXref.int_Pos:=-1;
 obj_ItemXref.int_Gen:=-1;
 If Length(str_Dado)>=20 Then
    Begin
     //Obtém o status
     obj_ItemXref.chr_Status:=str_Dado[18];
     obj_ItemXref.int_Pos:=StrToIntDef(Copy(str_Dado,1,10),0);
     obj_ItemXref.int_Gen:=StrToIntDef(Copy(str_Dado,12,5),0);
    End;
 lst_Conteudo.Add(obj_ItemXref);
 int_Tam:=lst_Conteudo.Count;
End;
//-----------------------------------------------------------------------------
Function TXRef.BuscaObjetoPorId(int_IdObj:Integer):TObject;
Var bol_Achou:Boolean;
    I,
    int_Gen:Integer;
    int_PosAnt:Int64;
Begin
 bol_Achou:=False;
 I:=0;
 While (Not bol_Achou) And (I<Self.lst_Conteudo.Count) Do
       Begin
        If Self.lst_Conteudo[I]<>Nil Then
           Begin
            If TXRefItem(Self.lst_Conteudo[I]).int_Id=int_IdObj Then
               bol_Achou:=True
            Else
               Inc(I);
           End
        Else
           Inc(I);
       End;
 If bol_Achou Then
    Begin
     If TXRefItem(Self.lst_Conteudo[I]).int_Pos>0 Then
        Begin
         int_PosAnt:=Self.stm_Dados.Position;
         Self.stm_Dados.Position:=TXRefItem(Self.lst_Conteudo[I]).int_Pos;
         Result:=TPdfObjeto.Create(Self.stm_Dados,Self,TXRefItem(Self.lst_Conteudo[I]).int_Id,TXRefItem(Self.lst_Conteudo[I]).int_Gen,False);
         Self.stm_Dados.Position:=int_PosAnt;
        End
     Else
        Result:=Nil;
    End
 Else
    Result:=Nil;
End;
//-----------------------------------------------------------------------------
Function TXRef.BuscaObjetoPorIndice(int_Indice:Word):TObject;
Begin
 If (int_Indice>=0) And (int_Indice<Self.lst_Conteudo.Count) Then
    Result:=TPdfObjeto(Self.lst_Conteudo[int_Indice])
 Else
    Result:=Nil;
End;
//-----------------------------------------------------------------------------

End.
