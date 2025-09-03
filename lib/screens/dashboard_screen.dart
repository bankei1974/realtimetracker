import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../widgets/unit_painter.dart';

/// The main dashboard screen that displays the real-time status of all rooms.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('40-Bed Surgery Unit Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the 'rooms' collection and order by room_id to ensure consistent layout
        stream: FirebaseFirestore.instance.collection('rooms').orderBy('room_id').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No room data found. Please run the seed script.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Convert Firestore documents into a list of Room objects
          final rooms = snapshot.data!.docs.map((doc) => Room.fromFirestore(doc)).toList();

          // Use InteractiveViewer to allow zooming and panning of the floor plan
          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 0.5,
            maxScale: 4.0,
            child: GestureDetector(
              // The painter itself will handle hit testing and navigation
              child: CustomPaint(
                size: Size.infinite, // Allow the painter to take up available space
                painter: UnitPainter(rooms: rooms, context: context),
              ),
            ),
          );
        },
      ),
    );
  }
}
