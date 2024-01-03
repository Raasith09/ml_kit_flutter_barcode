import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiServices {
  Future<String> sendImages(Map<String, dynamic> map) async {
    try {
      var url = Uri.parse("http://219.91.197.245:72/rra/microtext");
      final apiResponse = await http.post(url,
          headers: {'Keep-Alive': 'true', 'Content-Type': 'application/json'},
          body: jsonEncode(map));
      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        return "Success";
      } else {
        return "Something went wrong";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
