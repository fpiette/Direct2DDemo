program Direct2DDemo;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Direct2DDemoMain in 'Direct2DDemoMain.pas' {Direct2DDemoMainForm},
  AcceleratedPaintPanel in 'AcceleratedPaintPanel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDirect2DDemoMainForm, Direct2DDemoMainForm);
  Application.Run;
end.
