import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../services/auth_service.dart';
import '../widgets/unit_painter.dart';

/// The main dashboard screen that displays the real-time status of all rooms.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String? _selectedStatus; // null means 'All'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('40-Bed Surgery Unit Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // AuthGate will handle navigation
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                    child: Text('No room data found. Please run the seed script.'),
                  );
                }

                // 1. Convert to Room objects
                var rooms = snapshot.data!.docs.map((doc) => Room.fromFirestore(doc)).toList();

                // 2. Apply filters
                if (_selectedStatus != null) {
                  rooms = rooms.where((room) => room.status == _selectedStatus).toList();
                }

                // 3. Apply search
                if (_searchQuery.isNotEmpty) {
                  rooms = rooms.where((room) {
                    final query = _searchQuery.toLowerCase();
                    return room.roomId.toLowerCase().contains(query) ||
                        (room.assignedNurse?.toLowerCase().contains(query) ?? false) ||
                        (room.surgeonName?.toLowerCase().contains(query) ?? false);
                  }).toList();
                }

                return InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: GestureDetector(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: UnitPainter(rooms: rooms, context: context),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the search bar and filter chips.
  Widget _buildControls() {
    final statuses = ['cleaned', 'occupied', 'in_surgery', 'back_from_surgery', 'discharged'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by Room #, Nurse, or Surgeon',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
              ),
              ...statuses.map((status) => ChoiceChip(
                    label: Text(status.replaceAll('_', ' ').toUpperCase()),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });
                    },
                  )),
            ],
          )
        ],
      ),
    );
  }
}
