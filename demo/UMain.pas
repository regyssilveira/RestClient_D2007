unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;



type
  TFrmMain = class(TForm)
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

procedure TFrmMain.BtnUATSaldoClick(Sender: TObject);
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

      Memo1.Lines.Add('Dados lidos da resposta:');
      Memo1.Lines.Add('balanceValue: '                 + FloatToStr(LBalance.BalanceValue));
      Memo1.Lines.Add('balanceBlockedCheck: '          + FloatToStr(LBalance.BalanceBlockedCheck));
      Memo1.Lines.Add('balanceBlockedAdministrative: ' + FloatToStr(LBalance.balanceBlockedAdministrative));
      Memo1.Lines.Add('balanceBlockedJudicial: '       + FloatToStr(LBalance.BalanceBlockedJudicial));
      Memo1.Lines.Add('balanceBlockedSpecial: '        + FloatToStr(LBalance.BalanceBlockedSpecial));
      Memo1.Lines.Add('balanceProvisioned: '           + FloatToStr(LBalance.BalanceProvisioned));
      Memo1.Lines.Add('valueLimit: '                   + FloatToStr(LBalance.ValueLimit));
      Memo1.Lines.Add('netBalanceValue: '              + FloatToStr(LBalance.NetBalanceValue));
    finally
      LBalance.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

procedure TFrmMain.BtnUATCREDITClick(Sender: TObject);
var
  LClient: IRestClient;
  LResponse: IRestResponse;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
  OperationId: String;
  ContaNumero, ContaAgencia: String;
begin
  Memo1.Lines.Clear;

  ContaNumero := '0010261290';

  LClient := TRestClient.Create(
    'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
    rtWinInet,
    'https://api.cre.uatesb.local/oauth/token',
    'srvc.ce.core.banking.service.uat',
    'K>9.V=n20T9vo!bn0>bbn'
  );

  // chamar o transaction operation
  // chamar o transaction movement
  // se der erro então chamar o reversal
  // saldo para verficar a transação

  // json enviado no body da transacao
  JSonRequest := SO;
  JSonRequest.S['requestingService'] := 'ce-installment-amortization';
  JSonRequest.S['accountNumber']     := ContaNumero;
  JSonRequest.S['description']       := 'Credit';

  Memo1.Lines.Add('Body request');
  Memo1.Lines.Add(JSonRequest.AsJSon(True));
  Memo1.Lines.Add('');

  try
    // operation
    LResponse := LClient.CreateRequest
      .Resource('/transaction-dk/operation')
      .AddBody(JSonRequest)
      .Execute(rmPOST);

    if LResponse.StatusCode = 201 then
    begin
      JsonResponse := LResponse.ContentAsJson;
      if Assigned(JsonResponse) then
      begin
        OperationId := JsonResponse.S['sagaOperationId'];

        Memo1.Lines.Add('');
        Memo1.Lines.Add('OperationId: ' + OperationId);
        Memo1.Lines.Add('');
        Memo1.Lines.Add(JsonResponse.AsJSon(True));

        // movement
        JSonRequest := SO;
        JSonRequest.S['dateMovement']     := FormatDateTime('YYYY-MM-DD', NOW);
        JSonRequest.S['dateType']         := 'D_0';
        JSonRequest.S['historicalCode']   := '07129';
        JSonRequest.S['originSystem']     := 'INTCREDPJ';
        JSonRequest.S['documentNumber']   := '03300974000189';
        JSonRequest.I['channel']          := 0;
        JSonRequest.S['accountNumber']    := ContaNumero;
        JSonRequest.S['originAgencyCode'] := ContaAgencia;
        JSonRequest.S['sagaOperationId']  := OperationId;
        JSonRequest.D['valueMovement']    := 12559.15;
        JSonRequest.S['complement']       := '';
        JSonRequest.S['userCode']         := 'REST_API_EXECUTION';

        Memo1.Lines.Add('Movimento Body Request: ');
        Memo1.Lines.Add('');
        Memo1.Lines.Add('');
        Memo1.Lines.Add(JSonRequest.AsJSon(True));

        LResponse := LClient.CreateRequest
          .Resource('/transaction-dk/movement')
          .AddBody(JSonRequest)
          .Execute(rmPOST);

        if LResponse.StatusCode = 201 then
        begin
          JsonResponse := LResponse.ContentAsJson;
          if Assigned(JsonResponse) then
          begin
            Memo1.Lines.Add('Movimento Resposta: ');
            Memo1.Lines.Add('');
            Memo1.Lines.Add('');
            Memo1.Lines.Add(JsonResponse.AsJSon(True));

            if JsonResponse.S['status'] = 'DK_ERROR' then
            begin
              raise Exception.Create(Format(
                '%s - %s'#13#10'%s', [
                  JsonResponse.S['operationNumber'],
                  JsonResponse.S['status'],
                  JsonResponse.S['message']
                ])
              );
            end;




          end
          else
          begin
            raise Exception.Create(
              'Não foi possível ler a resposta!' + sLineBreak +
              'Json Resposta:' +
              JsonResponse.AsJSon(True)
            );
          end;
        end;
      end
      else
      begin

      end;
    end;
  except
    on E: Exception do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('');
      Memo1.Lines.Add(E.Message);
    end;
  end;
end;

procedure TFrmMain.BtnUATDebitClick(Sender: TObject);
begin
//
end;

end.

