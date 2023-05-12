unit Hunger.View.Carrinho;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Graphics,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  FMX.ListBox, Hunger.Model.Entidade.Pedidos, Hunger.Model.Entidade.Produto,
  System.Generics.Collections, Hunger.Utils, System.ImageList, FMX.ImgList;

type
  TfrmCarrinho = class(TfrmBase)
    lbProdutos: TListBox;
    imgFotoCarrinho: TImage;
    spbVoltar: TSpeedButton;
    recAdicionar: TRectangle;
    lblAdicionar: TLabel;
    ImageList1: TImageList;
    procedure FormShow(Sender: TObject);
    procedure spbVoltarClick(Sender: TObject);
    procedure RecAddDropClick(Sender: TObject);
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
  recAdd: TRectangle;
  recDrop: TRectangle;
begin
  item := TListBoxItem.Create(nil);
  item.StyledSettings := [];
  item.Padding.Left := 10;
  item.Padding.Top := 5;
  item.Padding.Bottom := 5;
  item.Padding.Right := 10;
  item.Height := 50;

//  recQtde := TRectangle.Create(Rectangle2);
//  recQtde.Align := TAlignLayout.Left;
//  recQtde.Width := 50;
//  recQtde.Opacity := 0.5;
//  recQtde.Fill.Color := TAlphaColors.Antiquewhite;
//  recQtde.Stroke.Color := TAlphaColors.White;
//  recQtde.Stroke.Thickness := 10;
//  recQtde.XRadius := 3;
//  recQtde.YRadius := 3;

  recDrop := TRectangle.Create(lbProdutos);
  with recDrop do
  begin
    Align := TAlignLayout.None;
    Fill.Bitmap.Bitmap := ImageList1.Bitmap(TSizeF.Create(20,20), 1);
    Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
    Fill.Kind := TBrushKind.Bitmap;
    Position.X := 0;
    Position.Y := 15;
    Size.Width := 20.000000000000000000;
    Size.Height := 20.000000000000000000;
    Size.PlatformDefault := False;
    Stroke.Kind := TBrushKind.None;
    Name := 'recDrop';
    OnClick := RecAddDropClick;
  end;

  lblQtde := TLabel.Create(lbProdutos);
  with lblQtde do
  begin
    StyledSettings := [];
    Align := TAlignLayout.None;
    Position.X := -25;
    Position.Y := 15;
    Padding.Left := 10;
    Padding.Right := 10;
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.VertAlign := TTextAlign.Center;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := TAlphaColors.Black;
    Text := FloatToStrF(aPedidoItem.Qtde, ffFixed, 15,0);
    Name := 'lblQtde';
    Self.InsertComponent(lblQtde);
  end;

  recAdd := TRectangle.Create(lbProdutos);
  with recAdd do
  begin
    Align := TAlignLayout.None;
    Fill.Bitmap.Bitmap := ImageList1.Bitmap(TSizeF.Create(20,20), 0);
    Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
    Fill.Kind := TBrushKind.Bitmap;
    Position.X := 50;
    Position.Y := 15;
    Size.Width := 20.000000000000000000;
    Size.Height := 20.000000000000000000;
    Size.PlatformDefault := False;
    Stroke.Kind := TBrushKind.None;
    Name := 'recAdd';
    OnClick := RecAddDropClick;
  end;

  lblValor := TLabel.Create(lbProdutos);
  with lblValor do
  begin
    StyledSettings := [];
    Align := TAlignLayout.Right;
    Padding.Left := 10;
    Padding.Right := 10;
    TextSettings.HorzAlign := TTextAlign.Trailing;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := TAlphaColors.Darkgreen;
    Text := FloatToStrF(aPedidoItem.ValorTotal, ffCurrency, 15,2);
  end;

  item.AddObject(recAdd);
  item.AddObject(lblQtde);
  item.AddObject(recDrop);
  item.AddObject(lblValor);
  lbProdutos.AddObject(item);

  lblDescricao := TLabel.Create(lbProdutos);
  with lblDescricao do
  begin
    StyledSettings := [];
    Align := TAlignLayout.None;
    Position.X := recAdd.Position.X + recAdd.Width + 10;
    Position.Y := 15;
    Width := -(lblValor.Position.X) + lblValor.Width - recAdd.Position.X + recAdd.Width + 10;
    TextSettings.HorzAlign := TTextAlign.Leading;
    TextSettings.VertAlign := TTextAlign.Center;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := $FFF83923;
    Text := Produtos[aIndex].Descricao;
    WordWrap := True;
  end;

  item.AddObject(lblDescricao);

  if Assigned(FImage) then
    item.AddObject(FImage);

//  item.AddObject(recAdd);
//  item.AddObject(lblQtde);
//  item.AddObject(recDrop);
//  item.AddObject(lblDescricao);
//  item.AddObject(lblValor);
//  lbProdutos.AddObject(item);

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

procedure TfrmCarrinho.RecAddDropClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Pred(ComponentCount) do
  begin
    if (Components[I] is TLabel) and (Components[I].Name = 'lblQtde')
    and ((Sender as TRectangle).Name = 'recAdd') then
    begin
      Pedido.PedidoItem[0].Qtde := (Components[I] as TLabel).Text.ToDouble + 1;
      Pedido.PedidoItem[0].ValorTotal := Pedido.PedidoItem[0].Qtde * Pedido.PedidoItem[0].ValorUnitario;
      Pedido.ValorTotal := Pedido.ValorTotal + Pedido.PedidoItem[0].ValorUnitario;
    end
    else
    if ((Sender as TRectangle).Name = 'recDrop') and (Components[I].Name = 'lblQtde')
    and ((Components[I] as TLabel).Text.ToDouble > 1) then
    begin
      Pedido.PedidoItem[0].Qtde := (Components[I] as TLabel).Text.ToDouble - 1;
      Pedido.PedidoItem[0].ValorTotal := Pedido.PedidoItem[0].Qtde * Pedido.PedidoItem[0].ValorUnitario;
      Pedido.ValorTotal := Pedido.ValorTotal - Pedido.PedidoItem[0].ValorUnitario;
    end
      //(Components[I] as TLabel).Text := FloatToStr((Components[I] as TLabel).Text.ToDouble + 1);
  end;
  PreencherLbProdutos;
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
