unit RestClient.Interfaces;

interface

uses
  Classes, SysUtils, SuperObject;

type
  THTTPMethod = (rmGET, rmPOST, rmPUT, rmDELETE, rmPATCH);

  TLogEvent = procedure(const AMsg: string) of object;

  IRestResponse = interface
    ['{10000000-0000-0000-0000-000000000001}']
    function GetStatusCode: Integer;
    function GetContent: string;
    function GetHeader(const AName: string): string;
    function ContentAsJson: ISuperObject;
    function GetHeaders: String;
    function IsError: Boolean;
    property StatusCode: Integer read GetStatusCode;
    property Content: string read GetContent;
    property Headers: String read GetHeaders;
  end;

  IRestRequest = interface
    ['{10000000-0000-0000-0000-000000000002}']
    function Resource(const AResource: string): IRestRequest;
    function AddHeader(const AName, AValue: string): IRestRequest;
    function AddParam(const AName, AValue: string): IRestRequest;
    function AddBody(const ABody: string; const AContentType: string = 'application/json'): IRestRequest; overload;
    function AddBody(const AJson: ISuperObject): IRestRequest; overload;
    function AddPart(const AName, AValue: string): IRestRequest; overload;
    function AddPart(const AName, AFileName: string; AStream: TStream; const AContentType: string = ''; const ACharset: string = ''): IRestRequest; overload;
    function Execute(AMethod: THTTPMethod): IRestResponse;
    function GetFullUrl: string;
    function IgnoreToken: IRestRequest;
    function ShouldIgnoreToken: Boolean;
    function ObterToken: String;
    
    // Data Accessors for Client
    function GetHeaders: TStrings;
    function GetParams: TStrings;
    function GetBody: string;
    function GetBodyContentType: string;
    function GetParts: TList;
    function GetResource: string;
  end;

  IRestClient = interface
    ['{10000000-0000-0000-0000-000000000004}']
    function CreateRequest: IRestRequest;
    function GetBaseURL: string;
    procedure SetBaseURL(const AValue: string);
    function ExecuteRequest(ARequest: IRestRequest; AMethod: THTTPMethod): IRestResponse;
    function ObterToken: String;
    procedure TratarRetornoNaoEsperado(LResponseContent: string);
    
    function GetOnLog: TLogEvent;
    procedure SetOnLog(const Value: TLogEvent);
    procedure Log(const AMsg: string);
    
    property BaseURL: string read GetBaseURL write SetBaseURL;
    property OnLog: TLogEvent read GetOnLog write SetOnLog;
  end;

  IOAuthTokenManager = interface
    ['{10000000-0000-0000-0000-000000000003}']
    function GetAccessToken: string;
    procedure ForceRefresh;
    procedure SetClient(const AClient: IRestClient);
  end;
  
implementation

end.
