class Configuration {
  Configuration._();

  ///Rest URI
  static String indentityS4Uri = "https://login.idproo.id/";
  static String idProoUri = "https://idproo.id/";
  static String discoveryUri =
      "https://login.idproo.id/.well-known/openid-configuration";

  ///Login Scopes
  static List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'api.auth',
    'user.role',
    'user.read',
    'user.readAll',
    'application.read',
    'application.readAll',
    'unit.readAll',
    'unit.read'
  ];

  ///Login Properties
  ///Client Id
  static String clientId = "410db968-8b8a-4123-974a-ad94e9ac4311";

  ///Redirect Uri
  static String redirectUri = "id.idproo.hybrid.auth:/oauthredirect";
}