unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmMain = class(TForm)
    GroupBox1: TGroupBox;
    BtnUATObterToken: TButton;
    Button2: TButton;
    BtnUATCREDIT: TButton;
    BtnUATSaldo: TButton;
    BtnUATDebit: TButton;
    Memo1: TMemo;
    procedure BtnUATObterTokenClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtnUATCREDITClick(Sender: TObject);
    procedure BtnUATSaldoClick(Sender: TObject);
    procedure BtnUATDebitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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

{$R *.dfm}

procedure TFrmMain.Button2Click(Sender: TObject);
var
  LClient: IRestClient;
  LResponse: IRestResponse;
begin
  LClient := TRestClient.Create(
    'https://ce-api.bancointer.com.br/oauth/token',
    rtIndy
  );

  LResponse := LClient.CreateRequest
    .AddPart('grant_type', 'client_credentials')
    .AddPart('client_id', '7a0c6e2f-aeb1-4d50-bcf1-5df1c61a9668')
    .AddPart('client_secret', '95f46fd7-882a-4890-8402-af6b5669566a')
    .AddPart('scope', 'ce-imp-api:write ce-imp-api:read')
    .Execute(rmPOST);

  ShowMessage(LResponse.Content);
end;

procedure TFrmMain.BtnUATObterTokenClick(Sender: TObject);
var
  LClient: IRestClient;
  Token: String;
begin
  try
    LClient := TRestClient.Create(
      'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
      rtWinInet,
      'https://api.cre.uatesb.local/oauth/token',
      'srvc.web-bff.service.uat',
      'NB9w7J66*PG5h6Cg'
    );
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
  LService := TTransactionService.Create(
    'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
    'https://api.cre.uatesb.local/oauth/token',
    'srvc.web-bff.service.uat',
    'NB9w7J66*PG5h6Cg'
  );

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
    LService := TTransactionService.Create(
      'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
      'https://api.cre.uatesb.local/oauth/token',
      'srvc.web-bff.service.uat',
      'NB9w7J66*PG5h6Cg'
    );

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
    LService := TTransactionService.Create(
      'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
      'https://api.cre.uatesb.local/oauth/token',
      'srvc.web-bff.service.uat',
      'NB9w7J66*PG5h6Cg'
    );

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

