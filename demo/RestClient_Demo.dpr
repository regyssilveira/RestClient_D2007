program RestClient_Demo;

uses
  Forms,
  UMain in 'UMain.pas' {FrmMain},
  Service.Transaction.DTO in '..\Services\Service.Transaction.DTO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
