program RestClientExample;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Dialogs,
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
  Token: String;
  //LStream: TFileStream;
begin
  try
    {
    LClient := TRestClient.Create(
      'https://ce-api.bancointer.com.br/oauth/token',
      'https://ce-api.bancointer.com.br/oauth/token',
      '',//'srvc.ce.core.banking.service.uat',
      '', //'K>9.V=n20T9vo!bn0>bbn'
    );

    Writeln('--- GET Request ---');

    LResponse := LClient.CreateRequest
      .IgnoreToken
      .AddPart('client_id',      UTF8Encode('7a0c6e2f-aeb1-4d50-bcf1-5df1c61a9668'))
      .AddPart('client_secret',  UTF8Encode('95f46fd7-882a-4890-8402-af6b5669566a'))
      .AddPart('grant_type',     UTF8Encode('client_credentials'))
      .AddPart('scope',          UTF8Encode('ce-imp-api:write ce-imp-api:read'))
      .Execute(rmPOST);

    ShowMessage(IntToStr(LResponse.StatusCode));
    ShowMessage(LResponse.Content);
    }


    LClient := TRestClient.Create(
      'https://api.cre.uatesb.local/api/ce-core-banking-service/v1',
      'https://api.cre.uatesb.local/oauth/token',
      'srvc.ce.core.banking.service.uat',
      'K>9.V=n20T9vo!bn0>bbn'
    );

    Writeln('--- TOKEN Teste Request ---');
    Token := LClient.CreateRequest
      .UpdateToken;

    ShowMessage(Token);

    {
    Writeln('--- POST Request ---');
    LResponse := LClient.CreateRequest
      .Resource('account/balance')
      .AddHeader('accountNumber', '0010261290')
      .AddHeader('bankBranch', '00019')
      .AddHeader('originSystem', 'INTERCREDPJ')
      .Execute(rmPOST);
    }
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
