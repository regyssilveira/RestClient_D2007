program RestClientExample;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  SuperObject,
  RestClient.Interfaces in 'RestClient.Interfaces.pas',
  RestClient.TokenManager in 'RestClient.TokenManager.pas',
  RestClient.Request in 'RestClient.Request.pas',
  RestClient.Response in 'RestClient.Response.pas',
  RestClient.Core in 'RestClient.Core.pas';

procedure Main;
var
  LClient: IRestClient;
  LResponse: IRestResponse;
  LStream: TFileStream;
begin
  try
    // 1. Initialize Client with Internal Token Management
    LClient := TRestClient.Create(
      'https://api.example.com/v1',
      'https://api.example.com/oauth/token',
      'my-client-id',
      'my-client-secret'
    );

    Writeln('--- GET Request ---');
    // 3. Simple GET Request
    LResponse := LClient.CreateRequest
      .Resource('users')
      .AddParam('page', '1')
      .Execute(rmGET);
      
    Writeln('Status: ', LResponse.StatusCode);
    Writeln('Body: ', LResponse.Content);
    
    Writeln('--- POST Request ---');
    // 4. POST Request with JSON Body
    LResponse := LClient.CreateRequest
      .Resource('users')
      .AddHeader('X-Custom-Header', 'Value')
      .AddBody(SO('{"name": "John Doe", "email": "john@example.com"}'))
      .Execute(rmPOST);

    Writeln('Status: ', LResponse.StatusCode);
    
    Writeln('--- Multipart Upload ---');
    // 5. Multipart/Form-Data Upload
    if FileExists('test.txt') then
    begin
      LStream := TFileStream.Create('test.txt', fmOpenRead);
      try
        LResponse := LClient.CreateRequest
          .Resource('upload')
          .AddPart('description', 'File upload test')
          .AddPart('file', 'test.txt', LStream)
          .Execute(rmPOST);
          
        Writeln('Status: ', LResponse.StatusCode);
      finally
        LStream.Free;
      end;
    end
    else
      Writeln('test.txt not found, skipping upload test.');

  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;
end;

begin
  try
    Main;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Press Enter to exit...');
  Readln;
end.
