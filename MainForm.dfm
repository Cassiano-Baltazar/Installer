object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 175
  ClientWidth = 325
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 325
    Height = 25
    Align = alTop
    Caption = 'Run'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Log: TcxMemo
    Left = 0
    Top = 25
    Align = alClient
    TabOrder = 1
    Height = 133
    Width = 325
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 158
    Width = 325
    Height = 17
    Align = alBottom
    TabOrder = 2
  end
end
