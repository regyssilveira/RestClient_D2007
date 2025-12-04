unit RestClient.Request;

interface

uses
  Classes, SysUtils, RestClient.Interfaces, SuperObject;

type
  TRequestPart = class
  public
    Name: string;
    Value: string;
    FileName: string;
    Stream: TStream;
    OwnsStream: Boolean;
    ContentType: string;
    Charset: string;
    constructor Create(const AName, AValue: string); overload;
    constructor Create(const AName, AFileName: string; AStream: TStream; const AContentType: string = ''; const ACharset: string = ''); overload;
    destructor Destroy; override;
  end;

  TRestRequest = class(TInterfacedObject, IRestRequest)
  private
    FClient: IRestClient; // Weak reference conceptually, but interface keeps it alive. 
                          // In D2007, we need to be careful about circular ref if Client holds Request.
                          // Here Request is created by Client, so Client should probably not hold a ref to Request 
                          // or we use a weak pointer if needed. 
                          // For this design, Request executes via Client.
    FResource: string;
    FHeaders: TStringList;
    FParams: TStringList;
    FBody: string;
    FBodyContentType: string;
    FParts: TList;
  public
    constructor Create(AClient: IRestClient);
    destructor Destroy; override;

    function Resource(const AResource: string): IRestRequest;
    function AddHeader(const AName, AValue: string): IRestRequest;
    function AddParam(const AName, AValue: string): IRestRequest;
    function AddBody(const ABody: string; const AContentType: string = 'application/json'): IRestRequest; overload;
    function AddBody(const AJson: ISuperObject): IRestRequest; overload;
    function AddPart(const AName, AValue: string): IRestRequest; overload;
    function AddPart(const AName, AFileName: string; AStream: TStream; const AContentType: string = ''; const ACharset: string = ''): IRestRequest; overload;
    function Execute(AMethod: THTTPMethod): IRestResponse;
    function GetFullUrl: string;

    // Internal getters for the Client to access
    property Headers: TStringList read FHeaders;
    property Params: TStringList read FParams;
    property Body: string read FBody;
    property BodyContentType: string read FBodyContentType;
    property Parts: TList read FParts;
    property ResourcePath: string read FResource;
  end;

implementation

uses
  RestClient.Core; // Need to cast IRestClient to TRestClient to call ExecuteRequest if not on interface
                   // Or better, add ExecuteRequest to IRestClient? 
                   // Let's assume we can cast or IRestClient has a method we can use.
                   // Actually, I'll add ExecuteRequest to TRestClient public section and cast.

{ TRequestPart }

constructor TRequestPart.Create(const AName, AValue: string);
begin
  Name := AName;
  Value := AValue;
  FileName := '';
  Stream := nil;
  OwnsStream := False;
  ContentType := '';
  Charset := '';
end;

constructor TRequestPart.Create(const AName, AFileName: string; AStream: TStream; const AContentType: string = ''; const ACharset: string = '');
begin
  Name := AName;
  Value := '';
  FileName := AFileName;
  Stream := AStream;
  OwnsStream := False;
  ContentType := AContentType;
  Charset := ACharset;
end;

destructor TRequestPart.Destroy;
begin
  if OwnsStream and Assigned(Stream) then
    Stream.Free;
  inherited;
end;

{ TRestRequest }

constructor TRestRequest.Create(AClient: IRestClient);
begin
  inherited Create;
  FClient := AClient;
  FHeaders := TStringList.Create;
  FParams := TStringList.Create;
  FParts := TList.Create;
  FBody := '';
  FBodyContentType := '';
end;

destructor TRestRequest.Destroy;
var
  I: Integer;
begin
  FHeaders.Free;
  FParams.Free;
  for I := 0 to FParts.Count - 1 do
    TRequestPart(FParts[I]).Free;
  FParts.Free;
  inherited;
end;

function TRestRequest.Resource(const AResource: string): IRestRequest;
begin
  FResource := AResource;
  Result := Self;
end;

function TRestRequest.AddBody(const ABody, AContentType: string): IRestRequest;
begin
  FBody := ABody;
  FBodyContentType := AContentType;
  Result := Self;
end;

function TRestRequest.AddBody(const AJson: ISuperObject): IRestRequest;
begin
  FBody := AJson.AsJSon;
  FBodyContentType := 'application/json';
  Result := Self;
end;

function TRestRequest.AddHeader(const AName, AValue: string): IRestRequest;
begin
  FHeaders.Add(AName + '=' + AValue);
  Result := Self;
end;

function TRestRequest.AddParam(const AName, AValue: string): IRestRequest;
begin
  FParams.Add(AName + '=' + AValue);
  Result := Self;
end;

function TRestRequest.AddPart(const AName, AValue: string): IRestRequest;
begin
  FParts.Add(TRequestPart.Create(AName, AValue));
  Result := Self;
end;

function TRestRequest.AddPart(const AName, AFileName: string; AStream: TStream; const AContentType: string = ''; const ACharset: string = ''): IRestRequest;
begin
  FParts.Add(TRequestPart.Create(AName, AFileName, AStream, AContentType, ACharset));
  Result := Self;
end;

function TRestRequest.Execute(AMethod: THTTPMethod): IRestResponse;
begin
  // We need to call the client to execute this request.
  // Since IRestClient doesn't expose ExecuteRequest (it exposes CreateRequest),
  // we rely on the fact that we know the implementation or we should have added it to the interface.
  // For better design, IRestClient should have ExecuteRequest(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
  // But I defined IRestRequest.Execute.
  // So I will cast FClient to TRestClient.
  Result := (FClient as TRestClient).ExecuteRequest(Self, AMethod);
end;

function TRestRequest.GetFullUrl: string;
begin
  Result := FClient.BaseURL;
  if (Result <> '') and (Result[Length(Result)] <> '/') and (FResource <> '') and (FResource[1] <> '/') then
    Result := Result + '/';
  Result := Result + FResource;
end;

end.
