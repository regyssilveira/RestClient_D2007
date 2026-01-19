
interface

uses
  SysUtils,
  Classes,
  Contnrs,
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

  ISagaIdDTO = interface
    ['{3BABAEF7-DDA8-4092-B7C8-68234543C5F4}']
    function GetId: Integer;
    procedure SetId(const Value: Integer);
    function GetSagaOperationId: string;
    procedure SetSagaOperationId(const Value: string);
    function GetRequestingService: string;
    procedure SetRequestingService(const Value: string);
    function GetAccountNumber: string;
    procedure SetAccountNumber(const Value: string);
    function GetValueMovement: Double;
    procedure SetValueMovement(const Value: Double);
    function GetMovementNumber: string;
    procedure SetMovementNumber(const Value: string);
    function GetDescription: string;
    procedure SetDescription(const Value: string);
    function GetHistoricalCode: string;
    procedure SetHistoricalCode(const Value: string);
    function GetDateType: string;
    procedure SetDateType(const Value: string);
    function GetUserCode: string;
    procedure SetUserCode(const Value: string);
    function GetStatus: string;
    procedure SetStatus(const Value: string);
    function GetVersion: Integer;
    procedure SetVersion(const Value: Integer);
    function GetInclude: TDateTime;
    procedure SetInclude(const Value: TDateTime);
    function GetUpdate: TDateTime;
    procedure SetUpdate(const Value: TDateTime);

    procedure FromJson(AJson: ISuperObject);    

    property Id: Integer read GetId write SetId;
    property SagaOperationId: string read GetSagaOperationId write SetSagaOperationId;
    property RequestingService: string read GetRequestingService write SetRequestingService;
    property AccountNumber: string read GetAccountNumber write SetAccountNumber;
    property ValueMovement: Double read GetValueMovement write SetValueMovement;
    property MovementNumber: string read GetMovementNumber write SetMovementNumber;
    property Description: string read GetDescription write SetDescription;
    property HistoricalCode: string read GetHistoricalCode write SetHistoricalCode;
    property DateType: string read GetDateType write SetDateType;
    property UserCode: string read GetUserCode write SetUserCode;
    property Status: string read GetStatus write SetStatus;
    property Version: Integer read GetVersion write SetVersion;
    property Include: TDateTime read GetInclude write SetInclude;
    property Update: TDateTime read GetUpdate write SetUpdate;
  end;

  IExtractItemDTO = interface
    ['{5396CD81-1964-4F93-8438-E3060B8664DF}']
    function GetNumberMovement: Integer;
    procedure SetNumberMovement(const Value: Integer);
    function GetTypeOperation: Integer;
    procedure SetTypeOperation(const Value: Integer);
    function GetDateInclusion: TDateTime;
    procedure SetDateInclusion(const Value: TDateTime);
    function GetDateMovement: TDateTime;
    procedure SetDateMovement(const Value: TDateTime);
    function GetCodeHistorical: string;
    procedure SetCodeHistorical(const Value: string);
    function GetDescriptionHistory: string;
    procedure SetDescriptionHistory(const Value: string);
    function GetTypeHistoric: string;
    procedure SetTypeHistoric(const Value: string);
    function GetNature: string;
    procedure SetNature(const Value: string);
    function GetTypeNature: string;
    procedure SetTypeNature(const Value: string);
    function GetValueMovement: Double;
    procedure SetValueMovement(const Value: Double);
    function GetPreviousBalance: Double;
    procedure SetPreviousBalance(const Value: Double);
    function GetValueCpmf: Double;
    procedure SetValueCpmf(const Value: Double);
    function GetComplement: string;
    procedure SetComplement(const Value: string);
    function GetCodeAlinea: string;
    procedure SetCodeAlinea(const Value: string);
    function GetDocumentNumber: string;
    procedure SetDocumentNumber(const Value: string);
    function GetCodeCategory: string;
    procedure SetCodeCategory(const Value: string);

    property NumberMovement: Integer read GetNumberMovement write SetNumberMovement;
    property TypeOperation: Integer read GetTypeOperation write SetTypeOperation;
    property DateInclusion: TDateTime read GetDateInclusion write SetDateInclusion;
    property DateMovement: TDateTime read GetDateMovement write SetDateMovement;
    property CodeHistorical: string read GetCodeHistorical write SetCodeHistorical;
    property DescriptionHistory: string read GetDescriptionHistory write SetDescriptionHistory;
    property TypeHistoric: string read GetTypeHistoric write SetTypeHistoric;
    property Nature: string read GetNature write SetNature;
    property TypeNature: string read GetTypeNature write SetTypeNature;
    property ValueMovement: Double read GetValueMovement write SetValueMovement;
    property PreviousBalance: Double read GetPreviousBalance write SetPreviousBalance;
    property ValueCpmf: Double read GetValueCpmf write SetValueCpmf;
    property Complement: string read GetComplement write SetComplement;
    property CodeAlinea: string read GetCodeAlinea write SetCodeAlinea;
    property DocumentNumber: string read GetDocumentNumber write SetDocumentNumber;
    property CodeCategory: string read GetCodeCategory write SetCodeCategory;
  end;

  IExtractDTO = interface
    ['{FDB39C49-E82C-4655-9621-7FE0B78E9EA2}']
    procedure FromJson(AJson: ISuperObject);

    function GetRecordOffset: Integer;
    procedure SetRecordOffset(const Value: Integer);
    function GetTotalRecords: Integer;
    procedure SetTotalRecords(const Value: Integer);
    function GetExtract: TObjectList;
    procedure SetExtract(const Value: TObjectList);

    property RecordOffset: Integer read GetRecordOffset write SetRecordOffset;
    property TotalRecords: Integer read GetTotalRecords write SetTotalRecords;
    property Extract: TObjectList read GetExtract write SetExtract;
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
    property BalanceValue: Double read GetBalanceValue write SetBalanceValue;
    property BalanceBlockedCheck: Double read GetBalanceBlockedCheck write SetBalanceBlockedCheck;
    property BalanceBlockedAdministrative: Double read GetBalanceBlockedAdministrative write SetBalanceBlockedAdministrative;
    property BalanceBlockedJudicial: Double read GetBalanceBlockedJudicial write SetBalanceBlockedJudicial;
    property BalanceBlockedSpecial: Double read GetBalanceBlockedSpecial write SetBalanceBlockedSpecial;
    property BalanceProvisioned: Double read GetBalanceProvisioned write SetBalanceProvisioned;
    property ValueLimit: Integer read GetValueLimit write SetValueLimit;
    property NetBalanceValue: Double read GetNetBalanceValue write SetNetBalanceValue;
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
    property RequestingService: string read GetRequestingService write SetRequestingService;
    property AccountNumber: string read GetAccountNumber write SetAccountNumber;
    property SagaOperationId: string read GetSagaOperationId write SetSagaOperationId;
    property Status: string read GetStatus write SetStatus;
    property Message: string read GetMessage write SetMessage;
    property OperationNumber: string read GetOperationNumber write SetOperationNumber;  
  end;

  TSagaIdDTO = class(TJsonDTO, ISagaIdDTO)
  private
    FId: Integer;
    FSagaOperationId: string;
    FRequestingService: string;
    FAccountNumber: string;
    FValueMovement: Double;
    FMovementNumber: string;
    FDescription: string;
    FHistoricalCode: string;
    FDateType: string;
    FUserCode: string;
    FStatus: string;
    FVersion: Integer;
    FInclude: TDateTime;
    FUpdate: TDateTime;
    function GetId: Integer;
    procedure SetId(const Value: Integer);
    function GetSagaOperationId: string;
    procedure SetSagaOperationId(const Value: string);
    function GetRequestingService: string;
    procedure SetRequestingService(const Value: string);
    function GetAccountNumber: string;
    procedure SetAccountNumber(const Value: string);
    function GetValueMovement: Double;
    procedure SetValueMovement(const Value: Double);
    function GetMovementNumber: string;
    procedure SetMovementNumber(const Value: string);
    function GetDescription: string;
    procedure SetDescription(const Value: string);
    function GetHistoricalCode: string;
    procedure SetHistoricalCode(const Value: string);
    function GetDateType: string;
    procedure SetDateType(const Value: string);
    function GetUserCode: string;
    procedure SetUserCode(const Value: string);
    function GetStatus: string;
    procedure SetStatus(const Value: string);
    function GetVersion: Integer;
    procedure SetVersion(const Value: Integer);
    function GetInclude: TDateTime;
    procedure SetInclude(const Value: TDateTime);
    function GetUpdate: TDateTime;
    procedure SetUpdate(const Value: TDateTime);
  published
    property Id: Integer read GetId write SetId;
    property SagaOperationId: string read GetSagaOperationId write SetSagaOperationId;
    property RequestingService: string read GetRequestingService write SetRequestingService;
    property AccountNumber: string read GetAccountNumber write SetAccountNumber;
    property ValueMovement: Double read GetValueMovement write SetValueMovement;
    property MovementNumber: string read GetMovementNumber write SetMovementNumber;
    property Description: string read GetDescription write SetDescription;
    property HistoricalCode: string read GetHistoricalCode write SetHistoricalCode;
    property DateType: string read GetDateType write SetDateType;
    property UserCode: string read GetUserCode write SetUserCode;
    property Status: string read GetStatus write SetStatus;
    property Version: Integer read GetVersion write SetVersion;
    property Include: TDateTime read GetInclude write SetInclude;
    property Update: TDateTime read GetUpdate write SetUpdate;  
  end;


  TExtractItemDTO = class(TJsonDTO, IExtractItemDTO)

  private
    FNumberMovement: Integer;
    FTypeOperation: Integer;
    FDateInclusion: TDateTime;
    FDateMovement: TDateTime;
    FCodeHistorical: string;
    FDescriptionHistory: string;
    FTypeHistoric: string;
    FNature: string;
    FTypeNature: string;
    FValueMovement: Double;
    FPreviousBalance: Double;
    FValueCpmf: Double;
    FComplement: string;
    FCodeAlinea: string;
    FDocumentNumber: string;
    FCodeCategory: string;
    function GetNumberMovement: Integer;
    procedure SetNumberMovement(const Value: Integer);
    function GetTypeOperation: Integer;
    procedure SetTypeOperation(const Value: Integer);
    function GetDateInclusion: TDateTime;
    procedure SetDateInclusion(const Value: TDateTime);
    function GetDateMovement: TDateTime;
    procedure SetDateMovement(const Value: TDateTime);
    function GetCodeHistorical: string;
    procedure SetCodeHistorical(const Value: string);
    function GetDescriptionHistory: string;
    procedure SetDescriptionHistory(const Value: string);
    function GetTypeHistoric: string;
    procedure SetTypeHistoric(const Value: string);
    function GetNature: string;
    procedure SetNature(const Value: string);
    function GetTypeNature: string;
    procedure SetTypeNature(const Value: string);
    function GetValueMovement: Double;
    procedure SetValueMovement(const Value: Double);
    function GetPreviousBalance: Double;
    procedure SetPreviousBalance(const Value: Double);
    function GetValueCpmf: Double;
    procedure SetValueCpmf(const Value: Double);
    function GetComplement: string;
    procedure SetComplement(const Value: string);
    function GetCodeAlinea: string;
    procedure SetCodeAlinea(const Value: string);
    function GetDocumentNumber: string;
    procedure SetDocumentNumber(const Value: string);
    function GetCodeCategory: string;
    procedure SetCodeCategory(const Value: string);
  published
    property NumberMovement: Integer read GetNumberMovement write SetNumberMovement;
    property TypeOperation: Integer read GetTypeOperation write SetTypeOperation;
    property DateInclusion: TDateTime read GetDateInclusion write SetDateInclusion;
    property DateMovement: TDateTime read GetDateMovement write SetDateMovement;
    property CodeHistorical: string read GetCodeHistorical write SetCodeHistorical;
    property DescriptionHistory: string read GetDescriptionHistory write SetDescriptionHistory;
    property TypeHistoric: string read GetTypeHistoric write SetTypeHistoric;
    property Nature: string read GetNature write SetNature;
    property TypeNature: string read GetTypeNature write SetTypeNature;
    property ValueMovement: Double read GetValueMovement write SetValueMovement;
    property PreviousBalance: Double read GetPreviousBalance write SetPreviousBalance;
    property ValueCpmf: Double read GetValueCpmf write SetValueCpmf;
    property Complement: string read GetComplement write SetComplement;
    property CodeAlinea: string read GetCodeAlinea write SetCodeAlinea;
    property DocumentNumber: string read GetDocumentNumber write SetDocumentNumber;
    property CodeCategory: string read GetCodeCategory write SetCodeCategory;
  end;


  TExtractDTO = class(TJsonDTO, IExtractDTO)

  private
    FRecordOffset: Integer;
    FTotalRecords: Integer;
    FExtract: TObjectList;
    FExtract: TObjectList;
  public
    function GetItemClass(const APropName: string): TClass; override;
  published
    constructor Create;
    destructor Destroy; override;

    function GetRecordOffset: Integer;
    procedure SetRecordOffset(const Value: Integer);
    function GetTotalRecords: Integer;
    procedure SetTotalRecords(const Value: Integer);
    function GetExtract: TObjectList;
    procedure SetExtract(const Value: TObjectList);

    property RecordOffset: Integer read GetRecordOffset write SetRecordOffset;
    property TotalRecords: Integer read GetTotalRecords write SetTotalRecords;
    property Extract: TObjectList read GetExtract write SetExtract;
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

{ TSagaIdDTO }

function TSagaIdDTO.GetId: Integer;
begin
  Result := FId;
end;

procedure TSagaIdDTO.SetId(const Value: Integer);
begin
  FId := Value;
end;

function TSagaIdDTO.GetSagaOperationId: string;
begin
  Result := FSagaOperationId;
end;

procedure TSagaIdDTO.SetSagaOperationId(const Value: string);
begin
  FSagaOperationId := Value;
end;

function TSagaIdDTO.GetRequestingService: string;
begin
  Result := FRequestingService;
end;

procedure TSagaIdDTO.SetRequestingService(const Value: string);
begin
  FRequestingService := Value;
end;

function TSagaIdDTO.GetAccountNumber: string;
begin
  Result := FAccountNumber;
end;

procedure TSagaIdDTO.SetAccountNumber(const Value: string);
begin
  FAccountNumber := Value;
end;

function TSagaIdDTO.GetValueMovement: Double;
begin
  Result := FValueMovement;
end;

procedure TSagaIdDTO.SetValueMovement(const Value: Double);
begin
  FValueMovement := Value;
end;

function TSagaIdDTO.GetMovementNumber: string;
begin
  Result := FMovementNumber;
end;

procedure TSagaIdDTO.SetMovementNumber(const Value: string);
begin
  FMovementNumber := Value;
end;

function TSagaIdDTO.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TSagaIdDTO.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

function TSagaIdDTO.GetHistoricalCode: string;
begin
  Result := FHistoricalCode;
end;

procedure TSagaIdDTO.SetHistoricalCode(const Value: string);
begin
  FHistoricalCode := Value;
end;

function TSagaIdDTO.GetDateType: string;
begin
  Result := FDateType;
end;

procedure TSagaIdDTO.SetDateType(const Value: string);
begin
  FDateType := Value;
end;

function TSagaIdDTO.GetUserCode: string;
begin
  Result := FUserCode;
end;

procedure TSagaIdDTO.SetUserCode(const Value: string);
begin
  FUserCode := Value;
end;

function TSagaIdDTO.GetStatus: string;
begin
  Result := FStatus;
end;

procedure TSagaIdDTO.SetStatus(const Value: string);
begin
  FStatus := Value;
end;

function TSagaIdDTO.GetVersion: Integer;
begin
  Result := FVersion;
end;

procedure TSagaIdDTO.SetVersion(const Value: Integer);
begin
  FVersion := Value;
end;

function TSagaIdDTO.GetInclude: TDateTime;
begin
  Result := FInclude;
end;

procedure TSagaIdDTO.SetInclude(const Value: TDateTime);
begin
  FInclude := Value;
end;

function TSagaIdDTO.GetUpdate: TDateTime;
begin
  Result := FUpdate;
end;

procedure TSagaIdDTO.SetUpdate(const Value: TDateTime);
begin
  FUpdate := Value;
end;

{ TExtractDTO }

function TExtractDTO.GetItemClass(const APropName: string): TClass;
begin
  WriteLn('TExtractDTO.GetItemClass called for: ', APropName);
  // Default logic or specific check
  if SameText(APropName, 'Extract') then
    Result := TExtractItemDTO
  else
    Result := inherited GetItemClass(APropName);
end;

constructor TExtractDTO.Create;
begin
  inherited Create;
  FExtract := TObjectList.Create(True);
end;

destructor TExtractDTO.Destroy;
begin
  FExtract.Free;
  inherited Destroy;
end;

function TExtractDTO.GetRecordOffset: Integer;
begin
  Result := FRecordOffset;
end;

procedure TExtractDTO.SetRecordOffset(const Value: Integer);
begin
  FRecordOffset := Value;
end;

function TExtractDTO.GetTotalRecords: Integer;
begin
  Result := FTotalRecords;
end;

procedure TExtractDTO.SetTotalRecords(const Value: Integer);
begin
  FTotalRecords := Value;
end;

function TExtractDTO.GetExtract: TObjectList;
begin
  Result := FExtract;
end;

procedure TExtractDTO.SetExtract(const Value: TObjectList);
begin
  if FExtract <> Value then
  begin
    FExtract.Free;
    FExtract := Value;
  end;
end;

{ TExtractItemDTO }

function TExtractItemDTO.GetNumberMovement: Integer;
begin
  Result := FNumberMovement;
end;

procedure TExtractItemDTO.SetNumberMovement(const Value: Integer);
begin
  FNumberMovement := Value;
end;

function TExtractItemDTO.GetTypeOperation: Integer;
begin
  Result := FTypeOperation;
end;

procedure TExtractItemDTO.SetTypeOperation(const Value: Integer);
begin
  FTypeOperation := Value;
end;

function TExtractItemDTO.GetDateInclusion: TDateTime;
begin
  Result := FDateInclusion;
end;

procedure TExtractItemDTO.SetDateInclusion(const Value: TDateTime);
begin
  FDateInclusion := Value;
end;

function TExtractItemDTO.GetDateMovement: TDateTime;
begin
  Result := FDateMovement;
end;

procedure TExtractItemDTO.SetDateMovement(const Value: TDateTime);
begin
  FDateMovement := Value;
end;

function TExtractItemDTO.GetCodeHistorical: string;
begin
  Result := FCodeHistorical;
end;

procedure TExtractItemDTO.SetCodeHistorical(const Value: string);
begin
  FCodeHistorical := Value;
end;

function TExtractItemDTO.GetDescriptionHistory: string;
begin
  Result := FDescriptionHistory;
end;

procedure TExtractItemDTO.SetDescriptionHistory(const Value: string);
begin
  FDescriptionHistory := Value;
end;

function TExtractItemDTO.GetTypeHistoric: string;
begin
  Result := FTypeHistoric;
end;

procedure TExtractItemDTO.SetTypeHistoric(const Value: string);
begin
  FTypeHistoric := Value;
end;

function TExtractItemDTO.GetNature: string;
begin
  Result := FNature;
end;

procedure TExtractItemDTO.SetNature(const Value: string);
begin
  FNature := Value;
end;

function TExtractItemDTO.GetTypeNature: string;
begin
  Result := FTypeNature;
end;

procedure TExtractItemDTO.SetTypeNature(const Value: string);
begin
  FTypeNature := Value;
end;

function TExtractItemDTO.GetValueMovement: Double;
begin
  Result := FValueMovement;
end;

procedure TExtractItemDTO.SetValueMovement(const Value: Double);
begin
  FValueMovement := Value;
end;

function TExtractItemDTO.GetPreviousBalance: Double;
begin
  Result := FPreviousBalance;
end;

procedure TExtractItemDTO.SetPreviousBalance(const Value: Double);
begin
  FPreviousBalance := Value;
end;

function TExtractItemDTO.GetValueCpmf: Double;
begin
  Result := FValueCpmf;
end;

procedure TExtractItemDTO.SetValueCpmf(const Value: Double);
begin
  FValueCpmf := Value;
end;

function TExtractItemDTO.GetComplement: string;
begin
  Result := FComplement;
end;

procedure TExtractItemDTO.SetComplement(const Value: string);
begin
  FComplement := Value;
end;

function TExtractItemDTO.GetCodeAlinea: string;
begin
  Result := FCodeAlinea;
end;

procedure TExtractItemDTO.SetCodeAlinea(const Value: string);
begin
  FCodeAlinea := Value;
end;

function TExtractItemDTO.GetDocumentNumber: string;
begin
  Result := FDocumentNumber;
end;

procedure TExtractItemDTO.SetDocumentNumber(const Value: string);
begin
  FDocumentNumber := Value;
end;

function TExtractItemDTO.GetCodeCategory: string;
begin
  Result := FCodeCategory;
end;

procedure TExtractItemDTO.SetCodeCategory(const Value: string);
begin
  FCodeCategory := Value;
end;

end.
