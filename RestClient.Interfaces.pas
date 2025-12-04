unit RestClient.Interfaces;

interface

uses
  Classes, SysUtils, SuperObject;

type
  THTTPMethod = (rmGET, rmPOST, rmPUT, rmDELETE, rmPATCH);

  IRestResponse = interface
    ['{10000000-0000-0000-0000-000000000001}']
    function GetStatusCode: Integer;
    function GetContent: string;
    function GetHeader(const AName: string): string;
    function ContentAsJson: ISuperObject;
    property StatusCode: Integer read GetStatusCode;
    property Content: string read GetContent;
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
  end;

  IOAuthTokenManager = interface
    ['{10000000-0000-0000-0000-000000000003}']
    function GetAccessToken: string;
    procedure ForceRefresh;
  end;

  IRestClient = interface
    ['{10000000-0000-0000-0000-000000000004}']
    function CreateRequest: IRestRequest;
    function GetBaseURL: string;
    procedure SetBaseURL(const AValue: string);
    property BaseURL: string read GetBaseURL write SetBaseURL;
  end;

implementation

end.
