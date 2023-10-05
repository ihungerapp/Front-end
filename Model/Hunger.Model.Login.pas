unit Hunger.Model.Login;

interface

uses
  Authentication;

type

  TModelLogin = class
    private
      FAuthentication: TAuthentication;
      FUsuario: String;
      FSenha: String;
      FCpfCnpj: String;
    public
      property Usuario: String read FUsuario write FUsuario;
      property Senha: String read FSenha write FSenha;
      property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
      function Autenticar: Boolean;
  end;
implementation

uses
  System.SysUtils, FMX.DialogService;

{ TModelLogin }

function TModelLogin.Autenticar: Boolean;
begin
  if not Assigned(FAuthentication) then
    FAuthentication := TAuthentication.GetInstance(nil);

  try
    if FAuthentication.Token = EmptyStr then
    begin
      FAuthentication.URLServer := FAuthentication.Connection.URLBase;
      FAuthentication.BodyString :=
        '{'+
        '  "cpfCnpj":"' + CpfCnpj + '",'+
        '  "user":"' + Usuario + '",'+
        '  "password":"' + Senha + '"' +
        '}';
      FAuthentication.UseURL := True;
      FAuthentication.Authentication;
    end;
  except on E:Exception do
    TDialogService.ShowMessage('Dados de login inválido, vamos tentar novamente!' + E.Message);
  end;
end;

end.
