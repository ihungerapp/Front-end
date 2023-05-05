unit Hunger.View.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  System.Generics.Collections, Hunger.Model.Entidade.Produto, FMX.ListBox;

type
  TfrmProduto = class(TfrmBase)
    imgProduto: TImage;
    spbVoltar: TSpeedButton;
    vsbProduto: TVertScrollBox;
    texDescricao: TText;
    texComplemento: TText;
    lbProdutoPrecificacao: TListBox;
    Text1: TText;
    procedure spbVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FProduto: TProduto;
    procedure SetProduto(const Value: TProduto);
    procedure PreencherLbProdutoPrecificacao;
  public
    property Produto: TProduto read FProduto write SetProduto;
  end;

var
  frmProduto: TfrmProduto;

implementation

{$R *.fmx}

procedure TfrmProduto.FormShow(Sender: TObject);
begin
  inherited;
  texDescricao.Text := Produto.Descricao;
  texComplemento.Text := Produto.Complemento;
  PreencherLbProdutoPrecificacao;
end;


procedure TfrmProduto.PreencherLbProdutoPrecificacao;
var
  item: TListBoxItem;
  rdbDescPrec: TRadioButton;
  lblValor: TLabel;
  produtoPrecificacao: TProdutoPrecificacao;
begin
  lbProdutoPrecificacao.BeginUpdate;
  try
    for produtoPrecificacao in Produto.ProdutoPrecificacao do
    begin
      item := TListBoxItem.Create(nil);
      item.Height := 30;

      rdbDescPrec := TRadioButton.Create(nil);
      rdbDescPrec.Align := TAlignLayout.Client;
      rdbDescPrec.Text := produtoPrecificacao.Precificacao.Tipo;

      lblValor := TLabel.Create(nil);
      lblValor.Align := TAlignLayout.Right;
      lblValor.Width := 100;
      lblValor.TextSettings.HorzAlign := TTextAlign.Trailing;
      lblValor.TextSettings.FontColor := TAlphaColors.Darkolivegreen;
      lblValor.Text := FloatToStrF(produtoPrecificacao.Valor, ffCurrency, 15,2);

      item.AddObject(lblValor);
      item.AddObject(rdbDescPrec);
      lbProdutoPrecificacao.AddObject(item);
    end;
  finally
    lbProdutoPrecificacao.EndUpdate;
  end;
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
