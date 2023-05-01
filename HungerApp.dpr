program HungerApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  Hunger.View.Main in 'View\Hunger.View.Main.pas' {frmPrincipal},
  Hunger.Model.Permissions in 'Model\Hunger.Model.Permissions.pas',
  Hunger.View.LeitorCamera in 'View\Hunger.View.LeitorCamera.pas' {frmLeitorCamera},
  Hunger.Model.Produto in 'Model\Entidade\Hunger.Model.Produto.pas',
  Pkg.Json.DTO in 'Model\Pkg.Json.DTO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmLeitorCamera, frmLeitorCamera);
  Application.Run;
end.
