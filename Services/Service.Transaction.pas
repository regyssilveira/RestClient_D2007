unit Service.Transaction;

interface

uses
  SysUtils,
  Classes,
  SuperObject,
  RestClient.Interfaces,
  RestClient.Core,
  Service.DTO.Base,
  Service.Transaction.DTO;

type
  ITransactionService = interface
    ['{B2A99E3D-2F8C-49D3-8E56-7B8C9A0F1E2D}']
    function GetSaldo(const AAccountNumber, ABankBranch: string): IBalanceDTO;
    function GetExtract(AAccountNumber, AAgency, AAgenciDigit: string; AStartDate, AEndDAte: TDateTime): IExtractDTO;
    function GetTransactionBySagaId(const ASagaId: string): ISagaIdDTO;
    function Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime): ITransactionDTO;
    function Movement(ADescription, AHistoricalCode, AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement, AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;

    function GetOnLog: TLogEvent;
    procedure SetOnLog(const Value: TLogEvent);
    property OnLog: TLogEvent read GetOnLog write SetOnLog;
  end;

  TTransactionService = class(TInterfacedObject, ITransactionService)
  private
    FClient: IRestClient;
  public
    constructor Create(const ABaseURL, ATokenEndpoint, AClientId, AClientSecret: string);
    function GetSaldo(const AAccountNumber, ABankBranch: string): IBalanceDTO;
    function GetExtract(AAccountNumber, AAgency, AAgenciDigit: string; AStartDate, AEndDAte: TDateTime): IExtractDTO;
    function GetTransactionBySagaId(const ASagaId: string): ISagaIdDTO;
    function Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime): ITransactionDTO;
    function Movement(ADescription, AHistoricalCode, AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement, AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;

    function GetOnLog: TLogEvent;
    procedure SetOnLog(const Value: TLogEvent);
  end;

implementation

const
  HISTORICAL_CODE_REVERSAL = '07320';

  // Resources
  RES_BALANCE           = '/account/balance';
  RES_EXTRACT           = '/account/extract';
  RES_TRANS_REVERSAL    = '/transaction-dk/reversal';
  RES_TRANS_OPERATION   = '/transaction-dk/operation';
  RES_TRANS_MOVEMENT    = '/transaction-dk/movement';
  RES_OPERATION_HISTORY = '/transaction-dk/operation-history';

{ TTransactionService }

constructor TTransactionService.Create(const ABaseURL, ATokenEndpoint, AClientId, AClientSecret: string);
begin
  FClient := TRestClient.Create(ABaseURL, ATokenEndpoint, AClientId, AClientSecret, rtWinInet);
end;

function TTransactionService.GetOnLog: TLogEvent;
begin
  Result := FClient.OnLog;
end;

procedure TTransactionService.SetOnLog(const Value: TLogEvent);
begin
  FClient.OnLog := Value;
end;

function TTransactionService.GetSaldo(const AAccountNumber, ABankBranch: string): IBalanceDTO;
var
  LResponse: IRestResponse;
begin
  Result := nil;

  LResponse := FClient.CreateRequest
    .Resource(RES_BALANCE)
    .AddHeader('accountNumber', AAccountNumber)
    .AddHeader('bankBranch', ABankBranch)
    .AddHeader('originSystem', ORIGIN_SYSTEM)
    .Execute(rmGET);

  if LResponse.StatusCode = 200 then
  begin
    Result := TBalanceDTO.Create;
    Result.FromJson(LResponse.ContentAsJson)
  end
  else
    raise Exception.CreateFmt('Erro ao consultar saldo. Status: %d. Erro: %s', [LResponse.StatusCode, LResponse.Content]);
end;

function TTransactionService.GetTransactionBySagaId(const ASagaId: string): ISagaIdDTO;
var
  LResponse: IRestResponse;
begin
  Result := nil;

  if Trim(ASagaId) = '' then
    raise Exception.Create('Identificador da transação (SagaId) não informado!');

  LResponse := FClient.CreateRequest
    .Resource(RES_OPERATION_HISTORY)
    .AddParam('operationId', ASagaId)
    .Execute(rmGET);

  if LResponse.StatusCode = 200 then
  begin
    Result := tSagaIdDTO.Create;
    Result.FromJson(LResponse.ContentAsJson)
  end
  else
    raise Exception.CreateFmt('Erro ao consultar dados da transação (SagaId). Status: %d. Erro: %s', [LResponse.StatusCode, LResponse.Content]);
end;

function TTransactionService.Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime): ITransactionDTO;
var
  LResponse: IRestResponse;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
begin
  Result := nil;

  JSonRequest := SO;
  JSonRequest.S['accountNumber']     := AAccountNumber;
  JSonRequest.S['originSystem']      := ORIGIN_SYSTEM;
  JSonRequest.S['complement']        := AComplement;
  JSonRequest.S['operationIdSource'] := AOperationIdSource;
  JSonRequest.S['userCode']          := AUserCode;
  JSonRequest.S['dateMovement']      := FormatDateTime('YYYY-MM-DD', ADateMovement);
  JSonRequest.S['historicalCode']    := HISTORICAL_CODE_REVERSAL;

  LResponse := FClient.CreateRequest
    .Resource(RES_TRANS_REVERSAL)
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
      end
      else
      begin
        Result := TTransactionDTO.Create;
        Result.FromJson(LResponse.ContentAsJson)
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

function TTransactionService.Movement(ADescription, AHistoricalCode, AAccountNumber,
  AOriginAgencyCode, ADocumentNumber, AComplement, AUserCode: String;
  AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
var
  LResponse: IRestResponse;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
  SagaOperationId: String;
begin
  Result := TTransactionDTO.Create;

  // chamar o transaction operation
  // chamar o transaction movement
  // se der erro então chamar o reversal  (DK_ERROR, ORIGIN_ERROR, ERROR)

  // inicar operação chamando o endpoint operation
  // json enviado no body da transacao
  JSonRequest := SO;
  JSonRequest.S['requestingService'] := 'ce-installment-amortization';
  JSonRequest.S['accountNumber']     := AAccountNumber;
  JSonRequest.S['description']       := ADescription;

  // operation
  LResponse := FClient.CreateRequest
    .Resource(RES_TRANS_OPERATION)
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
      SagaOperationId := JsonResponse.S['sagaOperationId'];

      // se operation ocorreu bem, chama o movement para a ação
      // movement
      JSonRequest := SO;
      JSonRequest.S['dateMovement']     := FormatDateTime('YYYY-MM-DD', ADateMovement);
      JSonRequest.S['dateType']         := 'D_0';
      JSonRequest.S['historicalCode']   := AHistoricalCode;
      JSonRequest.S['originSystem']     := ORIGIN_SYSTEM;
      JSonRequest.S['documentNumber']   := ADocumentNumber;
      JSonRequest.I['channel']          := 0;
      JSonRequest.S['accountNumber']    := AAccountNumber;
      JSonRequest.S['originAgencyCode'] := AOriginAgencyCode;
      JSonRequest.S['sagaOperationId']  := SagaOperationId;
      JSonRequest.D['valueMovement']    := AValueMovement;
      JSonRequest.S['complement']       := AComplement;
      JSonRequest.S['userCode']         := AUserCode;

      LResponse := FClient.CreateRequest
        .Resource(RES_TRANS_MOVEMENT)
        .AddBody(JSonRequest)
        .Execute(rmPOST);

      if LResponse.StatusCode = 201 then
      begin
        JsonResponse := LResponse.ContentAsJson;
        if Assigned(JsonResponse) then
        begin
          Result.FromJson(LResponse.ContentAsJson);

          if LResponse.IsError then
          begin
            Result.FromJson(JsonResponse);
            if Pos('error on processing', Result.Message) >= 0 then
            begin
              raise Exception.Create(
                'Erro no processamento da transação, não é possível continuar' + sLineBreak +
                'Erro: ' +Result.Message
              );
            end;

            // chamar o reversal em caso de retorno de erro e tenha sido processado
            Self.Reversal(AAccountNumber, '', SagaOperationId, AUserCode, ADateMovement);
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

function TTransactionService.GetExtract(AAccountNumber, AAgency, AAgenciDigit: string; AStartDate, AEndDAte: TDateTime): IExtractDTO;
var
  LResponse: IRestResponse;
  JsonResponse: ISuperObject;
begin
  Result := TExtractDTO.Create;

  LResponse := FClient.CreateRequest
    .Resource(RES_EXTRACT)
    .AddHeader('accountNumber', AAccountNumber)
    .AddHeader('agency', AAgency)
    .AddHeader('agencyDigit', AAgenciDigit)
    .AddHeader('originSystem', ORIGIN_SYSTEM)
    .AddHeader('startDate', FormatDateTime('YYYY-MM-DD', AStartDate))
    .AddHeader('endDate', FormatDateTime('YYYY-MM-DD', AEndDAte))
    .Execute(rmGET);

  if LResponse.StatusCode = 200 then
  begin
    JsonResponse := LResponse.ContentAsJson;
    if Assigned(JsonResponse) then
    begin
      Result.FromJson(LResponse.ContentAsJson)
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

end.
