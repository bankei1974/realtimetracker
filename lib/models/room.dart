import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents the data model for a single room in the surgery unit.
/// This class includes logic for serialization from/to Firestore and
/// helper methods for UI display.
class Room {
  final String id; // Document ID from Firestore (e.g., "room_1")
  final String roomId; // User-facing room number (e.g., "1")
  final String? patientId;
  final String status;
  final DateTime? entryTime;
  final DateTime? surgeryDepartTime;
  final DateTime? surgeryReturnTime;
  final DateTime? dischargeTime;
  final DateTime? cleanTime;
  final bool mdaSeen;
  final bool apassSeen;
  final bool preopSeen;
  final bool isFirstCase;
  final int prepTimeMinutes;

  // New fields for staff and procedure info
  final String? assignedNurse;
  final String? procedureType;
  final String? surgeonName;

  Room({
    required this.id,
    required this.roomId,
    this.patientId,
    required this.status,
    this.entryTime,
    this.surgeryDepartTime,
    this.surgeryReturnTime,
    this.dischargeTime,
    this.cleanTime,
    required this.mdaSeen,
    required this.apassSeen,
    required this.preopSeen,
    required this.isFirstCase,
    required this.prepTimeMinutes,
    this.assignedNurse,
    this.procedureType,
    this.surgeonName,
  });

  /// Computes whether the room is ready for surgery.
  /// This is true if all necessary pre-op checks are completed.
  bool get isReady => mdaSeen && apassSeen && preopSeen;

  /// Factory constructor to create a Room instance from a Firestore document.
  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      roomId: data['room_id'] ?? '',
      patientId: data['patient_id'],
      status: data['status'] ?? 'cleaned',
      entryTime: _parseDate(data['entry_time']),
      surgeryDepartTime: _parseDate(data['surgery_depart_time']),
      surgeryReturnTime: _parseDate(data['surgery_return_time']),
      dischargeTime: _parseDate(data['discharge_time']),
      cleanTime: _parseDate(data['clean_time']),
      mdaSeen: data['mda_seen'] ?? false,
      apassSeen: data['apass_seen'] ?? false,
      preopSeen: data['preop_seen'] ?? false,
      isFirstCase: data['is_first_case'] ?? false,
      prepTimeMinutes: data['prep_time_minutes'] ?? 0,
      assignedNurse: data['assigned_nurse'],
      procedureType: data['procedure_type'],
      surgeonName: data['surgeon_name'],
    );
  }

  /// Converts a Room instance into a map for writing to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'room_id': roomId,
      'patient_id': patientId,
      'status': status,
      'entry_time': entryTime?.toIso8601String(),
      'surgery_depart_time': surgeryDepartTime?.toIso8601String(),
      'surgery_return_time': surgeryReturnTime?.toIso8601String(),
      'discharge_time': dischargeTime?.toIso8601String(),
      'clean_time': cleanTime?.toIso8601String(),
      'mda_seen': mdaSeen,
      'apass_seen': apassSeen,
      'preop_seen': preopSeen,
      'is_first_case': isFirstCase,
      'is_ready': isReady, // Also write the computed property
      'prep_time_minutes': prepTimeMinutes,
      'assigned_nurse': assignedNurse,
      'procedure_type': procedureType,
      'surgeon_name': surgeonName,
    };
  }

  /// Helper to safely parse ISO8601 strings to DateTime objects.
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Helper to get the display color for the current room status.
  Color get statusColor {
    switch (status) {
      case 'occupied':
        return Colors.green;
      case 'in_surgery':
        return Colors.yellow;
      case 'back_from_surgery':
        return Colors.purple;
      case 'discharged':
        return Colors.grey;
      case 'cleaned':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  /// Helper to calculate prep time.
  /// Returns the duration in minutes between entry and surgery departure.
  static int calculatePrepTime(DateTime? entry, DateTime? departure) {
    if (entry == null || departure == null) {
      return 0;
    }
    return departure.difference(entry).inMinutes;
  }
}
