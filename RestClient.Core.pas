unit RestClient.Core;

interface

uses
  Classes, SysUtils, IdHTTP, IdSSLOpenSSL, IdMultipartFormData,
  RestClient.Interfaces, RestClient.TokenManager, RestClient.Response, RestClient.Request;

type
  TRestClient = class(TInterfacedObject, IRestClient)
  private
    FBaseURL: string;
    FTokenManager: IOAuthTokenManager;
    FIdHTTP: TIdHTTP;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    procedure ConfigureSSL;
    procedure PrepareRequest(ARequest: TRestRequest);
  public
    constructor Create(const ABaseURL: string; const ATokenEndpoint, AClientId, AClientSecret: string);
    destructor Destroy; override;

    function CreateRequest: IRestRequest;
    function GetBaseURL: string;
    procedure SetBaseURL(const AValue: string);
    
    // Public but not in IRestClient (used by TRestRequest)
    function ExecuteRequest(ARequest: TRestRequest; AMethod: THTTPMethod): IRestResponse;
  end;

implementation

{ TRestClient }

constructor TRestClient.Create(const ABaseURL: string; const ATokenEndpoint, AClientId, AClientSecret: string);
begin
  inherited Create;
  FBaseURL := ABaseURL;
  if (ATokenEndpoint <> '') and (AClientId <> '') then
    FTokenManager := TOAuthTokenManager.Create(ATokenEndpoint, AClientId, AClientSecret)
  else
    FTokenManager := nil;
    
  FIdHTTP := TIdHTTP.Create(nil);
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FIdHTTP.IOHandler := FSSLHandler;
  ConfigureSSL;
end;

destructor TRestClient.Destroy;
begin
  FSSLHandler.Free;
  FIdHTTP.Free;
  inherited;
end;

procedure TRestClient.ConfigureSSL;
begin
  FSSLHandler.SSLOptions.Method := sslvTLSv1_2;
  FSSLHandler.SSLOptions.Mode := sslmClient;
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

procedure TRestClient.PrepareRequest(ARequest: TRestRequest);
var
  I: Integer;
  LName, LValue: string;
begin
  FIdHTTP.Request.Clear;
  FIdHTTP.Request.CustomHeaders.Clear;
  
  // Add Headers
  for I := 0 to ARequest.Headers.Count - 1 do
  begin
    FIdHTTP.Request.CustomHeaders.Add(ARequest.Headers[I]);
  end;

  // Add Auth Token if available
  if Assigned(FTokenManager) then
  begin
    FIdHTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + FTokenManager.GetAccessToken;
  end;
  
  // Content Type
  if ARequest.BodyContentType <> '' then
    FIdHTTP.Request.ContentType := ARequest.BodyContentType;
end;

function TRestClient.ExecuteRequest(ARequest: TRestRequest; AMethod: THTTPMethod): IRestResponse;
var
  LUrl: string;
  LResponseStream: TStringStream;
  LBodyStream: TStringStream;
  LMultiPart: TIdMultiPartFormDataStream;
  I: Integer;
  LPart: TRequestPart;
begin
  PrepareRequest(ARequest);
  
  LUrl := ARequest.GetFullUrl;
  
  // Append Query Params to URL
  if ARequest.Params.Count > 0 then
  begin
    if Pos('?', LUrl) = 0 then
      LUrl := LUrl + '?'
    else
      LUrl := LUrl + '&';
    LUrl := LUrl + ARequest.Params.DelimitedText; // Assuming standard URL encoding is handled or simple key=value
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
            if ARequest.Parts.Count > 0 then
            begin
              // Multipart Form Data
              LMultiPart := TIdMultiPartFormDataStream.Create;
              try
                for I := 0 to ARequest.Parts.Count - 1 do
                begin
                  LPart := TRequestPart(ARequest.Parts[I]);
                  if LPart.FileName <> '' then
                    LMultiPart.AddFormField(LPart.Name, LPart.ContentType, LPart.Charset, LPart.Stream, LPart.FileName)
                  else
                    LMultiPart.AddFormField(LPart.Name, LPart.Value);
                end;
                FIdHTTP.Post(LUrl, LMultiPart, LResponseStream);
              finally
                LMultiPart.Free;
              end;
            end
            else
            begin
              // Raw Body
              LBodyStream := TStringStream.Create(ARequest.Body);
              try
                FIdHTTP.Post(LUrl, LBodyStream, LResponseStream);
              finally
                LBodyStream.Free;
              end;
            end;
          end;
          
        rmPUT:
          begin
             LBodyStream := TStringStream.Create(ARequest.Body);
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
        // Handle HTTP errors (4xx, 5xx) gracefully by returning a response object
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
