unit Hunger.Utils;

interface

uses
  FMX.Graphics, System.Classes, System.SysUtils, System.NetEncoding;

type
  TUtils = class
  private
  public
    class function Base64ToStream(aBase64: String): TMemoryStream; static;
    class function RetirarQuebraDeLinha(aText : String): String; static;
    class function RemoverAcentos(const aText: string): String; static;
    class function RemoveChar(Const Texto:String):String;
    class function FormataCPF(CPF : string): string;
    class function FormataCNPJ(CNPJ : string): string;
    class function ValidaCPF(num: string): boolean;
    class function ValidaCNPJ(num: string): boolean;

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

class function TUtils.ValidaCPF(num: string): boolean;
var
   n1,n2,n3,n4,n5,n6,n7,n8,n9: integer;
   d1,d2: integer;
   digitado, calculado: string;
begin
  if (num = '00000000000') or (num = '11111111111') or
     (num = '22222222222') or (num = '33333333333') or
     (num = '44444444444') or (num = '55555555555') or
     (num = '66666666666') or (num = '77777777777') or
     (num = '88888888888') or (num = '99999999999') or
     (length(num) <> 11) then
     Result := False
  else
  begin
    n1:=StrToInt(num[1]);
    n2:=StrToInt(num[2]);
    n3:=StrToInt(num[3]);
    n4:=StrToInt(num[4]);
    n5:=StrToInt(num[5]);
    n6:=StrToInt(num[6]);
    n7:=StrToInt(num[7]);
    n8:=StrToInt(num[8]);
    n9:=StrToInt(num[9]);
    d1:=n9*2+n8*3+n7*4+n6*5+n5*6+n4*7+n3*8+n2*9+n1*10;
    d1:=11-(d1 mod 11);
    if d1>=10 then
      d1:=0;
    d2:=d1*2+n9*3+n8*4+n7*5+n6*6+n5*7+n4*8+n3*9+n2*10+n1*11;
    d2:=11-(d2 mod 11);
    if d2>=10 then
     d2:=0;
    calculado:=inttostr(d1)+inttostr(d2);
    digitado:=num[10]+num[11];
    if calculado=digitado then
         validaCPF := true
    else
         validaCPF := false;
  end;
end;

class function TUtils.ValidaCNPJ(num: string): boolean;
var
    n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12: integer;
    d1,d2: integer;
    digitado, calculado: string;
begin
  if (num = '00000000000000') or (num = '11111111111111') or
     (num = '22222222222222') or (num = '33333333333333') or
     (num = '44444444444444') or (num = '55555555555555') or
     (num = '66666666666666') or (num = '77777777777777') or
     (num = '88888888888888') or (num = '99999999999999') or
     (length(num) <> 14) then
     Result := False
  else
  begin
    n1:=StrToInt(num[1]);
    n2:=StrToInt(num[2]);
    n3:=StrToInt(num[3]);
    n4:=StrToInt(num[4]);
    n5:=StrToInt(num[5]);
    n6:=StrToInt(num[6]);
    n7:=StrToInt(num[7]);
    n8:=StrToInt(num[8]);
    n9:=StrToInt(num[9]);
    n10:=StrToInt(num[10]);
    n11:=StrToInt(num[11]);
    n12:=StrToInt(num[12]);
    d1:=n12*2+n11*3+n10*4+n9*5+n8*6+n7*7+n6*8+n5*9+n4*2+n3*3+n2*4+n1*5;
    d1:=11-(d1 mod 11);
    if d1>=10 then d1:=0;
    d2:=d1*2+n12*3+n11*4+n10*5+n9*6+n8*7+n7*8+n6*9+n5*2+n4*3+n3*4+n2*5+n1*6;
    d2:=11-(d2 mod 11);
    if d2>=10 then d2:=0;
    calculado:=inttostr(d1)+inttostr(d2);
    digitado:=num[13]+num[14];
    if calculado=digitado then
         validaCNPJ := true
    else
         validaCNPJ := false;
  end;
end;

class Function TUtils.formataCPF(CPF : string): string;
begin
    Result := Copy(CPF,1,3)+'.'+Copy(CPF,4,3)+'.'+Copy(CPF,7,3)+'-'+Copy(CPF,10,2);
end;

class Function TUtils.formataCNPJ(CNPJ : string): string;
begin
    Result := Copy(cnpj,1,2)+'.'+Copy(cnpj,3,3)+'.'+Copy(cnpj,6,3)+'/'+Copy(cnpj,9,4)+'-'+Copy(cnpj,13,2);
end;

class function TUtils.RemoveChar(Const Texto:String):String;
var
   I: integer;
   S: string;
begin
   S := '';
   for I := 1 To Length(Texto) Do
   begin
        if (Texto[I] in ['0'..'9']) then
        begin
              S := S + Copy(Texto, I, 1);
        end;
   end;
   result := S;
end;

class function TUtils.RemoverAcentos(const aText: string): String;
type
  USAscii20127 = type AnsiString(20127);
begin
  Result := String(USAscii20127(aText));
end;

class function TUtils.RetirarQuebraDeLinha(aText: string): string;
begin
  Result := StringReplace(aText, #$D#$A, '', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '', [rfReplaceAll]);
end;

end.
