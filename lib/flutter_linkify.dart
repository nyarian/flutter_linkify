import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';

export 'package:linkify/linkify.dart'
    show
        LinkifyElement,
        LinkableElement,
        LinkElement,
        EmailElement,
        TextElement,
        LinkType;

/// Callback clicked link
typedef LinkCallback(LinkableElement link);

/// Turns URLs into links
class Linkify extends StatelessWidget {
  /// Text to be linkified
  final String text;

  /// Enables some types of links (URL, email).
  /// Will default to all (if `null`).
  final List<LinkType> linkTypes;

  /// Callback for tapping a link
  final LinkCallback onOpen;

  /// Removes http/https from shown URLS.
  /// Will default to `false` (if `null`)
  final bool humanize;

  // TextSpan
  final TextSpanFactory spanFactory;

  /// Style for non-link text
  final TextStyle style;

  /// Style of link text
  final TextStyle linkStyle;

  // RichText

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// Text direction of the text
  final TextDirection textDirection;

  final int maxLines;
  final TextOverflow overflow;

  /// Text scale factor
  final double textScaleFactor;

  const Linkify({
    Key key,
    this.text,
    this.linkTypes,
    this.onOpen,
    this.humanize,
    this.spanFactory,
    // TextSpawn
    this.style = const TextStyle(),
    this.linkStyle = const TextStyle(),
    // RichText
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<LinkifyElement> elements = linkify(
      text,
      humanize: humanize,
      linkTypes: linkTypes,
    );

    return RichText(
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textScaleFactor:
          textScaleFactor ?? MediaQuery.of(context).textScaleFactor,
      text: buildTextSpan(
        elements,
        textSpanFactory: spanFactory,
        style: style,
        onOpen: onOpen,
        linkStyle: style
            .copyWith(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            )
            .merge(linkStyle),
      ),
    );
  }
}

/// Raw TextSpan builder for more control on the RichText
TextSpan buildTextSpan(List<LinkifyElement> elements,
    {TextStyle style,
    TextStyle linkStyle,
    LinkCallback onOpen,
    TextSpanFactory textSpanFactory}) {
  final TextSpanFactory spanFactory = textSpanFactory ??
      (String text, TextStyle style) => [
            TextSpan(
              text: text,
              style: style,
            )
          ];
  final List<TextSpan> result = <TextSpan>[];
  for (int i = 0; i < elements.length; i++) {
    final LinkifyElement element = elements[i];
    if (element is LinkableElement) {
      result.add(TextSpan(
        text: element.text,
        style: linkStyle,
        recognizer: onOpen != null
            ? (TapGestureRecognizer()..onTap = () => onOpen(element))
            : null,
      ));
    } else {
      result.addAll(spanFactory(element.text, style));
    }
  }
  return TextSpan(children: result);
}

typedef TextSpanFactory = List<TextSpan> Function(String text, TextStyle style);
