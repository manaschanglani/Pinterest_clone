import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String username;
  final String gender;
  final String location;
  final DateTime dob;
  final List<String> topics;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.gender,
    required this.location,
    required this.dob,
    required this.topics,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'gender': gender,
      'location': location,
      'dob': Timestamp.fromDate(dob),
      'topics': topics,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      gender: map['gender'],
      location: map['location'],
      dob: (map['dob'] as Timestamp).toDate(),
      topics: List<String>.from(map['topics']),
    );
  }
}
