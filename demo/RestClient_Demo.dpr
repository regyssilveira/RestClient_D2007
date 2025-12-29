program RestClient_Demo;

uses
  Forms,
  UMain in 'UMain.pas' {FrmMain},
  Service.DTO.Base in '..\Services\Service.DTO.Base.pas',
  Service.Transaction.DTO in '..\Services\Service.Transaction.DTO.pas',
  Service.Transaction in '..\Services\Service.Transaction.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
