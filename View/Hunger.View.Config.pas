unit Hunger.View.Config;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  FMX.Edit;

type
  TfrmConfig = class(TfrmBase)
    spbVoltar: TSpeedButton;
    recURL: TRectangle;
    edtURL: TEdit;
    procedure spbVoltarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.fmx}

procedure TfrmConfig.spbVoltarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
