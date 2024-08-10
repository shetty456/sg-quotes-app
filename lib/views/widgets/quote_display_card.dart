// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';
import 'package:quotes_app/views/widgets/bold_substring.dart';
import 'package:shimmer/shimmer.dart';

class QuoteDisplayCard extends StatelessWidget {
  final String id;
  final String showSignature;
  final String engText;
  final String altTag;
  final String imageName;
  final String announcement;
  final String searchText;
  final DateTime? date;
  final bool isSearchFocused;

  const QuoteDisplayCard({
    super.key,
    required this.id,
    required this.showSignature,
    required this.engText,
    required this.altTag,
    required this.imageName,
    required this.announcement,
    required this.searchText,
    required this.date,
    required this.isSearchFocused,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final imageHeight = height * 0.26;
    final imageWidth = double.infinity;
    final BoxFit imageBoxFit = BoxFit.fill;

    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
            DateFormat('yyyy-MM-dd').format(date!)
        ? "Today"
        : DateFormat('d MMM yyyy').format(date!);

    // Map<String, HighlightedWord> words = {
    //   searchText: HighlightedWord(
    //     textStyle: TextStyle(
    //       color: Colors.red,
    //       fontSize: engText.length > 150 ? 16 : 20,
    //       fontWeight: FontWeight.w400,
    //     ),
    //   )
    // };

    Future<bool> unblurImage() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    return isSearchFocused
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Please search for a keyword, to find quotes'),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(todayDate),
                Expanded(
                  child: Container(
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageBuilder: (context, imageProvider) {
                                  return FutureBuilder<bool>(
                                    future: unblurImage(),
                                    builder: (context, snapshot) {
                                      bool isBlurred = !snapshot.hasData ||
                                          snapshot.connectionState !=
                                              ConnectionState.done;

                                      return AnimatedSwitcher(
                                        switchInCurve: Curves.easeIn,
                                        duration:
                                            const Duration(milliseconds: 100),
                                        child: isBlurred
                                            ? ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                  sigmaX: 20,
                                                  sigmaY: 20,
                                                ),
                                                child: Image(
                                                  image: imageProvider,
                                                  fit: imageBoxFit,
                                                  width: imageWidth,
                                                ),
                                              )
                                            : Image(
                                                image: imageProvider,
                                                fit: imageBoxFit,
                                                width: imageWidth,
                                              ),
                                      );
                                    },
                                  );
                                },
                                imageUrl: imageName,
                                // imageUrl: "https://quotes.isha.in/resources/jul-27-20161018_chi_0512-e.jpg",
                                // imageUrl:
                                //     'https://images.news18.com/ibnlive/uploads/2023/03/sadhguru.jpg',
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.white,
                                  enabled: true,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      height: height * 0.26,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                height: imageHeight,
                                fit: imageBoxFit,
                                width: imageWidth,
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              left: 0,
                              right: 0,
                              child: SvgPicture.asset(
                                'assets/images/img_bottom.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      'assets/images/demo_quote.svg',
                                      colorFilter: const ColorFilter.mode(
                                        Colors.cyan,
                                        BlendMode.srcIn,
                                      ),
                                      semanticsLabel: 'A quote',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                  Expanded(
                                    child: AutoSizeText(
                                      engText,
                                      textAlign: TextAlign.center,
                                    ).boldSubString(
                                      searchText,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  // TextHighlight(
                                  //   textAlign: TextAlign.center,
                                  //   text: engText,
                                  //   words: words,
                                  //   textStyle: TextStyle(
                                  //     fontSize: engText.length > 150 ? 16 : 20,
                                  //     fontWeight: FontWeight.w400,
                                  //   ),
                                  // ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Image.network(
                                    'https://static.sadhguru.org/d/46272/1663654954-signature_name.png',
                                    height: 50.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                // Text('${engText.length}'),
                announcement.isNotEmpty &&
                        DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                            DateFormat('yyyy-MM-dd').format(date!)
                    ? Text(
                        announcement,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      )
                    : const Text('')
              ],
            ),
          );
  }
}
