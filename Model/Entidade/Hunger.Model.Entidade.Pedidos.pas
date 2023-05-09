unit Hunger.Model.Entidade.Pedidos;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types;

{$M+}

type
  TPedidoItem = class;

  TPedidoItem = class
  private
    [SuppressZero, JSONName('data_hora_emissao')]
    FDataHoraEmissao: TDateTime;
    [SuppressZero, JSONName('data_hora_status')]
    FDataHoraStatus: TDateTime;
    [JSONName('id_pedido')]
    FIdPedido: Integer;
    [JSONName('id_pedido_item')]
    FIdPedidoItem: Integer;
    [JSONName('id_produto')]
    FIdProduto: Integer;
    [JSONName('pedido_item_status')]
    FPedidoItemStatus: string;
    FQtde: Double;
    [JSONName('valor_total')]
    FValorTotal: Double;
    [JSONName('valor_unitario')]
    FValorUnitario: Double;
  published
    property DataHoraEmissao: TDateTime read FDataHoraEmissao write FDataHoraEmissao;
    property DataHoraStatus: TDateTime read FDataHoraStatus write FDataHoraStatus;
    property IdPedido: Integer read FIdPedido write FIdPedido;
    property IdPedidoItem: Integer read FIdPedidoItem write FIdPedidoItem;
    property IdProduto: Integer read FIdProduto write FIdProduto;
    property PedidoItemStatus: string read FPedidoItemStatus write FPedidoItemStatus;
    property Qtde: Double read FQtde write FQtde;
    property ValorTotal: Double read FValorTotal write FValorTotal;
    property ValorUnitario: Double read FValorUnitario write FValorUnitario;
    property EMail: string read FEMail write FEMail;
  end;

  TPedido = class(TJsonDTO)
  private
    [SuppressZero, JSONName('data_hora_abertura')]
    FDataHoraAbertura: TDateTime;
    [SuppressZero, JSONName('data_hora_finalizacao')]
    FDataHoraFinalizacao: TDateTime;
    [JSONName('e_mail')]
    FEMail: string;
    [JSONName('id_mesa')]
    FIdMesa: Integer;
    [JSONName('id_pedido')]
    FIdPedido: Integer;
    [JSONName('id_pessoa')]
    FIdPessoa: Integer;
    [JSONName('nome_cliente')]
    FNomeCliente: string;
    [JSONName('numero_celular')]
    FNumeroCelular: string;
    [JSONName('numero_comanda')]
    FNumeroComanda: Integer;
    [JSONName('pedido_item'), JSONMarshalled(False)]
    FPedidoItemArray: TArray<TPedidoItem>;
    [GenericListReflect]
    FPedidoItem: TObjectList<TPedidoItem>;
    [JSONName('pedido_status')]
    FPedidoStatus: string;
    [JSONName('valor_total')]
    FValorTotal: Double;
    [JSONName('fechar_conta')]
    FFecharConta: Boolean;
    function GetPedidoItem: TObjectList<TPedidoItem>;
  protected
    function GetAsJson: string; override;
  published
    property DataHoraAbertura: TDateTime read FDataHoraAbertura write FDataHoraAbertura;
    property DataHoraFinalizacao: TDateTime read FDataHoraFinalizacao write FDataHoraFinalizacao;
    property EMail: string read FEMail write FEMail;
    property IdMesa: Integer read FIdMesa write FIdMesa;
    property IdPedido: Integer read FIdPedido write FIdPedido;
    property IdPessoa: Integer read FIdPessoa write FIdPessoa;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property NumeroCelular: string read FNumeroCelular write FNumeroCelular;
    property NumeroComanda: Integer read FNumeroComanda write FNumeroComanda;
    property PedidoItem: TObjectList<TPedidoItem> read GetPedidoItem;
    property PedidoStatus: string read FPedidoStatus write FPedidoStatus;
    property ValorTotal: Double read FValorTotal write FValorTotal;
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
