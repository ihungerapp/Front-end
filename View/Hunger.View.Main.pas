unit Hunger.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Hunger.Model.Permissions, Hunger.View.LeitorCamera, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, Authentication, System.JSON,
  Client.Connection, Hunger.Model.Produto, Hunger.Model.Entidade.Produto,
  System.Generics.Collections, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.Edit, FMX.ListView, Hunger.Utils,
  System.NetEncoding, System.Classes
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
    Timer: TTimer;
    imgFoto: TImage;
    lytLista: TLayout;
    lvConsultaProduto: TListView;
    edtPesquisar: TEdit;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure TimerTimer(Sender: TObject);
  private
    FPermissions: TPermissions;
    FUtils: TUtils;
    FAutenticar_API: TAuthentication;
    FModelProduto: TModelProduto;
    FProdutos: TObjectList<TProduto>;

    FContentImage: String;
    FMesaUUID: String;
    FMesaDescricao: String;
    FURL_API: String;
    FUser_API: String;
    FPass_API: String;

    procedure LerQRCode;
    procedure SetAutenticar_API(const aAutenticar_API: TAuthentication);
    procedure ConsultarProduto;
    function ValidarMesaUUID(aMesaUUID: String): Boolean;
    procedure PreencherListView(aProdutos: TObjectList<TProduto>);
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
    LJsonResponse := FModelProduto.ConsultarProduto(FAutenticar_API.Connection);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"produtos":[]}') then
    begin
      if not Assigned(FProdutos) then
        FProdutos := TObjectList<TProduto>.Create;

      FProdutos.Clear;
      FProdutos := FModelProduto.PopularListaProduto(LJsonResponse);
      if FProdutos.Count > 0 then
        PreencherListView(FProdutos);
    end;
  except on E:Exception do
    begin
      ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
  end;
end;

procedure TfrmPrincipal.FormActivate(Sender: TObject);
begin
  LerQRCode;

  {$IFDEF MSWINDOWS}
  FMesaUUID := '6970c819-df81-11ed-8f53-706979a6915f';
  FMesaDescricao := 'MESA 01';
  FURL_API := 'http://localhost:8081/v1/';
  FUser_API := 'hunger';
  FPass_API := 'rm045369';
  lblMesa.Text := FMesaDescricao;
  {$ENDIF MSWINDOWS}

  SetAutenticar_API(FAutenticar_API);
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
  FModelProduto := TModelProduto.create;
  {$IFDEF ANDROID}
  Application.FormFactor.Orientations := [TFormOrientation.Landscape];
  Application.FormFactor.AdjustToScreenSize;
  {$ENDIF ANDROID}
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  FPermissions.DisposeOf;
  FModelProduto.DisposeOf;
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

procedure TfrmPrincipal.LerQRCode;
var
  LParams: TArray<String>;
begin
  {$IFDEF ANDROID}
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
    end);
  end;
  {$ENDIF ANDROID}
end;

procedure TfrmPrincipal.PreencherListView(aProdutos: TObjectList<TProduto>);
var
  t: TThread;
begin
  lvConsultaProduto.Items.Clear;
  lvConsultaProduto.BeginUpdate;
  imgFoto.MultiResBitmap.Clear;

  t := TThread.CreateAnonymousThread(procedure
  var
    LItem: TListViewItem;
    I: Integer;
  begin
    for I := 0 to Pred(aProdutos.Count) do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        LItem := lvConsultaProduto.Items.Add;
        with LItem do
        begin
          Height := 90;
          Tag := I;
          if aProdutos[I].Imagem <> EmptyStr then
          begin
            imgFoto.MultiResBitmap.Add;
            imgFoto.MultiResBitmap.Items[I].Bitmap.LoadFromStream(FUtils.Base64ToStream(aProdutos[I].Imagem));
            if not imgFoto.Bitmap.IsEmpty then
              TListItemImage(Objects.FindDrawable('imgProduto')).Bitmap := imgFoto.Bitmap;
          end;
          TListItemText(Objects.FindDrawable('descricao')).Text := aProdutos[I].Descricao;
          TListItemText(Objects.FindDrawable('complemento')).Text := aProdutos[I].Complemento;
          TListItemText(Objects.FindDrawable('valor')).Text := 'A partir de ' +
            FloatToStrF(aProdutos[I].ValorInicial, ffCurrency, 15,2);
          //Layout_lvConsulta(LItem);
        end;
      end);
    end;
  end);
  lvConsultaProduto.EndUpdate;
  t.Start;
end;

procedure TfrmPrincipal.SetAutenticar_API(const aAutenticar_API: TAuthentication);
begin
  if not Assigned(aAutenticar_API) then
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
end;

procedure TfrmPrincipal.TimerTimer(Sender: TObject);
begin
  if Assigned(FAutenticar_API) then
    if (FAutenticar_API.Token <> EmptyStr) then
    begin
      Timer.Enabled := False;
      if ValidarMesaUUID(FMesaUUID) then
        ConsultarProduto
      else
      begin
        ShowMessage('Mesa inválida! Entre em contato com o estabelecimento.');
        Application.Terminate;
      end;
    end
    else
      SetAutenticar_API(FAutenticar_API);
end;

function TfrmPrincipal.ValidarMesaUUID(aMesaUUID: String): Boolean;
var
  LJsonResponse: TJSONObject;
begin
  Result := False;
  try
    LJsonResponse := Autenticar_API.Connection.Execute(
      'mesa?search=mesa_uuid:' + aMesaUUID + '&JSON=<!"TypeSearch":"no incidence"!>', tpGet, nil);

    Result := (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{}');
  except on E:Exception do
    begin
      ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
  end;
end;

end.
