import 'package:flutter/material.dart';
import '../models/room.dart';
import '../screens/room_detail_screen.dart';

/// A custom painter that draws the floor plan of the surgery unit.
/// It takes a list of rooms and renders them as a grid, handling tap events.
class UnitPainter extends CustomPainter {
  final List<Room> rooms;
  final BuildContext context;
  final int crossAxisCount = 5; // 5 rooms horizontally
  final double roomSpacing = 8.0;
  final double roomAspectRatio = 1.2;

  // Store the calculated layout to detect taps
  final Map<String, Rect> _roomRects = {};

  UnitPainter({required this.rooms, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final double roomWidth = (size.width - (crossAxisCount + 1) * roomSpacing) / crossAxisCount;
    final double roomHeight = roomWidth * roomAspectRatio;

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final int row = i ~/ crossAxisCount;
      final int col = i % crossAxisCount;

      final double x = col * (roomWidth + roomSpacing) + roomSpacing;
      final double y = row * (roomHeight + roomSpacing) + roomSpacing;

      final rect = Rect.fromLTWH(x, y, roomWidth, roomHeight);
      _roomRects[room.id] = rect;

      // Draw room rectangle
      final paint = Paint()
        ..color = room.statusColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);

      // Draw room border
      final borderPaint = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

      // Draw room text content
      _drawText(canvas, room, rect);
    }
  }

  void _drawText(Canvas canvas, Room room, Rect rect) {
    // Room Number
    final textPainter = TextPainter(
      text: TextSpan(
        text: room.roomId,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, rect.center - Offset(textPainter.width / 2, textPainter.height / 2));

    // Prep Time
    if (room.prepTimeMinutes > 0) {
      final prepTimePainter = TextPainter(
        text: TextSpan(
          text: '${room.prepTimeMinutes}min',
          style: const TextStyle(color: Colors.black87, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      prepTimePainter.layout();
      prepTimePainter.paint(canvas, rect.topLeft + const Offset(4, 4));
    }

    // Flags/Icons
    List<String> icons = [];
    if (room.isFirstCase) icons.add('★'); // Star for first case
    if (room.isReady) icons.add('👍'); // Thumbs up for ready
    if (room.mdaSeen) icons.add('M');
    if (room.apassSeen) icons.add('A');
    if (room.preopSeen) icons.add('P');

    final iconPainter = TextPainter(
      text: TextSpan(
        text: icons.join(' '),
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, rect.bottomRight - Offset(iconPainter.width + 4, iconPainter.height + 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever data changes
  }

  /// Override hitTest to enable tap detection on individual rooms.
  @override
  bool? hitTest(Offset position) {
    for (final entry in _roomRects.entries) {
      if (entry.value.contains(position)) {
        // If a room is tapped, navigate to its detail screen
        _navigateToRoomDetail(entry.key);
        return true;
      }
    }
    return false;
  }

  void _navigateToRoomDetail(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(roomId: roomId),
      ),
    );
  }
}
