unit Hunger.Model.Produto;

interface

uses
  Hunger.Model.Entidade.Produto, System.Generics.Collections, System.JSON,
  Client.Connection, Hunger.Utils;

type
  TModelProduto = class
  private
    FProdutos: TProdutoList;
    FProdutoPrecificacao: TProdutoPrecificacaoList;
    FUtils: TUtils;
  public
    constructor create;
    destructor destroy;
    function PopularListaProduto(aJsonObject: TJSONObject): TObjectList<TProduto>;
    function ConsultarProduto(aConnection: TClientConnection; aDescricao: String): TJSONObject;
  end;

implementation

uses
  REST.Json, System.SysUtils, FMX.Dialogs, FMX.DialogService;

{ TModelProduto }

constructor TModelProduto.create;
begin
  inherited create;
end;

destructor TModelProduto.destroy;
begin
  inherited destroy;
end;

function TModelProduto.PopularListaProduto(
  aJsonObject: TJSONObject): TObjectList<TProduto>;
var
  LJSONArray: TJSONArray;
  LJSONValue: TJSONValue;
  produto: TProduto;
  lstProduto: TObjectList<TProduto>;
  i: Integer;
begin
  Result := nil;
  FProdutos := nil;
  FProdutos := TProdutoList.Create;
  lstProduto:= TObjectList<TProduto>.Create;
  LJSONArray := aJSONObject.GetValue('produtos') as TJSONArray;
  try
    for LJSONValue in LJSONArray do
    begin
      produto := TJson.JsonToObject<TProduto>(LJSONValue.ToString);
      lstProduto.Add(produto);
    end;
    FProdutos.Produtos := lstProduto;
    Result := FProdutos.Produtos;
  finally
    FreeAndNil(LJSONArray);
  end;
end;

function TModelProduto.ConsultarProduto(aConnection: TClientConnection; aDescricao: String): TJSONObject;
var
  LJsonResponse: TJSONObject;
  search: String;
begin
  Result := nil;
  try
    search := EmptyStr;
    if aDescricao <> EmptyStr then
      search := '&search=produto:descricao:' + LowerCase(aDescricao) +
                '@@@produto:exibir_app:true';
    LJsonResponse := aConnection.Execute('produto?method=ListarProdutos' + search, tpGet, nil);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"produtos":[]}') then
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
