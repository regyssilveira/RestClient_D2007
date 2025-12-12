unit Service.Transaction;

interface

uses
  SysUtils, Classes, SuperObject, TypInfo, RestClient.Interfaces, RestClient.Core, Service.DTO.Base;

type
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
  end;

  TTransactionService = class(TInterfacedObject, ITransactionService)
  private
    FClient: IRestClient;
  public
    constructor Create(const ABaseURL, ATokenEndpoint, AClientId, AClientSecret: string);
    function GetSaldo(const AAccountNumber, ABankBranch, AOriginSystem: string): TBalanceDTO;
  end;

implementation

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
    begin
      Result.FromJson(LResponse.ContentAsJson);
    end
    else
    begin
      // Handle error or raise exception
      raise Exception.CreateFmt('Erro ao consultar saldo. Status: %d. Erro: %s', [LResponse.StatusCode, LResponse.Content]);
    end;
  except
    Result.Free;
    raise;
  end;
end;

end.
