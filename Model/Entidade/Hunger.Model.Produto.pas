unit Hunger.Model.Produto;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types;

{$M+}

type
  TProduto = class
  private
    FComplemento: string;
    FDescricao: string;
    [JSONName('id_grupo')]
    FIdGrupo: Integer;
    [JSONName('id_produto')]
    FIdProduto: Integer;
    FImagem: string;
    [JSONName('promocao_do_dia')]
    FPromocaoDoDia: Boolean;
    [JSONName('valor_inicial')]
    FValorInicial: string;
    [JSONName('valor_promocao')]
    FValorPromocao: string;
  published
    property Complemento: string read FComplemento write FComplemento;
    property Descricao: string read FDescricao write FDescricao;
    property IdGrupo: Integer read FIdGrupo write FIdGrupo;
    property IdProduto: Integer read FIdProduto write FIdProduto;
    property Imagem: string read FImagem write FImagem;
    property PromocaoDoDia: Boolean read FPromocaoDoDia write FPromocaoDoDia;
    property ValorInicial: string read FValorInicial write FValorInicial;
    property ValorPromocao: string read FValorPromocao write FValorPromocao;
  end;

  TProdutoList = class(TJsonDTO)
  private
    [JSONName('content'), JSONMarshalled(False)]
    FProdutosArray: TArray<TProduto>;
    [GenericListReflect]
    FProdutos: TObjectList<TProduto>;
    FPageNumber: Integer;
    FPageSize: Integer;
    FTotalElements: Integer;
    FTotalPages: Integer;
    function GetProdutos: TObjectList<TProduto>;
  protected
    function GetAsJson: string; override;
  published
    property Produtos: TObjectList<TProduto> read GetProdutos;
    property PageNumber: Integer read FPageNumber write FPageNumber;
    property PageSize: Integer read FPageSize write FPageSize;
    property TotalElements: Integer read FTotalElements write FTotalElements;
    property TotalPages: Integer read FTotalPages write FTotalPages;
  public
    destructor Destroy; override;
  end;

implementation

{ TProdutoList }

destructor TProdutoList.Destroy;
begin
  GetProdutos.Free;
  inherited;
end;

function TProdutoList.GetProdutos: TObjectList<TProduto>;
begin
  Result := ObjectList<TProduto>(FProdutos, FProdutosArray);
end;

function TProdutoList.GetAsJson: string;
begin
  RefreshArray<TProduto>(FProdutos, FProdutosArray);
  Result := inherited;
end;

end.
