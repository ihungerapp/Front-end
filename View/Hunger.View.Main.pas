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
  Hunger.View.Carrinho, FMX.ListBox
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
    TimerPesquisar: TTimer;
    imgConfig: TImage;
    lbGrupos: TListBox;
    ListBoxItem1: TListBoxItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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
    procedure spbPedidosClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerPesquisarTimer(Sender: TObject);
    procedure edtPesquisarChangeTracking(Sender: TObject);
    procedure imgConfigClick(Sender: TObject);
    procedure lbGruposItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private
    FPermissions: TPermissions;
    FUtils: TUtils;
    FAuthentication: TAuthentication;
    FModelProduto: TModelProduto;
    FProdutos: TObjectList<TProduto>;
    FGrupos: TObjectList<TGrupo>;

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
    procedure ConsultarGrupo;
    procedure PreencherListView(aProdutos: TObjectList<TProduto>; idGrupo: Integer = 0);
    procedure SetPedido(const Value: TPedido);
    procedure SetProdutosCarrinho(const Value: TObjectList<TProduto>);
    procedure SetNumeroComanda(const Value: String);
    procedure Layout_lvConsulta(AItem: TListViewItem);
    procedure PreencherLbGrupos(aGrupos: TObjectList<TGrupo>);
    procedure AddItemLb(aIndex: Integer; aGrupo: TGrupo);
    function ValidarMesaUUID: Boolean;
    procedure SetProdutos(const Value: TObjectList<TProduto>);
  public
    property MesaUUID: String read FMesaUUID write FMesaUUID;
    property MesaDescricao: String read FMesaDescricao write FMesaDescricao;
    property URL_API: String read FURL_API write FURL_API;
    property User_API: String read FUser_API write FUser_API;
    property Pass_API: String read FPass_API write FPass_API;
    property Authentication: TAuthentication read FAuthentication;
    property Pedido: TPedido read FPedido write SetPedido;
    property Produtos: TObjectList<TProduto> read FProdutos write SetProdutos;
    property ProdutosCarrinho: TObjectList<TProduto> read FProdutosCarrinho write SetProdutosCarrinho;
    property NumeroComanda: String read FNumeroComanda write SetNumeroComanda;
    procedure LerQRCode(aTipoQRCode: TTipoQRCode);
    function GetTextHeight(const D: TListItemText;
  const Width: single; const Text: string; LineBreak: Integer = 0): Integer;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  FMX.DialogService, Hunger.View.Produto, Hunger.View.Pedidos,
  Hunger.View.Mesas, Hunger.View.Config, FMX.TextLayout;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfrmPrincipal.AddItemLb(aIndex: Integer; aGrupo: TGrupo);
var
  item: TListBoxItem;

  procedure FormatarItem(aItem: TListBoxItem);
  begin
    item.StyledSettings := [];
    item.StyleLookup := 'listboxitemstyle';
    item.Padding.Left := 10;
    item.Padding.Top := 5;
    item.Padding.Bottom := 5;
    item.Padding.Right := 10;
    item.TextSettings.Font.Family := 'Inter';
    item.TextSettings.Font.Size := 14;
    item.TextSettings.HorzAlign := TTextAlign.Center;
    item.Size.Width := 120;
  end;

begin
  if aIndex = 0 then
  begin
    item := TListBoxItem.Create(nil);
    FormatarItem(item);
    item.Text := 'Todos';
    item.TextSettings.FontColor := $FFF83923;
    lbGrupos.AddObject(item);
  end;

  item := TListBoxItem.Create(nil);
  FormatarItem(item);
  item.Text := Trim(aGrupo.Descricao);
  item.TextSettings.FontColor := TAlphaColors.Black;
  lbGrupos.AddObject(item);
end;

procedure TfrmPrincipal.Autenticar_API;
begin
  try
    Timer.Enabled := False;
    if not Assigned(FAuthentication) then
      FAuthentication := TAuthentication.GetInstance(Self);

    try
//      if FAuthentication.Token = EmptyStr then
//      begin
//        FAuthentication.URLServer := FAuthentication.Connection.URLBase;
//        FAuthentication.BodyString :=
//          '{'+
//          '  "user":"hunger",'+
//          '  "password":"rm045369"' +
//          '}';
//        FAuthentication.UseURL := True;
//        FAuthentication.Authentication;
//      end;
      if FAuthentication.Token <> EmptyStr then
      begin
        if MesaUUID = EmptyStr then
        begin
          lblMesa.Text := 'Selecione uma mesa';
          FMesaDescricao := 'Selecione uma mesa';
        end;
        if MesaUUID <> EmptyStr then
          ValidarMesaUUID;
        if lvConsultaProduto.Items.Count = 0 then
          ConsultarProduto(EmptyStr);
        if lbGrupos.Items.Count = 1 then
          ConsultarGrupo;
      end;
    except on E:Exception do
      begin
        TDialogService.ShowMessage('Tentativa de conexão falhou! Vamos tentar novamente. ' + E.Message);
        Autenticar_API;
      end;
    end;
  finally
    //Timer.Enabled := FAuthentication.Token = EmptyStr;
  end;
end;

procedure TfrmPrincipal.ConsultarGrupo;
var
  LJsonResponse: TJSONObject;
begin
  try
    LJsonResponse := FModelProduto.ConsultarGrupo(FAuthentication.Connection);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"grupos":[]}') then
    begin
      if not Assigned(FGrupos) then
        FGrupos := TObjectList<TGrupo>.Create;
      FGrupos := FModelProduto.PopularListaGrupo(LJsonResponse);
      if FGrupos.Count > 0 then
        PreencherLbGrupos(FGrupos);
    end;
  except on E:Exception do
    begin
       TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                  E.Message);
      Exit;
    end;
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
        if Assigned(FGrupos) and (lbGrupos.ItemIndex <> -1) then
          PreencherListView(FProdutos, FGrupos.Items[Pred(lbGrupos.ItemIndex)].IdGrupo)
        else
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

procedure TfrmPrincipal.edtPesquisarChangeTracking(Sender: TObject);
begin
  TimerPesquisar.Enabled := False;
  TimerPesquisar.Enabled := True;
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

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  Timer.Enabled := True;
end;

function TfrmPrincipal.GetTextHeight(const D: TListItemText;
  const Width: single; const Text: string; LineBreak: Integer = 0): Integer;
var
  Layout: TTextLayout;
begin
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := D.WordWrap;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;
    Result := Round(Layout.Height + LineBreak);
    Layout.Text := 'm';
    Result := Result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;

procedure TfrmPrincipal.imgConfigClick(Sender: TObject);
begin
  Application.CreateForm(TfrmConfig, frmConfig);

  with frmConfig do
  begin
    lblMesa.Text := 'Configurações';
    edtURL.Text := Authentication.URLServer;
  end;
  frmConfig.ShowModal(procedure(ModalResult: TModalResult)
    begin
      if frmConfig.edtURL.Text <> Authentication.URLServer then
      begin
        Authentication.URLServer := frmConfig.edtURL.Text;
        Authentication.Connection.Ini.WriteString('Config', 'URL_Server', frmConfig.edtURL.Text);
      end;
    end);
end;

procedure TfrmPrincipal.imgLerQRClick(Sender: TObject);
begin
  if Assigned(Pedido) and (Pedido.PedidoItem.Count > 0) then
  begin
    TDialogService.ShowMessage('Finalize o pedido atual ou exclua todos os itens do carrinho para trocar de mesa!');
    Exit;
  end;

  LerQRCode(qrMesa);
end;

procedure TfrmPrincipal.Layout_lvConsulta(AItem: TListViewItem);
var
  txt: TListItemText;
  heights: TArray<Single>;
begin
  SetLength(heights, 2);

  txt := AItem.Objects.FindDrawable('descricao') as TListItemText;
  txt.Width := lvConsultaProduto.Width - 100;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text) + 5;
  heights[0] := Trunc(txt.Height);

  txt := AItem.Objects.FindDrawable('valor') as TListItemText;
  txt.Width := lvConsultaProduto.Width - 100;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text) + 5;
  txt.PlaceOffset.Y := Trunc(heights[0]);
  heights[1] := Trunc(txt.Height);

  txt := AItem.Objects.FindDrawable('complemento') as TListItemText;
  txt.Width := lvConsultaProduto.Width - 100;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text) + 5;
  txt.PlaceOffset.Y := Trunc(heights[0] + heights[1]);
  AItem.Height := Trunc(txt.PlaceOffset.Y + txt.Height);
end;

procedure TfrmPrincipal.lbGruposItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
var
  I: Integer;
begin
  for I := 0 to Pred(lbGrupos.Count) do
    lbGrupos.ListItems[I].TextSettings.FontColor := TAlphaColors.Black;

  Item.TextSettings.FontColor := $FFF83923;

  if Item.Index = 0 then
    PreencherListView(FProdutos)
  else
    PreencherListView(FProdutos, FGrupos.Items[Pred(Item.Index)].IdGrupo);
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
    FContentImage := EmptyStr;
    if not Assigned(frmLeitorCamera) then
      Application.CreateForm(TfrmLeitorCamera, frmLeitorCamera);
    frmLeitorCamera.Codigo := EmptyStr;
    frmLeitorCamera.TipoQRCode := aTipoQRCode;
    frmLeitorCamera.ShowModal(procedure(ModalResult: TModalResult)
    begin
      FContentImage := FrmLeitorCamera.Codigo;
      if (aTipoQRCode = qrMesa) and (FContentImage = EmptyStr) then
      begin
        if Assigned(Authentication) and (Authentication.Token <> EmptyStr) then
        begin
          Application.CreateForm(TfrmMesas, frmMesas);
          with frmMesas do
          begin
            lblMesa.Text := 'Selecione uma mesa';
            MesaSelecionada := 0;
            frmMesas.ShowModal(procedure(ModalResult: TModalResult)
            begin
              if lvMesas.ItemIndex >= 0 then
              begin
                FMesaID := Mesas.Mesas.Items[MesaSelecionada].IdMesa;
                FMesaUUID := Mesas.Mesas.Items[MesaSelecionada].MesaUUID;
                FMesaDescricao := 'MESA ' + Mesas.Mesas.Items[MesaSelecionada].IdMesa.ToString;
                frmPrincipal.lblMesa.Text := FMesaDescricao;
                if lvConsultaProduto.Items.Count = 0 then
                  ConsultarProduto(EmptyStr);
              end;
            end);
          end;
        end;
        Exit;
      end;

      if aTipoQRCode = qrMesa then
      begin
        LParams := FContentImage.Split(['|']);
        FMesaUUID := LParams[0];
        FMesaDescricao := LParams[1];
        FURL_API := Authentication.URLServer;
        FUser_API := 'hunger';
        FPass_API := 'rm045369';
        lblMesa.Text := FMesaDescricao;
        Timer.Enabled := True;
      end;

      if (FContentImage <> EmptyStr) and (aTipoQRCode = qrComanda) then
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

  {$IFDEF MSWINDOWS}
  if Assigned(Authentication) and (Authentication.Token <> EmptyStr) then
  begin
    Application.CreateForm(TfrmMesas, frmMesas);
    with frmMesas do
    begin
      lblMesa.Text := 'Selecione uma mesa';
      MesaSelecionada := 0;
      frmMesas.ShowModal(procedure(ModalResult: TModalResult)
      begin
        if lvMesas.ItemIndex >= 0 then
        begin
          FMesaID := Mesas.Mesas.Items[MesaSelecionada].IdMesa;
          FMesaUUID := Mesas.Mesas.Items[MesaSelecionada].MesaUUID;
          FMesaDescricao := 'MESA ' + Mesas.Mesas.Items[MesaSelecionada].IdMesa.ToString;
          frmPrincipal.lblMesa.Text := FMesaDescricao;
          FNumeroComanda := '10';
          if lvConsultaProduto.Items.Count = 0 then
            ConsultarProduto(EmptyStr);
        end;
      end);
    end;
  end;
  {$ENDIF MSWINDOWS}
end;

procedure TfrmPrincipal.lvConsultaProdutoItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if FMesaUUID = EmptyStr then
  begin
    TDialogService.ShowMessage('Selecione uma mesa antes de adicionar itens no carrinho!');
    Exit;
  end;

  //Abrir tela de inclusão do item no carrinho
  Application.CreateForm(TfrmProduto, frmProduto);

  with frmProduto do
  begin
    lblMesa.Text := FMesaDescricao + ' > Produto';
    imgProduto.Bitmap := imgFoto.MultiResBitmap.Items[ItemIndex].Bitmap;
    if not Assigned(imgProduto.Bitmap) then
      imgProduto.Destroy;
    Produto := FProdutos[lvConsultaProduto.Items[ItemIndex].Tag];
    if NumeroComanda <> EmptyStr then
      NComanda := NumeroComanda.ToInteger;
  end;
  frmProduto.ShowModal(procedure(ModalResult: TModalResult)
    begin
      if Assigned(frmProduto.PedidoItem) then
      begin
        if not Assigned(Pedido) then
        begin
          Pedido := TPedido.Create;
          Pedido.Codcli := 0;
          Pedido.Codap := FMesaID;
          Pedido.DataEntrada := Now;
          Pedido.DataSaida := Pedido.DataEntrada;
          Pedido.Situacao := 'Em aberto';
          Pedido.FecharConta := False;
          Pedido.Vlrtotal := 0;
        end;
        Pedido.PedidoItem.Add(frmProduto.PedidoItem);
        Pedido.Vlrtotal := Pedido.Vlrtotal + frmProduto.PedidoItem.Vlrtotalitem;
        recItensCarrinho.Visible := True;
        lblItensCarrinho.Visible := True;
        lblItensCarrinho.Text := Pedido.PedidoItem.Count.ToString;

        if not Assigned(FProdutosCarrinho) then
          FProdutosCarrinho := TObjectList<TProduto>.Create;
        FProdutosCarrinho.Add(frmProduto.Produto);
      end;
    end);
end;

procedure TfrmPrincipal.PreencherLbGrupos(aGrupos: TObjectList<TGrupo>);
var
  I: Integer;
begin
  lbGrupos.Items.Clear;
  lbGrupos.BeginUpdate;
  try
    for I := 0 to Pred(aGrupos.Count) do
      AddItemLb(I, aGrupos[I]);
  finally
    lbGrupos.EndUpdate;
  end;
end;

procedure TfrmPrincipal.PreencherListView(aProdutos: TObjectList<TProduto>; idGrupo: Integer = 0);
var
  t: TThread;
begin
  lvConsultaProduto.Items.Clear;
  lvConsultaProduto.BeginUpdate;
  imgFoto.MultiResBitmap.Clear;
  lbGrupos.Enabled := False;
  t := TThread.CreateAnonymousThread(procedure
  var
    LItem: TListViewItem;
    I: Integer;
  begin
    for I := 0 to Pred(aProdutos.Count) do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        if ((idGrupo > 0) and (aProdutos[I].IdGrupo = idGrupo))
        or (idGrupo = 0) then
        begin
          LItem := lvConsultaProduto.Items.Add;
          with LItem do
          begin
            Height := 90;
            Tag := I;

            imgFoto.MultiResBitmap.Add;
            if aProdutos[I].Imagem <> EmptyStr then
            begin
              //imgFoto.MultiResBitmap.Add;
              imgFoto.MultiResBitmap.Items[I].Bitmap.LoadFromStream(FUtils.Base64ToStream(aProdutos[I].Imagem));
              if not imgFoto.Bitmap.IsEmpty then
                TListItemImage(Objects.FindDrawable('imgProduto')).Bitmap := imgFoto.MultiResBitmap.Items[I].Bitmap;
            end
            else
              imgFoto.MultiResBitmap.Items[I].Bitmap.Create(1,1);

            TListItemText(Objects.FindDrawable('descricao')).Text := aProdutos[I].Descricao;
            TListItemText(Objects.FindDrawable('complemento')).Text := aProdutos[I].Complemento;
            TListItemText(Objects.FindDrawable('valor')).Text := 'A partir de ' +
              FloatToStrF(aProdutos[I].ValorInicial, ffCurrency, 15,2);
            Layout_lvConsulta(LItem);
          end;
        end
        else
        begin
          imgFoto.MultiResBitmap.Add;
          imgFoto.MultiResBitmap.Items[I].Bitmap.Create(1,1);
        end;
      end);
    end;
    lbGrupos.Enabled := True;
  end);
  lvConsultaProduto.EndUpdate;
  t.Start;

end;

procedure TfrmPrincipal.sebPesquisarClick(Sender: TObject);
begin
  TimerPesquisar.Enabled := False;

  if not Assigned(FAuthentication) then
  begin
    TDialogService.ShowMessage('Conexão com sevidor não estabelecida!');
    Exit;
  end;

  if Assigned(FAuthentication) and (FAuthentication.Token <> EmptyStr) then
  begin
    ConsultarProduto(edtPesquisar.Text);
    if lbGrupos.Items.Count = 1 then
      ConsultarGrupo;
  end
  else
  if Assigned(FAuthentication) and (FAuthentication.Token = EmptyStr) then
    Autenticar_API;
end;

procedure TfrmPrincipal.SetNumeroComanda(const Value: String);
begin
  FNumeroComanda := Value;
end;

procedure TfrmPrincipal.SetPedido(const Value: TPedido);
begin
  FPedido := Value;
end;

procedure TfrmPrincipal.SetProdutos(const Value: TObjectList<TProduto>);
begin
  FProdutos := Value;
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

  Application.CreateForm(TfrmCarrinho, frmCarrinho);
  with frmCarrinho do
  begin
    lblMesa.Text := FMesaDescricao + ' > Carrinho';
    lblFinalizar.Text := 'Finalizar pedido';
    Pedido := FPedido;
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
      end
      else
        ConsultarProduto(edtPesquisar.Text);
    end);
end;

procedure TfrmPrincipal.spbPedidosClick(Sender: TObject);
begin
  //Abrir tela de histórico de pedidos
  if FMesaUUID = EmptyStr then
  begin
    TDialogService.ShowMessage('Selecione uma mesa para consultar os pedidos em aberto!');
    Exit;
  end;

//  if not Assigned(frmPedidos) then
  Application.CreateForm(TfrmPedidos, frmPedidos);

  with frmPedidos do
    lblMesa.Text := FMesaDescricao + ' > Pedidos';

  frmPedidos.ShowModal(procedure(ModalResult: TModalResult)
    begin
    end);
end;

procedure TfrmPrincipal.TimerPesquisarTimer(Sender: TObject);
begin
  sebPesquisarClick(Sender);
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
