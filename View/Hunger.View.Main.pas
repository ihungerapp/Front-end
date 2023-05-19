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
  System.NetEncoding, System.Classes, Hunger.Model.Entidade.Pedidos,
  Hunger.View.Carrinho
  {$IFDEF ANDROID}
  , Androidapi.Helpers
  {$ENDIF ANDROID}
  ;

type
  TfrmPrincipal = class(TForm)
    lblMesa: TLabel;
    layRodape: TLayout;
    recRodape: TRectangle;
    pathPedidos: TPath;
    pathCarrinho: TPath;
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
    sebPesquisar: TSearchEditButton;
    lblItensCarrinho: TLabel;
    recItensCarrinho: TRectangle;
    imgLerQR: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure TimerTimer(Sender: TObject);
    procedure lvConsultaProdutoItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure sebPesquisarClick(Sender: TObject);
    procedure spbCarrinhoClick(Sender: TObject);
    procedure imgLerQRClick(Sender: TObject);
  private
    FPermissions: TPermissions;
    FUtils: TUtils;
    FAuthentication: TAuthentication;
    FModelProduto: TModelProduto;
    FProdutos: TObjectList<TProduto>;

    FContentImage: String;
    FMesaUUID: String;
    FMesaID: Integer;
    FMesaDescricao: String;
    FURL_API: String;
    FUser_API: String;
    FPass_API: String;
    FPedido: TPedido;
    FProdutosCarrinho: TObjectList<TProduto>;
    FNumeroComanda: String;

    procedure Autenticar_API;
    procedure ConsultarProduto(aDescricao: String);
    function ValidarMesaUUID: Boolean;
    procedure PreencherListView(aProdutos: TObjectList<TProduto>);
    procedure SetPedido(const Value: TPedido);
    procedure SetProdutosCarrinho(const Value: TObjectList<TProduto>);
    procedure SetNumeroComanda(const Value: String);
  public
    property MesaUUID: String read FMesaUUID write FMesaUUID;
    property MesaDescricao: String read FMesaDescricao write FMesaDescricao;
    property URL_API: String read FURL_API write FURL_API;
    property User_API: String read FUser_API write FUser_API;
    property Pass_API: String read FPass_API write FPass_API;
    property Authentication: TAuthentication read FAuthentication;
    property Pedido: TPedido read FPedido write SetPedido;
    property ProdutosCarrinho: TObjectList<TProduto> read FProdutosCarrinho write SetProdutosCarrinho;
    property NumeroComanda: String read FNumeroComanda write SetNumeroComanda;
    procedure LerQRCode(aTipoQRCode: TTipoQRCode);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  FMX.DialogService, Hunger.View.Produto;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfrmPrincipal.Autenticar_API;
begin
  try
    Timer.Enabled := False;
    if not Assigned(FAuthentication) then
      FAuthentication := TAuthentication.GetInstance(Self);

    try
      if (MesaUUID <> EmptyStr) and (FAuthentication.Token = EmptyStr) then
      begin
        FAuthentication.URLServer := FURL_API;
        FAuthentication.BodyString :=
          '{'+
          '  "user":"'+ FUser_API +'",'+
          '  "password":"'+ FPass_API +'"' +
          '}';
        FAuthentication.UseURL := True;
        FAuthentication.Authentication;
      end;
      if (FAuthentication.Token <> EmptyStr) then
      begin
        if MesaUUID = EmptyStr then
        begin
          lblMesa.Text := 'Selecione uma mesa para iniciar...';
          FMesaDescricao := 'Selecione uma mesa para iniciar...';
        end;
        if ValidarMesaUUID then
          ConsultarProduto(EmptyStr)
        else
        begin
          TDialogService.ShowMessage('Mesa inválida! Tente ler o QRCode novamente.');
          LerQRCode(qrMesa);
        end;
      end;
    except on E:Exception do
      begin
        TDialogService.ShowMessage('Tentativa de conexão falhou! Vamos tentar novamente. ' + E.Message);
        Autenticar_API;
      end;
    end;
  finally
    Timer.Enabled := FAuthentication.Token = EmptyStr;
  end;
end;

procedure TfrmPrincipal.ConsultarProduto(aDescricao: String);
var
  LJsonResponse: TJSONObject;
begin
  try
    LJsonResponse := FModelProduto.ConsultarProduto(FAuthentication.Connection, aDescricao);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"produtos":[]}') then
    begin
      if not Assigned(FProdutos) then
        FProdutos := TObjectList<TProduto>.Create;
      FProdutos := FModelProduto.PopularListaProduto(LJsonResponse);
      if FProdutos.Count > 0 then
        PreencherListView(FProdutos);
    end;
  except on E:Exception do
    begin
       TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
  end;
end;

procedure TfrmPrincipal.FormActivate(Sender: TObject);
begin
  if FMesaUUID = EmptyStr then
  begin
    LerQRCode(qrMesa);
    {$IFDEF MSWINDOWS}
    FMesaUUID := '6e8febb8-e768-11ed-a28a-9fbdff546e45';
    FMesaDescricao := 'MESA 01';
    FURL_API := 'http://localhost:8081/v1/';
    FUser_API := 'hunger';
    FPass_API := 'rm045369';
    lblMesa.Text := FMesaDescricao;
    FNumeroComanda := '10';
    Autenticar_API;
    {$ENDIF MSWINDOWS}
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
  FModelProduto := TModelProduto.create;
  FMesaUUID := EmptyStr;
  FMesaID := 0;
  FMesaDescricao := EmptyStr;
  FURL_API := EmptyStr;
  FUser_API := EmptyStr;
  FPass_API := EmptyStr;
  FContentImage := EmptyStr;
  FNumeroComanda := EmptyStr;
  recItensCarrinho.Visible := False;
  lblItensCarrinho.Visible := False;

  {$IFDEF ANDROID}
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
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

procedure TfrmPrincipal.imgLerQRClick(Sender: TObject);
begin
  LerQRCode(qrMesa);
end;

procedure TfrmPrincipal.LerQRCode(aTipoQRCode: TTipoQRCode);
var
  LParams: TArray<String>;
begin
  {$IFDEF ANDROID}
  if NOT FPermissions.VerifyCameraAccess then
    FPermissions.Camera(nil, nil)
  else
  begin
    frmLeitorCamera.TipoQRCode := aTipoQRCode;
    frmLeitorCamera.ShowModal(procedure(ModalResult: TModalResult)
    begin
      FContentImage := FrmLeitorCamera.Codigo;
      if FContentImage = EmptyStr then
      begin
        TDialogService.ShowMessage('Não foi possível ler o QRCode. Tente novamente!');
        LerQRCode(aTipoQRCode);
        Exit;
      end;

      if aTipoQRCode = qrMesa then
      begin
        LParams := FContentImage.Split(['|']);
        FMesaUUID := LParams[0];
        FMesaDescricao := LParams[1];
        FURL_API := LParams[2];
        FUser_API := LParams[3];
        FPass_API := LParams[4];
        lblMesa.Text := FMesaDescricao;
        Timer.Enabled := True;
      end;

      if aTipoQRCode = qrComanda then
      begin
        LParams := FContentImage.Split(['|']);
        if LParams[0] <> 'COMANDA' then
        begin
          TDialogService.ShowMessage('Comanda inválida! Tente ler o QRCode novamente.');
          LerQRCode(qrComanda);
          Exit;
        end;
        FNumeroComanda := LParams[1];
        frmCarrinho.FinalizarPedido;
      end;
    end);
  end;
  {$ENDIF ANDROID}
end;

procedure TfrmPrincipal.lvConsultaProdutoItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  //Abrir tela de inclusão do item no carrinho
  if not Assigned(frmProduto) then
    Application.CreateForm(TfrmProduto, frmProduto);

  with frmProduto do
  begin
    lblMesa.Text := FMesaDescricao + ' > Produto';
    imgProduto.Bitmap := imgFoto.MultiResBitmap.Items[ItemIndex].Bitmap;
    Produto := FProdutos[ItemIndex];
  end;
  frmProduto.ShowModal(procedure(ModalResult: TModalResult)
    begin
      if Assigned(frmProduto.PedidoItem) then
      begin
        if not Assigned(Pedido) then
        begin
          Pedido := TPedido.Create;
          Pedido.IdPessoa := 0;
          Pedido.IdMesa := FMesaID;
          Pedido.DataHoraAbertura := Now;
          Pedido.DataHoraFinalizacao := Pedido.DataHoraAbertura;
          Pedido.PedidoStatus := 'Em aberto';
          Pedido.FecharConta := False;
          Pedido.ValorTotal := 0;
        end;
        Pedido.PedidoItem.Add(frmProduto.PedidoItem);
        Pedido.ValorTotal := Pedido.ValorTotal + frmProduto.PedidoItem.ValorTotal;
        recItensCarrinho.Visible := True;
        lblItensCarrinho.Visible := True;
        lblItensCarrinho.Text := Pedido.PedidoItem.Count.ToString;

        if not Assigned(FProdutosCarrinho) then
          FProdutosCarrinho := TObjectList<TProduto>.Create;
        FProdutosCarrinho.Add(frmProduto.Produto);
      end;
    end);
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
              TListItemImage(Objects.FindDrawable('imgProduto')).Bitmap := imgFoto.MultiResBitmap.Items[I].Bitmap;
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

procedure TfrmPrincipal.sebPesquisarClick(Sender: TObject);
begin
  if FMesaUUID = EmptyStr then
  begin
    TDialogService.ShowMessage('Selecione uma mesa antes de pesquisar!');
    Exit;
  end;

  ConsultarProduto(edtPesquisar.Text);
end;

procedure TfrmPrincipal.SetNumeroComanda(const Value: String);
begin
  FNumeroComanda := Value;
end;

procedure TfrmPrincipal.SetPedido(const Value: TPedido);
begin
  FPedido := Value;
end;

procedure TfrmPrincipal.SetProdutosCarrinho(const Value: TObjectList<TProduto>);
begin
  FProdutosCarrinho := Value;
end;

procedure TfrmPrincipal.spbCarrinhoClick(Sender: TObject);
begin
  //Abrir tela de inclusão do item no carrinho
  if not Assigned(Pedido) then
  begin
    TDialogService.ShowMessage('Nenhum produto adicionado ao carrinho!');
    Exit;
  end;

  if not Assigned(frmCarrinho) then
    Application.CreateForm(TfrmCarrinho, frmCarrinho);

  with frmCarrinho do
  begin
    lblMesa.Text := FMesaDescricao + ' > Carrinho';
    lblFinalizar.Text := 'Finalizar pedido';
    Pedido := FPedido;
    Produtos := FProdutosCarrinho;
  end;
  frmCarrinho.ShowModal(procedure(ModalResult: TModalResult)
    begin
      if Assigned(Pedido) and (Pedido.PedidoItem.Count = 0) then
      begin
        FreeAndNil(Pedido);
        FProdutosCarrinho.Clear;
      end;

      if not Assigned(Pedido) then
      begin
        recItensCarrinho.Visible := False;
        lblItensCarrinho.Visible := False;
        ConsultarProduto(edtPesquisar.Text);
        {$IFDEF ANDROID}
        FNumeroComanda := EmptyStr;
        {$ENDIF ANDROID}
      end;
    end);
end;

procedure TfrmPrincipal.TimerTimer(Sender: TObject);
begin
  Autenticar_API;
end;

function TfrmPrincipal.ValidarMesaUUID: Boolean;
var
  LJsonResponse: TJSONObject;
  LJsonArray: TJSONArray;
  sucesso: Boolean;
begin
  Result := False;
  try
    LJsonResponse := FAuthentication.Connection.Execute(
      'mesa?search=mesa_uuid:' + FMesaUUID + '&JSON=<!"TypeSearch":"no incidence"!>', tpGet, nil);
    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{}') then
    begin
      LJsonResponse.TryGetValue('content', LJsonArray);
      if LJsonArray.Count > 0 then
      begin
        LJsonResponse := LJsonArray[0] as TJSONObject;
        FMesaID := LJsonResponse.GetValue('id_mesa').Value.ToInteger;
        Result := True;
      end;
    end;
  except on E:Exception do
    TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                               E.Message);
  end;
end;

end.
