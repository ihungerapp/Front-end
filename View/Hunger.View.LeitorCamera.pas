unit Hunger.View.LeitorCamera;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Media,
  ZXing.ScanManager,
  ZXing.ReadResult,
  ZXing.BarcodeFormat,
  FMX.Platform, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts;

type
  TTipoQRCode = (qrMesa, qrComanda);

  TfrmLeitorCamera = class(TForm)
    CameraComponent: TCameraComponent;
    img_close: TImage;
    img_camera: TImage;
    lblStatus: TLabel;
    Layout1: TLayout;
    procedure CameraComponentSampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure img_closeClick(Sender: TObject);
  private
    FScanManager : TScanManager;
    FScanInProgress : Boolean;
    FFrameTake : Integer;
    FCodigo: String;
    FTipoQRCode: TTipoQRCode;
    procedure ProcessImage;
    procedure SetCodigo(const Value: String);
    procedure SetTipoQRCode(const Value: TTipoQRCode);
  public
    property Codigo: String read FCodigo write SetCodigo;
    property TipoQRCode: TTipoQRCode read FTipoQRCode write SetTipoQRCode;
  end;

var
  frmLeitorCamera: TfrmLeitorCamera;

implementation

{$R *.fmx}

procedure TfrmLeitorCamera.CameraComponentSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  ProcessImage;
end;

procedure TfrmLeitorCamera.FormCreate(Sender: TObject);
begin
  FScanManager := TScanManager.Create(TBarcodeFormat.Auto, nil);
end;

procedure TfrmLeitorCamera.FormDestroy(Sender: TObject);
begin
  FScanManager.DisposeOf;
end;

procedure TfrmLeitorCamera.FormShow(Sender: TObject);
begin
  if TipoQRCode = qrMesa then
    lblStatus.Text := 'Aponte a c�mera para o QRCode da mesa!';
  if TipoQRCode = qrComanda then
    lblStatus.Text := 'Aponte a c�mera para o QRCode da comanda!';
  FFrameTake := 0;
  CameraComponent.Active := false;
  CameraComponent.Kind := TCameraKind.BackCamera;
  CameraComponent.FocusMode := TFocusMode.ContinuousAutoFocus;
  CameraComponent.Quality := TVideoCaptureQuality.MediumQuality;
  CameraComponent.Active := true;
end;

procedure TfrmLeitorCamera.img_closeClick(Sender: TObject);
begin
  CameraComponent.Active := false;
  close;
end;

procedure TfrmLeitorCamera.ProcessImage;
var
  bmp : TBitmap;
  ReadResult : TReadResult;
begin
  CameraComponent.SampleBufferToBitmap(img_camera.Bitmap, true);

  if FScanInProgress then
    exit;

  inc(FFrameTake);

  if (FFrameTake mod 2 <> 0) then
   exit;

  bmp := TBitmap.Create;
  bmp.Assign(img_camera.Bitmap);
  ReadResult := nil;

  try
    FScanInProgress := true;

    try
      ReadResult := FScanManager.Scan(bmp);

      if ReadResult <> nil then
      begin
        CameraComponent.Active := false;
        codigo := ReadResult.text;
        close;
      end;

    except on ex:exception do
      lblStatus.Text := ex.Message;
    end;
  finally
    bmp.DisposeOf;
    ReadResult.DisposeOf;
    FScanInProgress := false;
  end;
end;

procedure TfrmLeitorCamera.SetCodigo(const Value: String);
begin
  FCodigo := Value;
end;

procedure TfrmLeitorCamera.SetTipoQRCode(const Value: TTipoQRCode);
begin
  FTipoQRCode := Value;
end;

end.
