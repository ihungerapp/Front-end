unit Hunger.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Hunger.Model.Permissions, Hunger.View.LeitorCamera, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, Authentication, System.JSON,
  Client.Connection
  {$IFDEF ANDROID}
  , Androidapi.Helpers
  {$ENDIF ANDROID}
  ;

type
  TfrmPrincipal = class(TForm)
    lblMesa: TLabel;
    layRodape: TLayout;
    recRodape: TRectangle;
    pathHome: TPath;
    pathPedidos: TPath;
    pathCarrinho: TPath;
    spbHome: TSpeedButton;
    spbPedidos: TSpeedButton;
    spbCarrinho: TSpeedButton;
    layCabecalho: TLayout;
    Rectangle1: TRectangle;
    lblHungerApp: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    FPermissions: TPermissions;
    FContentImage: String;
    FMesaUUID: String;
    FMesaDescricao: String;
    FURL_API: String;
    FUser_API: String;
    FPass_API: String;
    FAutenticar_API: TAuthentication;
    procedure SetAutenticar_API(const Value: TAuthentication);
    procedure ConsultarProduto;
  public
    property MesaUUID: String read FMesaUUID write FMesaUUID;
    property MesaDescricao: String read FMesaDescricao write FMesaDescricao;
    property URL_API: String read FURL_API write FURL_API;
    property User_API: String read FUser_API write FUser_API;
    property Pass_API: String read FPass_API write FPass_API;
    property Autenticar_API: TAuthentication read FAutenticar_API write SetAutenticar_API;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.ConsultarProduto;
var
  LJsonResponse: TJSONObject;
begin
  try
    LJsonResponse := Autenticar_API.Connection.Execute(
      'produto?method=ListarProdutos', tpGet, nil);
//      'produto?method=ListarProdutos&search=pessoa:nmprimeiro:' +
//      edtPesquisar.Text, tpGet, nil);

//    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"pessoas":[]}') then
//      PopularListaPessoas(LJsonResponse);
  except on E:Exception do
    begin
      ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
  end;
end;

procedure TfrmPrincipal.FormActivate(Sender: TObject);
var
  LParams: TArray<String>;
begin
  if NOT FPermissions.VerifyCameraAccess then
    FPermissions.Camera(nil, nil)
  else
  begin
    FrmLeitorCamera.ShowModal(procedure(ModalResult: TModalResult)
    begin
      FContentImage := FrmLeitorCamera.codigo;
      LParams := FContentImage.Split(['|']);

      FMesaUUID := LParams[0];
      FMesaDescricao := LParams[1];
      FURL_API := LParams[2];
      FUser_API := LParams[3];
      FPass_API := LParams[4];

      lblMesa.Text := FMesaDescricao;

      FAutenticar_API := TAuthentication.GetInstance(Self);
      try
        FAutenticar_API.URLServer := FURL_API;
        FAutenticar_API.BodyString :=
          '{'+
          '  "user":"'+ FUser_API +'",'+
          '  "password":"'+ FPass_API +'"' +
          '}';
        FAutenticar_API.UseURL := True;
        FAutenticar_API.Authentication;
      except on E:Exception do
        ShowMessage('Autenticação na API falhou: ' + E.Message);
      end;
    end);
  end;
end;

procedure TfrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  MessageDlg('Tem certeza que deseja sair do HungerApp?',
  System.UITypes.TMsgDlgType.mtInformation,
  [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
  procedure(const BotaoPressionado: TModalResult)
  begin
    case BotaoPressionado of
      mrYes:
       {$IFDEF ANDROID}
       SharedActivity.Finish;
       {$ENDIF ANDROID}
    end;
  end);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FPermissions := TPermissions.Create;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  FPermissions.DisposeOf;
end;

procedure TfrmPrincipal.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var
  Fechar : Boolean;
begin
  if Key = vkHardwareBack then
  begin
    key := 0;
    FormCloseQuery(Sender, Fechar);
  end;
end;

procedure TfrmPrincipal.SetAutenticar_API(const Value: TAuthentication);
begin
  FAutenticar_API := Value;
end;

end.
