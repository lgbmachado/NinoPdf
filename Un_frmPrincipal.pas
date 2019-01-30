unit Un_frmPrincipal;

interface

uses System.SysUtils,
     System.Types,
     System.UITypes,
     System.Classes,
     System.Variants,

     FMX.Types,
     FMX.Controls,
     FMX.Forms,
     FMX.Dialogs,
     FMX.Objects,
     FMX.Ani,
     FMX.Layouts,

     Un_PdfNino, FMX.StdCtrls, FMX.Controls.Presentation;

type
  Tfrm_Principal = class(TForm)
    tbr_Principal: TToolBar;
    pnl_Principal: TPanel;
    txt_Arquivo: TLabel;
    txt_Paginas: TLabel;
    txt_Titulo: TLabel;
    txt_Assunto: TLabel;
    txt_PalavrasChave: TLabel;
    txt_Criador: TLabel;
    txt_Produtor: TLabel;
    stb_Principal: TStatusBar;
    bot_Abre: TButton;
    img_Abre: TImage;
    bot_Primeiro: TButton;
    img_Primeiro: TImage;
    bot_Anterior: TButton;
    img_Anterior: TImage;
    bot_Proximo: TButton;
    img_Proximo: TImage;
    bot_Ultimo: TButton;
    img_Ultimo: TImage;
    dlg_SelecArquivo: TOpenDialog;
    scb_Principal: TScrollBox;
    img_Pagina: TImage;
    txt_NumPagina: TLabel;
    pnl_Arquivo: TPanel;
    pnl_Paginas: TPanel;
    pnl_Titulo: TPanel;
    pnl_Autor: TPanel;
    pnl_Assunto: TPanel;
    pnl_PalavrasChave: TPanel;
    pnl_Criador: TPanel;
    pnl_Produtor: TPanel;
    edt_Arquivo: TLabel;
    edt_Paginas: TLabel;
    edt_Titulo: TLabel;
    txt_Autor: TLabel;
    edt_Autor: TLabel;
    edt_Assunto: TLabel;
    edt_PalavrasChave: TLabel;
    edt_Criador: TLabel;
    edt_Produtor: TLabel;
    bot_MaisZoom: TButton;
    img_MaisZoom: TImage;
    bot_MenosZoom: TButton;
    img_MenosZoom: TImage;
    pnl_Zoom: TPanel;
    txt_Zoom: TLabel;
    bot_Info: TButton;
    img_Info: TImage;
    procedure bot_AbreClick(Sender: TObject);
    procedure bot_PrimeiroClick(Sender: TObject);
    procedure bot_AnteriorClick(Sender: TObject);
    procedure bot_ProximoClick(Sender: TObject);
    procedure bot_UltimoClick(Sender: TObject);
    procedure bot_MaisZoomClick(Sender: TObject);
    procedure bot_MenosZoomClick(Sender: TObject);
    procedure bot_InfoClick(Sender: TObject);
  private
    Pdf:TPdf;
  Public
    { Public declarations }
  end;

var
  frm_Principal: Tfrm_Principal;

implementation

{$R *.fmx}

//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_AbreClick(Sender: TObject);
begin
 If dlg_SelecArquivo.Execute Then
    Begin
     Self.Cursor:=crHourGlass;

     edt_Arquivo.Text:=dlg_SelecArquivo.FileName;
     edt_Paginas.Text:='';
     edt_Titulo.Text:='';
     edt_Autor.Text:='';
     edt_Assunto.Text:='';
     edt_PalavrasChave.Text:='';
     edt_Criador.Text:='';
     edt_Produtor.Text:='';


     If Pdf<>Nil Then
        Pdf.Free;

     Pdf:=TPdf.Create(dlg_SelecArquivo.FileName,img_Pagina);

     edt_Paginas.Text:=FormatFloat('000#',Pdf.QtdPaginas);
     edt_Titulo.Text:=Pdf.Info.Titulo;
     edt_Autor.Text:=Pdf.Info.Autor;
     edt_Assunto.Text:=Pdf.Info.Assunto;
     edt_PalavrasChave.Text:=Pdf.Info.PalavrasChave;
     edt_Criador.Text:=Pdf.Info.Criador;
     edt_Produtor.Text:=Pdf.Info.Produtor;

     Self.Cursor:=crDefault;
     img_Pagina.Repaint;

     txt_NumPagina.Text:=FormatFloat('00#',Pdf.PagAtual)+'/'+FormatFloat('00#',Pdf.QtdPaginas);
     txt_Zoom.Text:=FormatFloat('#',Pdf.Zoom)+' %';
    End;
end;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_AnteriorClick(Sender: TObject);
begin
 If Pdf.PagAtual>1 Then
    Pdf.PagAtual:=Pdf.PagAtual-1;
 txt_NumPagina.Text:=FormatFloat('00#',Pdf.PagAtual)+'/'+FormatFloat('00#',Pdf.QtdPaginas);
end;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_InfoClick(Sender: TObject);
begin
 pnl_Principal.Visible:=Not pnl_Principal.Visible;
end;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_MaisZoomClick(Sender: TObject);
begin
 Pdf.Zoom:=Pdf.Zoom+10;
 txt_Zoom.Text:=FormatFloat('#',Pdf.Zoom)+' %';
end;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_MenosZoomClick(Sender: TObject);
begin
 Pdf.Zoom:=Pdf.Zoom-10;
 txt_Zoom.Text:=FormatFloat('#',Pdf.Zoom)+' %';
end;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_PrimeiroClick(Sender: TObject);
begin
 Pdf.PagAtual:=1;
 txt_NumPagina.Text:=FormatFloat('00#',Pdf.PagAtual)+'/'+FormatFloat('00#',Pdf.QtdPaginas);
End;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_ProximoClick(Sender: TObject);
begin
 If Pdf.PagAtual<Pdf.QtdPaginas Then
    Pdf.PagAtual:=Pdf.PagAtual+1;
 txt_NumPagina.Text:=FormatFloat('00#',Pdf.PagAtual)+'/'+FormatFloat('00#',Pdf.QtdPaginas);
end;
//-----------------------------------------------------------------------------
procedure Tfrm_Principal.bot_UltimoClick(Sender: TObject);
begin
 Pdf.PagAtual:=Pdf.QtdPaginas;
 txt_NumPagina.Text:=FormatFloat('00#',Pdf.PagAtual)+'/'+FormatFloat('00#',Pdf.QtdPaginas);
end;
//-----------------------------------------------------------------------------
end.
