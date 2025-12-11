program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  RestClient.Core in '..\RestClient.Core.pas',
  RestClient.Interfaces in '..\RestClient.Interfaces.pas',
  RestClient.Request in '..\RestClient.Request.pas',
  RestClient.Response in '..\RestClient.Response.pas',
  RestClient.TokenManager in '..\RestClient.TokenManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
