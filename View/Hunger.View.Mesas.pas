unit Hunger.View.Mesas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Hunger.View.Base, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  Hunger.Model.Entidade.Mesas, System.JSON, System.Generics.Collections,
  Hunger.View.Main, Client.Connection, FMX.DialogService, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.TextLayout;

type
  TfrmMesas = class(TfrmBase)
    spbVoltar: TSpeedButton;
    lvMesas: TListView;
    procedure spbVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvMesasUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lvMesasItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    FMesas: TMesasList;
    FMesaSelecionada: Integer;
    function ConsultarMesas: TJSONOBject;
    procedure Carregar_LvMesas(aMesas: TObjectList<TMesa>);
    procedure SetMesas(const Value: TMesasList);
    procedure SetMesaSelecionada(const Value: Integer);
    procedure Layout_lvMesas(AItem: TListViewItem);
    function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
  public
    property Mesas: TMesasList read FMesas write SetMesas;
    property MesaSelecionada: Integer read FMesaSelecionada write SetMesaSelecionada;
  end;

var
  frmMesas: TfrmMesas;

implementation

uses
  REST.Json;

{$R *.fmx}

procedure TfrmMesas.Carregar_LvMesas(aMesas: TObjectList<TMesa>);
var
  LItem: TListViewItem;
  I, J, IndexImage : Integer;
  mesa: TMesa;
  comandas: String;
begin
  lvMesas.Items.Clear;
  lvMesas.BeginUpdate;
  IndexImage := 0;
  for I := 0 to Pred(aMesas.Count) do
  begin
    mesa := aMesas.Items[I];
    LItem := lvMesas.Items.Add;
    with LItem do
    begin
      Tag := mesa.IdMesa;
      Height := 50 + (23 * mesa.Pedido.Count);
      TListItemText(Objects.FindDrawable('mesa')).Text := 'Mesa ' + mesa.IdMesa.ToString;
      comandas := EmptyStr;
      for J := 0 to Pred(mesa.Pedido.Count) do
        if Assigned(mesa.Pedido.Items[J]) then
          comandas := comandas + #13 + 'Nº ' + mesa.Pedido.Items[J].NumeroComanda.ToString +
                       '    Valor Total ' + FloatToStrF(mesa.Pedido.Items[J].ValorTotal, ffCurrency, 15,2);
      if comandas <> EmptyStr then
      begin
        //TListItemText(Objects.FindDrawable('comandas')).Height := Height; //23 * mesa.Pedido.Count + 1;
        TListItemText(Objects.FindDrawable('comandas')).Text := 'Comandas' + comandas;
        //Layout_lvMesas(LItem);
      end
      else
        TListItemText(Objects.FindDrawable('comandas')).Height := 23
    end;
  end;
  lvMesas.EndUpdate;
end;

function TfrmMesas.ConsultarMesas: TJSONOBject;
var
  LJsonResponse: TJSONObject;
begin
  Result := nil;
  try
    LJsonResponse := nil;
    LJsonResponse := frmPrincipal.Authentication.Connection.Execute(
      'mesa?method=ListarMesasComPedido', tpGet, nil);

    if (Assigned(LJsonResponse)) and (LJsonResponse.ToJSON <> '{"mesas":[]}') then
      Result := LJsonResponse;
  except on E:Exception do
    TDialogService.ShowMessage('Erro na requisição para a API. Operação cancelada! ' +
                E.Message);
  end;
end;

procedure TfrmMesas.FormShow(Sender: TObject);
var
  LJSONResponse: TJSONObject;
  LJSONArray: TJSONArray;
  LJSONArrayItem: TJSONArray;
  LJSONValue: TJSONValue;
  mesa: TMesa;
  lstMesa: TObjectList<TMesa>;
  i: Integer;
begin
  inherited;
  FMesas := TMesasList.Create;
  lstMesa := TObjectList<TMesa>.Create;
  LJSONResponse := ConsultarMesas;
  if LJSONResponse <> nil then
  begin
    LJSONArray := LJSONResponse.GetValue('mesas') as TJSONArray;
    try
      for LJSONValue in LJSONArray do
      begin
        mesa := TJson.JsonToObject<TMesa>(LJSONValue.ToString);
        lstMesa.Add(mesa);
      end;
      FMesas.Mesas := lstMesa;
      Carregar_LvMesas(FMesas.Mesas);
    finally
      FreeAndNil(LJSONArray);
    end;
  end;

end;

function TfrmMesas.GetTextHeight(const D: TListItemText; const Width: single;
  const Text: string): Integer;
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
    Result := Round(Layout.Height);
    Layout.Text := 'm';
    Result := Result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;

procedure TfrmMesas.Layout_lvMesas(AItem: TListViewItem);
var
  txt: TListItemText;
begin
  txt := AItem.Objects.FindDrawable('comandas') as TListItemText;
  txt.Width := lvMesas.Width - 70 - 25;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text) + 5;
  AItem.Height := Trunc(txt.PlaceOffset.Y + txt.Height);
end;

procedure TfrmMesas.lvMesasItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  inherited;
  MesaSelecionada := ItemIndex;
  Close;
end;

procedure TfrmMesas.lvMesasUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
var
  subItem: TListItemDrawable;
begin
  inherited;
  subItem := AItem.Objects.FindDrawable('mesa');
  if TListItemText(AItem.Objects.FindDrawable('comandas')).Text <> EmptyStr then
  begin
    TListItemText(subItem).TextColor := TAlphaColors.Orange;
    TListItemText(AItem.Objects.FindDrawable('comandas')).Height := 35 *
      FMesas.Mesas.Items[AItem.Index].Pedido.Count;
  end
  else
    TListItemText(subItem).TextColor := TAlphaColors.Green;
end;

procedure TfrmMesas.SetMesas(const Value: TMesasList);
begin
  FMesas := Value;
end;

procedure TfrmMesas.SetMesaSelecionada(const Value: Integer);
begin
  FMesaSelecionada := Value;
end;

procedure TfrmMesas.spbVoltarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
