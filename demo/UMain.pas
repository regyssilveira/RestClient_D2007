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
    procedure FormCreate(Sender: TObject);
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
  Service.Transaction,
  Service.Transaction.DTO;

const
  UrlAPI    = 'https://api.cre.uatesb.local/api/ce-core-banking-service/v1';
  UrlToken  = 'https://api.cre.uatesb.local/oauth/token';
  UsuarioWs = 'srvc.web-bff.service.uat';
  SenhaWs   = 'NB9w7J66*PG5h6Cg';

  // dados para testes
  ContaNumero = '0010261290';
  AgenciaNumero = '00019';
  Usuario = 'BIXXXXX';

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
  LBalance: IBalanceDTO;
begin
  LService := TTransactionService.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
  LService.OnLog := Logar;

  try
    LBalance := LService.GetSaldo(ContaNumero, AgenciaNumero);
    if LBalance <> nil then
    begin
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
    end;
  except
    on E: Exception do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Erro: ' + E.Message);
    end;
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
end;

procedure TFrmMain.BtnUATCREDITClick(Sender: TObject);
var
  LService: ITransactionService;
  LTransaction: ITransactionDTO;
  NumeroDocumento: String;
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Operao de CREDITO');

  // numero fake para testes
  NumeroDocumento := FormatDateTime('YYYYMMDDHHMMSSZZZ', NOW);

  try
    LService := TTransactionService.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
    LService.OnLog := Logar;

    LTransaction := LService.Credit(
      ContaNumero,
      AgenciaNumero,
      NumeroDocumento,
      '',
      Usuario,
      12599.11,
      Now
    );

    if LTransaction <> nil then
      Memo1.Lines.Add('SagaOperationId: ' + LTransaction.SagaOperationId + ', OperationNumber: ' + LTransaction.OperationNumber);
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
  LTransaction: ITransactionDTO;
  NumeroDocumento: String;  
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Operao de DEBITO');

  // numero fake para testes
  NumeroDocumento := FormatDateTime('YYYYMMDDHHMMSSZZZ', NOW);

  try
    LService := TTransactionService.Create(UrlAPI, UrlToken, UsuarioWs, SenhaWs);
    LService.OnLog := Logar;
    
    LTransaction := LService.Debit(
      ContaNumero,
      AgenciaNumero,
      NumeroDocumento,
      '',
      Usuario,
      12599.11,
      Now
    );

    if LTransaction <> nil then
      Memo1.Lines.Add('SagaOperationId: ' + LTransaction.SagaOperationId + ', OperationNumber: ' + LTransaction.OperationNumber);
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
