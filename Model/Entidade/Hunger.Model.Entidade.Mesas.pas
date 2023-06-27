unit Hunger.Model.Entidade.Mesas;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types,
  Hunger.Model.Entidade.Pedidos;

{$M+}

type
  TMesa = class(TJsonDTO)
  private
    [JSONName('mesa_uuid')]
    FMesaUUID: string;
    FDescricao: string;
    [JSONName('id_mesa')]
    FIdMesa: Integer;

    [JSONName('pedido'), JSONMarshalled(False)]
    FPedidoArray: TArray<TPedido>;
    [GenericListReflect]
    FPedido: TObjectList<TPedido>;
    function GetPedido: TObjectList<TPedido>;
  published
    property MesaUUID: string read FMesaUUID write FMesaUUID;
    property Descricao: string read FDescricao write FDescricao;
    property IdMesa: Integer read FIdMesa write FIdMesa;
    property Pedido: TObjectList<TPedido> read GetPedido;
  end;

  TMesasList = class(TJsonDTO)
  private
    [JSONName('mesas'), JSONMarshalled(False)]
    FMesasArray: TArray<TMesa>;
    [GenericListReflect]
    FMesas: TObjectList<TMesa>;
    FPageNumber: Integer;
    FPageSize: Integer;
    FTotalElements: Integer;
    FTotalPages: Integer;
    function GetMesas: TObjectList<TMesa>;
    procedure SetMesaList(const Value: TObjectList<TMesa>);
  protected
    function GetAsJson: string; override;
  published
    property Mesas: TObjectList<TMesa> read GetMesas write SetMesaList;
    property PageNumber: Integer read FPageNumber write FPageNumber;
    property PageSize: Integer read FPageSize write FPageSize;
    property TotalElements: Integer read FTotalElements write FTotalElements;
    property TotalPages: Integer read FTotalPages write FTotalPages;
  public
    destructor Destroy; override;
  end;

implementation

{ TMesasList }

destructor TMesasList.Destroy;
begin
  GetMesas.Free;
  inherited;
end;

function TMesasList.GetMesas: TObjectList<TMesa>;
begin
  Result := ObjectList<TMesa>(FMesas, FMesasArray);
end;

procedure TMesasList.SetMesaList(const Value: TObjectList<TMesa>);
begin
  FMesas := Value;
end;

function TMesasList.GetAsJson: string;
begin
  RefreshArray<TMesa>(FMesas, FMesasArray);
  Result := inherited;
end;

{ TMesa }

function TMesa.GetPedido: TObjectList<TPedido>;
begin
  Result := ObjectList<TPedido>(FPedido, FPedidoArray);
end;

end.
