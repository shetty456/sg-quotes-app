import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quotes_app/models/quote_model.dart';
import 'package:quotes_app/providers/quote_provider.dart';
import 'package:quotes_app/views/widgets/quote_display_card.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PageController _pageController = PageController();
  String _searchText = '';
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesModel = Provider.of<QuoteProvider>(context);
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
            DateFormat('yyyy-MM-dd').format(quotesModel.date)
        ? "Today"
        : DateFormat('d MMM yyyy').format(quotesModel.date);

    // Use FuzzyWuzzy to filter quotes
    List<QuoteModel> filteredQuotes = quotesModel.data.where((quote) {
      final score = tokenSetPartialRatio(
        quote.engText!.toLowerCase(),
        _searchText.toLowerCase(),
      );

      if (_searchText.isEmpty) {
        return score >= 0;
      }
      return score >= 65; // Adjust the threshold score as needed
    }).toList();

    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      floatingActionButton: todayDate != "Today"
          ? FloatingActionButton(
              child: const Icon(Icons.restore),
              onPressed: () async {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: Center(
              child: SizedBox(
                width: width * 0.9,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchText = '';
                              });
                            },
                          )
                        : null,
                    hintText: 'Search quotes...',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Fully rounded corners
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Fully rounded corners
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Fully rounded corners
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: quotesModel.loading && !quotesModel.isBackgroundFetching
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredQuotes.isEmpty
                    ? const Center(
                        child: Text('No quotes found.'),
                      )
                    : PageView.builder(
                        // replacing page view builder to get accurate data of the page position
                        reverse: true,
                        controller: _pageController,
                        itemCount: filteredQuotes.length,
                        onPageChanged: (index) {
                          final quote = filteredQuotes[index];
                          Provider.of<QuoteProvider>(context, listen: false)
                              .setDate(quote.date);
                        },
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - value.abs()).clamp(0.0, 1.0);
                              }
                              double blur = (1 - value) * 10;

                              final quote = filteredQuotes[index];
                              return QuoteDisplayCard(
                                id: quote.id.toString(),
                                showSignature: quote.showSignature.toString(),
                                engText: quote.engText.toString(),
                                altTag: quote.altTag.toString(),
                                announcement: quote.announcement.toString(),
                                imageName: quote.imageName.toString(),
                                date: quote.date,
                                isSearchFocused: _isSearchFocused,
                                searchText: _searchText,
                                blurValue: blur,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
