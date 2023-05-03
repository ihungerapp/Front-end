unit Hunger.Utils;

interface

uses
  FMX.Graphics, System.Classes, System.SysUtils, System.NetEncoding;

type
  TUtils = class
  private
  public
    class function Base64ToStream(aBase64: String): TMemoryStream; static;
    class function RetirarQuebraDeLinha(aText : string): string; static;
  end;

implementation

{ TUtils }

class function TUtils.Base64ToStream(aBase64: String): TMemoryStream;
var
  bstBytes: TBytesStream;
  mstImg: TMemoryStream;
  base64: AnsiString;
  arrBytes: TArray<Byte>;
begin
  base64 := RetirarQuebraDeLinha(aBase64);
  bstBytes := TBytesStream.Create;
  //bstBytes.SetSize(Length(base64));
  SetLength(arrBytes, Length(base64));
  arrBytes := TNetEncoding.Base64.DecodeStringToBytes(base64);
  bstBytes.Write(arrBytes, Length(arrBytes));
  mstImg := TMemoryStream.Create;
  //mstImg.SetSize(Length(bstBytes.Bytes));
  Result := nil;
  try
    if Length(bstBytes.Bytes) > 0 then
    begin
      mstImg.LoadFromStream(bstBytes);
      mstImg.Position := 0;
      Result := mstImg;
    end;
  finally
    FreeAndNil(bstBytes);
  end;
end;

class function TUtils.RetirarQuebraDeLinha(aText: string): string;
begin
  Result := StringReplace(aText, #$D#$A, '', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '', [rfReplaceAll]);
end;

end.
