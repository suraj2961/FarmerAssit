import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sell_advisory.dart';

class PriceTrendChart extends StatefulWidget {
  final List<PricePoint> history;
  final List<ForecastPoint> forecast;
  final Color primaryColor;
  final Color forecastColor;

  const PriceTrendChart({
    super.key,
    required this.history,
    required this.forecast,
    this.primaryColor = const Color(0xFF1C5A2C),
    this.forecastColor = const Color(0xFFD97706),
  });

  @override
  State<PriceTrendChart> createState() => _PriceTrendChartState();
}

class _PriceTrendChartState extends State<PriceTrendChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty && widget.forecast.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No price trend data available')),
      );
    }

    // Build unified data list
    final allPoints = <_ChartNode>[];
    for (int i = 0; i < widget.history.length; i++) {
      allPoints.add(_ChartNode(
        date: widget.history[i].date,
        price: widget.history[i].modalPrice,
        isForecast: false,
      ));
    }

    // If forecast is empty, generate projected 7-day linear forecast automatically
    final effectiveForecast = <ForecastPoint>[...widget.forecast];
    if (effectiveForecast.isEmpty && allPoints.isNotEmpty) {
      final lastPrice = allPoints.last.price;
      final firstPrice = allPoints.first.price;
      final slope = allPoints.length > 1
          ? (lastPrice - firstPrice) / (allPoints.length - 1)
          : 0.0;
      final now = DateTime.now();

      for (int i = 1; i <= 7; i++) {
        final fDate = now.add(Duration(days: i));
        final exp = (lastPrice + (slope * i)).roundToDouble();
        final margin = exp * 0.035 * sqrt(i);
        effectiveForecast.add(ForecastPoint(
          date: '${fDate.day.toString().padLeft(2, '0')} ${_monthName(fDate.month)}',
          expectedPrice: exp,
          lowerBound: (exp - margin).roundToDouble(),
          upperBound: (exp + margin).roundToDouble(),
        ));
      }
    }

    for (int i = 0; i < effectiveForecast.length; i++) {
      allPoints.add(_ChartNode(
        date: effectiveForecast[i].date,
        price: effectiveForecast[i].expectedPrice,
        lower: effectiveForecast[i].lowerBound,
        upper: effectiveForecast[i].upperBound,
        isForecast: true,
      ));
    }

    final rawPrices = allPoints.map((p) => p.price).toList();
    final rawMin = rawPrices.reduce(min);
    final rawMax = rawPrices.reduce(max);

    // Add 8% vertical breathing space so curve doesn't clip top/bottom
    final span = max(50.0, rawMax - rawMin);
    final minPrice = max(0.0, rawMin - (span * 0.08));
    final maxPrice = rawMax + (span * 0.08);
    final priceRange = max(1.0, maxPrice - minPrice);

    final selectedNode = _selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < allPoints.length
        ? allPoints[_selectedIndex!]
        : allPoints.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interactive inspection header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedNode.isForecast
                              ? widget.forecastColor
                              : widget.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          selectedNode.isForecast
                              ? 'ML Forecast (ಮುನ್ಸೂಚನೆ)'
                              : 'Mandi Rate (ಮಾರುಕಟ್ಟೆ ದರ)',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selectedNode.isForecast
                                ? widget.forecastColor
                                : widget.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        '₹${selectedNode.price.toStringAsFixed(0)}',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: selectedNode.isForecast
                                  ? widget.forecastColor
                                  : widget.primaryColor,
                        ),
                      ),
                      Text(
                        '/ Quintal',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (selectedNode.lower != null && selectedNode.upper != null)
                        Text(
                          '(₹${selectedNode.lower!.toStringAsFixed(0)} - ₹${selectedNode.upper!.toStringAsFixed(0)})',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (selectedNode.isForecast
                        ? widget.forecastColor
                        : widget.primaryColor)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (selectedNode.isForecast
                          ? widget.forecastColor
                          : widget.primaryColor)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 13,
                    color: selectedNode.isForecast
                        ? widget.forecastColor
                        : widget.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    selectedNode.date,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selectedNode.isForecast
                          ? widget.forecastColor
                          : widget.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Custom painter chart canvas with Desktop Hover + Touch Drag
        SizedBox(
          height: 190,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onHover: (event) => _updateTouchIndex(
                  event.localPosition.dx,
                  constraints.maxWidth,
                  allPoints.length,
                ),
                child: GestureDetector(
                  onTapDown: (details) => _updateTouchIndex(
                    details.localPosition.dx,
                    constraints.maxWidth,
                    allPoints.length,
                  ),
                  onPanDown: (details) => _updateTouchIndex(
                    details.localPosition.dx,
                    constraints.maxWidth,
                    allPoints.length,
                  ),
                  onPanUpdate: (details) => _updateTouchIndex(
                    details.localPosition.dx,
                    constraints.maxWidth,
                    allPoints.length,
                  ),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 190),
                    painter: _ChartPainter(
                      nodes: allPoints,
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                      priceRange: priceRange,
                      selectedIndex: _selectedIndex ?? (allPoints.length - 1),
                      primaryColor: widget.primaryColor,
                      forecastColor: widget.forecastColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Legend & Explanations (Wraps gracefully on mobile screens)
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              _legendItem(
                color: widget.primaryColor,
                label: 'Historical (ಹಿಂದಿನ ದರ)',
                isDashed: false,
              ),
              _legendItem(
                color: widget.forecastColor,
                label: '7D Forecast (ಮುನ್ಸೂಚನೆ)',
                isDashed: true,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.forecastColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: widget.forecastColor.withValues(alpha: 0.4)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Range (±σ)',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateTouchIndex(double touchX, double width, int count) {
    if (count <= 1 || width <= 0) return;
    final fraction = (touchX / width).clamp(0.0, 1.0);
    final index = (fraction * (count - 1)).round();
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  static String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[month - 1];
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required bool isDashed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _ChartNode {
  final String date;
  final double price;
  final double? lower;
  final double? upper;
  final bool isForecast;

  _ChartNode({
    required this.date,
    required this.price,
    this.lower,
    this.upper,
    required this.isForecast,
  });
}

class _ChartPainter extends CustomPainter {
  final List<_ChartNode> nodes;
  final double minPrice;
  final double maxPrice;
  final double priceRange;
  final int selectedIndex;
  final Color primaryColor;
  final Color forecastColor;

  _ChartPainter({
    required this.nodes,
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
    required this.selectedIndex,
    required this.primaryColor,
    required this.forecastColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final paddingBottom = 22.0;
    final paddingTop = 15.0;
    final chartHeight = size.height - paddingBottom - paddingTop;
    final stepX = nodes.length > 1 ? size.width / (nodes.length - 1) : size.width / 2;

    // Draw horizontal grid lines & price values
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + (chartHeight * (i / 3));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Price tag label
      final priceVal = maxPrice - ((priceRange) * (i / 3));
      final tp = TextPainter(
        text: TextSpan(
          text: '₹${priceVal.round()}',
          style: TextStyle(fontSize: 9.5, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - 12));
    }

    final points = <Offset>[];
    int forecastStartIndex = -1;

    for (int i = 0; i < nodes.length; i++) {
      final x = nodes.length > 1 ? i * stepX : size.width / 2;
      final normalizedY = (nodes[i].price - minPrice) / priceRange;
      final y = paddingTop + chartHeight * (1.0 - normalizedY.clamp(0.0, 1.0));
      points.add(Offset(x, y));
      if (nodes[i].isForecast && forecastStartIndex == -1) {
        forecastStartIndex = i;
      }
    }

    // Historical actuals curve
    final histPath = Path();
    final histPointsCount = forecastStartIndex == -1 ? points.length : forecastStartIndex;

    if (histPointsCount > 0) {
      histPath.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < histPointsCount; i++) {
        histPath.lineTo(points[i].dx, points[i].dy);
      }

      // If forecast exists, bridge cleanly from last actual to first forecast
      if (forecastStartIndex != -1 && forecastStartIndex < points.length) {
        histPath.lineTo(points[forecastStartIndex].dx, points[forecastStartIndex].dy);
      }

      final histPaint = Paint()
        ..color = primaryColor
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(histPath, histPaint);

      // Gradient area under historical curve
      final fillPath = Path.from(histPath);
      final lastX = forecastStartIndex != -1 && forecastStartIndex < points.length
          ? points[forecastStartIndex].dx
          : points[histPointsCount - 1].dx;
      fillPath.lineTo(lastX, size.height - paddingBottom);
      fillPath.lineTo(points[0].dx, size.height - paddingBottom);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.22),
            primaryColor.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartHeight))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // 7-Day ML Forecast Projection (dashed effect + confidence corridor)
    if (forecastStartIndex != -1 && forecastStartIndex < points.length) {
      // 1. Shaded Confidence Corridor
      final corridorPath = Path();
      bool corridorStarted = false;

      for (int i = forecastStartIndex; i < nodes.length; i++) {
        final node = nodes[i];
        final upperVal = node.upper ?? node.price;
        final normUpper = (upperVal - minPrice) / priceRange;
        final yUpper = paddingTop + chartHeight * (1.0 - normUpper.clamp(0.0, 1.0));

        if (!corridorStarted) {
          corridorPath.moveTo(points[i].dx, yUpper);
          corridorStarted = true;
        } else {
          corridorPath.lineTo(points[i].dx, yUpper);
        }
      }

      for (int i = nodes.length - 1; i >= forecastStartIndex; i--) {
        final node = nodes[i];
        final lowerVal = node.lower ?? node.price;
        final normLower = (lowerVal - minPrice) / priceRange;
        final yLower = paddingTop + chartHeight * (1.0 - normLower.clamp(0.0, 1.0));
        corridorPath.lineTo(points[i].dx, yLower);
      }
      corridorPath.close();

      final corridorPaint = Paint()
        ..color = forecastColor.withValues(alpha: 0.14)
        ..style = PaintingStyle.fill;
      canvas.drawPath(corridorPath, corridorPaint);

      // 2. Dashed Forecast Line
      final forecastPath = Path();
      final startIdx = max(0, forecastStartIndex - 1);
      forecastPath.moveTo(points[startIdx].dx, points[startIdx].dy);

      for (int i = forecastStartIndex; i < points.length; i++) {
        forecastPath.lineTo(points[i].dx, points[i].dy);
      }

      final forecastPaint = Paint()
        ..color = forecastColor
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      _drawDashedPath(canvas, forecastPath, forecastPaint, 6.0, 4.0);
    }

    // Date Labels at Bottom
    if (nodes.isNotEmpty) {
      // Start date
      _drawDateLabel(canvas, nodes.first.date, points.first.dx, size.height - paddingBottom + 6);
      // Forecast split marker or mid
      if (forecastStartIndex > 0 && forecastStartIndex < nodes.length) {
        _drawDateLabel(canvas, 'Forecast Start', points[forecastStartIndex].dx - 30, size.height - paddingBottom + 6);
      }
      // End date
      _drawDateLabel(canvas, nodes.last.date, points.last.dx - 40, size.height - paddingBottom + 6);
    }

    // Active Scrubber Indicator
    if (selectedIndex >= 0 && selectedIndex < points.length) {
      final selPoint = points[selectedIndex];
      final isFc = nodes[selectedIndex].isForecast;
      final activeColor = isFc ? forecastColor : primaryColor;

      // Vertical guide line
      final scrubPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.45)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(selPoint.dx, paddingTop),
        Offset(selPoint.dx, size.height - paddingBottom),
        scrubPaint,
      );

      // Outer glow halo
      canvas.drawCircle(
        selPoint,
        8.0,
        Paint()..color = activeColor.withValues(alpha: 0.28),
      );

      // Center solid dot
      canvas.drawCircle(
        selPoint,
        5.0,
        Paint()..color = activeColor,
      );

      // Inner white pin
      canvas.drawCircle(
        selPoint,
        2.2,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawDateLabel(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x.clamp(0.0, 1000.0), y));
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = min(dashWidth, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.nodes != nodes ||
        oldDelegate.priceRange != priceRange;
  }
}
