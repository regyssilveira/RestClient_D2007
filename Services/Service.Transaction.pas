unit Service.Transaction;

interface

uses
  SysUtils, Classes, SuperObject, TypInfo, RestClient.Interfaces, RestClient.Core, Service.DTO.Base;

type
  TTransactionType = (ttCredito, ttDebito);

  // delphi 2007 não possui helpers para record (enum), então quebrar o galho utilizando isso
  TTransactionTypeHelper = record
    class function ToString(const AValue: TTransactionType): String; static;
    class function FromString(const AValue: String): TTransactionType; static;
  end;

  IBalanceDTO = interface
    ['{D93A7C7E-2B2F-4C1A-9D3E-5F8A6B4C7D2E}']
    function GetBalanceValue: Double;
    procedure SetBalanceValue(const Value: Double);
    function GetBalanceBlockedCheck: Double;
    procedure SetBalanceBlockedCheck(const Value: Double);
    function GetBalanceBlockedAdministrative: Double;
    procedure SetBalanceBlockedAdministrative(const Value: Double);
    function GetBalanceBlockedJudicial: Double;
    procedure SetBalanceBlockedJudicial(const Value: Double);
    function GetBalanceBlockedSpecial: Double;
    procedure SetBalanceBlockedSpecial(const Value: Double);
    function GetBalanceProvisioned: Double;
    procedure SetBalanceProvisioned(const Value: Double);
    function GetValueLimit: Integer;
    procedure SetValueLimit(const Value: Integer);
    function GetNetBalanceValue: Double;
    procedure SetNetBalanceValue(const Value: Double);
    
    procedure FromJson(AJson: ISuperObject);

    property BalanceValue: Double read GetBalanceValue write SetBalanceValue;
    property BalanceBlockedCheck: Double read GetBalanceBlockedCheck write SetBalanceBlockedCheck;
    property BalanceBlockedAdministrative: Double read GetBalanceBlockedAdministrative write SetBalanceBlockedAdministrative;
    property BalanceBlockedJudicial: Double read GetBalanceBlockedJudicial write SetBalanceBlockedJudicial;
    property BalanceBlockedSpecial: Double read GetBalanceBlockedSpecial write SetBalanceBlockedSpecial;
    property BalanceProvisioned: Double read GetBalanceProvisioned write SetBalanceProvisioned;
    property ValueLimit: Integer read GetValueLimit write SetValueLimit;
    property NetBalanceValue: Double read GetNetBalanceValue write SetNetBalanceValue;
  end;

  TBalanceDTO = class(TJsonDTO, IBalanceDTO)
  private
    FBalanceValue: Double;
    FBalanceBlockedCheck: Double;
    FBalanceBlockedAdministrative: Double;
    FBalanceBlockedJudicial: Double;
    FBalanceBlockedSpecial: Double;
    FBalanceProvisioned: Double;
    FValueLimit: Integer;
    FNetBalanceValue: Double;
    function GetBalanceValue: Double;
    procedure SetBalanceValue(const Value: Double);
    function GetBalanceBlockedCheck: Double;
    procedure SetBalanceBlockedCheck(const Value: Double);
    function GetBalanceBlockedAdministrative: Double;
    procedure SetBalanceBlockedAdministrative(const Value: Double);
    function GetBalanceBlockedJudicial: Double;
    procedure SetBalanceBlockedJudicial(const Value: Double);
    function GetBalanceBlockedSpecial: Double;
    procedure SetBalanceBlockedSpecial(const Value: Double);
    function GetBalanceProvisioned: Double;
    procedure SetBalanceProvisioned(const Value: Double);
    function GetValueLimit: Integer;
    procedure SetValueLimit(const Value: Integer);
    function GetNetBalanceValue: Double;
    procedure SetNetBalanceValue(const Value: Double);
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

  ITransactionDTO = interface
    ['{E4B2A1C9-8F7D-4E3B-9C5A-2D8F6E4B7C3A}']
    function GetRequestingService: string;
    procedure SetRequestingService(const Value: string);
    function GetAccountNumber: string;
    procedure SetAccountNumber(const Value: string);
    function GetSagaOperationId: string;
    procedure SetSagaOperationId(const Value: string);
    function GetStatus: string;
    procedure SetStatus(const Value: string);
    function GetMessage: string;
    procedure SetMessage(const Value: string);
    function GetOperationNumber: string;
    procedure SetOperationNumber(const Value: string);

    procedure FromJson(AJson: ISuperObject);

    property RequestingService: string read GetRequestingService write SetRequestingService;
    property AccountNumber: string read GetAccountNumber write SetAccountNumber;
    property SagaOperationId: string read GetSagaOperationId write SetSagaOperationId;
    property Status: string read GetStatus write SetStatus;
    property Message: string read GetMessage write SetMessage;
    property OperationNumber: string read GetOperationNumber write SetOperationNumber;
  end;

  TTransactionDTO = class(TJsonDTO, ITransactionDTO)
  private
    FRequestingService: string;
    FAccountNumber: string;
    FSagaOperationId: string;
    FStatus: string;
    FMessage: string;
    FOperationNumber: string;
    function GetRequestingService: string;
    procedure SetRequestingService(const Value: string);
    function GetAccountNumber: string;
    procedure SetAccountNumber(const Value: string);
    function GetSagaOperationId: string;
    procedure SetSagaOperationId(const Value: string);
    function GetStatus: string;
    procedure SetStatus(const Value: string);
    function GetMessage: string;
    procedure SetMessage(const Value: string);
    function GetOperationNumber: string;
    procedure SetOperationNumber(const Value: string);
  published
    property RequestingService: string read FRequestingService write FRequestingService;
    property AccountNumber: string read FAccountNumber write FAccountNumber;
    property SagaOperationId: string read FSagaOperationId write FSagaOperationId;
    property Status: string read FStatus write FStatus;
    property Message: string read FMessage write FMessage;
    property OperationNumber: string read FOperationNumber write FOperationNumber;
  end;

  ITransactionService = interface
    ['{B2A99E3D-2F8C-49D3-8E56-7B8C9A0F1E2D}']
    function GetSaldo(const AAccountNumber, ABankBranch: string): IBalanceDTO;
    function Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime): ITransactionDTO;
    function Credit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
    function Debit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
      
    function GetOnLog: TLogEvent;
    procedure SetOnLog(const Value: TLogEvent);
    property OnLog: TLogEvent read GetOnLog write SetOnLog;
  end;

  TTransactionService = class(TInterfacedObject, ITransactionService)
  private
    FClient: IRestClient;
    function Movement(ATransactionType: TTransactionType; AHistoricalCode, AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
  public
    constructor Create(const ABaseURL, ATokenEndpoint, AClientId, AClientSecret: string);
    function GetSaldo(const AAccountNumber, ABankBranch: string): IBalanceDTO;
    function Reversal(AAccountNumber, AComplement, AOperationIdSource, AUserCode: String; ADateMovement: TDateTime): ITransactionDTO;
    function Credit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
    function Debit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
      AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
      
    function GetOnLog: TLogEvent;
    procedure SetOnLog(const Value: TLogEvent);
  end;

implementation

const
  HISTORICAL_CODE_REVERSAL = '07320';
  HISTORICAL_CODE_DEBIT    = '07129';
  HISTORICAL_CODE_CREDIT   = '08179';

{ TTranscationTypeHelper }

class function TTransactionTypeHelper.FromString(const AValue: String): TTransactionType;
begin
  if UpperCase(Trim(AValue)) = 'CREDIT' then
    Result := ttCredito
  else
  if UpperCase(Trim(AValue)) = 'DEBIT' then
    Result := ttDebito
  else
    raise Exception.CreateFmt('Transação "%s" não reconhecida.', [AValue]);
end;

class function TTransactionTypeHelper.ToString(const AValue: TTransactionType): String;
begin
  case AValue of
    ttCredito: Result := 'CREDIT';
    ttDebito:  Result := 'DEBIT';
  else
    Result := 'UNKNOW';
  end;
end;

{ TBalanceDTO }

function TBalanceDTO.GetBalanceBlockedAdministrative: Double;
begin
  Result := FBalanceBlockedAdministrative;
end;

function TBalanceDTO.GetBalanceBlockedCheck: Double;
begin
  Result := FBalanceBlockedCheck;
end;

function TBalanceDTO.GetBalanceBlockedJudicial: Double;
begin
  Result := FBalanceBlockedJudicial;
end;

function TBalanceDTO.GetBalanceBlockedSpecial: Double;
begin
  Result := FBalanceBlockedSpecial;
end;

function TBalanceDTO.GetBalanceProvisioned: Double;
begin
  Result := FBalanceProvisioned;
end;

function TBalanceDTO.GetBalanceValue: Double;
begin
  Result := FBalanceValue;
end;

function TBalanceDTO.GetNetBalanceValue: Double;
begin
  Result := FNetBalanceValue;
end;

function TBalanceDTO.GetValueLimit: Integer;
begin
  Result := FValueLimit;
end;

procedure TBalanceDTO.SetBalanceBlockedAdministrative(const Value: Double);
begin
  FBalanceBlockedAdministrative := Value;
end;

procedure TBalanceDTO.SetBalanceBlockedCheck(const Value: Double);
begin
  FBalanceBlockedCheck := Value;
end;

procedure TBalanceDTO.SetBalanceBlockedJudicial(const Value: Double);
begin
  FBalanceBlockedJudicial := Value;
end;

procedure TBalanceDTO.SetBalanceBlockedSpecial(const Value: Double);
begin
  FBalanceBlockedSpecial := Value;
end;

procedure TBalanceDTO.SetBalanceProvisioned(const Value: Double);
begin
  FBalanceProvisioned := Value;
end;

procedure TBalanceDTO.SetBalanceValue(const Value: Double);
begin
  FBalanceValue := Value;
end;

procedure TBalanceDTO.SetNetBalanceValue(const Value: Double);
begin
  FNetBalanceValue := Value;
end;

procedure TBalanceDTO.SetValueLimit(const Value: Integer);
begin
  FValueLimit := Value;
end;

{ TTransactionDTO }

function TTransactionDTO.GetAccountNumber: string;
begin
  Result := FAccountNumber;
end;

function TTransactionDTO.GetMessage: string;
begin
  Result := FMessage;
end;

function TTransactionDTO.GetOperationNumber: string;
begin
  Result := FOperationNumber;
end;

function TTransactionDTO.GetRequestingService: string;
begin
  Result := FRequestingService;
end;

function TTransactionDTO.GetSagaOperationId: string;
begin
  Result := FSagaOperationId;
end;

function TTransactionDTO.GetStatus: string;
begin
  Result := FStatus;
end;

procedure TTransactionDTO.SetAccountNumber(const Value: string);
begin
  FAccountNumber := Value;
end;

procedure TTransactionDTO.SetMessage(const Value: string);
begin
  FMessage := Value;
end;

procedure TTransactionDTO.SetOperationNumber(const Value: string);
begin
  FOperationNumber := Value;
end;

procedure TTransactionDTO.SetRequestingService(const Value: string);
begin
  FRequestingService := Value;
end;

procedure TTransactionDTO.SetSagaOperationId(const Value: string);
begin
  FSagaOperationId := Value;
end;

procedure TTransactionDTO.SetStatus(const Value: string);
begin
  FStatus := Value;
end;

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
  Result := TBalanceDTO.Create;
  try
    LResponse := FClient.CreateRequest
      .Resource('/account/balance')
      .AddHeader('accountNumber', AAccountNumber)
      .AddHeader('bankBranch', ABankBranch)
      .AddHeader('originSystem', ORIGIN_SYSTEM)
      .Execute(rmGET);

    if LResponse.StatusCode = 200 then
      Result.FromJson(LResponse.ContentAsJson)
    else
      raise Exception.CreateFmt('Erro ao consultar saldo. Status: %d. Erro: %s', [LResponse.StatusCode, LResponse.Content]);
  except
    // Result is an interface, it will be automatically released if exception occurs before return?
    // Actually, TInterfacedObject.AfterConstruction has RefCount=0.
    // Result := ... assigns to interface, RefCount=1.
    // If exception raised, Result (interface) goes out of scope?
    // In function, 'Result' is a variable.
    // If exception raised, does Result get cleared?
    // Regardless, we should NOT call Result.Free.
    raise;
  end;
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

function TTransactionService.Movement(ATransactionType: TTransactionType; AHistoricalCode, AAccountNumber,
  AOriginAgencyCode, ADocumentNumber, AComplement, AUserCode: String;
  AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
var
  LResponse: IRestResponse;
  JSonRequest: ISuperObject;
  JsonResponse: ISuperObject;
  SagaOperationId: String;
begin
  Result := nil;

  // chamar o transaction operation
  // chamar o transaction movement
  // se der erro então chamar o reversal  (DK_ERROR, ORIGIN_ERROR, ERROR)

  // inicar operação chamando o endpoint operation
  // json enviado no body da transacao
  JSonRequest := SO;
  JSonRequest.S['requestingService'] := 'ce-installment-amortization';
  JSonRequest.S['accountNumber']     := AAccountNumber;
  JSonRequest.S['description']       := TTransactionTypeHelper.ToString(ATransactionType);

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
            Self.Reversal(AAccountNumber, '', SagaOperationId, AUserCode, ADateMovement);

            raise Exception.CreateFmt(
              'Movement Transacation Error: %s - %s'#13#10'%s', [
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
      begin
        FClient.TratarRetornoNaoEsperado(LResponse.Content);
      end;
    end;
  end
  else
    FClient.TratarRetornoNaoEsperado(LResponse.Content);
end;

function TTransactionService.Credit(AAccountNumber, AOriginAgencyCode, ADocumentNumber, AComplement,
  AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
begin
  Result := Self.Movement(
    ttCredito,
    HISTORICAL_CODE_CREDIT,
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
  AUserCode: String; AValueMovement: Double; ADateMovement: TDateTime): ITransactionDTO;
begin
  Result := Self.Movement(
    ttDebito,
    HISTORICAL_CODE_DEBIT,
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
