unit AcceleratedPaintPanelReg;

interface

uses
    Classes, AcceleratedPaintPanel;

procedure Register;

implementation

procedure Register;
begin
    RegisterComponents('Overbyte Ctrls', [TAcceleratedPaintPanel]);
end;


end.
