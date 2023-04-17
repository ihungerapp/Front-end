unit Hunger.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Hunger.Model.Permissions, Hunger.View.LeitorCamera;

type
  TfrmPrincipal = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    permissions: TPermissions;
    contentImage: String;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  permissions := TPermissions.Create;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  permissions.DisposeOf;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  if NOT permissions.VerifyCameraAccess then
    permissions.Camera(nil, nil)
  else
  begin
    FrmLeitorCamera.ShowModal(procedure(ModalResult: TModalResult)
    begin
      contentImage := FrmLeitorCamera.codigo;
    end);
  end;

end;

end.
