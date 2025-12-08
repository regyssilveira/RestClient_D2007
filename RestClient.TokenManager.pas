unit RestClient.TokenManager;

interface

uses
  Classes,
  SysUtils,
  DateUtils,
  RestClient.Interfaces;

type
  TOAuthTokenManager = class(TInterfacedObject, IOAuthTokenManager)
  private
    FTokenEndpoint: string;
    FClientId: string;
    FClientSecret: string;
    FAccessToken: string;
    FExpiresAt: TDateTime;
    FClient: IRestClient;
    function GetClient: IRestClient;
    procedure RequestNewToken;
  public
    constructor Create(const ATokenEndpoint, AClientId, AClientSecret: string);
    function GetAccessToken: string;
    procedure ForceRefresh;
    procedure SetClient(const AClient: IRestClient);
  end;

implementation

uses
  SuperObject, IdURI;

{ TOAuthTokenManager }

constructor TOAuthTokenManager.Create(const ATokenEndpoint, AClientId, AClientSecret: string);
begin
  inherited Create;
  FTokenEndpoint := ATokenEndpoint;
  FClientId := AClientId;
  FClientSecret := AClientSecret;
  FAccessToken := '';
  FExpiresAt := 0;
  FClient := nil;
end;

procedure TOAuthTokenManager.ForceRefresh;
begin
  FExpiresAt := 0;
end;

function TOAuthTokenManager.GetAccessToken: string;
begin
  if (FAccessToken = '') or (Now >= FExpiresAt) then
    RequestNewToken;
  Result := FAccessToken;
end;

procedure TOAuthTokenManager.SetClient(const AClient: IRestClient);
begin
  FClient := AClient;
end;

function TOAuthTokenManager.GetClient: IRestClient;
begin
  if FClient <> nil then
    Result := FClient
  else
    Result := nil;
end;

procedure TOAuthTokenManager.RequestNewToken;
var
  LClient: IRestClient;
  LResponse: IRestResponse;
  LJson: ISuperObject;
  LExpiresIn: Integer;
  LBody: string;
begin
  LClient := GetClient;
  if LClient = nil then
    raise Exception.Create('RestClient não foi linkado corretamente ao token manager');

  try
    LBody := 'grant_type=client_credentials'
           + '&client_id=' + TIdURI.ParamsEncode(FClientId)
           + '&client_secret=' + TIdURI.ParamsEncode(FClientSecret);

    LResponse := LClient.CreateRequest
      .Resource(FTokenEndpoint)
      .IgnoreToken
      .AddBody(LBody, 'application/x-www-form-urlencoded')
      .Execute(rmPOST);
      
    if LResponse.StatusCode = 200 then
    begin
      LJson := LResponse.ContentAsJson;
      if Assigned(LJson) then
      begin
        FAccessToken := LJson.S['access_token'];
        LExpiresIn := LJson.I['expires_in'];
        
        if LExpiresIn <= 0 then
          LExpiresIn := 3600;
          
        FExpiresAt := IncSecond(Now, LExpiresIn - 10);
      end
      else
        raise Exception.Create('Json de resposta inválido');
    end
    else
      raise Exception.Create('Falha ao obter o token de acesso. Status: ' + IntToStr(LResponse.StatusCode) + ', Conteúdo: ' + LResponse.Content);

  except
    on E: Exception do
      raise Exception.Create('Falha ao obter o token de acesso: ' + E.Message);
  end;
end;

end.
