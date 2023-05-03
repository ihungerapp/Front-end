unit Hunger.View.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  System.Generics.Collections, Hunger.Model.Entidade.Produto,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView;

type
  TfrmProduto = class(TfrmBase)
    imgProduto: TImage;
    spbVoltar: TSpeedButton;
    vsbProduto: TVertScrollBox;
    texDescricao: TText;
    texComplemento: TText;
    lvProduto: TListView;
    procedure spbVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FProduto: TProduto;
    procedure SetProduto(const Value: TProduto);
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
