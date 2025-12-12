unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;



type
  TForm1 = class(TForm)
    BtnUATObterToken: TButton;
    Button2: TButton;
    Memo1: TMemo;
    BtnUATCREDIT: TButton;
    BtnUATSaldo: TButton;
    BtnUATDebit: TButton;
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
  Form1: TForm1;

implementation

uses
  SuperObject,
  RestClient.Interfaces,
  RestClient.Response,
  RestClient.Core,
  Service.Transaction;

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
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

procedure TForm1.BtnUATObterTokenClick(Sender: TObject);
var
  LClient: IRestClient;
  Token: String;
begin
  LClient := TRestClient.Create(
    'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
    rtWinInet,
    'https://api.cre.uatesb.local/oauth/token',
    'srvc.ce.core.banking.service.uat',
    'K>9.V=n20T9vo!bn0>bbn'
  );
  Token := LClient.CreateRequest
    .ObterToken;

  Memo1.Lines.Text := Token;
end;

procedure TForm1.BtnUATSaldoClick(Sender: TObject);
var
  LService: ITransactionService;
  LBalance: TBalanceDTO;
begin
  LService := TTransactionService.Create(
    'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
    'https://api.cre.uatesb.local/oauth/token',
    'srvc.ce.core.banking.service.uat',
    'K>9.V=n20T9vo!bn0>bbn'
  );

  try
    LBalance := LService.GetSaldo('0010261290', '00019', 'INTERCREDPJ');
    try
      Memo1.Lines.Clear;
      Memo1.Lines.Add('Saldo: ' + FloatToStr(LBalance.Balance));
      Memo1.Lines.Add('Bloqueado: ' + FloatToStr(LBalance.BlockedBalance));
    finally
      LBalance.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

procedure TForm1.BtnUATDebitClick(Sender: TObject);
begin
//
end;

procedure TForm1.BtnUATCREDITClick(Sender: TObject);
var
  LClient: IRestClient;
  LResponse: IRestResponse;
  StrBody: string;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
  OperationId: String;
begin
  LClient := TRestClient.Create(
    'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
    rtWinInet,
    'https://api.cre.uatesb.local/oauth/token',
    'srvc.ce.core.banking.service.uat',
    'K>9.V=n20T9vo!bn0>bbn'
  );

  // chamar o transaction operations

  // chamar o transaction movement

  // se der erro ento chamar o

  JSonRequest := SO;
  JSonRequest.S['requestingService'] := 'ce-installment-amortization';
  JSonRequest.S['accountNumber']     := '0010261290';
  JSonRequest.S['description']       := 'Debit';

  ShowMessage(JSonRequest.AsJSon(True));

  LResponse := LClient.CreateRequest
    .Resource('/ransaction-dk/operation')
    .AddBody(JSonRequest)
    .Execute(rmGET);

  if LResponse.StatusCode <> 201 then
  begin
    raise Exception.Create('Erro ao cefetuar transao: ' + InttoStr(LResponse.StatusCode) + ' - ' + LResponse.Content)
  end
  else
  begin
    JsonResponse := LResponse.ContentAsJson;

    Memo1.Lines.Text := JsonResponse.S['sagaOperationId'];
  end;
end;

end.
