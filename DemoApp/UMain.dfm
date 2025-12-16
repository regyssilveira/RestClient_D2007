object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'App Demo RestClient'
  ClientHeight = 524
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 788
    Height = 350
    ActivePage = TabAuth
    Align = alTop
    TabOrder = 0
    object TabBasic: TTabSheet
      Caption = 'CRUD B'#225#161'sico (JSONPlaceholder)'
      object BtnGetTasks: TButton
        Left = 16
        Top = 16
        Width = 129
        Height = 25
        Caption = 'GET /posts'
        TabOrder = 0
        OnClick = BtnGetTasksClick
      end
      object BtnCreateTask: TButton
        Left = 16
        Top = 47
        Width = 129
        Height = 25
        Caption = 'POST /posts'
        TabOrder = 1
        OnClick = BtnCreateTaskClick
      end
      object BtnUpdateTask: TButton
        Left = 16
        Top = 78
        Width = 129
        Height = 25
        Caption = 'PUT /posts/1'
        TabOrder = 2
        OnClick = BtnUpdateTaskClick
      end
      object BtnDeleteTask: TButton
        Left = 16
        Top = 109
        Width = 129
        Height = 25
        Caption = 'DELETE /posts/1'
        TabOrder = 3
        OnClick = BtnDeleteTaskClick
      end
      object MemoBasicResult: TMemo
        Left = 168
        Top = 16
        Width = 593
        Height = 297
        ScrollBars = ssVertical
        TabOrder = 4
      end
    end
    object TabAdvanced: TTabSheet
      Caption = 'Avan'#231'ado (HTTPBin)'
      ImageIndex = 1
      object BtnUpload: TButton
        Left = 16
        Top = 16
        Width = 129
        Height = 25
        Caption = 'Upload Multipart'
        TabOrder = 0
        OnClick = BtnUploadClick
      end
      object BtnCustomHeaders: TButton
        Left = 16
        Top = 47
        Width = 129
        Height = 25
        Caption = 'Headers Customizados'
        TabOrder = 1
        OnClick = BtnCustomHeadersClick
      end
      object MemoAdvResult: TMemo
        Left = 168
        Top = 16
        Width = 593
        Height = 297
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
    object TabAuth: TTabSheet
      Caption = 'Autentica'#231#227'o'
      ImageIndex = 2
      object Label1: TLabel
        Left = 16
        Top = 56
        Width = 81
        Height = 13
        Caption = 'Token de Acesso'
      end
      object BtnGetToken: TButton
        Left = 16
        Top = 16
        Width = 129
        Height = 25
        Caption = 'Obter Mock Token'
        TabOrder = 0
        OnClick = BtnGetTokenClick
      end
      object MemoAuthToken: TMemo
        Left = 16
        Top = 75
        Width = 745
        Height = 238
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 356
    Width = 788
    Height = 168
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
