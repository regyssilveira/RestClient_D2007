object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
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
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 846
    Height = 175
    Align = alTop
    Caption = 'GroupBox1'
    TabOrder = 0
    object BtnUATObterToken: TButton
      Left = 16
      Top = 24
      Width = 219
      Height = 33
      Caption = 'UAT Obter Token (somente para testes)'
      TabOrder = 0
      OnClick = BtnUATObterTokenClick
    end
    object Button2: TButton
      Left = 609
      Top = 24
      Width = 219
      Height = 49
      Caption = 'Teste Servidor Publico'
      TabOrder = 1
      OnClick = Button2Click
    end
    object BtnUATCREDIT: TButton
      Left = 16
      Top = 63
      Width = 219
      Height = 33
      Caption = 'UAT Executar Fluxo CREDIT'
      TabOrder = 2
      OnClick = BtnUATCREDITClick
    end
    object BtnUATSaldo: TButton
      Left = 241
      Top = 24
      Width = 219
      Height = 33
      Caption = 'UAT GET SALDO'
      TabOrder = 3
      OnClick = BtnUATSaldoClick
    end
    object BtnUATDebit: TButton
      Left = 16
      Top = 102
      Width = 219
      Height = 33
      Caption = 'UAT Executar Fluxo DEBIT'
      TabOrder = 4
      OnClick = BtnUATDebitClick
    end
  end
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 184
    Width = 846
    Height = 412
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitWidth = 836
    ExplicitHeight = 407
  end
end
