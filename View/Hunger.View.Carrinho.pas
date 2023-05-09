unit Hunger.View.Carrinho;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  FMX.ListBox, Hunger.Model.Entidade.Pedidos;

type
  TfrmCarrinho = class(TfrmBase)
    lbProdutos: TListBox;
    imgFotoCarrinho: TImage;
    procedure FormShow(Sender: TObject);
  private
    FPedido: TPedido;
    procedure SetPedido(const Value: TPedido);
    procedure PreencherLbProdutos;
    procedure AddItemLb(aPedidoItem: TPedidoItem);
  public
    property Pedido: TPedido read FPedido write SetPedido;
  end;

var
  frmCarrinho: TfrmCarrinho;

implementation

{$R *.fmx}

{ TfrmBase1 }

procedure TfrmCarrinho.AddItemLb(aPedidoItem: TPedidoItem);
var
  item: TListBoxItem;
  rdbDescPrec: TRadioButton;
begin
  item := TListBoxItem.Create(nil);

  item.StyledSettings := [];
  item.Height := 30;
  item.TextSettings.HorzAlign := TTextAlign.Leading;
  item.TextSettings.Font.Family := 'Inter';
  item.TextSettings.Font.Size := 14;
  item.TextSettings.FontColor := $FFF83923;
  item.ItemData.Text := aPedidoItem.;

  rdbDescPrec := TRadioButton.Create(nil);
  rdbDescPrec.StyledSettings := [];
  rdbDescPrec.Align := TAlignLayout.Client;
  rdbDescPrec.TextSettings.FontColor := TAlphaColors.Darkgreen;
  rdbDescPrec.TextSettings.Font.Family := 'Inter';
  rdbDescPrec.TextSettings.Font.Size := 14;
  rdbDescPrec.Text := aTipo;

  item.AddObject(rdbDescPrec);
  lbProdutoPrecificacao.AddObject(item);
  rdbDescPrec.OnClick := lbProdutoPrecificacao.OnClick;
end;

procedure TfrmCarrinho.FormShow(Sender: TObject);
begin
  inherited;
  PreencherLbProdutos;
end;

procedure TfrmCarrinho.PreencherLbProdutos;
var
  pedidoItem: TPedidoItem;
begin
  lbProdutos.Items.Clear;
  lbProdutos.BeginUpdate;
  try
    for pedidoItem in Pedido.PedidoItem do
    begin
      AddItemLb(pedidoItem);
    end;
  finally
    lbProdutos.EndUpdate;
  end;
end;

procedure TfrmCarrinho.SetPedido(const Value: TPedido);
begin
  FPedido := Value;
end;

end.
