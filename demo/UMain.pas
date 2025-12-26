unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TFrmMain = class(TForm)
    GroupBox1: TGroupBox;
    BtnUATObterToken: TButton;
    BtnUATCREDIT: TButton;
    BtnUATSaldo: TButton;
    BtnUATDebit: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure BtnUATObterTokenClick(Sender: TObject);
    procedure BtnUATCREDITClick(Sender: TObject);
    procedure BtnUATSaldoClick(Sender: TObject);
    procedure BtnUATDebitClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Logar(const AMsg: string);
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  SuperObject,
  RestClient.Interfaces,
  RestClient.Response,
  RestClient.Core,
  Service.Transaction;

const
  UrlAPI    = 'https://api.cre.uatesb.local/api/ce-core-banking-service/v1';
  UrlToken  = 'https://api.cre.uatesb.local/oauth/token';
  UsuarioWs = 'srvc.web-bff.service.uat';
  SenhaWs   = 'NB9w7J66*PG5h6Cg';

{$R *.dfm}

procedure TFrmMain.Logar(const AMsg: string);
begin
  Memo2.Lines.Add('');
  Memo2.Lines.Add(AMsg);
end;

procedure TFrmMain.BtnUATObterTokenClick(Sender: TObject);
var
  LClient: IRestClient;
  Token: String;
begin
  try
    LClient := TRestClient.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
    LClient.OnLog := Logar;

    Token := LClient.CreateRequest
      .ObterToken;

    Memo1.Lines.Text := Token;
  except
    on E: Exception do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Erro: ' + E.Message);
    end;
  end;
end;

procedure TFrmMain.BtnUATSaldoClick(Sender: TObject);
var
  LService: ITransactionService;
  LBalance: TBalanceDTO;
begin
  LService := TTransactionService.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
  LService.OnLog := Logar;

  try
    LBalance := LService.GetSaldo('0010261290', '00019', 'INTERCREDPJ');
    try
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Dados lidos da resposta:');
      Memo1.Lines.Add('balanceValue: '                 + FloatToStr(LBalance.BalanceValue));
      //Memo1.Lines.Add('balanceBlockedCheck: '          + FloatToStr(LBalance.BalanceBlockedCheck));
      //Memo1.Lines.Add('balanceBlockedAdministrative: ' + FloatToStr(LBalance.balanceBlockedAdministrative));
      //Memo1.Lines.Add('balanceBlockedJudicial: '       + FloatToStr(LBalance.BalanceBlockedJudicial));
      //Memo1.Lines.Add('balanceBlockedSpecial: '        + FloatToStr(LBalance.BalanceBlockedSpecial));
      //Memo1.Lines.Add('balanceProvisioned: '           + FloatToStr(LBalance.BalanceProvisioned));
      //Memo1.Lines.Add('valueLimit: '                   + FloatToStr(LBalance.ValueLimit));
      Memo1.Lines.Add('netBalanceValue: '              + FloatToStr(LBalance.NetBalanceValue));
    finally
      LBalance.Free;
    end;
  except
    on E: Exception do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Erro: ' + E.Message);
    end;
  end;
end;

procedure TFrmMain.BtnUATCREDITClick(Sender: TObject);
var
  LService: ITransactionService;
  OperationId: String;
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Operação de CREDITO');

  try
    LService := TTransactionService.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
    LService.OnLog := Logar;

    OperationId := LService.Credit(
     '0010261290',
     '00019',
     '03300974000189',
     '',
     'BIXXXXX',
     12599.11,
     Now,
    );

    Memo1.Lines.Add('OperationId: ' + OperationId);
  except
    on E: Exception do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Erro: ' + E.Message);
    end;
  end;

  // chamar o saldo somente para conferencia do teste
  BtnUATSaldo.Click;
end;

procedure TFrmMain.BtnUATDebitClick(Sender: TObject);
var
  LService: ITransactionService;
  OperationId: String;
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Operação de DEBITO');

  try
    LService := TTransactionService.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
    LService.OnLog := Logar;
    
    OperationId := LService.Debit(
     '0010261290',
     '00019',
     '03300974000189',
     '',
     'BIXXXXX',
     12599.11,
     Now,
    );

    Memo1.Lines.Add('OperationId: ' + OperationId);
  except
    on E: Exception do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Erro: ' + E.Message);
    end;
  end;

  // chamar o saldo somente para conferencia do teste
  BtnUATSaldo.Click;
end;

end.

