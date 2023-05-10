unit Hunger.View.Carrinho;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Graphics,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  FMX.ListBox, Hunger.Model.Entidade.Pedidos, Hunger.Model.Entidade.Produto,
  System.Generics.Collections, Hunger.Utils;

type
  TfrmCarrinho = class(TfrmBase)
    lbProdutos: TListBox;
    imgFotoCarrinho: TImage;
    spbVoltar: TSpeedButton;
    recAdicionar: TRectangle;
    lblAdicionar: TLabel;
    ListBoxItem1: TListBoxItem;
    Label1: TLabel;
    Rectangle2: TRectangle;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure spbVoltarClick(Sender: TObject);
  private
    FPedido: TPedido;
    FProdutos: TObjectList<TProduto>;
    FUtils: TUtils;
    FImage: TImage;
    procedure SetPedido(const Value: TPedido);
    procedure PreencherLbProdutos;
    procedure AddItemLb(aIndex: Integer; aPedidoItem: TPedidoItem);
    procedure SetProdutos(const Value: TObjectList<TProduto>);
  public
    property Pedido: TPedido read FPedido write SetPedido;
    property Produtos: TObjectList<TProduto> read FProdutos write SetProdutos;
  end;

var
  frmCarrinho: TfrmCarrinho;

implementation

{$R *.fmx}

{ TfrmBase1 }

procedure TfrmCarrinho.AddItemLb(aIndex: Integer; aPedidoItem: TPedidoItem);
var
  item: TListBoxItem;
  lblDescricao: TLabel;
  lblValor: TLabel;
  lblQtde: TLabel;
  recQtde: TRectangle;
begin
  item := TListBoxItem.Create(nil);
  item.StyledSettings := [];
  item.Padding.Left := 10;
  item.Padding.Top := 5;
  item.Padding.Bottom := 5;
  item.Padding.Right := 10;
  item.Height := 50;

  lblQtde := TLabel.Create(nil);
  //lblQtde.Parent := recQtde;
  lblQtde.StyledSettings := [];
  lblQtde.Align := TAlignLayout.Client;
  lblQtde.Padding.Left := 10;
  lblQtde.Padding.Right := 10;
  lblQtde.TextSettings.HorzAlign := TTextAlign.Leading;
  lblQtde.TextSettings.Font.Family := 'Inter';
  lblQtde.TextSettings.Font.Size := 14;
  lblQtde.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblQtde.TextSettings.FontColor := TAlphaColors.Black;
  lblQtde.Text := FloatToStrF(aPedidoItem.Qtde, ffFixed, 15,0);

  recQtde := TRectangle.Create(lblQtde);
  recQtde.Parent := lblQtde;
  recQtde.Align := TAlignLayout.Left;
  recQtde.Width := 50;
  recQtde.Opacity := 0.5;
  recQtde.Fill.Color := TAlphaColors.Antiquewhite;
  recQtde.Stroke.Color := TAlphaColors.White;
  recQtde.Stroke.Thickness := 10;
  recQtde.XRadius := 3;
  recQtde.YRadius := 3;

  lblDescricao := TLabel.Create(nil);
  lblDescricao.StyledSettings := [];
  lblDescricao.Align := TAlignLayout.Client;
  lblDescricao.TextSettings.HorzAlign := TTextAlign.Center;
  lblDescricao.TextSettings.VertAlign := TTextAlign.Center;
  lblDescricao.TextSettings.Font.Family := 'Inter';
  lblDescricao.TextSettings.Font.Size := 14;
  lblDescricao.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblDescricao.TextSettings.FontColor := $FFF83923;
  lblDescricao.Text := Produtos[aIndex].Descricao;

  lblValor := TLabel.Create(nil);
  lblValor.StyledSettings := [];
  lblValor.Align := TAlignLayout.Right;
  lblValor.Padding.Left := 10;
  lblValor.Padding.Right := 10;
  lblValor.TextSettings.HorzAlign := TTextAlign.Trailing;
  lblValor.TextSettings.Font.Family := 'Inter';
  lblValor.TextSettings.Font.Size := 14;
  lblValor.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblValor.TextSettings.FontColor := TAlphaColors.Darkgreen;
  lblValor.Text := FloatToStrF(aPedidoItem.ValorTotal, ffCurrency, 15,2);

  if Assigned(FImage) then
    item.AddObject(FImage);

  item.AddObject(lblQtde);
  item.AddObject(recQtde);
  item.AddObject(lblDescricao);
  item.AddObject(lblValor);
  lbProdutos.AddObject(item);

//  if Assigned(imgFotoCarrinho.MultiResBitmap.Items[aIndex]) then
//  begin
//    imgFotoCarrinho.MultiResBitmap.Items[aIndex].Bitmap.LoadFromStream(FUtils.Base64ToStream(Produtos[aIndex].Imagem));
//    if not imgFotoCarrinho.Bitmap.IsEmpty then
//    begin
//      FImage := TImage.Create(nil);
//      FImage.Align := TAlignLayout.Left;
//      FImage.Width := 65;
//      FImage.Height := 65;
//      FImage.Bitmap := imgFotoCarrinho.MultiResBitmap.Items[aIndex].Bitmap;
//    end;
//  end;
end;

procedure TfrmCarrinho.FormShow(Sender: TObject);
begin
  inherited;
  PreencherLbProdutos;
end;

procedure TfrmCarrinho.PreencherLbProdutos;
var
  I: Integer;
begin
  lbProdutos.Items.Clear;
  lbProdutos.BeginUpdate;
  try
    for I := 0 to Pred(Pedido.PedidoItem.Count) do
    begin
      AddItemLb(I, Pedido.PedidoItem[I]);
    end;
  finally
    lbProdutos.EndUpdate;
  end;
end;

procedure TfrmCarrinho.SetPedido(const Value: TPedido);
begin
  FPedido := Value;
end;

procedure TfrmCarrinho.SetProdutos(const Value: TObjectList<TProduto>);
begin
  FProdutos := Value;
end;

procedure TfrmCarrinho.spbVoltarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
