unit Hunger.View.Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Effects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts;

type
  TfrmLogin = class(TForm)
    Layout1: TLayout;
    imgVision: TImage;
    imgPulsoft: TImage;
    Layout5: TLayout;
    Rectangle1: TRectangle;
    lblAcessar: TLabel;
    ShadowEffect1: TShadowEffect;
    Rectangle2: TRectangle;
    edtSenha: TEdit;
    Rectangle3: TRectangle;
    edtUsuarioConta: TEdit;
    StyleBook1: TStyleBook;
    Rectangle4: TRectangle;
    edtCPF: TEdit;
    CheckBox1: TCheckBox;
    procedure imgPulsoftClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Net,
  Androidapi.Helpers, idURi;

{$R *.fmx}

procedure TfrmLogin.imgPulsoftClick(Sender: TObject);
var
  uri : string;
  Intent : JIntent;
  idContato : Integer;
begin
  uri :='https://rmti.tec.br';
  try
    Intent := TJIntent.JavaClass.init(
                TJIntent.JavaClass.ACTION_VIEW,
                TJnet_Uri.JavaClass.
                  parse(StringToJString(TIdURI.URLEncode(uri))));
    SharedActivity.startActivity(Intent);
  except on E: Exception do
    ShowMessage(E.Message);
  end;
end;

end.
