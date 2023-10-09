unit Hunger.View.Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Effects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  Hunger.Utils, Authentication, Hunger.Model.Login, FMX.DialogService;

type
  TfrmLogin = class(TForm)
    Layout1: TLayout;
    imgHunger: TImage;
    imgRMTi: TImage;
    Layout5: TLayout;
    Rectangle1: TRectangle;
    lblAcessar: TLabel;
    ShadowEffect1: TShadowEffect;
    Rectangle2: TRectangle;
    edtSenha: TEdit;
    Rectangle3: TRectangle;
    edtUsuario: TEdit;
    StyleBook1: TStyleBook;
    Rectangle4: TRectangle;
    edtCPF: TEdit;
    cbLembrarSenha: TCheckBox;
    procedure imgRMTiClick(Sender: TObject);
    procedure lblAcessarClick(Sender: TObject);
    procedure edtCPFExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FAuthentication: TAuthentication;
    FLogin: TModelLogin;
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses
  idURi, Hunger.View.Main
  {$IFDEF ANDROID}
  , Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Net, Androidapi.Helpers
  {$ENDIF ANDROID}

  {$IFDEF MSWINDOWS}
  , Winapi.ShellAPI, FMX.Platform.Win
  {$ENDIF MSWINDOWS}
  ;

{$R *.fmx}

procedure TfrmLogin.edtCPFExit(Sender: TObject);
begin
  if TUtils.RemoveChar(edtCPF.Text) <> '' then
  begin
    if (Length(TUtils.RemoveChar(edtCPF.Text)) = 11) and (TUtils.validaCPF(TUtils.RemoveChar(edtCPF.Text))) then
      edtCPF.Text := TUtils.formataCPF(TUtils.RemoveChar(edtCPF.Text))
    else
    if (Length(TUtils.RemoveChar(edtCPF.Text)) = 14) and (TUtils.validaCNPJ(TUtils.RemoveChar(edtCPF.Text))) then
      edtCPF.Text := TUtils.formataCNPJ(TUtils.RemoveChar(edtCPF.Text))
    else
    begin
      ShowMessage('CPF ou CNPJ inválido!');
      edtCPF.SetFocus;
    end;
  end;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  if not Assigned(FAuthentication) then
    FAuthentication := TAuthentication.GetInstance(Self);

  edtCPF.Text := FAuthentication.Connection.ini.ReadString('SECAO','CPF','');
  edtUsuario.Text := FAuthentication.Connection.ini.ReadString('SECAO','USUARIO','');
  edtSenha.Text := FAuthentication.Connection.ini.ReadString('SECAO','SENHA','');
  cbLembrarSenha.IsChecked := FAuthentication.Connection.ini.ReadBool('SECAO','LEMBRAR_SENHA', False);

  //CPF Login
  if edtCPF.Text <> EmptyStr then
    edtUsuario.SetFocus
  else
    edtCPF.SetFocus;
end;

procedure TfrmLogin.imgRMTiClick(Sender: TObject);
var
  uri : string;

  idContato : Integer;
begin
  uri := 'https://rmti.tec.br';
  try
    {$IFDEF ANDROID}
    var
      Intent : JIntent;
    Intent := TJIntent.JavaClass.init(
                TJIntent.JavaClass.ACTION_VIEW,
                TJnet_Uri.JavaClass.
                  parse(StringToJString(TIdURI.URLEncode(uri))));
    SharedActivity.startActivity(Intent);
    {$ENDIF ANDROID}

    {$IFDEF MSWINDOWS}
    ShellExecute(FmxHandleToHWND(Handle), 'open', 'https://www.rmti.tec.br', '', '', 1);
    {$ENDIF MSWINDOWS}
  except on E: Exception do
    ShowMessage(E.Message);
  end;
end;

procedure TfrmLogin.lblAcessarClick(Sender: TObject);
begin
  FLogin := TModelLogin.Create;
  try
    FLogin.CpfCnpj := edtCPF.Text;
    FLogin.Usuario := edtUsuario.Text;
    FLogin.Senha := edtSenha.Text;
    FLogin.Autenticar;
    if FAuthentication.Token = EmptyStr then
    begin
      TDialogService.ShowMessage('Dados de login inválido, vamos tentar novamente!');
      Exit;
    end;

    FAuthentication.Connection.Ini.WriteString('SECAO','CPF', edtCPF.Text);
    FAuthentication.Connection.Ini.WriteString('SECAO','USUARIO', edtUsuario.Text);
    FAuthentication.Connection.Ini.WriteBool('SECAO','LEMBRAR_SENHA', cbLembrarSenha.IsChecked);
    if cbLembrarSenha.IsChecked then
      FAuthentication.Connection.Ini.WriteString('SECAO','SENHA', edtSenha.Text)
    else
      FAuthentication.Connection.Ini.WriteString('SECAO','SENHA', EmptyStr);

    Application.CreateForm(TfrmPrincipal, frmPrincipal);
    Application.MainForm := frmPrincipal;
    frmPrincipal.Show;
    frmLogin.Close;
  finally
    DisposeOfAndNil(FLogin);
  end;
end;

end.
