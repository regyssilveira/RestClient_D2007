unit RestClient.Response;

interface

uses
  Classes, SysUtils, RestClient.Interfaces, SuperObject;

type
  TRestResponse = class(TInterfacedObject, IRestResponse)
  private
    FStatusCode: Integer;
    FContent: string;
    FHeaders: TStringList;
    function GetHeaders: String;
  public
    constructor Create(AStatusCode: Integer; const AContent: string; AHeaders: TStrings);
    destructor Destroy; override;
    function GetStatusCode: Integer;
    function GetContent: string;
    function GetHeader(const AName: string): string;
    function ContentAsJson: ISuperObject;
  end;

implementation

{ TRestResponse }

constructor TRestResponse.Create(AStatusCode: Integer; const AContent: string; AHeaders: TStrings);
begin
  inherited Create;
  FStatusCode := AStatusCode;
  FContent := AContent;
  FHeaders := TStringList.Create;
  if Assigned(AHeaders) then
    FHeaders.Assign(AHeaders);
end;

destructor TRestResponse.Destroy;
begin
  FHeaders.Free;
  inherited;
end;

function TRestResponse.GetContent: string;
begin
  Result := FContent;
end;

function TRestResponse.GetHeader(const AName: string): string;
begin
  Result := FHeaders.Values[AName];
end;

function TRestResponse.GetHeaders: String;
begin
  Result := FHeaders.Text;
end;

function TRestResponse.GetStatusCode: Integer;
begin
  Result := FStatusCode;
end;

function TRestResponse.ContentAsJson: ISuperObject;
begin
  Result := SO(FContent);
end;

end.
