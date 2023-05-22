unit Hunger.Model.Pedido;

interface

uses
  Hunger.Model.Entidade.Pedidos, System.Generics.Collections, System.JSON,
  Client.Connection, Authentication;

type
  TModelPedido = class
  private
    FPedidos: TPedidosList;
  public
    constructor create;
    destructor destroy;
    function PopularListaPedido(aJsonObject: TJSONObject): TObjectList<TPedido>;
    function ConsultarPedido(aConnection: TClientConnection; aNumComanda: String): TJSONObject;
    function ExecutarRequisicao(aPedido: TPedido; aMetodo: TEnumMethod; aAuthentication: TAuthentication): Boolean;
  end;

implementation

uses
  REST.Json, System.SysUtils, FMX.Dialogs, FMX.DialogService;

{ TModelPedido }

constructor TModelPedido.create;
begin
  inherited create;
end;

destructor TModelPedido.destroy;
begin
  inherited destroy;
end;

function TModelPedido.ExecutarRequisicao(aPedido: TPedido; aMetodo: TEnumMethod; aAuthentication: TAuthentication): Boolean;
var
  LJsonObject: TJSONObject;
  LJsonArray: TJSONArray;
  LJsonResponse: TJSONObject;
begin
  try
    LJsonObject := TJSONObject.Create;
    LJsonArray := TJSONArray.Create;
    Result := False;
    try
      LJsonObject :=  TJSONObject(TJSONObject.ParseJSONValue(aPedido.AsJson)) as TJSONObject;
      LJsonArray.AddElement(LJsonObject);
      LJsonObject := nil;
      LJsonObject := TJSONObject.Create;
      LJsonObject.AddPair('pedido', LJsonArray);
      LJsonResponse := aAuthentication.Connection.Execute('pedido', aMetodo, LJsonObject);
      if LJsonResponse.FindValue('sucesso').ToString = 'true' then
        Result := True;
    finally
      FreeAndNil(LJsonObject);
      FreeAndNil(LJsonResponse);
    end;
  except on E:Exception do
    begin
      TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
  end;
end;

function TModelPedido.PopularListaPedido(
  aJsonObject: TJSONObject): TObjectList<TPedido>;
var
  LJSONArray: TJSONArray;
  LJSONValue: TJSONValue;
  Pedido: TPedido;
  lstPedido: TObjectList<TPedido>;
  i: Integer;
begin
  Result := nil;
  FPedidos := nil;
  FPedidos := TPedidosList.Create;
  lstPedido:= TObjectList<TPedido>.Create;
  LJSONArray := aJSONObject.GetValue('pedidos') as TJSONArray;
  try
    for LJSONValue in LJSONArray do
    begin
      Pedido := TJson.JsonToObject<TPedido>(LJSONValue.ToString);
      lstPedido.Add(Pedido);
    end;
    FPedidos.Pedidos := lstPedido;
    Result := FPedidos.Pedidos;
  finally
    FreeAndNil(LJSONArray);
  end;
end;

function TModelPedido.ConsultarPedido(aConnection: TClientConnection; aNumComanda: String): TJSONObject;
var
  LJsonResponse: TJSONObject;
  search: String;
begin
  Result := nil;
  try
    search := EmptyStr;
    if aNumComanda <> EmptyStr then
      search := '?search=pedido:numero_comanda:' + aNumComanda + '@@@'+
                'pedido:pedido_status:Em aberto' +
                '&JSON=<!"TypeSearch":"no incidence"!>';
    LJsonResponse := aConnection.Execute('pedido' + search, tpGet, nil);

    Result := LJsonResponse;
  except on E:Exception do
    begin
      TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
  end;
end;

end.
