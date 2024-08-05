import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

extension BoldSubString on AutoSizeText {
  AutoSizeText boldSubString(String target, {TextStyle? style}) {
    final textSpans = List<TextSpan>.empty(growable: true);
    final escapedTarget = RegExp.escape(target);
    final pattern = RegExp(escapedTarget, caseSensitive: false);
    final matches = pattern.allMatches(data!);

    int currentIndex = 0;
    for (final match in matches) {
      final beforeMatch = data!.substring(currentIndex, match.start);
      if (beforeMatch.isNotEmpty) {
        textSpans.add(TextSpan(text: beforeMatch, style: style));
      }

      final matchedText = data!.substring(match.start, match.end);
      textSpans.add(
        TextSpan(
          text: matchedText,
          style: (style ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < data!.length) {
      final remainingText = data!.substring(currentIndex);
      textSpans.add(TextSpan(text: remainingText, style: style));
    }

    return AutoSizeText.rich(
      TextSpan(children: textSpans),
      style: style,
      minFontSize: minFontSize,
      stepGranularity: stepGranularity,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: TextAlign.center,
    );
  }
}
