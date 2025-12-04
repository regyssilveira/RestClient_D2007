unit RestClient.TokenManager;

interface

uses
  Classes, SysUtils, DateUtils, RestClient.Interfaces;

type
  TOAuthTokenManager = class(TInterfacedObject, IOAuthTokenManager)
  private
    FTokenEndpoint: string;
    FClientId: string;
    FClientSecret: string;
    FAccessToken: string;
    FExpiresAt: TDateTime;
    FClient: Pointer; // Weak reference to IRestClient
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
  SuperObject;

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
  FClient := Pointer(AClient);
end;

function TOAuthTokenManager.GetClient: IRestClient;
begin
  if FClient <> nil then
    Result := IRestClient(FClient)
  else
    Result := nil;
end;

procedure TOAuthTokenManager.RequestNewToken;
var
  LClient: IRestClient;
  LResponse: IRestResponse;
  LJson: ISuperObject;
  LExpiresIn: Integer;
begin
  LClient := GetClient;
  if LClient = nil then
    raise Exception.Create('RestClient not assigned to TokenManager');

  try
    LResponse := LClient.CreateRequest
      .Resource(FTokenEndpoint)
      .IgnoreToken // Important to prevent recursion
      .AddParam('grant_type', 'client_credentials')
      .AddParam('client_id', FClientId)
      .AddParam('client_secret', FClientSecret)
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
        raise Exception.Create('Invalid JSON response from token endpoint');
    end
    else
      raise Exception.Create('Failed to obtain access token. Status: ' + IntToStr(LResponse.StatusCode) + ', Content: ' + LResponse.Content);
      
  except
    on E: Exception do
      raise Exception.Create('Failed to obtain access token: ' + E.Message);
  end;
end;

end.
