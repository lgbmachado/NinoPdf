program TestaNinoPdf;

uses
  FMX.Forms,
  Un_frmPrincipal in 'Un_frmPrincipal.pas' {frm_Principal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_Principal, frm_Principal);
  Application.Run;
end.

