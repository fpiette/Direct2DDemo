{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE @ overbyte.be
Creation:     Jan 15, 2013
Description:  This demo show how to use Direct2D and GDI+ to draw images and
              other graphic primitives faster than usual.
              Direct2D stuff if actually built in Delphi and is exposed here
              thru a simple comonent TAcceleratedPaintPanel which is a kind
              of PaintPanel with an OnPaint event so that you can paint
              whatever you need (Here we paint an image).
              Show also is how to zoom/pan/flip/rotate the image.
              Images are loaded using GDI+ for which Delphi provides units
              to encapsulate Windows GDI+ API. This means all image format
              supported by GDI+ is also supported by this demo program (JPG,
              TIF, BMP, PNG,...).
              The demo load a fixed bitmap. It is trivial to use a TOpenDialog
              to select another file. That's a good excercize for you :-)
              Before opening the demo, you MUST install TAcceleratedPaintPanel.
              To install, compile Direct2DDemoRunTime package and
              compile and install Direct2DDemoDesign package.
License:      This program is published under MOZILLA PUBLIC LICENSE V2.0;
              you may not use this file except in compliance with the License.
              You may obtain a copy of the License at
              https://www.mozilla.org/en-US/MPL/2.0/
Version:      1.00
History:
Aug 04, 2020  FPiette removed uneeded code so that the demo is more clear.
              Program is tested using Delphi 10.4 (AKA "Sidney").


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit Direct2DDemoMain;

interface

uses
    Winapi.Windows, Winapi.Messages, Winapi.D2D1, Winapi.DxgiFormat,
    Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.GDIPUTIL, Winapi.ShlObj,
    System.SysUtils, System.Classes, System.IniFiles,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Direct2D,
    AcceleratedPaintPanel;

const
    WM_APP_STARTUP       = WM_USER + 1;

type
    TDirect2DDemoMainForm = class(TForm)
        TopPanel: TPanel;
        DisplaySplitter: TSplitter;
        DisplayMemo: TMemo;
        AcceleratedPaintPanel1: TAcceleratedPaintPanel;
        RightPanel: TPanel;
        LoadImageButton: TButton;
        ZoomOutButton: TButton;
        ZoomInButton: TButton;
        PanLeftButton: TButton;
        PanRightButton: TButton;
        PanUpButton: TButton;
        PanDownButton: TButton;
        RotateCWButton: TButton;
        FlipHorizButton: TButton;
        FlipVertButton: TButton;
        procedure AcceleratedPaintBox1Paint(Sender: TObject);
        procedure AcceleratedPaintPanel1Click(Sender: TObject);
        procedure LoadImageButtonClick(Sender: TObject);
        procedure PanDownButtonClick(Sender: TObject);
        procedure PanLeftButtonClick(Sender: TObject);
        procedure PanRightButtonClick(Sender: TObject);
        procedure PanUpButtonClick(Sender: TObject);
        procedure ZoomInButtonClick(Sender: TObject);
        procedure ZoomOutButtonClick(Sender: TObject);
        procedure RotateCWButtonClick(Sender: TObject);
        procedure FlipHorizButtonClick(Sender: TObject);
        procedure FlipVertButtonClick(Sender: TObject);
    private
        FBitmapToPaint          : ID2D1Bitmap;
        FRotateFactor           : Double;
        FZoomFactor             : Double;
        FPanLeft                : Integer;
        FPanTop                 : Integer;
        FFlipHoriz              : Boolean;
        FFlipVert               : Boolean;
        FTransform              : TD2DMatrix3X2F;
        procedure WMAppStartup(var Msg: TMessage); message WM_APP_STARTUP;
        procedure ComputeTransform;
    protected
        procedure DoShow; override;
    public
        constructor Create(AOwner : TComponent); override;
        function  LoadBitmap(const FileName : String): Boolean;
        procedure ZoomFull;
        procedure PanCenter;
    end;

var
    Direct2DDemoMainForm : TDirect2DDemoMainForm;

implementation

{$R *.dfm}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TDirect2DDemoMainForm }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TDirect2DDemoMainForm.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FZoomFactor := 1.0;
    FTransform  := TD2DMatrix3X2F.Identity;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.DoShow;
begin
    PostMessage(Handle, WM_APP_STARTUP, 0, 0);
    inherited DoShow;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function CreateDirect2DBitmap(
    RenderTarget : ID2D1RenderTarget;
    GPBitmap     : TGPBitmap): ID2D1Bitmap; overload;
var
    BitmapBuf  : array of Byte;          // ARGB buffer
    BitmapProp : TD2D1BitmapProperties;
    BmpData    : TBitmapData;
begin
    Result := nil;
    if (GPBitmap.GetHeight = 0) or (GPBitmap.GetWidth = 0) then
        Exit;

    SetLength(BitmapBuf, GPBitmap.GetHeight * GPBitmap.GetWidth * 4);
    if GPBitmap.LockBits(MakeRect(0, 0,
                                  Integer(GPBitmap.GetWidth),
                                  Integer(GPBitmap.GetHeight)),
                         ImageLockModeRead,
                         PixelFormat32bppARGB,
                         BmpData) <> TStatus.Ok then
        raise Exception.Create('GPBitmap.LockBits failed');

    BitmapProp.DpiX                  := 0;
    BitmapProp.DpiY                  := 0;
    BitmapProp.PixelFormat.Format    := DXGI_FORMAT_B8G8R8A8_UNORM;
    BitmapProp.PixelFormat.AlphaMode := D2D1_ALPHA_MODE_PREMULTIPLIED;

    RenderTarget.CreateBitmap(D2D1SizeU(GPBitmap.GetWidth, GPBitmap.GetHeight),
                              BmpData.Scan0,
                              BmpData.Stride,
                              BitmapProp,
                              Result);
    GPBitmap.UnlockBits(BmpData);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TDirect2DDemoMainForm.LoadBitmap(const FileName : String): Boolean;
var
    GPBitmap     : TGPBitmap;
begin
    try
        GPBitmap := TGPBitmap.Create(FileName);
        try
            if (GPBitmap.GetWidth = 0) or (GPBitmap.GetHeight = 0) then begin
                ShowMessage('Invalid file');
                Result := FALSE;
                Exit;
            end;

            FBitmapToPaint := CreateDirect2DBitmap(
                            AcceleratedPaintPanel1.D2DCanvas.RenderTarget,
                            GPBitmap);
            // Reset transforms to something the user expects
            FFlipHoriz    := FALSE;
            FFlipVert     := FALSE;
            FRotateFactor := 0.0;
            ZoomFull;
            PanCenter;
            ComputeTransform;

            // Calling Invalidate will force the component to redraw which
            // in turn will trigger OnPaint event and our paint handler which
            // draw the image on screen.
            AcceleratedPaintPanel1.Invalidate;
            Result := TRUE;
            DisplayMemo.Lines.Add('Bitmap loaded');
        finally
            FreeAndNil(GPBitmap);
        end;
    except
        on E:Exception do begin
            DisplayMemo.Lines.Add(E.ClassName + ': ' + E.Message);
            Result := FALSE;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.WMAppStartup(var Msg: TMessage);
begin
    LoadImageButtonClick(nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.AcceleratedPaintPanel1Click(Sender: TObject);
begin
    DisplayMemo.Lines.Add('Click');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.ComputeTransform;
var
    Scaling      : TD2DMatrix3X2F;
    Translation  : TD2DMatrix3X2F;
    Rotation     : TD2DMatrix3X2F;
    FlippingH    : TD2DMatrix3X2F;
    FlippingHT   : TD2DMatrix3X2F;
    FlippingV    : TD2DMatrix3X2F;
    FlippingVT   : TD2DMatrix3X2F;
    Size         : TD2D1SizeU;
begin
    if not Assigned(FBitmapToPaint) then begin
        FTransform := TD2DMatrix3x2F.Identity;
        Exit;
    end;

    FBitmapToPaint.GetPixelSize(Size);

    if Abs(FZoomFactor - 1.0) <= 1E-5 then
        Scaling := TD2DMatrix3x2F.Identity
    else
        Scaling := TD2DMatrix3x2F.Scale(D2D1SizeF(FZoomFactor, FZoomFactor),
                                        D2D1PointF(0, 0));
    if Abs(FRotateFactor) <= 1E-5 then
        Rotation := TD2DMatrix3x2F.Identity
    else
        Rotation := TD2DMatrix3x2F.Rotation(FRotateFactor,
                                            Size.width div 2,
                                            Size.height div 2);

    Translation := TD2DMatrix3x2F.Translation(FPanLeft, FPanTop);

    if not FFlipHoriz then begin
        FlippingH     := TD2DMatrix3x2F.Identity;
        FlippingHT    := TD2DMatrix3x2F.Identity;
    end
    else begin
        FlippingH._11 := -1.0;   FlippingH._12 := 0.0;
        FlippingH._21 :=  0.0;   FlippingH._22 := 1.0;
        FlippingH._31 :=  0.0;   FlippingH._32 := 0.0;
        FlippingHT    := TD2DMatrix3x2F.Translation(-Size.width, 0);
    end;

    if not FFlipVert then begin
        FlippingV     := TD2DMatrix3x2F.Identity;
        FlippingVT    := TD2DMatrix3x2F.Identity;
    end
    else begin
        FlippingV._11 :=  1.0;   FlippingV._12 :=  0.0;
        FlippingV._21 :=  0.0;   FlippingV._22 := -1.0;
        FlippingV._31 :=  0.0;   FlippingV._32 :=  0.0;
        FlippingVT    := TD2DMatrix3x2F.Translation(0, -Size.Height);
    end;

    FTransform := FlippingVT * FlippingV *
                  FlippingHT * FlippingH *
                  Rotation   * Scaling   * Translation;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.AcceleratedPaintBox1Paint(Sender : TObject);
begin
    // Paint background
    AcceleratedPaintPanel1.RenderTarget.Clear(D2D1ColorF(clSilver));
    // Paint bitmap, if any
    if FBitmapToPaint <> nil then begin
        AcceleratedPaintPanel1.RenderTarget.SetTransform(FTransform);
        AcceleratedPaintPanel1.RenderTarget.DrawBitmap(FBitmapToPaint);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.LoadImageButtonClick(Sender: TObject);
var
    FileName : String;
begin
    // Demo image file. Try to locate in current directory and several
    // parent directories (In development, it is likely to be with the source).
    FileName := 'Delphi25 ICS.jpg';
    if not FileExists(FileName) then begin
        FileName := '..\' + FileName;
        if not FileExists(FileName) then begin
            FileName := '..\' + FileName;
            if not FileExists(FileName) then begin
                FileName := '..\' + FileName;
                if not FileExists(FileName) then
                    FileName := '..\' + FileName;
            end;
        end;
    end;

    LoadBitmap(FileName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.FlipHorizButtonClick(Sender: TObject);
begin
    FFlipHoriz := not FFlipHoriz;
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.FlipVertButtonClick(Sender: TObject);
begin
    FFlipVert := not FFlipVert;
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.ZoomFull;
var
    Size   : D2D1_SIZE_U;
    RW, RH : Double;
begin
    if Assigned(FBitmapToPaint) then begin
        FBitmapToPaint.GetPixelSize(Size);
        RW := AcceleratedPaintPanel1.Width  / Size.Width;
        RH := AcceleratedPaintPanel1.Height / Size.Height;
        if RW < RH then
            FZoomFactor := RW
        else
            FZoomFactor := RH;
    end;
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.PanCenter;
var
    Size   : D2D1_SIZE_U;
begin
    if Assigned(FBitmapToPaint) then begin
        FBitmapToPaint.GetPixelSize(Size);
        FPanLeft := (AcceleratedPaintPanel1.Width  - Round(Size.Width  * FZoomFactor)) div 2;
        FPanTop  := (AcceleratedPaintPanel1.Height - Round(Size.Height * FZoomFactor)) div 2;
        ComputeTransform;
        AcceleratedPaintPanel1.Invalidate;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.PanLeftButtonClick(Sender: TObject);
begin
    Dec(FPanLeft, 10);
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.PanRightButtonClick(Sender: TObject);
begin
    Inc(FPanLeft, 10);
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.PanDownButtonClick(Sender: TObject);
begin
    Inc(FPanTop, 10);
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.PanUpButtonClick(Sender: TObject);
begin
    Dec(FPanTop, 10);
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.RotateCWButtonClick(Sender: TObject);
begin
    FRotateFactor := FRotateFactor + 90.0;
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.ZoomInButtonClick(Sender: TObject);
begin
    FZoomFactor := FZoomFactor * 1.05;
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDirect2DDemoMainForm.ZoomOutButtonClick(Sender: TObject);
begin
    FZoomFactor := FZoomFactor / 1.05;
    if Abs(FZoomFactor - 1.0) < 1E-5 then
        FZoomFactor := 1.0;
    ComputeTransform;
    AcceleratedPaintPanel1.Invalidate;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
