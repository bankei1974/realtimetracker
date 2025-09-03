import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

/// A screen to display and edit the details of a single room.
class RoomDetailScreen extends StatefulWidget {
  final String roomId; // Firestore document ID, e.g., "room_1"

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late DocumentReference<Map<String, dynamic>> _roomRef;

  @override
  void initState() {
    super.initState();
    _roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _roomRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }

        final room = Room.fromFirestore(snapshot.data!);

        return Scaffold(
          appBar: AppBar(
            title: Text('Room ${room.roomId} Details'),
            backgroundColor: room.statusColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildStatusDropdown(room),
                const SizedBox(height: 20),
                _buildInfoCard(room),
                const SizedBox(height: 20),
                _buildChecklistCard(room),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the dropdown for changing the room's status.
  Widget _buildStatusDropdown(Room room) {
    final statuses = ['occupied', 'in_surgery', 'back_from_surgery', 'discharged', 'cleaned'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: room.status,
          decoration: const InputDecoration(
            labelText: 'Room Status',
            border: InputBorder.none,
          ),
          items: statuses.map((status) {
            return DropdownMenuItem(value: status, child: Text(status.replaceAll('_', ' ').toUpperCase()));
          }).toList(),
          onChanged: (newStatus) {
            if (newStatus != null) {
              _updateStatus(room, newStatus);
            }
          },
        ),
      ),
    );
  }

  /// Builds the card displaying room info like times and readiness.
  Widget _buildInfoCard(Room room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Room Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ListTile(
              title: const Text('Ready for Surgery'),
              trailing: Text(room.isReady ? 'YES' : 'NO', style: TextStyle(color: room.isReady ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('Prep Time'),
              trailing: Text('${room.prepTimeMinutes} minutes'),
            ),
             ListTile(
              title: const Text('First Case'),
              trailing: Checkbox(
                value: room.isFirstCase,
                onChanged: (val) => _roomRef.update({'is_first_case': val}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the card with the pre-op checklist.
  Widget _buildChecklistCard(Room room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pre-Op Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            CheckboxListTile(
              title: const Text('MDA Seen'),
              value: room.mdaSeen,
              onChanged: (val) => _updateChecklist('mda_seen', val!, room),
            ),
            CheckboxListTile(
              title: const Text('APASS Nurse Seen'),
              value: room.apassSeen,
              onChanged: (val) => _updateChecklist('apass_seen', val!, room),
            ),
            CheckboxListTile(
              title: const Text('Pre-Op Nurse Seen'),
              value: room.preopSeen,
              onChanged: (val) => _updateChecklist('preop_seen', val!, room),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles the logic for updating a room's status.
  /// This includes setting the correct timestamp and calculating prep time.
  Future<void> _updateStatus(Room room, String newStatus) async {
    final now = DateTime.now().toIso8601String();
    final updateData = <String, dynamic>{'status': newStatus};

    // Set timestamps based on the new status
    switch (newStatus) {
      case 'occupied':
        updateData['entry_time'] = now;
        break;
      case 'in_surgery':
        updateData['surgery_depart_time'] = now;
        // Calculate prep time only when departing for surgery
        final entryTime = room.entryTime ?? DateTime.parse(now);
        final departTime = DateTime.parse(now);
        updateData['prep_time_minutes'] = Room.calculatePrepTime(entryTime, departTime);
        break;
      case 'back_from_surgery':
        updateData['surgery_return_time'] = now;
        break;
      case 'discharged':
        updateData['discharge_time'] = now;
        break;
      case 'cleaned':
        updateData['clean_time'] = now;
        // Reset all patient-specific data when room is cleaned
        updateData.addAll({
          'patient_id': null,
          'entry_time': null,
          'surgery_depart_time': null,
          'surgery_return_time': null,
          'discharge_time': null,
          'mda_seen': false,
          'apass_seen': false,
          'preop_seen': false,
          'is_first_case': false,
          'is_ready': false,
          'prep_time_minutes': 0,
        });
        break;
    }

    await _roomRef.update(updateData);
  }

  /// Updates a checklist item and re-evaluates the `is_ready` status.
  Future<void> _updateChecklist(String field, bool value, Room room) async {
    // Optimistically update the boolean
    final newMda = field == 'mda_seen' ? value : room.mdaSeen;
    final newApass = field == 'apass_seen' ? value : room.apassSeen;
    final newPreop = field == 'preop_seen' ? value : room.preopSeen;

    final isReady = newMda && newApass && newPreop;

    await _roomRef.update({
      field: value,
      'is_ready': isReady,
    });
  }
}
