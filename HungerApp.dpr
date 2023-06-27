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
  Hunger.View.Produto in 'View\Hunger.View.Produto.pas' {frmProduto},
  Hunger.Model.Entidade.Pedidos in 'Model\Entidade\Hunger.Model.Entidade.Pedidos.pas',
  Hunger.View.Carrinho in 'View\Hunger.View.Carrinho.pas' {frmCarrinho},
  Hunger.Model.Pedido in 'Model\Hunger.Model.Pedido.pas',
  Hunger.View.Pedidos in 'View\Hunger.View.Pedidos.pas' {frmPedidos},
  Hunger.View.Mesas in 'View\Hunger.View.Mesas.pas' {frmMesas},
  Hunger.Model.Entidade.Mesas in 'Model\Entidade\Hunger.Model.Entidade.Mesas.pas',
  Hunger.View.Config in 'View\Hunger.View.Config.pas' {frmConfig};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmLeitorCamera, frmLeitorCamera);
  Application.CreateForm(TfrmBase, frmBase);
  Application.Run;
end.
