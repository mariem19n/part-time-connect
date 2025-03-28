import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:io';


Future<String?> getCsrfToken(CookieJar cookieJar) async {
  try {
    var client = http.Client();
    var uri = Uri.parse('http://10.0.2.2:8000/api/login/');  // Ensure the URL ends with a slash

    print('Sending GET request to $uri...');

    // Send GET request to retrieve the CSRF token
    final response = await client.get(uri);

    print('Response received.');
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');

    // Check if there are cookies in the response header and save them
    if (response.headers.containsKey('set-cookie')) {
      print('Set-Cookie header found, parsing cookies...');

      // Manually split cookies and create a List<Cookie>
      List<Cookie> parsedCookies = response.headers['set-cookie']!
          .split(RegExp(r',(?! )'))  // Split by comma only if not followed by a space
          .map((cookieStr) {
        print('Parsing cookie: $cookieStr');
        return Cookie.fromSetCookieValue(cookieStr);
      }).toList();

      // Save parsed cookies into CookieJar
      await cookieJar.saveFromResponse(uri, parsedCookies);
      print('Cookies saved: ${await cookieJar.loadForRequest(uri)}');
    } else {
      print('No cookies set in the response.');
    }
    // Retrieve CSRF token from saved cookies
    var cookies = await cookieJar.loadForRequest(uri);
    print('Cookies retrieved from CookieJar: $cookies');
    var csrfToken = cookies.firstWhere(
          (cookie) => cookie.name == 'csrftoken',
      orElse: () => Cookie('csrftoken', ''),
    ).value;
    if (csrfToken.isEmpty) {
      print('CSRF token not found.');
      return null;
    }
    print('CSRF token found: $csrfToken');
    return csrfToken;
  } catch (e) {
    print('Error retrieving CSRF token: $e');
    return null;
  }
}

