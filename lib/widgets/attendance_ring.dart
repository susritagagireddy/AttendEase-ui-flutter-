import 'package:flutter/material.dart';

Color statusColor(double pct, double target) {
  if (pct >= target) return Colors.green;
  if (pct >= target - 5) return Colors.orange;
  return Colors.red;
}

class AttendanceRing extends StatelessWidget {
  final double percent;
  final double target;
  final bool hasData;
  final double size;

  const AttendanceRing({
    super.key,
    required this.percent,
    required this.target,
    required this.hasData,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasData ? statusColor(percent, target) : Colors.grey;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: hasData ? (percent / 100).clamp(0.0, 1.0) : 0,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade300,
              color: color,
            ),
          ),
          Text(
            hasData ? '${percent.toStringAsFixed(1)}%' : '--',
            style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
