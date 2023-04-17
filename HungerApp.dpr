program HungerApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  Hunger.View.Main in 'View\Hunger.View.Main.pas' {frmPrincipal},
  Hunger.Model.Permissions in 'Model\Hunger.Model.Permissions.pas',
  Hunger.View.LeitorCamera in 'View\Hunger.View.LeitorCamera.pas' {frmLeitorCamera};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmLeitorCamera, frmLeitorCamera);
  Application.Run;
end.
