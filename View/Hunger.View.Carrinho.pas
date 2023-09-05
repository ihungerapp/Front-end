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
    FModelPedido: TModelPedido;
    FUtils: TUtils;
    FImage: TImage;
    FItemLbProdutos: TListBoxItem;
    procedure SetPedido(const Value: TPedido);
    procedure PreencherLbProdutos;
    procedure AddItemLb(aIndex: Integer; aPedidoItem: TPedidoItem);
    function ValidarMesaComanda: Boolean;
  public
    property Pedido: TPedido read FPedido write SetPedido;
    procedure FinalizarPedido;
  end;

var
  frmCarrinho: TfrmCarrinho;

implementation

uses
  Hunger.View.Main, Client.Connection, FMX.DialogService,
  Hunger.View.LeitorCamera, System.JSON;

{$R *.fmx}

{ TfrmBase1 }

procedure TfrmCarrinho.AddItemLb(aIndex: Integer; aPedidoItem: TPedidoItem);
var
  item: TListBoxItem;
  lblDescricao: TLabel;
  lblPrecificacao: TLabel;
  lblValor: TLabel;
  lblQtde: TLabel;
  recAdd: TRectangle;
  recDrop: TRectangle;
  recTrash: TRectangle;
  I, J: Integer;
begin
  item := TListBoxItem.Create(nil);
  item.StyledSettings := [];
  item.Padding.Left := 10;
  item.Padding.Top := 5;
  item.Padding.Bottom := 5;
  item.Padding.Right := 10;

  recDrop := TRectangle.Create(lbProdutos);
  with recDrop do
  begin
    Align := TAlignLayout.Right;
    Fill.Bitmap.Bitmap := imgCarrinho.Bitmap(TSizeF.Create(20,20), 1);
    Fill.Bitmap.WrapMode := TWrapMode.TileOriginal;
    Fill.Kind := TBrushKind.Bitmap;
    Margins.Bottom := -5;
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
    Align := TAlignLayout.Right;
    Margins.Bottom := -5;
    Size.Width := 30.000000000000000000;
    Size.Height := 30.000000000000000000;
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.VertAlign := TTextAlign.Leading;
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
    Align := TAlignLayout.Right;
    Fill.Bitmap.Bitmap := imgCarrinho.Bitmap(TSizeF.Create(20,20), 0);
    Fill.Bitmap.WrapMode := TWrapMode.TileOriginal;
    Fill.Kind := TBrushKind.Bitmap;
    Margins.Bottom := -5;
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
    Align := TAlignLayout.FitRight;
    Size.Width := 100;
    Size.Height := 40;
    Margins.Top := 10;
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.VertAlign := TTextAlign.Center;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := TAlphaColors.Darkgreen;
    Text := 'Total ' + FloatToStrF(aPedidoItem.Vlrtotalitem, ffCurrency, 15,2);
  end;

  recTrash := TRectangle.Create(lbProdutos);
  with recTrash do
  begin
    Align := TAlignLayout.MostRight;
    Fill.Bitmap.Bitmap := imgCarrinho.Bitmap(TSizeF.Create(20,20), 2);
    Fill.Bitmap.WrapMode := TWrapMode.TileOriginal;
    Fill.Kind := TBrushKind.Bitmap;
    Margins.Left := 20;
    Margins.Bottom := -5;
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
    Align := TAlignLayout.MostLeft;
    TextSettings.HorzAlign := TTextAlign.Leading;
    TextSettings.VertAlign := TTextAlign.Leading;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := $FFF83923;
    Text := aPedidoItem.Produto.Descricao;
    WordWrap := True;
  end;

  lblPrecificacao := TLabel.Create(lbProdutos);
  with lblPrecificacao do
  begin
    StyledSettings := [];
    Align := TAlignLayout.MostBottom;
    TextSettings.HorzAlign := TTextAlign.Leading;
    TextSettings.VertAlign := TTextAlign.Leading;
    TextSettings.Font.Family := 'Inter';
    TextSettings.Font.Size := 14;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.FontColor := $FF1D78CE;
    Text := EmptyStr;
    for I := 0 to Pred(aPedidoItem.ProdutoPrecificacao.Count) do
    begin
      Text := Text + #13 + aPedidoItem.ProdutoPrecificacao[I].Precificacao.Tipo;
      if aPedidoItem.ProdutoPrecificacao[I].Valor > 0 then
        Text := Text + '  ' + FloatToStrF(aPedidoItem.ProdutoPrecificacao[I].Valor, ffFixed, 15,2);
      lblPrecificacao.Height := lblPrecificacao.Height + 20;
    end;
    WordWrap := True;
  end;

  item.AddObject(lblDescricao);
  item.AddObject(lblPrecificacao);
  lblDescricao.Width := lbProdutos.Width - lblQtde.Width - recAdd.Width - recDrop.Width;
  lblPrecificacao.Width := lbProdutos.Width - lblQtde.Width - recAdd.Width - recDrop.Width;

  item.Height := lblDescricao.Height + lblPrecificacao.Height + 10;

  lblQtde.Position.X := recDrop.Position.X + recDrop.Width;
  recAdd.Position.X := lblQtde.Position.X + lblQtde.Width;

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
  pedidoItem: TPedidoItem;
begin
  FModelPedido := TModelPedido.Create;
  try
    Pedido.NComanda := frmPrincipal.NumeroComanda.ToInteger;
    if not (ValidarMesaComanda) then
      TDialogService.ShowMessage('Comanda vinculada a outra mesa!')
    else
    begin
      for pedidoItem in Pedido.PedidoItem do
      begin
        if Pedido.Codrecepcao > 0  then
          pedidoItem.Codrecepcao := Pedido.Codrecepcao;
        pedidoItem.NComandaRecepcao := Pedido.NComanda;
      end;

      if (FModelPedido.ExecutarRequisicao(Pedido, tpPost, frmPrincipal.Authentication)) then
      begin
        TDialogService.ShowMessage('Pedido enviado com sucesso!');
        if Assigned(frmPrincipal.Pedido) then
          FreeAndNil(frmPrincipal.Pedido);
        frmPrincipal.ProdutosCarrinho.Clear;
        Close;
      end
      else
        TDialogService.ShowMessage('Erro ao enviar o pedido!');
    end;
  finally
    FreeAndNil(FModelPedido);
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
    lblFinalizar.Text := 'Finalizar pedido ' + FloatToStrF(Pedido.Vlrtotal, ffCurrency, 15,2);
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
      Pedido.PedidoItem[FItemLbProdutos.Index].Vlrtotalitem := Pedido.PedidoItem[FItemLbProdutos.Index].Qtde * Pedido.PedidoItem[FItemLbProdutos.Index].Vlrunitario;
      Pedido.Vlrtotal := Pedido.Vlrtotal + Pedido.PedidoItem[FItemLbProdutos.Index].Vlrunitario;
    end
    else
    if ((Sender as TRectangle).Name = 'recDrop' + FItemLbProdutos.Index.ToString)
    and (Components[I].Name = 'lblQtde' + FItemLbProdutos.Index.ToString)
    and ((Components[I] as TLabel).Text.ToDouble > 1) then
    begin
      Pedido.PedidoItem[FItemLbProdutos.Index].Qtde := (Components[I] as TLabel).Text.ToDouble - 1;
      Pedido.PedidoItem[FItemLbProdutos.Index].Vlrtotalitem := Pedido.PedidoItem[FItemLbProdutos.Index].Qtde * Pedido.PedidoItem[FItemLbProdutos.Index].Vlrunitario;
      Pedido.Vlrtotal := Pedido.Vlrtotal - Pedido.PedidoItem[FItemLbProdutos.Index].Vlrunitario;
    end
    else
    if ((Sender as TRectangle).Name = 'recTrash' + FItemLbProdutos.Index.ToString)
    and (Components[I].Name = 'lblQtde' + FItemLbProdutos.Index.ToString) then
    begin
      Pedido.Vlrtotal := Pedido.Vlrtotal - Pedido.PedidoItem[FItemLbProdutos.Index].Vlrtotalitem;
      Pedido.PedidoItem.Delete(FItemLbProdutos.Index);
      frmPrincipal.ProdutosCarrinho.Delete(FItemLbProdutos.Index);
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

procedure TfrmCarrinho.spbVoltarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

function TfrmCarrinho.ValidarMesaComanda: Boolean;
var
  LJsonResponse: TJSONObject;
  LJsonValue: TJSONValue;
  LJsonArray: TJSONArray;
  I: integer;
begin
  //Verifica se o número da comanda que acabou de ler o QR,
  // é igual aos pedidos anteriores em aberto e da mesma mesa, se existente
  Result := False;
  LJsonResponse := FModelPedido.ConsultarPedido(frmPrincipal.Authentication.Connection, Pedido.NComanda.ToString);
  if Assigned(LJsonResponse) then
    if LJsonResponse.FindValue('totalElements').ToJSON.ToInteger = 0 then
      Result := True
    else
    begin
      LJsonResponse.TryGetValue('content', LJsonArray);
      for I := 0 to Pred(LJsonArray.Count) do
      begin
        if Pedido.Codap = LJsonArray.Items[I].FindValue('codap').ToJSON.ToInteger then
        begin
          Pedido.Codrecepcao := LJsonArray.Items[I].FindValue('codrecepcao').ToJSON.ToInteger;
          Result := True;
        end
        else
        begin
          Result := False;
          frmPrincipal.NumeroComanda := EmptyStr;
          Exit;
        end;
      end;
    end;
    if not Result then
      frmPrincipal.NumeroComanda := EmptyStr;
end;

end.
