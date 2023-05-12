unit Hunger.View.Base;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Edit, FMX.ListView, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Layouts;

type
  TfrmBase = class(TForm)
    layCabecalho: TLayout;
    recCabecalho: TRectangle;
    lblHungerApp: TLabel;
    layRodape: TLayout;
    recRodape: TRectangle;
    spbHome: TSpeedButton;
    pathHome: TPath;
    spbPedidos: TSpeedButton;
    pathPedidos: TPath;
    spbCarrinho: TSpeedButton;
    pathCarrinho: TPath;
    lytLista: TLayout;
    lblMesa: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBase: TfrmBase;

implementation

{$R *.fmx}

end.
