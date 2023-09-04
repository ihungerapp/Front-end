unit Hunger.View.Pedidos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.JSON, Hunger.Model.Entidade.Pedidos,
  System.Generics.Collections, Hunger.Utils;

type
  TfrmPedidos = class(TfrmBase)
    lvPedidosItens: TListView;
    imgFoto: TImage;
    spbVoltar: TSpeedButton;
    procedure spbVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvPedidosItensUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
  private
    FUtils: TUtils;
    FPedidos: TPedidosList;
    function ConsultarPedidos: TJSONOBject;
    procedure Carregar_LvPedidosItens(aPedidos: TObjectList<TPedido>);
    procedure Layout_LvPedidosItens(AItem: TListViewItem);
  end;

var
  frmPedidos: TfrmPedidos;

implementation

uses
  Hunger.View.Main, Client.Connection, REST.Json, FMX.DialogService,
  Hunger.Model.Entidade.Produto;

{$R *.fmx}

procedure TfrmPedidos.Carregar_LvPedidosItens(aPedidos: TObjectList<TPedido>);
var
  LItem: TListViewItem;
  I, J, L, IndexImage : Integer;
  pedido: TPedido;
  txt: TListItemText;
  precificacao: TPrecificacao;
  produtoPrecificacao: TProdutoPrecificacao;
  sTexto: String;
begin
  lvPedidosItens.Items.Clear;
  lvPedidosItens.BeginUpdate;
  imgFoto.MultiResBitmap.Clear;
  IndexImage := 0;
  for I := 0 to Pred(aPedidos.Count) do
  begin
    pedido := aPedidos.Items[I];
    for J := 0 to Pred(pedido.PedidoItem.Count) do
    begin
      LItem := lvPedidosItens.Items.Add;
      with LItem do
      begin
        Height := 90;
        Tag := pedido.PedidoItem.Items[J].IdConsumoAp;
        if pedido.PedidoItem.Items[J].Produto.Imagem <> EmptyStr then
        begin
          imgFoto.MultiResBitmap.Add;
          Inc(IndexImage);
          imgFoto.MultiResBitmap.Items[IndexImage]
            .Bitmap.LoadFromStream(FUtils.Base64ToStream(pedido.PedidoItem.Items[J].Produto.Imagem));
          if not imgFoto.Bitmap.IsEmpty then
            TListItemImage(Objects.FindDrawable('imgProduto')).Bitmap := imgFoto.MultiResBitmap.Items[IndexImage].Bitmap;
        end;
        TListItemText(Objects.FindDrawable('descricao')).Text := Trim(pedido.PedidoItem.Items[J].Produto.Descricao);
        TListItemText(Objects.FindDrawable('pedido_item_status')).Text := pedido.PedidoItem.Items[J].PedidoItemStatus;

        txt := TListItemText(Objects.FindDrawable('valor')) as TListItemText;
        txt.Text :=
        'Qtde ' + FloatToStrF(pedido.PedidoItem.Items[J].Qtde, ffFixed, 15,0) +
        '  Valor Total ' + FloatToStrF(pedido.PedidoItem.Items[J].Vlrtotalitem, ffCurrency, 15,2);

        txt := TListItemText(Objects.FindDrawable('precificacao')) as TListItemText;
        sTexto := EmptyStr;
        for L := 0 to Pred(pedido.PedidoItem.Items[J].ProdutoPrecificacao.Count) do
        begin
          precificacao := pedido.PedidoItem.Items[J].ProdutoPrecificacao[L].Precificacao;
          produtoPrecificacao := pedido.PedidoItem.Items[J].ProdutoPrecificacao[L];
          if L > 0 then
            sTexto := sTexto + #13 + ' - ';
          sTexto := sTexto + precificacao.Grupo + ': ' + precificacao.Tipo;
          if produtoPrecificacao.Valor > 0 then
            sTexto := sTexto + '  ' + FloatToStrF(produtoPrecificacao.Valor, ffFixed, 15,2);
        end;
        txt.Text := sTexto;
        Layout_LvPedidosItens(LItem);
      end;
    end;
  end;
  lvPedidosItens.EndUpdate;
end;

function TfrmPedidos.ConsultarPedidos: TJSONOBject;
var
  LJsonResponse: TJSONObject;
begin
  Result := nil;
  try
    LJsonResponse := nil;
    LJsonResponse := frmPrincipal.Authentication.Connection.Execute(
      'pedido?method=ListarPedidosComProduto&'+
      'search=pedido:"SITUACAO":Em aberto@@@'+
      'mesa:"CADAP_UUID":' + frmPrincipal.MesaUUID, tpGet, nil);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"pedidos":[]}') then
      Result := LJsonResponse;
  except on E:Exception do
    TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                E.Message);
  end;
end;

procedure TfrmPedidos.FormShow(Sender: TObject);
var
  LJSONResponse: TJSONObject;
  LJSONArray: TJSONArray;
  LJSONArrayItem: TJSONArray;
  LJSONValue: TJSONValue;
  pedido: TPedido;
  lstPedido: TObjectList<TPedido>;
  i: Integer;
begin
  inherited;
  FPedidos := TPedidosList.Create;
  lstPedido := TObjectList<TPedido>.Create;
  LJSONResponse := ConsultarPedidos;
  if LJSONResponse = nil then
  begin
    TDialogService.ShowMessage('Não há pedidos em aberto para esta mesa!');
    Close;
  end
  else
  begin
    LJSONArray := LJSONResponse.GetValue('pedidos') as TJSONArray;
    try
      for LJSONValue in LJSONArray do
      begin
        pedido := TJson.JsonToObject<TPedido>(LJSONValue.ToString);
        lstPedido.Add(pedido);
      end;
      FPedidos.Pedidos := lstPedido;
      Carregar_LvPedidosItens(FPedidos.Pedidos);
    finally
      FreeAndNil(LJSONArray);
      lstPedido.Clear;
      FreeAndNil(lstPedido);
    end;
  end;
end;

procedure TfrmPedidos.Layout_LvPedidosItens(AItem: TListViewItem);
var
  txt: TListItemText;
  heights: TArray<Single>;
begin
  SetLength(heights, 3);

  txt := AItem.Objects.FindDrawable('descricao') as TListItemText;
  txt.Width := lvPedidosItens.Width - 100;
  txt.Height := frmPrincipal.GetTextHeight(txt, txt.Width, txt.Text);
  heights[0] := Trunc(txt.Height);

  txt := AItem.Objects.FindDrawable('pedido_item_status') as TListItemText;
  txt.Width := lvPedidosItens.Width - 100;
  txt.Height := frmPrincipal.GetTextHeight(txt, txt.Width, txt.Text);
  txt.PlaceOffset.Y := Trunc(heights[0]);
  heights[1] := Trunc(txt.Height);

  txt := AItem.Objects.FindDrawable('valor') as TListItemText;
  txt.Width := lvPedidosItens.Width - 100;
  txt.Height := frmPrincipal.GetTextHeight(txt, txt.Width, txt.Text);
  txt.PlaceOffset.Y := Trunc(heights[0] + heights[1]);
  heights[2] := Trunc(txt.Height);


  txt := AItem.Objects.FindDrawable('precificacao') as TListItemText;
  txt.Width := lvPedidosItens.Width - 100;
  txt.Height := frmPrincipal.GetTextHeight(txt, txt.Width, txt.Text);
  txt.PlaceOffset.Y := Trunc(heights[0] + heights[1] + heights[2]);

  AItem.Height := Trunc(txt.PlaceOffset.Y + txt.Height);
end;

procedure TfrmPedidos.lvPedidosItensUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
var
  subItem: TListItemDrawable;
begin
  inherited;
  subItem := AItem.Objects.FindDrawable('pedido_item_status');
  if TListItemText(subItem).Text = 'Aguardando' then
    TListItemText(subItem).TextColor := TAlphaColors.Orange;
  if TListItemText(subItem).Text = 'Aprovado' then
    TListItemText(subItem).TextColor := TAlphaColors.Green;
  if TListItemText(subItem).Text = 'Cancelado' then
    TListItemText(subItem).TextColor := TAlphaColors.Red;
end;

procedure TfrmPedidos.spbVoltarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
