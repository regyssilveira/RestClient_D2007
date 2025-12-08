unit RestClient.Core;

interface

uses
  Classes,
  SysUtils,
  Dialogs,

  superobject,

  IdHTTP,
  IdCompressorZLib,
  IdSSLOpenSSL,
  IdStack,
  IdMultipartFormData,

  RestClient.Interfaces,
  RestClient.TokenManager,
  RestClient.Response,
  RestClient.Request;

type
  TRestClient = class(TInterfacedObject, IRestClient)
  private
    FBaseURL: string;
    FClientId: String;
    FClientSecret: String;
    FTokenManager: IOAuthTokenManager;
    FIdHTTP: TIdHTTP;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  public
    constructor Create(const ABaseURL: string; const ATokenEndpoint, AClientId, AClientSecret: string);
    destructor Destroy; override;

    function CreateRequest: IRestRequest;
    function GetBaseURL: string;
    procedure SetBaseURL(const AValue: string);
    
    function ExecuteRequest(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
    function UpdateToken: String;
  end;

implementation

{ TRestClient }

constructor TRestClient.Create(const ABaseURL: string; const ATokenEndpoint, AClientId, AClientSecret: string);
begin
  inherited Create;

  FBaseURL      := ABaseURL;
  FClientId     := AClientId;
  FClientSecret := AClientSecret;

  if (ATokenEndpoint <> '') and (AClientId <> '') then
  begin
    FTokenManager := TOAuthTokenManager.Create(ATokenEndpoint, AClientId, AClientSecret);
    FTokenManager.SetClient(Self);
  end
  else
    FTokenManager := nil;
    
  FIdHTTP := TIdHTTP.Create(nil);
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP);

  // SSSL
  FSSLHandler.SSLOptions.Method      := sslvTLSv1_2;
  FSSLHandler.SSLOptions.Mode        := sslmClient;
  FSSLHandler.SSLOptions.VerifyMode  := [];
  FSSLHandler.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];

  // client http indy
  FIdHTTP.IOHandler                       := FSSLHandler;
  FIdHTTP.HandleRedirects                 := True;
  FIdHTTP.Request.CustomHeaders.FoldLines := False;
end;

destructor TRestClient.Destroy;
begin
  FSSLHandler.Free;
  FIdHTTP.Free;
  inherited;
end;

function TRestClient.CreateRequest: IRestRequest;
begin
  Result := TRestRequest.Create(Self);
end;

function TRestClient.GetBaseURL: string;
begin
  Result := FBaseURL;
end;

procedure TRestClient.SetBaseURL(const AValue: string);
begin
  FBaseURL := AValue;
end;

function TRestClient.UpdateToken: String;
begin
  if Assigned(FTokenManager) then
    Result := FTokenManager.GetAccessToken
  else
    Result := '';
end;

function TRestClient.ExecuteRequest(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
var
  LUrl: string;
  LResponseStream: TStringStream;
  LBodyStream: TStringStream;
  LMultiPart: TIdMultiPartFormDataStream;
  I: Integer;
  LPart: TRequestPart;
  LParts: TList;
  LParams: TStrings;
begin
  FIdHTTP.Request.Clear;
  FIdHTTP.Request.CustomHeaders.Clear;

  if Trim(FClientId) <> '' then
    FIdHTTP.Request.Password := FClientId;

  if Trim(FClientSecret) <> '' then
    FIdHTTP.Request.Username := FClientSecret;

  FIdHTTP.Request.UserAgent := 'InterCredPJ (compatible; Delphi 2007)';
  FIdHTTP.Request.Accept    := 'application/json';//'text/html,application/json,x-www-form-urlencoded,*/*';
  FIdHTTP.Request.CharSet   := 'utf-8';

  // Add Headers
  for I := 0 to ARequest.GetHeaders.Count - 1 do
    FIdHTTP.Request.CustomHeaders.Add(ARequest.GetHeaders[I]);

  if Assigned(FTokenManager) and (not ARequest.ShouldIgnoreToken) then
    FIdHTTP.Request.CustomHeaders.Values['x-api-token'] := UTF8Encode(FTokenManager.GetAccessToken);

  if ARequest.GetBodyContentType <> '' then
    FIdHTTP.Request.ContentType := ARequest.GetBodyContentType;
  
  LUrl := ARequest.GetFullUrl;
  
  // Append Query Params
  LParams := ARequest.GetParams;
  if LParams.Count > 0 then
  begin
    if Pos('?', LUrl) = 0 then
      LUrl := LUrl + '?'
    else
      LUrl := LUrl + '&';
    LUrl := LUrl + LParams.DelimitedText;
  end;

  LResponseStream := TStringStream.Create('');
  try
    try
      case AMethod of
        rmGET:
          begin
            FIdHTTP.Get(LUrl, LResponseStream);
          end;
          
        rmPOST:
          begin
            LParts := ARequest.GetParts;
            if LParts.Count > 0 then
            begin
              // Multipart Form Data
              LMultiPart := TIdMultiPartFormDataStream.Create;
              try
                for I := 0 to LParts.Count - 1 do
                begin
                  LPart := TRequestPart(LParts[I]);
                  if LPart.FileName <> '' then
                    LMultiPart.AddFormField(LPart.Name, LPart.ContentType, LPart.Charset, LPart.Stream, LPart.FileName)
                  else
                    LMultiPart.AddFormField(LPart.Name, UTF8Encode(LPart.Value));
                end;
                FIdHTTP.Post(LUrl, LMultiPart, LResponseStream);
              finally
                LMultiPart.Free;
              end;
            end
            else
            begin
              // Raw Body
              LBodyStream := TStringStream.Create(ARequest.GetBody);
              try
                FIdHTTP.Post(LUrl, LBodyStream, LResponseStream);
              finally
                LBodyStream.Free;
              end;
            end;
          end;
          
        rmPUT:
          begin
             LBodyStream := TStringStream.Create(ARequest.GetBody);
              try
                FIdHTTP.Put(LUrl, LBodyStream, LResponseStream);
              finally
                LBodyStream.Free;
              end;
          end;
          
        rmDELETE:
          begin
            FIdHTTP.Delete(LUrl, LResponseStream);
          end;
      end;
      
      Result := TRestResponse.Create(FIdHTTP.ResponseCode, LResponseStream.DataString, FIdHTTP.Response.RawHeaders);
      
    except
      on E: EIdHTTPProtocolException do
      begin
        Result := TRestResponse.Create(FIdHTTP.ResponseCode, E.ErrorMessage, FIdHTTP.Response.RawHeaders);
      end;
      on E: Exception do
        raise;
    end;
  finally
    LResponseStream.Free;
  end;
end;

end.


