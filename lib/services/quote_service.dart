import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quotes_app/models/quote_model.dart';

class Services {
  Future<QuoteModel?> getData(String date, context) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://quotes.isha.in/dmq/index.php/Webservice/fetchDailyQuote?date=$date'),
      );

      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        final quoteData = item['response']['data']
            [0]; // Adjusted to correctly access the data
        return QuoteModel.fromJson(quoteData);
      } else {
        if (kDebugMode) {
          print('Error Occurred: Status code ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error Occurred: $e');
      }
    }
    return null; // Return null in case of an error
  }
}
