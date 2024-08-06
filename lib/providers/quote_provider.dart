import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quotes_app/models/quote_model.dart';
import 'package:quotes_app/services/quote_service.dart';

class QuoteProvider with ChangeNotifier {
  static const int quoteCount = 30;
  static const int initialQuoteCount = 2;

  List<QuoteModel> data = [];
  bool loading = false;
  bool isBackgroundFetching = false;
  Services services = Services();

  DateTime _date = DateTime.now();
  DateTime get date => _date;

  Future<void> fetchAndSaveQuoteData(
    DateTime currentDate,
    int count, {
    bool backgroundFetching = false,
  }) async {
    loading = true;
    isBackgroundFetching = backgroundFetching;
    notifyListeners();

    await _loadDataFromPreferences();

    DateFormat formatter = DateFormat('yyyy-MM-dd');
    List<DateTime> missingDates = [];

    for (int i = 0; i < count; i++) {
      DateTime date = currentDate.subtract(Duration(days: i));
      if (!data.any(
          (quote) => formatter.format(quote.date!) == formatter.format(date))) {
        missingDates.add(date);
      }
    }

    for (DateTime date in missingDates) {
      print('Fetching data for date: ${formatter.format(date)}');
      QuoteModel? quote = await services.getData(formatter.format(date), null);
      if (quote != null) {
        quote.date = date;
        data.add(quote);
      }
    }

    data.sort((a, b) => b.date!.compareTo(a.date!));

    if (data.length > quoteCount) {
      data = data.sublist(0, quoteCount);
    }

    await _saveDataToPreferences(data);
    loading = false;
    isBackgroundFetching = false;
    notifyListeners();
  }

  Future<void> fetchRemainingQuotes(DateTime currentDate) async {
    await fetchAndSaveQuoteData(
      currentDate,
      quoteCount - initialQuoteCount,
      backgroundFetching: true,
    );
  }

  Future<void> _saveDataToPreferences(List<QuoteModel> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(quotes.map((quote) => quote.toJson()).toList());
    await prefs.setString('quotes_data', jsonData);
  }

  Future<void> _loadDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString('quotes_data');

    if (jsonData != null) {
      final List<dynamic> jsonList = jsonDecode(jsonData);
      data = jsonList.map((json) => QuoteModel.fromJson(json)).toList();

      DateFormat formatter = DateFormat('yyyy-MM-dd');
      DateTime currentDate = DateTime.now();
      String currentDateString = formatter.format(currentDate);

      if (!data
          .any((quote) => formatter.format(quote.date!) == currentDateString)) {
        if (data.length >= quoteCount) {
          data.removeRange(0, data.length - quoteCount + 1);
        }
      }
      notifyListeners();
    }
  }

  void setDate(DateTime? newDate) {
    _date = newDate!;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _loadDataFromPreferences();
    if (data.isEmpty || data.length != quoteCount) {
      await fetchAndSaveQuoteData(_date, initialQuoteCount);
      // todo: implement the functionality of background fetch.
      fetchRemainingQuotes(
        _date.subtract(
          const Duration(days: initialQuoteCount),
        ),
      );
    }
  }
}
