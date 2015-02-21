object Form1: TForm1
  Left = 254
  Top = 180
  Width = 454
  Height = 527
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Ave'#39's DesktopSites'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object panContents: TPanel
    Left = 0
    Top = 0
    Width = 438
    Height = 491
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 438
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Sites'
    end
    object Splitter1: TSplitter
      Left = 0
      Top = 193
      Width = 438
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ResizeStyle = rsUpdate
    end
    object Panel1: TPanel
      Left = 0
      Top = 450
      Width = 438
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      Color = clAppWorkSpace
      TabOrder = 0
      object Label8: TLabel
        Left = 216
        Top = 16
        Width = 53
        Height = 13
        Caption = 'Version 1.6'
      end
      object butApply: TButton
        Left = 344
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Apply'
        TabOrder = 0
        OnClick = butApplyClick
      end
      object butHide: TButton
        Left = 9
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Hide'
        TabOrder = 1
        OnClick = butHideClick
      end
    end
    object panData: TPanel
      Left = 0
      Top = 196
      Width = 438
      Height = 254
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object imgPreview: TPaintBox
        Left = 233
        Top = 50
        Width = 150
        Height = 150
        OnPaint = imgPreviewPaint
      end
      object Label6: TLabel
        Left = 8
        Top = 198
        Width = 77
        Height = 14
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Update interval '
      end
      object Label7: TLabel
        Left = 156
        Top = 198
        Width = 46
        Height = 13
        Caption = '(seconds)'
      end
      object editURL: TLabeledEdit
        Left = 32
        Top = 22
        Width = 353
        Height = 21
        EditLabel.Width = 22
        EditLabel.Height = 13
        EditLabel.Caption = 'URL'
        LabelPosition = lpLeft
        TabOrder = 0
        OnChange = editURLChange
      end
      object groupPosSize: TGroupBox
        Left = 32
        Top = 44
        Width = 137
        Height = 141
        Caption = 'Position and Size'
        TabOrder = 1
        object Label2: TLabel
          Left = 11
          Top = 26
          Width = 39
          Height = 14
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Left'
        end
        object Label3: TLabel
          Left = 11
          Top = 53
          Width = 39
          Height = 14
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Top'
        end
        object Label4: TLabel
          Left = 11
          Top = 81
          Width = 39
          Height = 14
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Width'
        end
        object Label5: TLabel
          Left = 11
          Top = 109
          Width = 39
          Height = 14
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Height'
        end
        object spinLeft: TSpinEdit
          Left = 56
          Top = 23
          Width = 60
          Height = 22
          AutoSize = False
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object spinTop: TSpinEdit
          Left = 56
          Top = 50
          Width = 60
          Height = 22
          AutoSize = False
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 0
        end
        object spinWidth: TSpinEdit
          Left = 56
          Top = 78
          Width = 60
          Height = 22
          AutoSize = False
          MaxValue = 0
          MinValue = 0
          TabOrder = 2
          Value = 0
        end
        object spinHeight: TSpinEdit
          Left = 56
          Top = 106
          Width = 60
          Height = 22
          AutoSize = False
          MaxValue = 0
          MinValue = 0
          TabOrder = 3
          Value = 0
        end
      end
      object spinInterval: TSpinEdit
        Left = 91
        Top = 195
        Width = 60
        Height = 22
        AutoSize = False
        MaxValue = 0
        MinValue = 0
        TabOrder = 2
        Value = 0
      end
      object checkIsLive: TCheckBox
        Left = 93
        Top = 224
        Width = 97
        Height = 17
        Caption = 'Is live item'
        TabOrder = 3
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 13
      Width = 438
      Height = 180
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object Panel3: TPanel
        Left = 396
        Top = 0
        Width = 42
        Height = 180
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object butAdd: TButton
          Left = 6
          Top = -1
          Width = 30
          Height = 25
          Hint = 'Add a new Site'
          Caption = '+'
          TabOrder = 0
          OnClick = butAddClick
        end
        object butRemove: TButton
          Left = 6
          Top = 32
          Width = 30
          Height = 25
          Hint = 'Remove the current selected site'
          Caption = '-'
          TabOrder = 1
          OnClick = ButtonRemoveClick
        end
      end
      object lbSites: TListBox
        Left = 0
        Top = 0
        Width = 396
        Height = 180
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
        OnClick = lbSitesClick
      end
    end
  end
  object butCapture: TPanel
    Left = 136
    Top = 240
    Width = 185
    Height = 41
    Caption = 'butCapture'
    TabOrder = 1
    Visible = False
  end
  object XPManifest1: TXPManifest
    Left = 264
    Top = 152
  end
  object TrayIcon1: TTrayIcon
    Active = True
    Animate = False
    ShowDesigning = False
    Icon.Data = {
      0000010001001010000001002000680400001600000028000000100000002000
      0000010020000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000010000000B000000200000002E0000
      002E000000200000000B00000001000000000000000000000000000000000000
      0000000000000000000000000000000000050000002A000000680000008B0000
      008B000000680000002A00000005000000000000000000000000000000000000
      0000000000000000000000000000B8001E1DE7535EDDBC0C0CFFAA005AFFA400
      18F32200059F0000004A0000000E000000000000000000000000000000000000
      0000000000000000000000000000ECA9925FBC7D73FF6D1600FFC9246EFF860C
      00FF490005C10000005B00000016000000000000000000000000000000000000
      0000000000000000000000000000FF7E898DBC7874FFFF2602FFEA3594FFB302
      02FF7A000CD5000000670000001C000000000000000000000000000000000000
      0000000000000000000000000004FF4C7C97FFAED9FFFFABD5FFFFACD4FFFFAB
      D4FFAB1B3BDA0000007F0000002E000000040000000000000000000000000000
      0000000000000000000200000019FF7DA5E0FFB3CDFFFFB6CBFFFFB7CAFFFFB7
      CAFFFF5C81F30000009F00000058000000190000000200000000000000000000
      0000000000000000000DDD335489FFB9C8FFFFBEC4FFFFC1C1FFFFC3C1FFFFC2
      C1FFFFB8BDFF93182AD10000008B000000420000000D00000000000000000000
      000000000000D11F3E4AFFA5B4F6FFC9C9FFFFCDC7FFFFD8D3FFFFDCD7FFFFD9
      D4FFFFD0CAFFFFA1A1FB510D16BD0000006F0000002000000000000000000000
      000000000000FF8297CAFFDFE1FFFFEBE8FFFFE3E0FFFFEDEBFFFFF1EFFFFFEE
      ECFFFFE6E3FFFFD6D1FFF25C62EE000000890000002D00000000000000000000
      000000000000FFA3AFFFFFDFDDFFFFE6E3FFFFF0EEFFFFF8F8FFFFFBFBFFFFF9
      F9FFFFF3F1FFFFE5E1FFFFB2B4FF0000008F0000003000000000000000000000
      000000000000FFB8BEFFFFF1EFFFFFEAE7FFFFF6F5FFFFFDFDFFFFFFFFFFFFFE
      FDFFFFF8F7FFFFECE9FFFFB8BBFF000000860000002B00000000000000000000
      000000000000FFA4ADFFFFF1EFFFFFF1EFFFFFF6F5FFFFFDFDFFFFFFFFFFFFFE
      FDFFFFF8F7FFFFECE9FFFFB0B5FF000000650000001C00000000000000000000
      000000000000FF8192A3FFDBD7FFFFFAF9FFFFF1EFFFFFF8F8FFFFFBFBFFFFF9
      F9FFFFF3F1FFFFE5E2FFF14D5ECB000000320000000900000000000000000000
      000000000000FF456311FFA4A8D2FFE8E5FFFFF7F6FFFFEFEDFFFFF1EFFFFFEE
      ECFFFFE6E3FFFF999DE158000E3D0000000D0000000100000000000000000000
      00000000000000000000FF456311FF899393FFB2B5F1FFD5D2FFFFD5D2FFFFB4
      B8F2FF707DA1880016280000000800000001000000000000000000000000F00F
      0000F00F0000F00F0000F00F0000F00F0000E0070000C0030000C0030000C003
      0000C0030000C0030000C0030000C0030000C0030000C0030000E0070000}
    ToolTip = 'Ave'#39's DesktopSites'
    OnClick = TrayIcon1Click
    OnDblClick = TrayIcon1DblClick
    Left = 216
    Top = 93
  end
  object timerGlobalRefresh: TTimer
    Enabled = False
    OnTimer = timerGlobalRefreshTimer
    Left = 256
    Top = 280
  end
  object Timer2: TTimer
    Interval = 5000
    OnTimer = Timer2Timer
    Left = 208
    Top = 296
  end
end
