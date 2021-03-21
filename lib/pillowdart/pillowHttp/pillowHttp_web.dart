import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

http.Client getClient() {
  final client = http.Client();
  (client as BrowserClient).withCredentials = true;
  return client;
}
