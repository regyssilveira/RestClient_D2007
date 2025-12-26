unit Service.Transaction.DTO;

interface

uses
  SysUtils,
  Classes,
  SuperObject,
  RestClient.Interfaces,
  RestClient.Core,
  Service.DTO.Base;

type
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

implementation

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
  

end.
