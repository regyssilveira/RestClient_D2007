unit Service.Transaction;

interface

uses
  SysUtils, Classes, SuperObject, TypInfo, RestClient.Interfaces, RestClient.Core, Service.DTO.Base;

type
  TTransactionType = (ttCredito, ttDebito);

  // delphi 2007 não possui helpers para record (enum), então quebrar o galho utilizando isso
  TTranscationTypeHelper = record
    class function ToString(const AValue: TTransactionType): String; static;
    class function FromString(const AValue: String): TTransactionType; static;
  end;

  TBalanceDTO = class(TJsonDTO)
  private
    FBalanceValue: Double;
    FBalanceBlockedCheck: Double;
    FBalanceBlockedAdministrative: Double;
    FBalanceBlockedJudicial: Double;
    FBalanceBlockedSpecial: Double;
    FBalanceProvisioned: Double;
    FValueLimit: Integer;
    FNetBalanceValue: Double;
  published
    property BalanceValue: Double read FBalanceValue write FBalanceValue;
    property BalanceBlockedCheck: Double read FBalanceBlockedCheck write FBalanceBlockedCheck;
    property BalanceBlockedAdministrative: Double read FBalanceBlockedAdministrative write FBalanceBlockedAdministrative;
    property BalanceBlockedJudicial: Double read FBalanceBlockedJudicial write FBalanceBlockedJudicial;
    property BalanceBlockedSpecial: Double read FBalanceBlockedSpecial write FBalanceBlockedSpecial;
    property BalanceProvisioned: Double read FBalanceProvisioned write FBalanceProvisioned;
    property ValueLimit: Integer read FValueLimit write FValueLimit;
    property NetBalanceValue: Double read FNetBalanceValue write FNetBalanceValue;
  end;

  ITransactionService = interface
    ['{B2A99E3D-2F8C-49D3-8E56-7B8C9A0F1E2D}']
    function GetSaldo(const AAccountNumber, ABankBranch, AOriginSystem: string): TBalanceDTO;
    procedure Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime);
    function Credit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;
    function Debit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;
  end;

  TTransactionService = class(TInterfacedObject, ITransactionService)
  private
    FClient: IRestClient;
    function Movement(ATransactionType: TTransactionType; AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;
  public
    constructor Create(const ABaseURL, ATokenEndpoint, AClientId, AClientSecret: string);
    function GetSaldo(const AAccountNumber, ABankBranch, AOriginSystem: string): TBalanceDTO;
    procedure Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime);
    function Credit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;
    function Debit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;      
  end;

implementation

{ TTranscationTypeHelper }

class function TTranscationTypeHelper.FromString(const AValue: String): TTransactionType;
begin
  if UpperCase(Trim(AValue)) = 'CREDIT' then
    Result := ttCredito
  else
  if UpperCase(Trim(AValue)) = 'DEBIT' then
    Result := ttDebito
  else
    raise Exception.CreateFmt('Transação "%s" não reconhecida.', [AValue]);
end;

class function TTranscationTypeHelper.ToString(const AValue: TTransactionType): String;
begin
  case AValue of
    ttCredito: Result := 'CREDIT';
    ttDebito:  Result := 'DEBIT';
  else
    Result := 'UNKNOW';
  end;
end;

{ TTransactionService }

constructor TTransactionService.Create(const ABaseURL, ATokenEndpoint, AClientId, AClientSecret: string);
begin
  FClient := TRestClient.Create(ABaseURL, rtWinInet, ATokenEndpoint, AClientId, AClientSecret);
end;

function TTransactionService.GetSaldo(const AAccountNumber, ABankBranch, AOriginSystem: string): TBalanceDTO;
var
  LResponse: IRestResponse;
begin
  Result := TBalanceDTO.Create;
  try
    LResponse := FClient.CreateRequest
      .Resource('/account/balance')
      .AddHeader('accountNumber', AAccountNumber)
      .AddHeader('bankBranch', ABankBranch)
      .AddHeader('originSystem', AOriginSystem)
      .Execute(rmGET);

    if LResponse.StatusCode = 200 then
      Result.FromJson(LResponse.ContentAsJson)
    else
      raise Exception.CreateFmt('Erro ao consultar saldo. Status: %d. Erro: %s', [LResponse.StatusCode, LResponse.Content]);
  except
    Result.Free;
    raise;
  end;
end;

procedure TTransactionService.Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime);
var
  LResponse: IRestResponse;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
begin
  JSonRequest := SO;
  JSonRequest.S['accountNumber']     := AAccountNumber;
  JSonRequest.S['originSystem']      := ORIGIN_SYSTEM;
  JSonRequest.S['complement']        := AComplement;
  JSonRequest.S['operationIdSource'] := AOperationIdSource;
  JSonRequest.S['userCode']          := AUserCode;
  JSonRequest.S['dateMovement']      := FormatDateTime('YYYY-MM-DD', ADateMovement);
  JSonRequest.S['historicalCode']    := HISTORICAL_CODE_REVERSAL;
  LResponse := FClient.CreateRequest
    .Resource('/transaction-dk/reversal')
    .AddBody(JSonRequest)
    .Execute(rmPOST);

  if LResponse.StatusCode = 201 then
  begin
    JsonResponse := LResponse.ContentAsJson;
    if Assigned(JsonResponse) then
    begin
      if JsonResponse.S['status'] <> 'CREATED' then
      begin
        raise Exception.CreateFmt(
          'Reversal Transacation Error: %s - %s'#13#10'%s', [
          JsonResponse.S['operationNumber'],
          JsonResponse.S['status'],
          JsonResponse.S['message']
        ]);
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
  end
  else
    FClient.TratarRetornoNaoEsperado(LResponse.Content);
end;

function TTransactionService.Movement(ATransactionType: TTransactionType; AAccountNumber,
  AOriginAgencyCode, ADocumentNumber, AComplement, AUserCode: String;
  AValueMovement: Double; ADateMovement: TDateTime): String;
var
  LResponse: IRestResponse;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
  JsonString: String;
  HistoricalCode: String;
begin
  // chamar o transaction operation
  // chamar o transaction movement
  // se der erro então chamar o reversal  (DK_ERROR, ORIGIN_ERROR, ERROR)
  case ATransactionType of
    ttCredito: HistoricalCode := HISTORICAL_CODE_CREDIT;
    ttDebito : HistoricalCode := HISTORICAL_CODE_DEBIT;
  end;

  // inicar operação chamando o endpoint operation
  // json enviado no body da transacao
  JSonRequest := SO;
  JSonRequest.S['requestingService'] := 'ce-installment-amortization';
  JSonRequest.S['accountNumber']     := AAccountNumber;
  JSonRequest.S['description']       := TTranscationTypeHelper.ToString(ATransactionType);

  JsonString := JSonRequest.AsJSon;

  // operation
  LResponse := FClient.CreateRequest
    .Resource('/transaction-dk/operation')
    .AddBody(JSonRequest)
    .Execute(rmPOST);

  if LResponse.StatusCode = 201 then
  begin
    JsonResponse := LResponse.ContentAsJson;
    if Assigned(JsonResponse) then
    begin
      if JsonResponse.S['status'] <> 'CREATED' then
      begin
        raise Exception.CreateFmt(
          'Operation Transacation Error: %s - %s'#13#10'%s', [
          JsonResponse.S['operationNumber'],
          JsonResponse.S['status'],
          JsonResponse.S['message']
        ]);
      end;

      // captura o operation id para utilização futura e retorno
      Result := JsonResponse.S['sagaOperationId'];

      // se operation ocorreu bem, chama o movement para a ação
      // movement
      JSonRequest := SO;
      JSonRequest.S['dateMovement']     := FormatDateTime('YYYY-MM-DD', ADateMovement);
      JSonRequest.S['dateType']         := 'D_0';
      JSonRequest.S['historicalCode']   := HistoricalCode;
      JSonRequest.S['originSystem']     := ORIGIN_SYSTEM;
      JSonRequest.S['documentNumber']   := ADocumentNumber;
      JSonRequest.I['channel']          := 0;
      JSonRequest.S['accountNumber']    := AAccountNumber;
      JSonRequest.S['originAgencyCode'] := AOriginAgencyCode;
      JSonRequest.S['sagaOperationId']  := Result;
      JSonRequest.D['valueMovement']    := AValueMovement;
      JSonRequest.S['complement']       := AComplement;
      JSonRequest.S['userCode']         := AUserCode;

      JsonString := JSonRequest.AsJSon;

      LResponse := FClient.CreateRequest
        .Resource('/transaction-dk/movement')
        .AddBody(JSonRequest)
        .Execute(rmPOST);

      if LResponse.StatusCode = 201 then
      begin
        JsonResponse := LResponse.ContentAsJson;
        if Assigned(JsonResponse) then
        begin
          if LResponse.IsError then
          begin
            // chamar o reversal em caso de retorno de erro
            Self.Reversal(AAccountNumber, '', Result, AUserCode, ADateMovement);

            raise Exception.CreateFmt(
              'Movement Transacation Error: %s - %s'#13#10'%s', [
              JsonResponse.S['operationNumber'],
              JsonResponse.S['status'],
              JsonResponse.S['message']
            ]);
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
      end
      else
      begin
        FClient.TratarRetornoNaoEsperado(LResponse.Content);
      end;
    end;
  end
  else
    FClient.TratarRetornoNaoEsperado(LResponse.Content);
end;

function TTransactionService.Credit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
  AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;
begin
  Result := Self.Movement(
    ttCredito,
    AAccountNumber,
    AOriginAgencyCode,
    ADocumentNumber,
    AComplement,
    AUserCode,
    AValueMovement,
    ADateMovement
  );
end;

function TTransactionService.Debit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
  AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): String;
begin
  Result := Self.Movement(
    ttDebito,
    AAccountNumber,
    AOriginAgencyCode,
    ADocumentNumber,
    AComplement,
    AUserCode,
    AValueMovement,
    ADateMovement
  );
end;

end.
