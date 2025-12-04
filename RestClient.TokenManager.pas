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
    procedure RequestNewToken;
  public
    constructor Create(const ATokenEndpoint, AClientId, AClientSecret: string);
    function GetAccessToken: string;
    procedure ForceRefresh;
  end;

implementation

uses
  IdHTTP, IdSSLOpenSSL, SuperObject; // Assuming SuperObject for JSON parsing, or we can use string manipulation if preferred for D2007

{ TOAuthTokenManager }

constructor TOAuthTokenManager.Create(const ATokenEndpoint, AClientId, AClientSecret: string);
begin
  inherited Create;
  FTokenEndpoint := ATokenEndpoint;
  FClientId := AClientId;
  FClientSecret := AClientSecret;
  FAccessToken := '';
  FExpiresAt := 0;
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

procedure TOAuthTokenManager.RequestNewToken;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LParams: TStringList;
  LResponse: string;
  LJson: ISuperObject; // Using SuperObject for JSON parsing
  LExpiresIn: Integer;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LParams := TStringList.Create;
  try
    LHttp.IOHandler := LSSL;
    LSSL.SSLOptions.Method := sslvTLSv1_2; // Ensure TLS 1.2
    LSSL.SSLOptions.Mode := sslmClient;

    LParams.Add('grant_type=client_credentials');
    LParams.Add('client_id=' + FClientId);
    LParams.Add('client_secret=' + FClientSecret);
  finally
    LParams.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;

end.
