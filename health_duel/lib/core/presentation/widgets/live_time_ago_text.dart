import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';

/// Live Time Ago Text
///
/// Displays a relative time string (e.g. "5m ago") that updates automatically.
/// Uses a timer to refresh the text every minute.
class LiveTimeAgoText extends StatefulWidget {
  const LiveTimeAgoText(
    this.dateTime, {
    this.style,
    this.prefix = '',
    this.suffix = '',
    super.key,
  });

  final DateTime dateTime;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  @override
  State<LiveTimeAgoText> createState() => _LiveTimeAgoTextState();
}

class _LiveTimeAgoTextState extends State<LiveTimeAgoText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Refresh every minute
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix}${widget.dateTime.relativeTime}${widget.suffix}',
      style: widget.style,
    );
  }
}
