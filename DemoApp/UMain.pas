unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  RestClient.Interfaces,
  RestClient.Core,
  RestClient.Response,
  SuperObject;

type
  TFrmMain = class(TForm)
    PgcMain: TPageControl;
    TabBasic: TTabSheet;
    TabAdvanced: TTabSheet;
    TabAuth: TTabSheet;
    MemoLog: TMemo;
    BtnGetTasks: TButton;
    BtnCreateTask: TButton;
    BtnUpdateTask: TButton;
    BtnDeleteTask: TButton;
    MemoBasicResult: TMemo;
    BtnUpload: TButton;
    BtnCustomHeaders: TButton;
    MemoAdvResult: TMemo;
    BtnGetToken: TButton;
    MemoAuthToken: TMemo;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnGetTasksClick(Sender: TObject);
    procedure BtnCreateTaskClick(Sender: TObject);
    procedure BtnUpdateTaskClick(Sender: TObject);
    procedure BtnDeleteTaskClick(Sender: TObject);
    procedure BtnUploadClick(Sender: TObject);
    procedure BtnCustomHeadersClick(Sender: TObject);
    procedure BtnGetTokenClick(Sender: TObject);
  private
    { Private declarations }
    FClient: IRestClient;
    function GetClient: IRestClient;
    procedure Log(const AMsg: string);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  PgcMain.ActivePageIndex := 0;
end;

function TFrmMain.GetClient: IRestClient;
begin
  if FClient = nil then
  begin
    // Inicializando com uma URL base fictícia, será sobrescrita por requisição ou alterada
    // Usando rtWinInet como padrão, pode ser alterado.
    FClient := TRestClient.Create('https://jsonplaceholder.typicode.com', rtWinInet);
  end;
  Result := FClient;
end;

procedure TFrmMain.Log(const AMsg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMsg);
end;

procedure TFrmMain.BtnGetTasksClick(Sender: TObject);
var
  LResp: IRestResponse;
begin
  Log('Solicitando GET /posts...');
  try
    GetClient.BaseURL := 'https://jsonplaceholder.typicode.com';
    LResp := GetClient.CreateRequest
      .Resource('posts')
      .Execute(rmGET);
      
    Log('Código de Resposta: ' + IntToStr(LResp.StatusCode));
    MemoBasicResult.Text := LResp.Content;
  except
    on E: Exception do
      Log('Erro: ' + E.Message);
  end;
end;

procedure TFrmMain.BtnCreateTaskClick(Sender: TObject);
var
  LResp: IRestResponse;
  LJson: ISuperObject;
begin
  Log('Solicitando POST /posts...');
  LJson := SO;
  LJson.S['title'] := 'foo';
  LJson.S['body'] := 'bar';
  LJson.I['userId'] := 1;

  try
    GetClient.BaseURL := 'https://jsonplaceholder.typicode.com';
    LResp := GetClient.CreateRequest
      .Resource('posts')
      .AddBody(LJson)
      .Execute(rmPOST);
      
    Log('Código de Resposta: ' + IntToStr(LResp.StatusCode));
    MemoBasicResult.Text := LResp.Content;
  except
    on E: Exception do
      Log('Erro: ' + E.Message);
  end;
end;

procedure TFrmMain.BtnUpdateTaskClick(Sender: TObject);
var
  LResp: IRestResponse;
  LJson: ISuperObject;
begin
  Log('Solicitando PUT /posts/1...');
  LJson := SO;
  LJson.S['id'] := '1';
  LJson.S['title'] := 'foo atualizado';
  LJson.S['body'] := 'bar atualizado';
  LJson.I['userId'] := 1;

  try
    GetClient.BaseURL := 'https://jsonplaceholder.typicode.com';
    LResp := GetClient.CreateRequest
      .Resource('posts/1')
      .AddBody(LJson)
      .Execute(rmPUT);

    Log('Código de Resposta: ' + IntToStr(LResp.StatusCode));
    MemoBasicResult.Text := LResp.Content;
  except
    on E: Exception do
      Log('Erro: ' + E.Message);
  end;
end;

procedure TFrmMain.BtnDeleteTaskClick(Sender: TObject);
var
  LResp: IRestResponse;
begin
  Log('Solicitando DELETE /posts/1...');
  try
    GetClient.BaseURL := 'https://jsonplaceholder.typicode.com';
    LResp := GetClient.CreateRequest
      .Resource('posts/1')
      .Execute(rmDELETE);

    Log('Código de Resposta: ' + IntToStr(LResp.StatusCode));
    MemoBasicResult.Text := 'Status: ' + IntToStr(LResp.StatusCode) + #13#10 + LResp.Content;
  except
    on E: Exception do
      Log('Erro: ' + E.Message);
  end;
end;

procedure TFrmMain.BtnUploadClick(Sender: TObject);
var
  LResp: IRestResponse;
  LStream: TStringStream;
begin
  Log('Solicitando Upload Multipart para httpbin.org...');
  LStream := TStringStream.Create('Este é o conteúdo de um arquivo de teste.');
  try
    GetClient.BaseURL := 'https://httpbin.org';
    LResp := GetClient.CreateRequest
      .Resource('post')
      .AddPart('field1', 'valor1')
      .AddPart('file', 'testKey.txt', LStream, 'text/plain', '')
      .Execute(rmPOST);

    Log('Código de Resposta: ' + IntToStr(LResp.StatusCode));
    MemoAdvResult.Text := LResp.Content;
  finally
    LStream.Free;
  end;
end;

procedure TFrmMain.BtnCustomHeadersClick(Sender: TObject);
var
  LResp: IRestResponse;
begin
  Log('Solicitando Headers para httpbin.org...');
  try
    GetClient.BaseURL := 'https://httpbin.org';
    LResp := GetClient.CreateRequest
      .Resource('headers')
      .AddHeader('X-Custom-Header', 'DelphiRestClient')
      .Execute(rmGET);

    Log('Código de Resposta: ' + IntToStr(LResp.StatusCode));
    MemoAdvResult.Text := LResp.Content;
  except
    on E: Exception do
      Log('Erro: ' + E.Message);
  end;
end;

procedure TFrmMain.BtnGetTokenClick(Sender: TObject);
begin
  Log('Testando Gerenciador de Token (Mock)...');
  // Isso requer um servidor Auth adequado ou implementação mock.
  // Por enquanto, vamos apenas simular a definição manual do token ou chamar o método da interface, se aplicável.
  
  MemoAuthToken.Text := 'A funcionalidade de token requer um endpoint OAuth2 válido configurado no construtor do TRestClient.';
end;

end.
