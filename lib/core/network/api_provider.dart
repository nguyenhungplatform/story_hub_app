import 'package:http/http.dart' as http;

class ApiProvider {
  ApiProvider({http.Client? client}) : client = client ?? http.Client();

  final http.Client client;
}