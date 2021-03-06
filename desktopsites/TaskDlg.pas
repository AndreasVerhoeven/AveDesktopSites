unit TaskDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan;

const
TD_ICON_BLANK = 100;
TD_ICON_WARNING = 101;
TD_ICON_QUESTION = 102;
TD_ICON_ERROR = 103;
TD_ICON_INFORMATION = 104;
TD_ICON_BLANK_AGAIN = 105;
TD_ICON_SHIELD = 106;

TD_OK = 1;
TD_YES = 2;
TD_NO = 4;
TD_CANCEL = 8;
TD_RETRY = 16;
TD_CLOSE = 32;

DLGRES_OK = 1;
DLGRES_CANCEL = 2;
DLGRES_RETRY = 4;
DLGRES_YES = 6;
DLGRES_NO = 7;
DLGRES_CLOSE = 8;

function TaskDialog(AForm: TCustomForm; ATitle, ADescription, AContent: string; Buttons,Icon: integer): integer;
procedure TaskMessage(AForm: TCustomForm; AMessage: string);

implementation

function TaskDialog(AForm: TCustomForm; ATitle, ADescription, AContent: string; Buttons,Icon: integer): integer;
var
  VerInfo: TOSVersioninfo;
  DLLHandle: THandle;
  res: integer;
  wTitle,wDescription,wContent: array[0..1024] of widechar;
  Btns: TMsgDlgButtons;
  DlgType: TMsgDlgType;
  TaskDialogProc: function(HWND: THandle; hInstance: THandle; cTitle, cDescription, cContent: pwidechar; Buttons: Integer; Icon: integer;
       ResButton: pinteger): integer; cdecl stdcall;

begin
  Result := 0;

  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(verinfo);

  if (verinfo.dwMajorVersion >= 6) then
  begin
    DLLHandle := LoadLibrary('comctl32.dll');
    if DLLHandle >= 32 then
    begin
      @TaskDialogProc := GetProcAddress(DLLHandle,'TaskDialog');

      if Assigned(TaskDialogProc) then
      begin
        StringToWideChar(ATitle, wTitle, sizeof(wTitle));
        StringToWideChar(ADescription, wDescription, sizeof(wDescription));
        StringToWideChar(AContent, wContent, sizeof(wContent));
        TaskDialogProc(AForm.Handle, 0, wTitle, wDescription, wContent, Buttons,Icon,@res);

        Result := mrOK;

        case res of
        DLGRES_CANCEL : Result := mrCancel;
        DLGRES_RETRY : Result := mrRetry;
        DLGRES_YES : Result := mrYes;
        DLGRES_NO : Result := mrNo;
        DLGRES_CLOSE : Result := mrAbort;
        end;
      end;
      FreeLibrary(DLLHandle);
    end;
  end
  else
  begin
    Btns := [];
    if Buttons and TD_OK = TD_OK then
      Btns := Btns + [MBOK];

    if Buttons and TD_YES = TD_YES then
      Btns := Btns + [MBYES];

    if Buttons and TD_NO = TD_NO then
      Btns := Btns + [MBNO];

    if Buttons and TD_CANCEL = TD_CANCEL then
      Btns := Btns + [MBCANCEL];

    if Buttons and TD_RETRY = TD_RETRY then
      Btns := Btns + [MBRETRY];

    if Buttons and TD_CLOSE = TD_CLOSE then
      Btns := Btns + [MBABORT];

    DlgType := mtCustom;

    case Icon of
    TD_ICON_WARNING : DlgType := mtWarning;
    TD_ICON_QUESTION : DlgType := mtConfirmation;
    TD_ICON_ERROR : DlgType := mtError;
    TD_ICON_INFORMATION: DlgType := mtInformation;
    end;

    Result := MessageDlg(AContent, DlgType, Btns, 0);
  end;
end;

procedure TaskMessage(AForm: TCustomForm; AMessage: string);
begin
  TaskDialog(AForm, '', '', AMessage, TD_OK, 0);
end;

end.
 