import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedButton extends StatefulWidget {
  final double size;
  final Duration feedInterval;

  const FeedButton({super.key, required this.size, required this.feedInterval});

  @override
  State<FeedButton> createState() => _FeedButtonState();
}

class _FeedButtonState extends State<FeedButton> {
  late Timer _timer;
  late DateTime _lastFed;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _lastFed = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final p =
          1 -
          DateTime.now().difference(_lastFed).inSeconds /
              widget.feedInterval.inSeconds;
      setState(() => _progress = p.clamp(0.0, 1.0));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _feed() {
    setState(() {
      _lastFed = DateTime.now();
      _progress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _feed,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CircleProgressPainter(progress: _progress),
            ),
            SvgPicture.asset(
              _progress > 0
                  ? 'assets/images/full_bowl.svg'
                  : 'assets/images/empty_bowl.svg',
              width: widget.size * 0.5,
            ),
            if (_progress == 0)
              Positioned(
                top: -widget.size * 0.05,
                right: -widget.size * 0.05,
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: widget.size * 0.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;

  _CircleProgressPainter({required this.progress});

  Color _getColor(double p) {
    if (p > 0.4) return Colors.green;
    if (p > 0.2) return Colors.orange;
    return Colors.red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    final bg =
        Paint()
          ..color = Colors.black.withAlpha((255 * 0.1).toInt())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    final fg =
        Paint()
          ..color = _getColor(progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      -2 * pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter old) =>
      old.progress != progress;
}
