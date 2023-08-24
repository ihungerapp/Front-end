unit Hunger.Model.Entidade.Pedidos;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types,
  Hunger.Model.Entidade.Produto;

{$M+}

type
  TPedidoItem = class;

  TPedidoItem = class
  private
    [SuppressZero, JSONName('DATA_CONSUMO')]
    FDataConsumo: TDateTime;
    [JSONName('CODRECEPCAO')]
    FCodrecepcao: Integer;
    [JSONName('ID_CONSUMO_AP')]
    FIdConsumoAp: Integer;
    [JSONName('CODPROD')]
    FCodprod: Integer;
    [JSONName('N_COMANDA_RECEPCAO')]
    FNComandaRecepcao: Integer;
    [JSONName('PEDIDO_ITEM_STATUS')]
    FPedidoItemStatus: string;
    FQtde: Double;
    [JSONName('VLRTOTALITEM')]
    FVlrtotalitem: Double;
    [JSONName('VLRUNITARIO')]
    FVlrunitario: Double;
    [JSONName('id_produto_precificacao')]
    FIdProdutoPrecificacao: String;
    [JSONName('produto'), JSONMarshalled(False)]
    FProduto: TProduto;
    FComplemento: String;
  published
    property DataConsumo: TDateTime read FDataConsumo write FDataConsumo;
    property Codrecepcao: Integer read FCodrecepcao write FCodrecepcao;
    property IdConsumoAp: Integer read FIdConsumoAp write FIdConsumoAp;
    property Codprod: Integer read FCodprod write FCodprod;
    property NComandaRecepcao: Integer read FNComandaRecepcao write FNComandaRecepcao;
    property PedidoItemStatus: string read FPedidoItemStatus write FPedidoItemStatus;
    property Qtde: Double read FQtde write FQtde;
    property Vlrtotalitem: Double read FVlrtotalitem write FVlrtotalitem;
    property Vlrunitario: Double read FVlrunitario write FVlrunitario;
    property IdProdutoPrecificacao: String read FIdProdutoPrecificacao write FIdProdutoPrecificacao;
    property Produto: TProduto read FProduto;
    property Complemento: string read FComplemento write FComplemento;
  end;

  TPedido = class(TJsonDTO)
  private
    [SuppressZero, JSONName('DATA_ENTRADA')]
    FDataEntrada: TDateTime;
    [SuppressZero, JSONName('DATA_SAIDA')]
    FDataSaida: TDateTime;
    [JSONName('e_mail')]
    FEMail: string;
    [JSONName('CODAP')]
    FCodap: Integer;
    [JSONName('CODREPCAO')]
    FCodrecepcao: Integer;
    [JSONName('CODCLI')]
    FCodcli: Integer;
    [JSONName('nome_cliente')]
    FNomeCliente: string;
    [JSONName('numero_celular')]
    FNumeroCelular: string;
    [JSONName('N_COMANDA')]
    FNComanda: Integer;
    [JSONName('QTDEPAGANTE')]
    FQtdepagante: Integer;
    [JSONName('pedido_item'), JSONMarshalled(False)]
    FPedidoItemArray: TArray<TPedidoItem>;
    [GenericListReflect]
    FPedidoItem: TObjectList<TPedidoItem>;
    [JSONName('SITUACAO')]
    FSituacao: string;
    [JSONName('VLRTOTAL')]
    FVlrtotal: Double;
    [JSONName('fechar_conta')]
    FFecharConta: Boolean;
    function GetPedidoItem: TObjectList<TPedidoItem>;
  protected
    function GetAsJson: string; override;
  published
    property DataEntrada: TDateTime read FDataEntrada write FDataEntrada;
    property DataSaida: TDateTime read FDataSaida write FDataSaida;
    property EMail: string read FEMail write FEMail;
    property Codap: Integer read FCodap write FCodap;
    property Codrecepcao: Integer read FCodrecepcao write FCodrecepcao;
    property Codcli: Integer read FCodcli write FCodcli;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property NumeroCelular: string read FNumeroCelular write FNumeroCelular;
    property NComanda: Integer read FNComanda write FNComanda;
    property Qtdepagante: Integer read FQtdepagante write FQtdepagante;
    property PedidoItem: TObjectList<TPedidoItem> read GetPedidoItem;
    property Situacao: string read FSituacao write FSituacao;
    property Vlrtotal: Double read FVlrtotal write FVlrtotal;
    property FecharConta: Boolean read FFecharConta write FFecharConta;
  public
    destructor Destroy; override;
  end;
  
  TPedidosList = class(TJsonDTO)
  private
    [JSONName('pedidos'), JSONMarshalled(False)]
    FPedidosArray: TArray<TPedido>;
    [GenericListReflect]
    FPedidos: TObjectList<TPedido>;
    function GetPedidos: TObjectList<TPedido>;
    procedure SetPedidoList(const Value: TObjectList<TPedido>);
  protected
    function GetAsJson: string; override;
  published
    property Pedidos: TObjectList<TPedido> read GetPedidos write SetPedidoList;
  public
    destructor Destroy; override;
  end;
  
implementation

{ TPedido }

destructor TPedido.Destroy;
begin
  GetPedidoItem.Free;
  inherited;
end;

function TPedido.GetPedidoItem: TObjectList<TPedidoItem>;
begin
  Result := ObjectList<TPedidoItem>(FPedidoItem, FPedidoItemArray);
end;

function TPedido.GetAsJson: string;
begin
  RefreshArray<TPedidoItem>(FPedidoItem, FPedidoItemArray);
  Result := inherited;
end;

{ TPedidosList }

destructor TPedidosList.Destroy;
begin
  GetPedidos.Free;
  inherited;
end;

function TPedidosList.GetPedidos: TObjectList<TPedido>;
begin
  Result := ObjectList<TPedido>(FPedidos, FPedidosArray);
end;

procedure TPedidosList.SetPedidoList(const Value: TObjectList<TPedido>);
begin
  FPedidos := Value;
end;

function TPedidosList.GetAsJson: string;
begin
  RefreshArray<TPedido>(FPedidos, FPedidosArray);
  Result := inherited;
end;

end.
