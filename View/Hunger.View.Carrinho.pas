unit Hunger.View.Carrinho;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Graphics,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  FMX.ListBox, Hunger.Model.Entidade.Pedidos, Hunger.Model.Entidade.Produto,
  System.Generics.Collections, Hunger.Utils, System.ImageList, FMX.ImgList,
  Hunger.Model.Pedido;

type
  TfrmCarrinho = class(TfrmBase)
    lbProdutos: TListBox;
    spbVoltar: TSpeedButton;
    recAdicionar: TRectangle;
    lblFinalizar: TLabel;
    imgCarrinho: TImageList;
    procedure FormShow(Sender: TObject);
    procedure spbVoltarClick(Sender: TObject);
    procedure RecAddDropClick(Sender: TObject);
    procedure lbProdutosMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure recAdicionarClick(Sender: TObject);
  private
    FPedido: TPedido;
    FProdutos: TObjectList<TProduto>;
    FUtils: TUtils;
    FImage: TImage;
    FItemLbProdutos: TListBoxItem;
    procedure SetPedido(const Value: TPedido);
    procedure PreencherLbProdutos;
    procedure AddItemLb(aIndex: Integer; aPedidoItem: TPedidoItem);
    procedure SetProdutos(const Value: TObjectList<TProduto>);
  public
    property Pedido: TPedido read FPedido write SetPedido;
    property Produtos: TObjectList<TProduto> read FProdutos write SetProdutos;
    procedure FinalizarPedido;
  end;

var
  frmCarrinho: TfrmCarrinho;

implementation

uses
  Hunger.View.Main, Client.Connection, FMX.DialogService,
  Hunger.View.LeitorCamera;

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
  recTrash: TRectangle;
begin
  item := TListBoxItem.Create(nil);
  item.StyledSettings := [];
  item.Padding.Left := 10;
  item.Padding.Top := 5;
  item.Padding.Bottom := 5;
  item.Padding.Right := 10;
  item.Height := 60;

  recDrop := TRectangle.Create(lbProdutos);
  with recDrop do
  begin
    Align := TAlignLayout.None;
    Fill.Bitmap.Bitmap := imgCarrinho.Bitmap(TSizeF.Create(20,20), 1);
    Fill.Bitmap.WrapMode := TWrapMode.TileOriginal;
    Fill.Kind := TBrushKind.Bitmap;
    Position.X := 0;
    Position.Y := 15;
    Size.Width := 30.000000000000000000;
    Size.Height := 30.000000000000000000;
    Size.PlatformDefault := False;
    Stroke.Kind := TBrushKind.None;
    OnClick := RecAddDropClick;
  end;

  lblQtde := TLabel.Create(lbProdutos);
  with lblQtde do
  begin
    StyledSettings := [];
    Align := TAlignLayout.None;
    Position.X := 35;
    Position.Y := 15;
    Size.Width := 25.000000000000000000;
    Size.Height := 25.000000000000000000;
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.VertAlign := TTextAlign.Center;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := TAlphaColors.Black;
    Text := FloatToStrF(aPedidoItem.Qtde, ffFixed, 15,0);
    Self.InsertComponent(lblQtde);
  end;

  recAdd := TRectangle.Create(lbProdutos);
  with recAdd do
  begin
    Align := TAlignLayout.None;
    Fill.Bitmap.Bitmap := imgCarrinho.Bitmap(TSizeF.Create(20,20), 0);
    Fill.Bitmap.WrapMode := TWrapMode.TileOriginal;
    Fill.Kind := TBrushKind.Bitmap;
    Position.X := 60;
    Position.Y := 15;
    Size.Width := 30.000000000000000000;
    Size.Height := 30.000000000000000000;
    Size.PlatformDefault := False;
    Stroke.Kind := TBrushKind.None;
    OnClick := RecAddDropClick;
  end;

  lblValor := TLabel.Create(lbProdutos);
  with lblValor do
  begin
    StyledSettings := [];
    Align := TAlignLayout.Right;
    TextSettings.HorzAlign := TTextAlign.Trailing;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := TAlphaColors.Darkgreen;
    Text := FloatToStrF(aPedidoItem.ValorTotal, ffCurrency, 15,2);
  end;

  recTrash := TRectangle.Create(lbProdutos);
  with recTrash do
  begin
    Align := TAlignLayout.FitRight;
    Fill.Bitmap.Bitmap := imgCarrinho.Bitmap(TSizeF.Create(20,20), 2);
    Fill.Bitmap.WrapMode := TWrapMode.TileOriginal;
    Fill.Kind := TBrushKind.Bitmap;
    Position.X := 0;
    Position.Y := 15;
    Size.Width := 30.000000000000000000;
    Size.Height := 30.000000000000000000;
    Size.PlatformDefault := False;
    Stroke.Kind := TBrushKind.None;
    OnClick := RecAddDropClick;
  end;

  item.AddObject(recAdd);
  item.AddObject(lblQtde);
  item.AddObject(recDrop);
  item.AddObject(lblValor);
  item.AddObject(recTrash);
  lbProdutos.AddObject(item);
  recDrop.Name := 'recDrop' + item.Index.ToString;
  lblQtde.Name := 'lblQtde' + item.Index.ToString;
  recAdd.Name := 'recAdd' + item.Index.ToString;
  recTrash.Name := 'recTrash' + item.Index.ToString;

  lblDescricao := TLabel.Create(lbProdutos);
  with lblDescricao do
  begin
    StyledSettings := [];
    Align := TAlignLayout.None;
    Position.X := recAdd.Position.X + recAdd.Width + 10;
    Position.Y := 15;
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
  lblDescricao.Width := lbProdutos.Width - lblValor.Width - recAdd.Width - recDrop.Width;

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
//  if Assigned(FImage) then
//    item.AddObject(FImage);
end;

procedure TfrmCarrinho.FinalizarPedido;
var
  LModelPedido: TModelPedido;
begin
  try
    LModelPedido := TModelPedido.Create;
    Pedido.NumeroComanda := frmPrincipal.NumeroComanda.ToInteger;
    if LModelPedido.ExecutarRequisicao(Pedido, tpPost, frmPrincipal.Authentication) then
    begin
      TDialogService.ShowMessage('Pedido enviado com sucesso!');
      FreeAndNil(frmPrincipal.Pedido);
      frmPrincipal.ProdutosCarrinho.Clear;
      frmPrincipal.NumeroComanda := EmptyStr;
      Close;
    end
    else
      TDialogService.ShowMessage('Erro ao enviar o pedido!');
  finally
    FreeAndNil(LModelPedido);
  end;
end;

procedure TfrmCarrinho.FormShow(Sender: TObject);
begin
  inherited;
  PreencherLbProdutos;
end;

procedure TfrmCarrinho.lbProdutosMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
begin
  inherited;
  FItemLbProdutos := lbProdutos.ItemByPoint(X, Y);
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
    lblFinalizar.Text := 'Finalizar pedido ' + FloatToStrF(Pedido.ValorTotal, ffCurrency, 15,2);
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
    if (Components[I] is TLabel) and (Components[I].Name = 'lblQtde' + FItemLbProdutos.Index.ToString)
    and ((Sender as TRectangle).Name = 'recAdd' + FItemLbProdutos.Index.ToString) then
    begin
      Pedido.PedidoItem[FItemLbProdutos.Index].Qtde := (Components[I] as TLabel).Text.ToDouble + 1;
      Pedido.PedidoItem[FItemLbProdutos.Index].ValorTotal := Pedido.PedidoItem[FItemLbProdutos.Index].Qtde * Pedido.PedidoItem[FItemLbProdutos.Index].ValorUnitario;
      Pedido.ValorTotal := Pedido.ValorTotal + Pedido.PedidoItem[FItemLbProdutos.Index].ValorUnitario;
    end
    else
    if ((Sender as TRectangle).Name = 'recDrop' + FItemLbProdutos.Index.ToString)
    and (Components[I].Name = 'lblQtde' + FItemLbProdutos.Index.ToString)
    and ((Components[I] as TLabel).Text.ToDouble > 1) then
    begin
      Pedido.PedidoItem[FItemLbProdutos.Index].Qtde := (Components[I] as TLabel).Text.ToDouble - 1;
      Pedido.PedidoItem[FItemLbProdutos.Index].ValorTotal := Pedido.PedidoItem[FItemLbProdutos.Index].Qtde * Pedido.PedidoItem[FItemLbProdutos.Index].ValorUnitario;
      Pedido.ValorTotal := Pedido.ValorTotal - Pedido.PedidoItem[FItemLbProdutos.Index].ValorUnitario;
    end
    else
    if ((Sender as TRectangle).Name = 'recTrash' + FItemLbProdutos.Index.ToString)
    and (Components[I].Name = 'lblQtde' + FItemLbProdutos.Index.ToString) then
    begin
      Pedido.ValorTotal := Pedido.ValorTotal - Pedido.PedidoItem[FItemLbProdutos.Index].ValorTotal;
      Pedido.PedidoItem.Delete(FItemLbProdutos.Index);
      Produtos.Delete(FItemLbProdutos.Index);
      frmPrincipal.lblItensCarrinho.Text := FloatToStr(frmPrincipal.lblItensCarrinho.Text.ToDouble - 1);
    end;
  end;
  PreencherLbProdutos;
end;

procedure TfrmCarrinho.recAdicionarClick(Sender: TObject);
begin
  inherited;
  {$IFDEF MSWINDOWS}
  frmPrincipal.NumeroComanda := '10';
  FinalizarPedido;
  {$ENDIF MSWINDOWS}

  {$IFDEF ANDROID}
  if frmPrincipal.NumeroComanda = EmptyStr then
    frmPrincipal.LerQRCode(qrComanda);
  {$ENDIF ANDROID}
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
