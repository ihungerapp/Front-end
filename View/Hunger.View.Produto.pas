unit Hunger.View.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  System.Generics.Collections, Hunger.Model.Entidade.Produto, FMX.ListBox,
  FMX.Edit, FMX.EditBox, FMX.NumberBox;

type
  TfrmProduto = class(TfrmBase)
    imgProduto: TImage;
    spbVoltar: TSpeedButton;
    texDescricao: TText;
    texComplemento: TText;
    lbProdutoPrecificacao: TListBox;
    texOpcao: TText;
    nbxQtde: TNumberBox;
    lblAdicionar: TLabel;
    Rectangle2: TRectangle;
    PathLabel1: TPathLabel;
    recAdd: TRectangle;
    recDrop: TRectangle;
    procedure spbVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbProdutoPrecificacaoClick(Sender: TObject);
    procedure nbxQtdeChange(Sender: TObject);
    procedure recDropClick(Sender: TObject);
    procedure recAddClick(Sender: TObject);
  private
    FProduto: TProduto;
    procedure SetProduto(const Value: TProduto);
    procedure PreencherLbProdutoPrecificacao;
    procedure CalcularValorTotal;
    procedure AddItemLb(aValor: Double; aTipo: String);
  public
    property Produto: TProduto read FProduto write SetProduto;
  end;

var
  frmProduto: TfrmProduto;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfrmProduto.AddItemLb(aValor: Double; aTipo: String);
var
  item: TListBoxItem;
  rdbDescPrec: TRadioButton;
begin
  item := TListBoxItem.Create(nil);

  item.StyledSettings := [];
  item.Height := 30;
  item.TextSettings.HorzAlign := TTextAlign.Trailing;
  item.TextSettings.Font.Family := 'Inter';
  item.TextSettings.Font.Size := 14;
  item.TextSettings.FontColor := TAlphaColors.Darkgreen;
  item.ItemData.Text := FloatToStrF(aValor, ffCurrency, 15,2);

  rdbDescPrec := TRadioButton.Create(nil);
  rdbDescPrec.StyledSettings := [];
  rdbDescPrec.Align := TAlignLayout.Client;
  rdbDescPrec.TextSettings.FontColor := TAlphaColors.Darkgreen;
  rdbDescPrec.TextSettings.Font.Family := 'Inter';
  rdbDescPrec.TextSettings.Font.Size := 14;
  rdbDescPrec.Text := aTipo;

  item.AddObject(rdbDescPrec);
  lbProdutoPrecificacao.AddObject(item);
  rdbDescPrec.OnClick := lbProdutoPrecificacao.OnClick;
end;

procedure TfrmProduto.CalcularValorTotal;
begin
  if lbProdutoPrecificacao.ItemIndex >= 0 then
    lblAdicionar.Text := 'Adicionar ao carrinho   ' +
      FloatToStrF(nbxQtde.Value *
      Produto.ProdutoPrecificacao[lbProdutoPrecificacao.Selected.Index].Valor
      , ffCurrency, 15,2);
end;

procedure TfrmProduto.FormShow(Sender: TObject);
begin
  inherited;
  texDescricao.Text := Produto.Descricao;
  texComplemento.Text := Produto.Complemento;
  PreencherLbProdutoPrecificacao;
end;


procedure TfrmProduto.lbProdutoPrecificacaoClick(Sender: TObject);
begin
  inherited;
  CalcularValorTotal;
end;

procedure TfrmProduto.nbxQtdeChange(Sender: TObject);
begin
  inherited;
  CalcularValorTotal;
end;

procedure TfrmProduto.PreencherLbProdutoPrecificacao;
var
  produtoPrecificacao: TProdutoPrecificacao;
begin
  lbProdutoPrecificacao.BeginUpdate;
  try
    if Produto.ProdutoPrecificacao.Count = 0 then
      AddItemLb(Produto.ValorInicial, 'Único')
    else
    for produtoPrecificacao in Produto.ProdutoPrecificacao do
    begin
      AddItemLb(produtoPrecificacao.Valor, produtoPrecificacao.Precificacao.Tipo);
    end;
  finally
    lbProdutoPrecificacao.EndUpdate;
  end;
end;

procedure TfrmProduto.recAddClick(Sender: TObject);
begin
  inherited;
 nbxQtde.ValueInc;
end;

procedure TfrmProduto.recDropClick(Sender: TObject);
begin
  inherited;
  nbxQtde.ValueDec;
end;

procedure TfrmProduto.SetProduto(const Value: TProduto);
begin
  FProduto := Value;
end;

procedure TfrmProduto.spbVoltarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
