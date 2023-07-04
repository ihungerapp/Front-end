unit Hunger.View.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  System.Generics.Collections, Hunger.Model.Entidade.Produto, FMX.ListBox,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, Hunger.Model.Entidade.Pedidos,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

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
    recAdicionar: TRectangle;
    recAdd: TRectangle;
    recDrop: TRectangle;
    recQtde: TRectangle;
    lblObs: TLabel;
    recObs: TRectangle;
    memObs: TMemo;
    procedure spbVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure nbxQtdeChange(Sender: TObject);
    procedure recDropClick(Sender: TObject);
    procedure recAddClick(Sender: TObject);
    procedure recAdicionarClick(Sender: TObject);
    procedure lbProdutoPrecificacaoClick(Sender: TObject);
  private
    FProduto: TProduto;
    FPedidoItem: TPedidoItem;
    FGrupo: String;
    FValor: Double;
    procedure SetProduto(const Value: TProduto);
    procedure PreencherLbProdutoPrecificacao;
    procedure AddItemLb(aValor: Double; aTipo, aGrupo: String; aQtdeMaxSelecao: Integer);
    procedure SetPedidoItem(const Value: TPedidoItem);
  public
    property Produto: TProduto read FProduto write SetProduto;
    property PedidoItem: TPedidoItem read FPedidoItem write SetPedidoItem;
  end;

var
  frmProduto: TfrmProduto;

implementation

uses
  FMX.DialogService;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfrmProduto.AddItemLb(aValor: Double; aTipo, aGrupo: String; aQtdeMaxSelecao: Integer);
var
  item: TListBoxItem;
  rdbDescPrec: TRadioButton;
  ckbDescPrec: TCheckBox;
  lbGrupo: TLabel;
begin
  item := TListBoxItem.Create(nil);
  item.StyledSettings := [];

  if (FGrupo = EmptyStr)
  or ((FGrupo <> EmptyStr) and (FGrupo <> aGrupo)) then
  begin
    lbGrupo := TLabel.Create(lbProdutoPrecificacao);
    with lbGrupo do
    begin
      StyledSettings := [];
      Height := 20;
      Align := TAlignLayout.Top;
      TextSettings.HorzAlign := TTextAlign.Center;
      TextSettings.Font.Family := 'Inter';
      TextSettings.Font.Size := 14;
      TextSettings.Font.Style := [TFontStyle.fsBold];
      TextSettings.FontColor := TAlphaColors.Black;
      Text := aGrupo;
    end;

    item.Height := 50;
    item.AddObject(lbGrupo);
  end
  else
    item.Height := 30;

  item.TextSettings.VertAlign := TTextAlign.Trailing;
  item.TextSettings.HorzAlign := TTextAlign.Trailing;
  item.TextSettings.Font.Family := 'Inter';
  item.TextSettings.Font.Size := 14;
  item.TextSettings.FontColor := TAlphaColors.Darkgreen;
  if aValor > 0 then
    item.ItemData.Text := FloatToStrF(aValor, ffCurrency, 15,2);

  if aQtdeMaxSelecao = 1 then
  begin
    rdbDescPrec := TRadioButton.Create(lbProdutoPrecificacao);
    with rdbDescPrec do
    begin
      StyledSettings := [];
      Align := TAlignLayout.Client;
      TextSettings.FontColor := TAlphaColors.Darkgreen;
      TextSettings.Font.Family := 'Inter';
      TextSettings.Font.Size := 14;
      Text := aTipo;
      if aValor > 0 then
        OnChange := lbProdutoPrecificacaoClick;
    end;
    item.AddObject(rdbDescPrec);
  end
  else
  begin
    ckbDescPrec := TCheckBox.Create(lbProdutoPrecificacao);
    with ckbDescPrec do
    begin
      StyledSettings := [];
      Align := TAlignLayout.Client;
      TextSettings.FontColor := TAlphaColors.Darkgreen;
      TextSettings.Font.Family := 'Inter';
      TextSettings.Font.Size := 14;
      Text := aTipo;
      if aValor > 0 then
        OnChange := lbProdutoPrecificacaoClick;
    end;
    item.AddObject(ckbDescPrec);
  end;

  lbProdutoPrecificacao.AddObject(item);

  if aQtdeMaxSelecao = 1 then
  begin
    rdbDescPrec.Name := 'rdbDescPrec' + item.Index.ToString;
    rdbDescPrec.GroupName := aGrupo;
    Self.InsertComponent(rdbDescPrec);
  end
  else
  begin
    ckbDescPrec.Name := 'ckbDescPrec' + item.Index.ToString;
    Self.InsertComponent(ckbDescPrec);
  end;
end;

procedure TfrmProduto.FormShow(Sender: TObject);
var
  a:integer;
begin
  inherited;
  PedidoItem := nil;

  texDescricao.Text := Produto.Descricao;
  texComplemento.Text := Produto.Complemento;
  PreencherLbProdutoPrecificacao;
  nbxQtde.Value := 1;
  lblAdicionar.Text := 'Adicionar ao carrinho';
  FValor := 0;

  if Assigned(imgProduto.Bitmap) then
    imgProduto.Bitmap.Resize(Trunc(imgProduto.Width), Trunc(imgProduto.Height))
end;


procedure TfrmProduto.lbProdutoPrecificacaoClick(Sender: TObject);
var
  I, J: Integer;
  checked: Boolean;
begin
  inherited;
  FValor := 0;
  J := -1;
  for I := 0 to Pred(ComponentCount) do
  begin
    if (Components[I] is TRadioButton) or (Components[I] is TCheckBox) then
      Inc(J);
    if (Components[I] is TRadioButton) and (Components[I] as TRadioButton).IsChecked then
      FValor := FValor + Produto.ProdutoPrecificacao[J].Valor;
    if (Components[I] is TCheckBox) and (Components[I] as TCheckBox).IsChecked then
      FValor := FValor + Produto.ProdutoPrecificacao[J].Valor;
  end;
  lblAdicionar.Text := 'Adicionar ao carrinho   ' +
    FloatToStrF(FValor * nbxQtde.Value, ffCurrency, 15,2);
  recAdicionar.SetFocus;
end;

procedure TfrmProduto.nbxQtdeChange(Sender: TObject);
begin
  inherited;
  lblAdicionar.Text := 'Adicionar ao carrinho   ' +
    FloatToStrF(FValor * nbxQtde.Value, ffCurrency, 15,2);
end;

procedure TfrmProduto.PreencherLbProdutoPrecificacao;
var
  produtoPrecificacao: TProdutoPrecificacao;
begin
  lbProdutoPrecificacao.Items.Clear;
  lbProdutoPrecificacao.BeginUpdate;
  try
    FGrupo := EmptyStr;
    if Produto.ProdutoPrecificacao.Count = 0 then
      AddItemLb(Produto.ValorInicial, 'Único', '', 1)
    else
    for produtoPrecificacao in Produto.ProdutoPrecificacao do
    begin
      AddItemLb(produtoPrecificacao.Valor,
                produtoPrecificacao.Precificacao.Tipo,
                produtoPrecificacao.Precificacao.Grupo,
                produtoPrecificacao.Precificacao.QtdeMaxSelecao);
      FGrupo := produtoPrecificacao.Precificacao.Grupo;
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

procedure TfrmProduto.recAdicionarClick(Sender: TObject);
begin
  inherited;
  if lbProdutoPrecificacao.ItemIndex < 0 then
  begin
    TDialogService.ShowMessage('Selecione uma opção!');
    lbProdutoPrecificacao.SetFocus;
    Exit;
  end;

  if not Assigned(PedidoItem) then
    PedidoItem := TPedidoItem.Create;

  PedidoItem.IdProduto := Produto.IdProduto;
  PedidoItem.Qtde := nbxQtde.Value;
  PedidoItem.ValorUnitario := FValor;
  PedidoItem.ValorTotal := nbxQtde.Value * FValor;
  PedidoItem.DataHoraEmissao := Now;
  PedidoItem.DataHoraStatus := Now;
  PedidoItem.PedidoItemStatus := 'Aguardando';
  PedidoItem.IdProdutoPrecificacao := Produto.ProdutoPrecificacao[lbProdutoPrecificacao.Selected.Index].IdProdutoPrecificacao;
  PedidoItem.Obs := memObs.Lines.Text;
  Close;
end;

procedure TfrmProduto.recDropClick(Sender: TObject);
begin
  inherited;
  nbxQtde.ValueDec;
end;

procedure TfrmProduto.SetPedidoItem(const Value: TPedidoItem);
begin
  FPedidoItem := Value;
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
