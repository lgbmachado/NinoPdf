Unit Un_PdfPagina;

Interface

Uses Classes,
     System.Types,

     FMX.Objects,
     System.UITypes,

     Un_PdfObjetos,
     Un_PdfXRef,
     Un_PdfGrafico,
     Un_PdfTexto;

     //------------------------------------------------------------------------
Type TPdfPagina=Class(TObject)
                Private
                   obj_Grafico:TPdfGrafico;
                   obj_Texto:TPdfTexto;

                   int_Rot:Integer;
                   lst_Recursos:TList;
                   obj_XRef:TXRef;
                   pto_Anterior:TPointF;
                   flt_Zoom:Double;
                Public
                   Constructor Create(Var img_Pagina:TImage;Var obj_XRef:TXRef;int_NumPagina:Integer;obj_ObjPagina:TPdfObjeto;flt_Zoom:Double);
                   Function ObtemConteudo(obj_Conteudo1:TPdfObjeto):TStringStream;
                End;

Implementation

Uses System.SysUtils,
     System.ZLib,

     Un_PdfUtils,
     Un_PdfRenderiza;

//-----------------------------------------------------------------------------
// TPdfPagina
//-----------------------------------------------------------------------------
Constructor TPdfPagina.Create(Var img_Pagina:TImage;Var obj_XRef:TXRef;int_NumPagina:Integer;obj_ObjPagina:TPdfObjeto;flt_Zoom:Double);
Var obj_Aux,
    obj_Mediabox,
    obj_CropBox,
    obj_Rot,
    obj_Conteudo1,
    obj_Conteudo2:TPdfObjeto;
    int_IdConteudo,
    int_Esq,
    int_Topo,
    int_Largura,
    int_Altura,
    J,K:Integer;
    str_TipoCodif:AnsiString;
    I:Int64;
    stm_DadoFlatDecode:TDecompressionStream;
    stm_DadoNaoFiltrado:TMemoryStream;
    stm_Conteudo:TStringStream;
    str_IdFonte:String;
    obj_Renderiza:TPdfRenderiza;
Begin
 Inherited Create;

 int_Rot:=0;

 Self.obj_XRef:=obj_XRef;
 Self.lst_Recursos:=TList.Create;

 obj_Aux:=obj_ObjPagina;

 Self.flt_Zoom:=flt_Zoom;

 //Monta a lista de recursos
 Repeat
       If TPdfObjDicionario(obj_Aux.Conteudo).ExisteChave('Resources') Then
          Begin
           If TPdfObjDicionario(obj_Aux.Conteudo).ObtemValorChave('Resources').Tipo=obj_indireto Then
              Self.lst_Recursos.Add(Self.obj_XRef.BuscaObjetoPorId(TPdfObjDicionario(obj_Aux.Conteudo).ObtemValorChave('Resources').Id))
           Else
              Self.lst_Recursos.Add(TPdfObjDicionario(obj_Aux.Conteudo).ObtemValorChave('Resources'));
          End;
       //Tem objeto pai?
       If TPdfObjDicionario(obj_Aux.Conteudo).ExisteChave('Parent') Then
          //Sim, então pega ele!
          obj_Aux:=TPdfObjIndireto(TPdfObjDicionario(obj_Aux.Conteudo).ObtemValorChave('Parent').Conteudo).ObtemValorRef(obj_XRef)
       Else
          obj_Aux:=Nil;
 Until obj_Aux=Nil;

 //Obtém as medidas do ítem "MediaBox"
 obj_Mediabox:=Nil;
 obj_Aux:=obj_ObjPagina;

 Repeat
       //Achou o ítem "MediaBox"?
       If TPdfObjDicionario(obj_Aux.Conteudo).ExisteChave('MediaBox') Then
          //Sim, então pega ele!
          obj_Mediabox:=TPdfObjDicionario(obj_Aux.Conteudo).ObtemValorChave('MediaBox')
       Else
          Begin
           //Não, mas tem objeto pai?
           If TPdfObjDicionario(obj_Aux.Conteudo).ExisteChave('Parent') Then
              //Sim, então pega ele!
              obj_Aux:=TPdfObjIndireto(TPdfObjDicionario(obj_Aux.Conteudo).ObtemValorChave('Parent').Conteudo).ObtemValorRef(obj_XRef)
           Else
              obj_Aux:=Nil;
          End;
 Until (obj_Mediabox<>Nil) Or (obj_Aux=Nil);

 //Obtém as medidas do ítem "CropBox" do objeto da página
 obj_CropBox:=TPdfObjDicionario(obj_ObjPagina.Conteudo).ObtemValorChave('CropBox');

 //Conseguiu as medidas "CropBox"
 If obj_CropBox<>Nil Then
    Begin
     //Sim, usa "CropBox"
     If obj_CropBox.Tipo=obj_array Then
        Begin
         If TPdfObjArray(obj_CropBox.Conteudo).Tamanho=4 Then
            Begin
             int_Esq:=TPdfObjNumerico(TPdfObjArray(obj_CropBox.Conteudo).ObtemValorItem(0).Conteudo).ObtemValorInteiro;
             int_Topo:=TPdfObjNumerico(TPdfObjArray(obj_CropBox.Conteudo).ObtemValorItem(1).Conteudo).ObtemValorInteiro;

             int_Largura:=TPdfObjNumerico(TPdfObjArray(obj_CropBox.Conteudo).ObtemValorItem(2).Conteudo).ObtemValorInteiro-TPdfObjNumerico(TPdfObjArray(obj_CropBox.Conteudo).ObtemValorItem(0).Conteudo).ObtemValorInteiro;
             int_Altura:=TPdfObjNumerico(TPdfObjArray(obj_CropBox.Conteudo).ObtemValorItem(3).Conteudo).ObtemValorInteiro-TPdfObjNumerico(TPdfObjArray(obj_CropBox.Conteudo).ObtemValorItem(1).Conteudo).ObtemValorInteiro;
            End
         Else
            Raise Exception.Create('A definição deve possuir 4 elementos.');
        End
    Else
        Raise Exception.Create('O objeto "MediaBox" deve ser do tipo array.');
    End
 Else
    Begin
     If obj_Mediabox.Tipo=obj_array Then
        Begin
         If TPdfObjArray(obj_Mediabox.Conteudo).Tamanho=4 Then
            Begin
             int_Esq:=TPdfObjNumerico(TPdfObjArray(obj_Mediabox.Conteudo).ObtemValorItem(0).Conteudo).ObtemValorInteiro;
             int_Topo:=TPdfObjNumerico(TPdfObjArray(obj_Mediabox.Conteudo).ObtemValorItem(1).Conteudo).ObtemValorInteiro;

             int_Largura:=TPdfObjNumerico(TPdfObjArray(obj_Mediabox.Conteudo).ObtemValorItem(2).Conteudo).ObtemValorInteiro-TPdfObjNumerico(TPdfObjArray(obj_Mediabox.Conteudo).ObtemValorItem(0).Conteudo).ObtemValorInteiro;
             int_Altura:=TPdfObjNumerico(TPdfObjArray(obj_Mediabox.Conteudo).ObtemValorItem(3).Conteudo).ObtemValorInteiro-TPdfObjNumerico(TPdfObjArray(obj_Mediabox.Conteudo).ObtemValorItem(1).Conteudo).ObtemValorInteiro;
            End
         Else
            Raise Exception.Create('A definição deve possuir 4 elementos.');
        End
    Else
        Raise Exception.Create('O objeto "MediaBox" deve ser do tipo array.');
    End;

 img_Pagina.Height:=int_Altura*Self.flt_Zoom;
 img_Pagina.Width:=int_Largura*Self.flt_Zoom;

 img_Pagina.Bitmap.Create(Trunc(int_Largura*Self.flt_Zoom),Trunc(int_Altura*Self.flt_Zoom));

 Self.obj_Grafico:=TPdfGrafico.Create(img_Pagina,Self.flt_Zoom);
 Self.obj_Texto:=TPdfTexto.Create(img_Pagina);

 img_Pagina.Bitmap.Clear(TAlphaColorRec.White);

 If TPdfObjDicionario(obj_ObjPagina.Conteudo).ExisteChave('Rotate') Then
    Begin
     //Obtém o objeto com valor da rotação da página
     obj_Rot:=TPdfObjDicionario(obj_ObjPagina.Conteudo).ObtemValorChave('Rotate');
     //Conseguiu o objeto?
     If obj_Rot.Tipo=obj_numero Then
        Begin
         //Sim, obtém o valor
         Self.int_Rot:=TPdfObjNumerico(obj_Rot.Conteudo).ObtemValorInteiro;

        End
     Else
        Raise Exception.Create('O objeto "Rotate" deve ser do tipo numérico.');
    End;

 //Obtém o conteúdo...
 obj_Conteudo1:=TPdfObjDicionario(obj_ObjPagina.Conteudo).ObtemValorChave('Contents');
 //Achou?
 If obj_Conteudo1<>Nil Then
    Begin
     //Sim, cria o objeto renderiza
     obj_Renderiza:=TPdfRenderiza.Create(Self.obj_Grafico,Self.obj_Texto);

     //É objeto indireto?
     If obj_Conteudo1.Tipo=obj_indireto Then
     //Sim, obtem o conteúdo
     obj_Conteudo1:=TPdfObjIndireto(obj_Conteudo1.Conteudo).ObtemValorRef(obj_XRef);

     //É objeto stream?
     If obj_Conteudo1.Tipo=obj_stream Then
        Begin
         stm_Conteudo:=ObtemConteudo(obj_Conteudo1);
         If stm_Conteudo.Size>0 Then
            obj_Renderiza.TrataConteudo(stm_Conteudo);
        End
     //É objeto array?
     Else If obj_Conteudo1.Tipo=obj_array Then
        Begin
         For J:=0 To TPdfObjArray(obj_Conteudo1.Conteudo).Tamanho-1 Do
             Begin
              obj_Conteudo2:=TPdfObjArray(obj_Conteudo1.Conteudo).ObtemValorItem(J);
              If obj_Conteudo2.Tipo=obj_indireto Then
                 Begin
                  obj_Conteudo2:=TPdfObjIndireto(obj_Conteudo2.Conteudo).ObtemValorRef(obj_XRef);
                  //É objeto stream?
                  If obj_Conteudo2.Tipo=obj_stream Then
                     Begin
                      stm_Conteudo:=ObtemConteudo(obj_Conteudo2);
                      If stm_Conteudo.Size>0 Then
                         obj_Renderiza.TrataConteudo(stm_Conteudo);
                     End
                 End;
             End;
        End;
    End
 Else
    Raise Exception.Create('O conteúdo da página não foi encontrado.');
End;
//-----------------------------------------------------------------------------
Function TPdfPagina.ObtemConteudo(obj_Conteudo1:TPdfObjeto):TStringStream;
Begin
 //Sim, mas tem algum filtro?
 If TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter')<>Nil Then
    Begin
     Result:=TStringStream.Create;
     If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='FlateDecode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='Fl') Then
        Result.LoadFromStream(_DecodificaZLib(TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValor))
     Else If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='LZWDecode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='LZW') Then
        Begin
        End
     Else If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='ASCII85Decode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='A85') Then
        Begin
        End
     Else If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='ASCIIHexDecode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='AHx') Then
        Begin
        End
     Else If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='RunLengthDecode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='RL') Then
        Begin
        End
     Else If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='DCTDecode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='DCT') Then
        Begin
        End
     Else If (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='CCITTFaxDecode') Or (TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='CCF') Then
        Begin
        End
     Else If TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValorMetadado('Filter').ObtemValorString='Crypt' Then
        Begin
        End
    End
 Else
    //Não, obtem o conteúdo
    Result:=TPdfObjStream(obj_Conteudo1.Conteudo).ObtemValor;
End;
//-----------------------------------------------------------------------------
End.

