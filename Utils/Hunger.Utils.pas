unit Hunger.Utils;

interface

uses
  FMX.Graphics, System.Classes, System.SysUtils, System.NetEncoding;

type
  TUtils = class
  public
    class function Base64ToStream(aBase64: String): TMemoryStream; static;
  end;

implementation

{ TUtils }

class function TUtils.Base64ToStream(aBase64: String): TMemoryStream;
var
  bstBytes: TBytesStream;
  mstImg: TMemoryStream;
begin
  bstBytes := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(aBase64));
  mstImg := TMemoryStream.Create;
  Result := nil;
  try
    if Length(bstBytes.Bytes) > 0 then
    begin
      mstImg.SaveToStream(bstBytes);
      mstImg.WriteData(mstImg, Length(bstBytes.Bytes));
      mstImg.Position := 0;
      Result := mstImg;
    end;
  finally
    FreeAndNil(bstBytes);
    FreeAndNil(mstImg);
  end;

end;

end.
