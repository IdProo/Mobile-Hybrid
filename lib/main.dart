import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'config.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String _codeVerifier;
  String _authorizationCode;
  String _refreshToken;
  String _accessToken;
  final TextEditingController _authorizationCodeTextController =
      TextEditingController();
  final TextEditingController _accessTokenTextController =
      TextEditingController();
  final TextEditingController _accessTokenExpirationTextController =
      TextEditingController();

  final TextEditingController _idTokenTextController = TextEditingController();
  final TextEditingController _refreshTokenTextController =
      TextEditingController();
  String _userInfo = '';

  AuthorizationServiceConfiguration _serviceConfiguration =
      AuthorizationServiceConfiguration(
          '${Configuration.indentityS4Uri}connect/authorize',
          '${Configuration.indentityS4Uri}connect/token');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    setBusyState();
    final TokenResponse result = await _appAuth.token(TokenRequest(
        Configuration.clientId, Configuration.redirectUri,
        refreshToken: _refreshToken,
        discoveryUrl: Configuration.discoveryUri,
        scopes: Configuration.scopes));
    _processTokenResponse(result);
  }

  Future<void> _exchangeCode() async {
    setBusyState();
    final TokenResponse result = await _appAuth.token(TokenRequest(
        Configuration.clientId, Configuration.redirectUri,
        authorizationCode: _authorizationCode,
        discoveryUrl: Configuration.discoveryUri,
        codeVerifier: _codeVerifier,
        scopes: Configuration.scopes));
    _processTokenResponse(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IdProo Hybrid Login'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Visibility(
                visible: _isBusy,
                child: const LinearProgressIndicator(),
              ),
              RaisedButton(
                child: const Text('Sign in with no code exchange'),
                onPressed: () async {
                  setBusyState();
                  // use the discovery endpoint to find the configuration
                  final AuthorizationResponse result = await _appAuth.authorize(
                    AuthorizationRequest(Configuration.clientId, Configuration.redirectUri,
                        discoveryUrl: Configuration.discoveryUri,
                        scopes: Configuration.scopes,
                        loginHint: 'bob'),
                  );

                  // or just use the issuer
                  // var result = await _appAuth.authorize(
                  //   AuthorizationRequest(
                  //     _clientId,
                  //     _redirectUrl,
                  //     issuer: _issuer,
                  //     scopes: _scopes,
                  //   ),
                  // );
                  if (result != null) {
                    _processAuthResponse(result);
                  }
                },
              ),
              RaisedButton(
                child: const Text('Exchange code'),
                onPressed: _authorizationCode != null ? _exchangeCode : null,
              ),
              RaisedButton(
                child: const Text('Sign in with auto code exchange'),
                onPressed: () async {
                  setBusyState();

                  // show that we can also explicitly specify the endpoints rather than getting from the details from the discovery document
                  final AuthorizationTokenResponse result =
                      await _appAuth.authorizeAndExchangeCode(
                    AuthorizationTokenRequest(
                      Configuration.clientId,
                      Configuration.redirectUri,
                      serviceConfiguration: _serviceConfiguration,
                      scopes: Configuration.scopes,
                    ),
                  );

                  // this code block demonstrates passing in values for the prompt parameter. in this case it prompts the user login even if they have already signed in. the list of supported values depends on the identity provider
                  // final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
                  //   AuthorizationTokenRequest(_clientId, _redirectUrl,
                  //       serviceConfiguration: _serviceConfiguration,
                  //       scopes: _scopes,
                  //       promptValues: ['login']),
                  // );

                  if (result != null) {
                    _processAuthTokenResponse(result);
                  }
                },
              ),
              RaisedButton(
                child: const Text('Refresh token'),
                onPressed: _refreshToken != null ? _refresh : null,
              ),
              const Text('authorization code'),
              TextField(
                controller: _authorizationCodeTextController,
              ),
              const Text('access token'),
              TextField(
                controller: _accessTokenTextController,
              ),
              const Text('access token expiration'),
              TextField(
                controller: _accessTokenExpirationTextController,
              ),
              const Text('id token'),
              TextField(
                controller: _idTokenTextController,
              ),
              const Text('refresh token'),
              TextField(
                controller: _refreshTokenTextController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setBusyState() {
    setState(() {
      _isBusy = true;
    });
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken;
      _idTokenTextController.text = response.idToken;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime?.toIso8601String();
    });
  }

  void _processAuthResponse(AuthorizationResponse response) {
    setState(() {
      // save the code verifier as it must be used when exchanging the token
      _codeVerifier = response.codeVerifier;
      _authorizationCode =
          _authorizationCodeTextController.text = response.authorizationCode;
      _isBusy = false;
    });
  }

  void _processTokenResponse(TokenResponse response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken;
      _idTokenTextController.text = response.idToken;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime?.toIso8601String();
    });
  }


}
