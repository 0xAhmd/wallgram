import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkify/linkify.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines = 4,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  bool get _shouldTrim =>
      widget.text.length > 500 ||
      widget.text.split('\n').length > widget.maxLines;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  TextSpan _buildLinkifiedTextSpan(String text) {
    final elements = linkify(text);

    return TextSpan(
      children:
          elements.map((element) {
            if (element is LinkableElement) {
              return TextSpan(
                text: element.text,
                style: widget.style?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        final uri = Uri.tryParse(element.url);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        }
                      },
              );
            } else {
              return TextSpan(text: element.text, style: widget.style);
            }
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            _buildLinkifiedTextSpan(widget.text),
            maxLines: _isExpanded ? null : widget.maxLines,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            textAlign: widget.textAlign,
          ),
          if (_shouldTrim)
            GestureDetector(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _isExpanded ? "Read less" : "Read more",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
