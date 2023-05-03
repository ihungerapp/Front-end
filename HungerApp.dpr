program HungerApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  Hunger.View.Main in 'View\Hunger.View.Main.pas' {frmPrincipal},
  Hunger.Model.Permissions in 'Model\Hunger.Model.Permissions.pas',
  Hunger.View.LeitorCamera in 'View\Hunger.View.LeitorCamera.pas' {frmLeitorCamera},
  Hunger.Model.Entidade.Produto in 'Model\Entidade\Hunger.Model.Entidade.Produto.pas',
  Pkg.Json.DTO in 'Model\Pkg.Json.DTO.pas',
  Hunger.Model.Produto in 'Model\Hunger.Model.Produto.pas',
  Hunger.Utils in 'Utils\Hunger.Utils.pas',
  Hunger.View.Base in 'View\Hunger.View.Base.pas' {frmBase},
  Hunger.View.Produto in 'View\Hunger.View.Produto.pas' {frmBase1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmLeitorCamera, frmLeitorCamera);
  Application.CreateForm(TfrmBase, frmBase);
  Application.CreateForm(TfrmBase1, frmBase1);
  Application.Run;
end.
