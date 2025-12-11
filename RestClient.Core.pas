unit RestClient.Core;

interface

uses
  Classes,
  SysUtils,
  Dialogs,
  Windows,
  WinInet, 

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
  TRestClientType = (rtIndy, rtWinInet);

  TRestClient = class(TInterfacedObject, IRestClient)
  private
    FBaseURL: string;
    FClientId: String;
    FClientSecret: String;
    FTokenManager: IOAuthTokenManager;
    FIdHTTP: TIdHTTP;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FType: TRestClientType;

    function SSLVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
    
    // Internal execution methods
    function ExecuteRequestIndy(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
    function ExecuteRequestWinInet(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
  public
    constructor Create(const ABaseURL: string; AType: TRestClientType = rtIndy; const ATokenEndpoint: String = ''; const AClientId: String = ''; const AClientSecret: string = '');
    destructor Destroy; override;

    function CreateRequest: IRestRequest;
    function GetBaseURL: string;
    procedure SetBaseURL(const AValue: string);
    
    function ExecuteRequest(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
    function ObterToken: String;
  end;

implementation

uses
  StrUtils;

{ TRestClient }

constructor TRestClient.Create(const ABaseURL: string; AType: TRestClientType = rtIndy; const ATokenEndpoint: String = ''; const AClientId: String = ''; const AClientSecret: string = '');
begin
  inherited Create;

  FBaseURL      := ABaseURL;
  FClientId     := AClientId;
  FClientSecret := AClientSecret;
  FType         := AType;

  if (ATokenEndpoint <> '') and (AClientId <> '') then
  begin
    FTokenManager := TOAuthTokenManager.Create(ATokenEndpoint, AClientId, AClientSecret);
    FTokenManager.SetClient(Self);
  end
  else
    FTokenManager := nil;
    
  if FType = rtIndy then
  begin
    FIdHTTP := TIdHTTP.Create(nil);
    FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP);

    // SSSL
    FSSLHandler.SSLOptions.Method      := sslvTLSv1_2;
    FSSLHandler.SSLOptions.Mode        := sslmClient;
    FSSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2]; //sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1, sslvTLSv1_1,
    FSSLHandler.SSLOptions.VerifyMode  := [];
    FSSLHandler.SSLOptions.VerifyDepth := 0;
    FSSLHandler.OnVerifyPeer           := SSLVerifyPeer;

    // client http indy
    FIdHTTP.IOHandler       := FSSLHandler;
    FIdHTTP.HandleRedirects := True;
    FIdHTTP.Request.CustomHeaders.FoldLines := False;
  end;
end;

destructor TRestClient.Destroy;
begin
  if Assigned(FSSLHandler) then
    FSSLHandler.Free;
  if Assigned(FIdHTTP) then
    FIdHTTP.Free;
  inherited;
end;

function TRestClient.SSLVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
begin
  Result := True;
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

function TRestClient.ObterToken: String;
begin
  if Assigned(FTokenManager) then
    Result := FTokenManager.GetAccessToken
  else
    Result := '';
end;

function TRestClient.ExecuteRequest(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
begin
  case FType of
    rtIndy: Result := ExecuteRequestIndy(ARequest, AMethod);
    rtWinInet: Result := ExecuteRequestWinInet(ARequest, AMethod);
  else
    raise Exception.Create('Invalid RestClient Type');
  end;
end;

function TRestClient.ExecuteRequestWinInet(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
var
  hInternet, hConnect, hRequest: Pointer;
  LRetries: Integer;
  LResponseBuffer: TStringStream;
  LBytesRead: DWORD;
  LBuffer: array[0..4095] of AnsiChar;
  LHeaders: string;
  LURLHost, LURLPath: string;
  LURLPort: Word;
  LMethodStr: string;
  LFullUrl: string;
  LParams: TStrings;
  I: Integer;
  LDataStream: TStream;
  LMultiPart: TIdMultiPartFormDataStream;
  LParts: TList;
  LPart: TRequestPart;
  LPPostBuffer: Pointer;
  LPostSize: LongWord;
  LStatusCode: DWORD;
  LRawHeaders: TStringList;
  LLen: DWORD;
  LHeaderIndex: DWORD;
  LRawHeadersBuffer: PAnsiChar;
  LTempUrl: string;
  LIsSSL: Boolean;
  LSlashPos, LColonPos: Integer;
  LFlags: DWORD;
begin
  Result := nil;
  LDataStream := nil;
  LMultiPart := nil;
  LResponseBuffer := TStringStream.Create('');
  LRawHeaders := TStringList.Create;
  try
    LRawHeaders.Text := '';
    try
      LFullUrl := ARequest.GetFullUrl;

      LParams := ARequest.GetParams;
      if LParams.Count > 0 then
      begin
        if Pos('?', LFullUrl) = 0 then
          LFullUrl := LFullUrl + '?'
        else
          LFullUrl := LFullUrl + '&';

        for I := 0 to LParams.Count - 1 do
        begin
          if I > 0 then LFullUrl := LFullUrl + '&';
          LFullUrl := LFullUrl + LParams[I];
        end;
      end;

      LTempUrl := LFullUrl;
      LIsSSL := False;
      LURLPort := 0;

      if Pos('https://', LowerCase(LTempUrl)) = 1 then
      begin
        LIsSSL := True;
        Delete(LTempUrl, 1, 8);
        LURLPort := 443;
      end
      else if Pos('http://', LowerCase(LTempUrl)) = 1 then
      begin
        Delete(LTempUrl, 1, 7);
        LURLPort := 80;
      end;

      LSlashPos := Pos('/', LTempUrl);
      if LSlashPos > 0 then
      begin
        LURLHost := Copy(LTempUrl, 1, LSlashPos - 1);
        LURLPath := Copy(LTempUrl, LSlashPos, Length(LTempUrl));
      end
      else
      begin
        LURLHost := LTempUrl;
        LURLPath := '/';
      end;
      
      LColonPos := Pos(':', LURLHost);
      if LColonPos > 0 then
      begin
        LURLPort := StrToIntDef(Copy(LURLHost, LColonPos + 1, Length(LURLHost)), LURLPort);
        LURLHost := Copy(LURLHost, 1, LColonPos - 1);
      end;

      if LURLPort = 0 then
        LURLPort := 80;

      case AMethod of
        rmGET:    LMethodStr := 'GET';
        rmPOST:   LMethodStr := 'POST';
        rmPUT:    LMethodStr := 'PUT';
        rmDELETE: LMethodStr := 'DELETE';
        rmPATCH:  LMethodStr := 'PATCH';
      end;

      if (AMethod in [rmPOST, rmPUT, rmPATCH]) then
      begin
          LParts := ARequest.GetParts;
          if (LParts <> nil) and (LParts.Count > 0) then
          begin
             LMultiPart := TIdMultiPartFormDataStream.Create;
             for I := 0 to LParts.Count - 1 do
              begin
                LPart := TRequestPart(LParts[I]);
                if LPart.FileName <> '' then
                  LMultiPart.AddFormField(LPart.Name, LPart.ContentType, LPart.Charset, LPart.Stream, LPart.FileName)
                else
                  LMultiPart.AddFormField(LPart.Name, UTF8Encode(LPart.Value));
              end;
              LDataStream := LMultiPart;
          end
          else
          begin
              if ARequest.GetBody <> '' then
              begin
                LDataStream := TStringStream.Create(ARequest.GetBody);
              end;
          end;
      end;

      hInternet := InternetOpen(PChar('InterCredPJ (compatible; Delphi 2007)'),
                                INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
      if hInternet = nil then RaiseLastOSError;
      
      try
        hConnect := InternetConnect(hInternet, PChar(LURLHost), LURLPort, 
                                    nil, 
                                    nil,
                                    INTERNET_SERVICE_HTTP, 0, 0);
                                    
        if hConnect = nil then
          RaiseLastOSError;
        
        try
          LFlags := INTERNET_FLAG_RELOAD or INTERNET_FLAG_KEEP_CONNECTION;
          if LIsSSL then
            LFlags := LFlags or INTERNET_FLAG_SECURE or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID;
            
          hRequest := HttpOpenRequest(hConnect, PChar(LMethodStr), PChar(LURLPath), nil, nil, nil, LFlags, 0);
          if hRequest = nil then
            RaiseLastOSError;
          
          try
             LHeaders := '';
             if ARequest.GetBodyContentType = '' then
               LHeaders := LHeaders + 'Accept: application/json' + #13#10
             else
               LHeaders := LHeaders + 'Accept: ' + ARequest.GetBodyContentType + #13#10;
               
             for I := 0 to ARequest.GetHeaders.Count - 1 do
               LHeaders := LHeaders + ARequest.GetHeaders[I] + #13#10;
             
             if Assigned(FTokenManager) and (not ARequest.ShouldIgnoreToken) then
               LHeaders := LHeaders + 'x-api-token: ' + UTF8Encode(FTokenManager.GetAccessToken) + #13#10
             else
             begin
                // if Assigned(FTokenManager) then ... else ...
             end;

             if Assigned(LMultiPart) then
               LHeaders := LHeaders + 'Content-Type: ' + LMultiPart.RequestContentType + #13#10
             else if ARequest.GetBodyContentType <> '' then
               LHeaders := LHeaders + 'Content-Type: ' + ARequest.GetBodyContentType + #13#10;

             HttpAddRequestHeaders(hRequest, PChar(LHeaders), Length(LHeaders), HTTP_ADDREQ_FLAG_ADD or HTTP_ADDREQ_FLAG_REPLACE);
             
             LPostSize := 0;
             LPPostBuffer := nil;
             if Assigned(LDataStream) then
             begin
               LDataStream.Position := 0;
               LPostSize := LDataStream.Size;
               if LPostSize > 0 then
               begin
                 GetMem(LPPostBuffer, LPostSize);
                 LDataStream.Read(LPPostBuffer^, LPostSize);
               end;
             end;
             
             try
                LRetries := 0;
                while True do
                begin
                  if HttpSendRequest(hRequest, nil, 0, LPPostBuffer, LPostSize) then
                    Break;
                  
                  // ERROR_INTERNET_CLIENT_AUTH_CERT_NEEDED (12044)
                  if (GetLastError = 12044) and (LRetries = 0) then
                  begin
                    // INTERNET_OPTION_SECURITY_SELECT_CLIENT_CERT (87)
                    // Select "no certificate" by passing nil/0 and retry
                    InternetSetOption(hRequest, 87, nil, 0);
                    Inc(LRetries);
                    Continue;
                  end;
                  
                  RaiseLastOSError;
                end;
             finally
               if Assigned(LPPostBuffer) then
                 FreeMem(LPPostBuffer);
             end;
             
             LLen := SizeOf(DWORD);
             LHeaderIndex := 0;
             LStatusCode := 0;
             if not HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER, @LStatusCode, LLen, LHeaderIndex) then
               LStatusCode := 0; 
             
             LRawHeaders.Text := '';
             LLen := 0;
             LHeaderIndex := 0;
             HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, nil, LLen, LHeaderIndex);
             if (GetLastError = ERROR_INSUFFICIENT_BUFFER) and (LLen > 0) then
             begin
               GetMem(LRawHeadersBuffer, LLen);
               try
                 if HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, LRawHeadersBuffer, LLen, LHeaderIndex) then
                   LRawHeaders.Text := StrPas(LRawHeadersBuffer);
               finally
                 FreeMem(LRawHeadersBuffer);
               end;
             end;
             
             repeat
               if not InternetReadFile(hRequest, @LBuffer, SizeOf(LBuffer), LBytesRead) then
                 Break;
               if LBytesRead = 0 then Break;
               LResponseBuffer.Write(LBuffer, LBytesRead);
             until False;
             
             Result := TRestResponse.Create(LStatusCode, LResponseBuffer.DataString, LRawHeaders);
             
          finally
            InternetCloseHandle(hRequest);
          end;
        finally
          InternetCloseHandle(hConnect);
        end;
      finally
        InternetCloseHandle(hInternet);
      end;
    except
      on E: Exception do
      begin
         Result := TRestResponse.Create(500, E.Message, LRawHeaders);
      end;
    end;
  finally
    LRawHeaders.Free;
    LResponseBuffer.Free;
    if Assigned(LMultiPart) then LMultiPart.Free
    else if Assigned(LDataStream) then LDataStream.Free;
  end;
end;

function TRestClient.ExecuteRequestIndy(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
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
    FIdHTTP.Request.Username := FClientId;

  if Trim(FClientSecret) <> '' then
    FIdHTTP.Request.Password := FClientSecret;

  FIdHTTP.Request.CustomHeaders.FoldLines := False;
  FIdHTTP.Request.UserAgent               := 'InterCredPJ (compatible; Delphi 2007)';
  FIdHTTP.Request.Accept                  := 'application/json';//'text/html,application/json,x-www-form-urlencoded,*/*';
  FIdHTTP.Request.CharSet                 := 'utf-8';

  // Add Headers
  for I := 0 to ARequest.GetHeaders.Count - 1 do
    FIdHTTP.Request.CustomHeaders.Add(ARequest.GetHeaders[I]);

  if Assigned(FTokenManager) and (not ARequest.ShouldIgnoreToken) then
    FIdHTTP.Request.CustomHeaders.Values['x-api-token'] := UTF8Encode(FTokenManager.GetAccessToken);

  if ARequest.GetBodyContentType <> '' then
    FIdHTTP.Request.ContentType := ARequest.GetBodyContentType;
  
  LUrl := ARequest.GetFullUrl;
  
  LParams := ARequest.GetParams;
  if LParams.Count > 0 then
  begin
    if Pos('?', LUrl) = 0 then
      LUrl := LUrl + '?'
    else
      LUrl := LUrl + '&';

    for I := 0 to LParams.Count - 1 do
    begin
        if I > 0 then LUrl := LUrl + '&';
        LUrl := LUrl + LParams[I];
    end;
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
        Result := TRestResponse.Create(
          FIdHTTP.ResponseCode,
          IfThen(Trim(FIdHTTP.ResponseText) = '', E.ErrorMessage, FIdHTTP.ResponseText),
          FIdHTTP.Response.RawHeaders
        );
      end;

      on E: Exception do
        raise;
    end;
  finally
    LResponseStream.Free;
  end;
end;

end.
