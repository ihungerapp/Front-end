unit Hunger.View.LeitorCamera;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Media,
  ZXing.ScanManager,
  ZXing.ReadResult,
  ZXing.BarcodeFormat,
  FMX.Platform, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TfrmLeitorCamera = class(TForm)
    CameraComponent: TCameraComponent;
    img_close: TImage;
    img_camera: TImage;
    lbl_erro: TLabel;
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
  public
    codigo: String;
  end;

var
  frmLeitorCamera: TfrmLeitorCamera;

implementation

{$R *.fmx}

procedure TfrmLeitorCamera.CameraComponentSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
var
  bmp : TBitmap;
  ReadResult : TReadResult;
begin
  CameraComponent.SampleBufferToBitmap(img_camera.Bitmap, true);

  if FScanInProgress then
    exit;

  inc(FFrameTake);

  if (FFrameTake mod 4 <> 0) then
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
      lbl_erro.Text := ex.Message;
    end;
  finally
    bmp.DisposeOf;
    ReadResult.DisposeOf;
    FScanInProgress := false;
  end;
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

end.
