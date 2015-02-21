unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan, TaskDlg, Spin, OleCtrls, SHDocVw_TLB, MSHTML_TLB, ActiveX, jpeg, inifiles,
  shlobj, shfolder, TrayIcon, AppEvnts, datafrm;

  procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
  external user32 Name 'SwitchToThisWindow';
         {x = false: Size unchanged, x = true: normal size}

type
   SiteItem = class;

  TForm1 = class(TForm)
    panContents: TPanel;
    Label1: TLabel;
    Panel1: TPanel;
    panData: TPanel;
    XPManifest1: TXPManifest;
    butApply: TButton;
    editURL: TLabeledEdit;
    Panel2: TPanel;
    Panel3: TPanel;
    lbSites: TListBox;
    Splitter1: TSplitter;
    butAdd: TButton;
    butRemove: TButton;
    groupPosSize: TGroupBox;
    Label2: TLabel;
    spinLeft: TSpinEdit;
    Label3: TLabel;
    spinTop: TSpinEdit;
    Label4: TLabel;
    spinWidth: TSpinEdit;
    Label5: TLabel;
    spinHeight: TSpinEdit;
    imgPreview: TPaintBox;
    Label6: TLabel;
    spinInterval: TSpinEdit;
    Label7: TLabel;
    TrayIcon1: TTrayIcon;
    butHide: TButton;
    timerGlobalRefresh: TTimer;
    Label8: TLabel;
    Timer2: TTimer;
    butCapture: TPanel;
    checkIsLive: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure butAddClick(Sender: TObject);
    procedure ButtonRemoveClick(Sender: TObject);
    procedure lbSitesClick(Sender: TObject);
    procedure editURLChange(Sender: TObject);
    procedure butApplyClick(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure imgPreviewPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure butHideClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure timerGlobalRefreshTimer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure WebBrowser1NavigateError(ASender: TObject;
      const pDisp: IDispatch; var URL, Frame, StatusCode: OleVariant;
      var Cancel: WordBool);
    procedure TrayIcon1Click(Sender: TObject);
  private
    { Private declarations }


    paintMsg:HWND;
    hmod:HMODULE;
    datafrm:TFrmData;

    StartHook: function(hmod:HMODULE;owner:HWND):Integer;stdcall;
    StopHook: function():Integer;stdcall;
    IsHookRunning: function():Integer;stdcall;

  public
      sites: TList;
    realWallpaper:TImage;
    realWallpaperPath:string;
    realWallpaperBmp:TBitmap;

    { Public declarations }
    procedure LoadSites();
    procedure RefreshSelection();
    function GetListSelIndex():Integer;
    function GetSettingsFilePath():string;
    procedure ReadSettings();
    procedure WriteSettings();
    procedure UpdateWallpaper();
    procedure UpdateWallpaperItem(item:SiteItem);

  end;

  SiteItem = class(TObject)
      public
      url:String;
      bounds, oldBounds:TRect;
      refreshIntervalSeconds:Integer;
      bmp:TBitmap;
      browser:TWebBrowser;
      interval:integer;
      timer:TTimer;
      isLive:boolean;

      destructor Destroy; override;
      procedure CreateImage(host:TForm1);
      procedure Read(ini:TIniFile; sectionName:string);
      procedure Write(ini:TIniFile; sectionName:string);

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function PathAppend(dir:string; filename:string):string;
begin
  Result := IncludeTrailingBackSlash(dir) + filename;
end;

function TForm1.GetSettingsFilePath():string;
var
  buf:pchar;
begin
  GetMem(buf, 1024);

  ShGetFolderPath(0, CSIDL_APPDATA, 0 ,0, buf);
  Result := PathAppend(string(buf), 'avedesktopsites.ini');
  FreeMem(buf);

end;

procedure TForm1.ReadSettings();
var
  cnt, i:integer;
  ini:TIniFile;
  item:SiteItem;
begin
  ini := TIniFile.Create(GetSettingsFilePath());

  Timer2.Interval := ini.ReadInteger('global', 'RedrawLoopDelayMs', Timer2.Interval);
  timerGlobalRefresh.Interval := ini.ReadInteger('global', 'GlobalRefreshIntervalMs', timerGlobalRefresh.Interval);

  cnt := ini.ReadInteger('global', 'count', 0);
  if cnt > 0 then begin
//  showmessage('a');
    for i:=0 to cnt-1 do begin
      item := SiteItem.Create;
      item.Read(ini, 'item' + IntToStr(i));
      sites.add(item);
    end;
  end;

  ini.Free;
end;


procedure TForm1.WriteSettings();
var
  i:integer;
  ini:TIniFile;
begin
  ini := TIniFile.Create(GetSettingsFilePath());

  ini.WriteInteger('global', 'count', sites.Count);
  for i := 0 to sites.count -1 do begin
    SiteItem(sites.Items[i]).Write(ini, 'item' + IntToStr(i));
  end;


  ini.Free;
end;

procedure SiteItem.Read(ini:TIniFile; sectionName:string);
begin
  url := ini.ReadString(sectionName, 'url', '');
  interval := ini.ReadInteger(sectionName, 'interval', 3600);
  bounds.Left := ini.ReadInteger(sectionName, 'left', 0);
  bounds.Top := ini.ReadInteger(sectionName, 'top', 0);
  bounds.Right := ini.ReadInteger(sectionName, 'width', 100)  + bounds.Left;
  bounds.Bottom := ini.ReadInteger(sectionName, 'height', 100) + bounds.Top;
  isLive := ini.ReadBool(sectionName, 'isLive', false);
end;

procedure SiteItem.Write(ini:TIniFile; sectionName:string);
var
  w,h:integer;
begin
  w := bounds.right - bounds.left;
  h := bounds.Bottom - bounds.Top;

  ini.WriteString(sectionName, 'url', url);
  ini.WriteInteger(sectionName, 'interval', interval);
  ini.WriteInteger(sectionName, 'left', bounds.left);
  ini.WriteInteger(sectionName, 'top', bounds.top);
  ini.WriteInteger(sectionName, 'width', w);
  ini.WriteInteger(sectionName, 'height', h);
  ini.WriteBool(sectionName, 'isLive', isLive)


end;

destructor SiteItem.Destroy;
begin
  if timer <> nil then
    timer.Destroy;

  if browser <> nil then
    browser.Destroy;


  if bmp <> nil then
    bmp.Destroy;

  inherited;
end;

procedure SiteItem.CreateImage(host:TForm1);
begin
  if browser = nil then begin
    browser := TWebBrowser.Create(host);
    TWinControl(browser).Parent := host;
    TWinControl(browser).Visible := false;
    browser.Visible := false;
    ShowWindow(browser.Handle, SW_HIDE);
   // SetParent(browser.Handle, 0);
    SetParent(browser.Handle, host.Handle);
    browser.Left := 2000;
    browser.top := 2000;
    browser.Visible := false;
    browser.Tag := Integer(self);
  end;

  if timer = nil then begin
    timer := TTimer.Create(host);
  end;

  timer.Enabled := false;
  timer.Interval := interval * 1000;
  timer.OnTimer := host.Timer1Timer;
  timer.Tag := Integer(self);
  timer.Enabled := true;

  browser.Tag := Integer(self);
  browser.Width := bounds.right - bounds.left;
  browser.Height:= bounds.Bottom - bounds.Top;

  browser.OnDocumentComplete := host.WebBrowser1DocumentComplete;

  if not browser.Busy then
    browser.Navigate(url);
//  ShowMessage('t');

end;

function TForm1.GetListSelIndex:Integer;
var
  i:integer;
begin
    for i := 0 to lbSites.count -1 do begin
      if lbSites.Selected[i] then begin
        Result := i;
        exit;
      end;
    end;
    Result := -1;
end;

procedure TForm1.RefreshSelection;
var
  selIndex : integer;
  item : SiteItem;
  hasItem : boolean;
begin
    selIndex := GetListSelIndex();
    hasItem := selIndex <> -1;

    editURL.Enabled := hasItem;
    groupPosSize.Enabled := hasItem;
    spinLeft.Enabled := hasItem;
    spinTop.Enabled := hasItem;
    spinWidth.Enabled := hasItem;
    spinHeight.Enabled := hasItem;
    panData.Enabled := hasItem;
    butRemove.Enabled := hasItem;
    spinInterval.Enabled := hasItem;
    checkIsLive.Enabled := hasItem;

  if not hasItem then begin
      editURL.Text := '';
  end else begin
    item := SiteItem(sites.items[selIndex]);
    editURL.Text := item.url;
    spinLeft.Value := item.bounds.Left;
    spinTop.Value := item.bounds.Top;
    spinWidth.Value := item.bounds.Right - item.bounds.Left;
    spinHeight.Value := item.bounds.Bottom - item.bounds.Top;
    spinInterval.Value := item.interval;
    checkIsLive.Checked := item.isLive;
  end;

  imgPreview.Invalidate;
end;

procedure TForm1.LoadSites;
begin
  sites := TList.Create;
  ReadSettings();
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
  buf:pchar;
  rc:TRect;
  dllPath:string;
  defv, pm:hwnd;
begin
  pm := FindWindow('progman', nil);
  defv := FindWindowEx(pm, 0, 'SHELLDLL_DefView', nil);

  SetWindowLong(Application.Handle, GWL_EXSTYLE,
  GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW
  or WS_EX_TOOLWINDOW);

  datafrm := TFrmData.create(nil);
  datafrm.Width := Screen.Width;
  datafrm.Height := Screen.Height;

  paintMsg := RegisterWindowMessage('AvePaintMePlease');
  dllPath := PathAppend(ExtractFileDir(Application.ExeName), 'desktophook.dll');
  hMod := LoadLibrary(pchar(dllPath));
  if hMod = 0 then begin
    TaskMessage(self, 'Could not load desktophook.');
  end;

  @StartHook := GetProcAddress(hMod, 'StartHook');
  @StopHook  := GetProcAddress(hMod, 'StopHook');
  @IsHookRunning := GetProcAddress(hMod, 'IsHookRunning');

  datafrm.Left := -32000;
  datafrm.Visible := true;
  SetWindowPos(datafrm.Handle, HWND_TOPMOST,0,0,0,0, SWP_NOSIZE or SWP_NOMOVE);
  if @StartHook <> nil then begin
    if StartHook(hMod, datafrm.Handle) = 0 then begin
      TaskMessage(self, 'Could not start hook.');
    end;
  end else begin
    TaskMessage(self, 'Could not load hook: entry point StartHook not found');
  end;


  Visible := false;
  Hide();
  GetMem(buf, 1024);
  SystemParametersInfo(115, 1024, pointer(buf),  0);
  realWallpaper := TImage.Create(self);
  realWallpaper.Visible := false;
  realWallpaper.AutoSize := true;
  realWallpaperPath := string(buf);
  try
    realWallpaper.Picture.LoadFromFile(realWallpaperPath);
    realWallpaperBmp := TBitmap.Create;
    realWallpaperBmp.Width := Screen.Width;
    realWallpaperBmp.Height := Screen.Height;
    rc.Left := 0;
    rc.Top := 0;
    rc.Right := realWallpaperBmp.Width;
    rc.Bottom := realWallpaperBmp.Height;
    SetStretchBltMode(realWallpaperBmp.Canvas.Handle, HALFTONE);
    realWallpaperBmp.Canvas.StretchDraw(rc, realWallpaper.Picture.Graphic);
  finally
  end;
  FreeMem(buf);


  OleInitialize(nil);
  LoadSites();
  if sites = nil then
    exit;

  for i := 0 to sites.Count -1 do begin
      lbSites.AddItem(SiteItem(sites.Items[i]).url, nil);
  end;

  for i:=0 to sites.Count -1 do begin
          SiteItem(sites.Items[i]).CreateImage(self);
  end;

  RefreshSelection();

end;

procedure TForm1.butAddClick(Sender: TObject);
var
  item:SiteItem;
begin
  item := SiteItem.Create;
  item.url := 'http://www.howtogeek.com';
  item.interval := 3600;
  item.bounds.Right := 200;
  item.bounds.Bottom := 200;
  sites.Add(item);
  lbSites.AddItem(item.url, nil);
  lbSites.Selected[lbSites.Count-1] := true;
  RefreshSelection();
  editURL.SetFocus;
end;

procedure TForm1.ButtonRemoveClick(Sender: TObject);
var
  i:Integer;
begin
  if lbSites.SelCount = 0 then
    exit;

  if TaskDialog(self, 'Desktop Sites', 'Remove the selected site?',
    'When a site is removed, it will no longer show up on the desktop.',
    TD_YES + TD_NO, TD_ICON_QUESTION) = mrYes then begin
            for i := 0 to lbSites.count-1 do begin
              if lbSites.Selected[i] then begin

                SiteItem(sites.items[i]).Free;
                sites.Delete(i);
                lbSites.Items.Delete(i);
                if lbSites.Count > 0 then begin
                      if i >= lbSites.Count then
                        lbSites.Selected[lbSites.Count - 1] := true
                      else
                        lbSites.Selected[i] := true;
                end;
                WriteSettings();
                RefreshSelection();
                UpdateWallpaper();
                exit;
              end;
            end;
    end;


end;

procedure TForm1.lbSitesClick(Sender: TObject);
begin
  RefreshSelection();
end;

procedure TForm1.editURLChange(Sender: TObject);
  var selIndex : Integer;
begin
  selIndex := GetListSelIndex();
  if selIndex = -1 then exit;

  lbSites.Items[selIndex] := editURL.text;
  SiteItem(sites.items[selIndex]).url := editURL.text;

end;

procedure TForm1.butApplyClick(Sender: TObject);
var
  item:SiteItem;
  selIndex:integer;
begin

  selIndex := GetListSelIndex();
  if selIndex = -1 then exit;

  item := sites.items[selIndex];

  item.bounds.left := spinLeft.Value;
  item.bounds.top  := spinTop.Value;
  item.bounds.Right:= spinLeft.Value + spinWidth.Value;
  item.bounds.Bottom:=spinTop.Value + spinHeight.Value;
  item.interval := spinInterval.Value;
  item.isLive := checkIsLive.Checked;

  item.url := editURL.Text;
  item.CreateImage(self);

  WriteSettings();

end;

function WebBrowserScreenShot(const wb: TWebBrowser):TBitmap;
var
  viewObject : IViewObject;
  r : TRect;
  bitmap : TBitmap;
  body:IHTMLBodyElement;
  doc:IHTMLDocument2;
begin
  Result := nil;

  if wb.Document <> nil then
  begin
    doc := wb.Document as IHTMLDocument2;
    body := doc.body as IHTMLBodyElement;
    body.leftMargin := 0;
    body.topMargin := 0;
    body.scroll := 'no';
    doc.body.style.border := 'none';
//    doc.body.style.overflow := 'none';
    wb.Document.QueryInterface(IViewObject, viewObject) ;
    if Assigned(viewObject) then
    try
      bitmap := TBitmap.Create;

        r := Rect(0, 0, wb.Width, wb.Height) ;

        bitmap.Height := wb.Height;
        bitmap.Width := wb.Width;

        viewObject.Draw(DVASPECT_CONTENT, 1, nil, nil, 0, bitmap.Canvas.Handle, @r, nil, nil, 0) ;

        Result := bitmap;
    finally
      viewObject._Release;
    end;
  end;
end;

procedure TForm1.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  browser:TWebBrowser;
  item:SiteItem;
  selIndex : integer;
begin
  browser := TWebBrowser(ASender);
  item := SiteItem(browser.Tag);



  //item.bmp := WebBrowserScreenShot(browser);

    item.oldBounds := item.Bounds;

  UpdateWallpaperItem(item);

  selIndex := GetListSelIndex();
  if selIndex <> -1 then begin
    if sites[selIndex] = item then begin
      if (item.bmp <> nil) then begin
        item.bmp.Destroy;
        item.bmp := nil;
      end;

      if (item.browser <> nil) then
        item.bmp := WebBrowserScreenShot(item.browser);

      imgPreview.Invalidate();
    end;
  end;
end;

procedure TForm1.imgPreviewPaint(Sender: TObject);
var
  selIndex:integer;
  item:SiteItem;
  rc:TRect;
begin
  selIndex := GetListSelIndex();
  if selIndex = -1 then exit;
  item := sites.items[selIndex];


  rc.Left := 0;
  rc.Right := imgPreview.Width;
  rc.Bottom := imgPreview.Height;
  rc.Top:= 0;

  if item.bmp <> nil then begin
    SetStretchBltMode(imgPreview.Canvas.Handle, HALFTONE);
    imgPreview.Canvas.StretchDraw(rc, item.bmp);
  end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  item:SiteItem;
begin
  item := SiteItem(TTimer(Sender).Tag);
  item.CreateImage(self);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // realWallpaperPath
    //SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, pChar(realWallpaperPath), SPIF_SENDCHANGE);

    if @StopHook <> nil then begin
        StopHook();
    end;

    if hMod <> 0 then begin
      FreeLibrary(hMod);
    end;

    sites.Free;

    updatewallpaper();

end;

procedure TForm1.butHideClick(Sender: TObject);
begin
  Hide();
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
    Show();
end;

procedure TForm1.timerGlobalRefreshTimer(Sender: TObject);
var
  item:siteitem;
  didUpdate:boolean;
  i:integer;
begin

  didUpdate := false;
  try
    for i := 0 to sites.count-1 do begin
      item := SiteItem(sites.Items[i]);
      try
        if (item <> nil) and (item.browser <> nil) and (item.isLive) then begin
  //        item.bmp.Destroy;
    //      item.bmp := WebBrowserScreenShot(item.browser);
         // wallpaper.Canvas.FillRect(item.bounds);
      //    wallpaper.Canvas.Draw(item.bounds.left,item.bounds.top, item.bmp);
//          wallpaper.Canvas.CopyRect(item.bounds, item.bmp.Canvas, item.bounds);
          updateWallpaperItem(item);
          didUpdate := true;
        end;
      finally
      end;
    end;
  finally
  end;

  if not didUpdate then exit;

//  UpdateWallpaper();
end;

procedure TForm1.UpdateWallpaperItem(item:SiteItem);
var
  pm, defview, lv:hwnd;
begin
  pm := FindWindow('progman', nil);
  if pm = 0 then exit;
  defview:=FindWindowEx(pm, 0, 'SHELLDLL_DefView', nil);
  if defview = 0 then exit;
  lv := FindWindowEx(defview, 0, 'SysListView32', nil);
  if lv = 0 then exit;
  InvalidateRect(lv, @item.bounds, true);
end;

procedure TForm1.UpdateWallpaper();
var
//  wallPaperPath:string;
  //buf:pchar;
  pm, defview, lv:hwnd;
begin
    //GetMem(buf, 1024);
    //ShGetFolderPath(0, CSIDL_APPDATA, 0 ,0, buf);
  //  wallPaperPath := PathAppend(string(buf), 'avedesktopsites.bmp');
    //FreeMem(buf);
    //wallpaper.SaveToFile(wallpaperPath);
//    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, pChar(wallpaperPath), SPIF_SENDCHANGE);
  pm := FindWindow('progman', nil);
  defview:=FindWindowEx(pm, 0, 'SHELLDLL_DefView', nil);
  lv := FindWindowEx(defview, 0, 'SysListView32', nil);
  InvalidateRect(lv, nil, true);

end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  timerGlobalRefresh.Enabled := true;
  timer2.Enabled := false;
end;

procedure TForm1.WebBrowser1NavigateError(ASender: TObject;
  const pDisp: IDispatch; var URL, Frame, StatusCode: OleVariant;
  var Cancel: WordBool);
begin
//  TWebBrowser(ASender).Refresh;
end;

procedure TForm1.TrayIcon1Click(Sender: TObject);
begin
  Show();
  SwitchToThisWindow(Handle,false);
//  SetWindowPos(Handle, HWND_NOT
  SetFocus();
end;

end.
