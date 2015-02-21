unit datafrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActiveX, shdocvw_tlb, mshtml_tlb ;

type
  TfrmData = class(TForm)
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmData: TfrmData;

implementation

uses main;

{$R *.dfm}

procedure WebBrowserScreenShot3(const wb: TWebBrowser; var bmp:TBitmap);
var
  viewObject : IViewObject;
  r : TRect;
  body:IHTMLBodyElement;
  doc:IHTMLDocument2;
begin
  if wb = nil then exit;

  if wb.Document <> nil then
  begin
    doc := wb.Document as IHTMLDocument2;
    if doc <> nil then begin
      body := doc.body as IHTMLBodyElement;
      if body <> nil then begin
        body.leftMargin := 0;
        body.topMargin := 0;
        body.scroll := 'no';
        if doc.body.style <> nil then begin
          doc.body.style.border := 'none';
    //    doc.body.style.overflow := 'none';
        end;
      end;
    end;
    wb.Document.QueryInterface(IViewObject, viewObject) ;
    if Assigned(viewObject) then
    try

        r := Rect(0, 0, wb.Width, wb.Height) ;

        if bmp.Canvas <> nil then
          viewObject.Draw(DVASPECT_CONTENT, 1, nil, nil, 0, bmp.Canvas.Handle, @r, nil, nil, 0) ;

    finally
      viewObject._Release;
    end;
  end;
end;

procedure PaintTheDesktop (Wnd: HWND; DC: HDC; DestX, DestY: Integer;
  const SourceRect: TRect); 
var 
  R: TRect; 
  Rgn: HRGN; 
  OldOrg: TPoint; 
begin 
  SetRectEmpty (R); 
  ClientToScreen (Wnd, R.TopLeft); 
  Rgn := CreateRectRgn(0, 0, 0, 0); 
  if GetClipRgn(DC, Rgn) <> 1 then begin 
    DeleteObject (Rgn); 
    Rgn := 0; 
  end; 
  SetWindowOrgEx (DC, -DestX - R.Left + SourceRect.Left, 
    -DestY - R.Top + SourceRect.Top, @OldOrg); 
  IntersectClipRect (DC, SourceRect.Left - R.Left, SourceRect.Top - R.Top, 
    SourceRect.Right - R.Left, SourceRect.Bottom - R.Top); 
  PaintDesktop (DC); 
  SetWindowOrgEx (DC, OldOrg.X, OldOrg.Y, nil); 
  SelectClipRgn (DC, Rgn); 
  if Rgn <> 0 then DeleteObject (Rgn); 
end;

procedure TfrmData.FormPaint(Sender: TObject);
var
  i:integer;
  item:SiteItem;
  rc, clip, it:TRect;
begin
//  exit;

  GetClipBox(canvas.handle, clip);
  if form1.realWallpaperBmp <> nil then
    canvas.CopyRect(clip, form1.realWallpaperBmp.Canvas, clip);

  if (form1 = nil) or (form1.sites = nil) then
    exit;


  for i:=0 to form1.sites.count -1 do begin
      item:= SiteItem(form1.sites.items[i]);
      if item = nil then continue;
      rc.Left := 0;
      rc.top := 0;
      rc.Right := item.bounds.right - item.bounds.left;
      rc.Bottom := item.bounds.bottom - item.bounds.top;

      if (item <> nil) and InterSectRect(it, clip, item.bounds) then begin

        if (item.bmp <> nil) and ((rc.right <> item.bmp.width) or(rc.bottom <> item.bmp.height)) then begin
          item.bmp.Destroy();
          item.bmp := nil;
        end;

        if item.browser <> nil then begin
          if item.bmp = nil then begin
            item.bmp := TBitmap.create;
            item.bmp.width := rc.right;
            item.bmp.height := rc.bottom;
          end;
          WebBrowserScreenShot3(item.browser, item.bmp);
        end;

        if item.bmp <> nil then begin
          canvas.Draw(item.bounds.left, item.bounds.top, item.bmp);
        end;
      end;
  end;

//  canvas.Brush.Color := rgb(255,0,Random(255));
  //canvas.FillRect(clip);
end;

end.
