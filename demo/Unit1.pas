unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;



type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  SuperObject,
  RestClient.Interfaces,
  RestClient.Response,
  RestClient.Core;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  LClient: IRestClient;
  Token: String;
begin
  LClient := TRestClient.Create(
    'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
    rtIndy,
    'https://api.cre.uatesb.local/oauth/token',
    'srvc.ce.core.banking.service.uat',
    'K>9.V=n20T9vo!bn0>bbn'
  );
  Token := LClient.CreateRequest
    .ObterToken;

  ShowMessage(Token);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  LClient: IRestClient;
  LResponse: IRestResponse;
begin
  LClient := TRestClient.Create(
    'https://ce-api.bancointer.com.br/oauth/token',
    rtWinInet
  );

  LResponse := LClient.CreateRequest
    .AddPart('grant_type', 'client_credentials')
    .AddPart('client_id', '7a0c6e2f-aeb1-4d50-bcf1-5df1c61a9668')
    .AddPart('client_secret', '95f46fd7-882a-4890-8402-af6b5669566a')
    .AddPart('scope', 'ce-imp-api:write ce-imp-api:read')
    .Execute(rmPOST);

  ShowMessage(LResponse.Content);
end;

end.
