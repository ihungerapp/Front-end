unit Hunger.View.Pedidos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.JSON, Hunger.Model.Entidade.Pedidos,
  System.Generics.Collections;

type
  TfrmBase1 = class(TfrmBase)
    lvPedidosItens: TListView;
    procedure FormCreate(Sender: TObject);
  private
    function ConsultarPedidos: TJSONOBject;
    procedure Carregar_LvPedidosItens(aPedidos: TObjectList<TPedido>);
    { Public declarations }
  end;

var
  frmBase1: TfrmBase1;

implementation

uses
  Hunger.View.Main, Client.Connection, REST.Json;

{$R *.fmx}

procedure TfrmBase1.Carregar_LvPedidosItens(aPedidos: TObjectList<TPedido>);
var
  item: TListItem;
  IndexPedido,
  IndexPedidoItem: Integer;
begin
  try
    for IndexPedido := 0 to Pred(aPedidos.Count) do
    begin
      for IndexPedidoItem := 0 to Pred(aPedidos[IndexPedido].PedidoItem.Count) do
      begin
        item := lvPedidosItens.Items.Add;
        item.Caption := aPedidos[IndexPedido].IdMesa.ToString;
        item.SubItems.Add(aPedidos[IndexPedido].NumeroComanda.ToString);
        item.SubItems.Add(dm.ZQProduto.FieldByName('DESCRICAO').AsString);

        dm.ZQuery.Locate('ID_CONSUMO_HUNGER_APP', aPedido[IndexPedido]
          .PedidoItem[IndexPedidoItem].IdPedidoItem, []);

        item.SubItems.Add(dm.ZQuery.FieldByName('ID_CONSUMO_AP').AsString);
        item.SubItems.Add(dm.ZQuery.FieldByName('ID_CONSUMO_HUNGER_APP').AsString);
        item.SubItems.Add(dm.ZQuery.FieldByName('CODRECEPCAO').AsString);
      end;
    end;
  finally
    FreeAndNil(produtoDAO);
  end;
end;

function TfrmBase1.ConsultarPedidos: TJSONOBject;
var
  LJsonResponse: TJSONObject;
begin
  try
    LJsonResponse := nil;
    LJsonResponse := frmPrincipal.Authentication.Connection.Execute(
      'pedido?method=ListarPedidos&method=ListarPedidos&'+
      'search=pedido:pedido_status:Em aberto@@@'+
      'pedido_item:pedido_item_status:Aprovado', tpGet, nil);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"pedidos":[]}') then
      //IncluirPedidos(LJsonResponse);
  except on E:Exception do
    ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                E.Message);
  end;
end;

procedure TfrmBase1.FormCreate(Sender: TObject);
var
  LJSONResponse: TJSONObject;
  LJSONArray: TJSONArray;
  LJSONArrayItem: TJSONArray;
  LJSONValue: TJSONValue;
  pedido: TPedido;
  pedidos: TPedidosList;
  lstPedido: TObjectList<TPedido>;
  i: Integer;
begin
  inherited;
  pedidos := TPedidosList.Create;
  lstPedido := TObjectList<TPedido>.Create;
  LJSONResponse := ConsultarPedidos;
  LJSONArray := LJSONResponse.GetValue('pedidos') as TJSONArray;
  try
    for LJSONValue in LJSONArray do
    begin
      pedido := TJson.JsonToObject<TPedido>(LJSONValue.ToString);
      lstPedido.Add(pedido);
    end;
    pedidos.Pedidos := lstPedido;
    Carregar_LvPedidosItens(pedidos.Pedidos);
  finally
    FreeAndNil(LJSONArray);
    lstPedido.Clear;
    FreeAndNil(lstPedido);
  end;
end;

end.
