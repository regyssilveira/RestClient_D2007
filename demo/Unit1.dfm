object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 599
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 219
    Height = 33
    Caption = 'UAT Obter Token'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 625
    Top = 8
    Width = 219
    Height = 49
    Caption = 'Teste Servidor Publico'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 184
    Width = 836
    Height = 407
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Button3: TButton
    Left = 8
    Top = 47
    Width = 219
    Height = 33
    Caption = 'UAT Executar Fluxo'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 86
    Width = 219
    Height = 33
    Caption = 'UAT GET SALDO'
    TabOrder = 4
    OnClick = Button4Click
  end
end
