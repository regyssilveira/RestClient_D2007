program RestClient_DemoApp;

uses
  Forms,
  UMain in 'UMain.pas' {FrmMain},
  RestClient.Interfaces in '..\RestClient.Interfaces.pas',
  RestClient.Core in '..\RestClient.Core.pas',
  RestClient.Request in '..\RestClient.Request.pas',
  RestClient.Response in '..\RestClient.Response.pas',
  RestClient.TokenManager in '..\RestClient.TokenManager.pas',
  SuperObject in '..\SuperObject\superobject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
