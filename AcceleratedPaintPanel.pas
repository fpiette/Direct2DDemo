{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE @ overbyte.be
Creation:     Sep 13, 2016
Description:  A PaintBox like control using Direct2D to draw faster
              Code based on DocWiki example code at:
              http://docwiki.embarcadero.com/RADStudio/Seattle/en/Using_the_Direct2D_Canvas
License:      This program is published under MOZILLA PUBLIC LICENSE V2.0;
              you may not use this file except in compliance with the License.
              You may obtain a copy of the License at
              https://www.mozilla.org/en-US/MPL/2.0/
Version:      1.0
History:


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit AcceleratedPaintPanel;

interface

uses
    Winapi.Messages, Winapi.D2D1,
    System.Classes,
    Vcl.Graphics, Vcl.ExtCtrls, Vcl.Direct2D;

type
    TCustomAcceleratedPaintPanel = class(TPanel)
    private
        FD2DCanvas             : TDirect2DCanvas;
        FPrevRenderTarget      : IntPtr;
        FOnPaint               : TNotifyEvent;
        FOnCreateRenderTarget  : TNotifyEvent;
        function  CreateD2DCanvas: Boolean;
        procedure WMEraseBkGnd(var Msg: TMessage); message WM_ERASEBKGND;
        procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
        procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    protected
        procedure CreateWnd; override;
        function  GetRenderTarget : ID2D1HwndRenderTarget;
        procedure TriggerCreateRenderTarget; virtual;
    public
        destructor Destroy; override;
        procedure Paint; override;
        property D2DCanvas             : TDirect2DCanvas
                                                   read  FD2DCanvas;
        property RenderTarget          : ID2D1HwndRenderTarget
                                                   read  GetRenderTarget;
        property OnPaint               : TNotifyEvent
                                                   read  FOnPaint
                                                   write FOnPaint;
        property OnCreateRenderTarget  : TNotifyEvent
                                                   read  FOnCreateRenderTarget
                                                   write FOnCreateRenderTarget;
    end;

    TAcceleratedPaintPanel = class(TCustomAcceleratedPaintPanel)
    published
        property Align;
        property Anchors;
        property Canvas;
        property Color;
        property D2DCanvas;
        property RenderTarget;
        property BevelEdges;
        property BevelInner;
        property BevelOuter;
        property BevelKind;
        property BevelWidth;
        property BorderWidth;
        property Ctl3D;
        property ParentBackground;
        property ParentCtl3D;
        property OnAlignInsertBefore;
        property OnAlignPosition;
        property OnDockDrop;
        property OnDockOver;
        property OnEnter;
        property OnExit;
        property OnGetSiteInfo;
        property OnKeyDown;
        property OnKeyPress;
        property OnKeyUp;
        property OnUnDock;
        property DragCursor;
        property DragMode;
        property ParentBiDiMode;
        property ParentColor;
        property ParentFont;
        property ParentShowHint;
        property PopupMenu;
        property OnCanResize;
        property OnClick;
        property OnConstrainedResize;
        property OnContextPopup;
        property OnDblClick;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDock;
        property OnEndDrag;
        property OnMouseActivate;
        property OnMouseDown;
        property OnMouseEnter;
        property OnMouseLeave;
        property OnMouseMove;
        property OnMouseUp;
        property OnMouseWheel;
        property OnMouseWheelDown;
        property OnMouseWheelUp;
        property OnResize;
        property OnStartDock;
        property OnStartDrag;
        property OnPaint;
    end;

implementation

uses
    Windows, SysUtils, Controls;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TCustomAcceleratedPaintPanel }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TCustomAcceleratedPaintPanel.Destroy;
begin
    FreeAndNil(FD2DCanvas);
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomAcceleratedPaintPanel.CreateD2DCanvas: Boolean;
begin
    try
        FD2DCanvas := TDirect2DCanvas.Create(Handle);
        Result     := TRUE;
    except
        Result     := FALSE;
    end;
    TriggerCreateRenderTarget;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomAcceleratedPaintPanel.CreateWnd;
begin
    inherited;
    if (Win32MajorVersion < 6) or (Win32Platform <> VER_PLATFORM_WIN32_NT) then
        raise Exception.Create('Your Windows version do not support Direct2D');
    if not CreateD2DCanvas then
        raise Exception.Create('Unable to create Direct2D canvas');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomAcceleratedPaintPanel.GetRenderTarget: ID2D1HwndRenderTarget;
begin
    if FD2DCanvas <> nil then begin
        Result := FD2DCanvas.RenderTarget as ID2D1HwndRenderTarget;
        if FPrevRenderTarget <> IntPtr(Result) then begin
            FPrevRenderTarget := IntPtr(Result);
            TriggerCreateRenderTarget;
        end;
    end
    else
        Result := nil;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomAcceleratedPaintPanel.TriggerCreateRenderTarget;
begin
    if Assigned(FOnCreateRenderTarget) then
        FOnCreateRenderTarget(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomAcceleratedPaintPanel.Paint;
begin
    D2DCanvas.Font.Assign(Font);
    D2DCanvas.Brush.Color := Color;
    if csDesigning in ComponentState then begin
        D2DCanvas.Pen.Style   := psDash;
        D2DCanvas.Brush.Style := bsSolid;
        D2DCanvas.Rectangle(0, 0, Width, Height);
    end;
    if Assigned(FOnPaint) then
        FOnPaint(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomAcceleratedPaintPanel.WMEraseBkGnd(var Msg: TMessage);
begin
    Msg.Result := 1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomAcceleratedPaintPanel.WMPaint(var Msg: TWMPaint);
var
    PaintStruct: TPaintStruct;
begin
    BeginPaint(Handle, PaintStruct);
    try
        FD2DCanvas.BeginDraw;
        try
            Paint;
        finally
            FD2DCanvas.EndDraw;
        end;
    finally
        EndPaint(Handle, PaintStruct);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomAcceleratedPaintPanel.WMSize(var Msg: TWMSize);
var
    Size: D2D1_SIZE_U;
begin
    if FD2DCanvas <> nil then begin
        Size := D2D1SizeU(Width, Height);
        ID2D1HwndRenderTarget(FD2DCanvas.RenderTarget).Resize(Size);
    end;
    inherited;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
