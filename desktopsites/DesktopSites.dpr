program DesktopSites;

uses
  Forms,
  main in 'main.pas' {Form1},
  TaskDlg in 'TaskDlg.pas',
  MSHTML_TLB in '..\..\delphi\Imports\MSHTML_TLB.pas',
  datafrm in 'datafrm.pas' {frmData};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Ave''s DesktopSites1.4';
  Application.ShowMainForm := false;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
