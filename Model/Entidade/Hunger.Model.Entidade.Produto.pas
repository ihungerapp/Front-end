unit Hunger.Model.Entidade.Produto;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types;

{$M+}

type
  TPrecificacao = class(TJsonDTO)
  private
    FTipo: string;
    [JSONName('id_precificacao')]
    FIdPrecificacao: Integer;
    FGrupo: string;
    [JSONName('qtde_max_selecao')]
    FQtdeMaxSelecao: Integer;
  published
    property Tipo: string read FTipo write FTipo;
    property IdPrecificacao: Integer read FIdPrecificacao write FIdPrecificacao;
    property Grupo: string read FGrupo write FGrupo;
    property QtdeMaxSelecao: Integer read FQtdeMaxSelecao write FQtdeMaxSelecao;
  end;

  TProdutoPrecificacao = class(TJsonDTO)
  private
    [JSONName('precificacao'), JSONMarshalled(False)]
    FPrecificacao: TPrecificacao;
    [JSONName('id_produto_precificacao')]
    FIdProdutoPrecificacao: Integer;
    [JSONName('id_precificacao')]
    FIdPrecificacao: Integer;
    [JSONName('id_produto')]
    FIdProduto: Integer;
    FValor: Double;
  published
    property Precificacao: TPrecificacao read FPrecificacao;
    property IdProdutoPrecificacao: Integer read FIdProdutoPrecificacao write FIdProdutoPrecificacao;
    property IdPrecificacao: Integer read FIdPrecificacao write FIdPrecificacao;
    property IdProduto: Integer read FIdProduto write FIdProduto;
    property Valor: Double read FValor write FValor;
  end;

  TGrupo = class(TJsonDTO)
  private
    FDescricao: string;
    [JSONName('id_grupo')]
    FIdGrupo: Integer;
  published
    property Descricao: string read FDescricao write FDescricao;
    property IdGrupo: Integer read FIdGrupo write FIdGrupo;
  end;

  TProduto = class(TJsonDTO)
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
    FValorInicial: Double;
    [JSONName('valor_promocao')]
    FValorPromocao: Double;
    [JSONName('grupo'), JSONMarshalled(False)]
    FGrupo: TGrupo;
    [JSONName('produto_precificacao'), JSONMarshalled(False)]
    FProdutoPrecificacaoArray: TArray<TProdutoPrecificacao>;
    [GenericListReflect]
    FProdutoPrecificacao: TObjectList<TProdutoPrecificacao>;
    function GetProdutoPrecificacao: TObjectList<TProdutoPrecificacao>;
  published
    property Grupo: TGrupo read FGrupo;
    property Complemento: string read FComplemento write FComplemento;
    property Descricao: string read FDescricao write FDescricao;
    property IdGrupo: Integer read FIdGrupo write FIdGrupo;
    property IdProduto: Integer read FIdProduto write FIdProduto;
    property Imagem: string read FImagem write FImagem;
    property PromocaoDoDia: Boolean read FPromocaoDoDia write FPromocaoDoDia;
    property ValorInicial: Double read FValorInicial write FValorInicial;
    property ValorPromocao: Double read FValorPromocao write FValorPromocao;
    property ProdutoPrecificacao: TObjectList<TProdutoPrecificacao> read GetProdutoPrecificacao;
  end;

  TProdutoList = class(TJsonDTO)
  private
    [JSONName('produtos'), JSONMarshalled(False)]
    FProdutosArray: TArray<TProduto>;
    [GenericListReflect]
    FProdutos: TObjectList<TProduto>;
    FPageNumber: Integer;
    FPageSize: Integer;
    FTotalElements: Integer;
    FTotalPages: Integer;
    function GetProdutos: TObjectList<TProduto>;
    procedure SetProdutoList(const Value: TObjectList<TProduto>);
  protected
    function GetAsJson: string; override;
  published
    property Produtos: TObjectList<TProduto> read GetProdutos write SetProdutoList;
    property PageNumber: Integer read FPageNumber write FPageNumber;
    property PageSize: Integer read FPageSize write FPageSize;
    property TotalElements: Integer read FTotalElements write FTotalElements;
    property TotalPages: Integer read FTotalPages write FTotalPages;
  public
    destructor Destroy; override;
  end;

  TProdutoPrecificacaoList = class(TJsonDTO)
  private
    [JSONName('produto_precificacao'), JSONMarshalled(False)]
    FProdutoPrecificacaoArray: TArray<TProdutoPrecificacao>;
    [GenericListReflect]
    FProdutoPrecificacao: TObjectList<TProdutoPrecificacao>;
    function GetProdutoPrecificacao: TObjectList<TProdutoPrecificacao>;
    procedure SetProdutoPrecificacaoList(const Value: TObjectList<TProdutoPrecificacao>);
  protected
    function GetAsJson: string; override;
  published
    property Enderecos: TObjectList<TProdutoPrecificacao> read GetProdutoPrecificacao write SetProdutoPrecificacaoList;
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

procedure TProdutoList.SetProdutoList(const Value: TObjectList<TProduto>);
begin
  FProdutos := Value;
end;

function TProdutoList.GetAsJson: string;
begin
  RefreshArray<TProduto>(FProdutos, FProdutosArray);
  Result := inherited;
end;

{ TProduto }

function TProduto.GetProdutoPrecificacao: TObjectList<TProdutoPrecificacao>;
begin
  Result := ObjectList<TProdutoPrecificacao>(FProdutoPrecificacao, FProdutoPrecificacaoArray);
end;

{ TProdutoPrecificacaoList }

destructor TProdutoPrecificacaoList.Destroy;
begin
  GetProdutoPrecificacao.Free;
  inherited;
end;

function TProdutoPrecificacaoList.GetAsJson: string;
begin
  RefreshArray<TProdutoPrecificacao>(FProdutoPrecificacao, FProdutoPrecificacaoArray);
  Result := inherited;
end;

function TProdutoPrecificacaoList.GetProdutoPrecificacao: TObjectList<TProdutoPrecificacao>;
begin
  Result := ObjectList<TProdutoPrecificacao>(FProdutoPrecificacao, FProdutoPrecificacaoArray);
end;

procedure TProdutoPrecificacaoList.SetProdutoPrecificacaoList(const Value: TObjectList<TProdutoPrecificacao>);
begin
  FProdutoPrecificacao := Value;
end;

end.
