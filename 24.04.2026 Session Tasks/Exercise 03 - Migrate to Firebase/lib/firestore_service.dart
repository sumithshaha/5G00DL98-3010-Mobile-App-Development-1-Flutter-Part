// lib/firestore_service.dart
//
// Firestore replacement for the SQLite DatabaseService. I deliberately kept
// the same method names and overall shape — insertStudent, students,
// findByName, updateStudent, deleteStudent, populateData — so the screens
// barely need to change. That's the value of a service layer: swap the
// implementation, leave the consumers alone.
//
// Three things genuinely change moving from SQLite to Firestore:
//
//   1. There's no schema definition. SQLite needed CREATE TABLE; Firestore
//      collections come into existence the moment you write your first
//      document. Quick to prototype with, more dangerous for data
//      integrity later.
//
//   2. IDs go from auto-incrementing ints to opaque random strings.
//      Firestore's .add() returns a DocumentReference whose .id is the
//      new ID; we need to read it back into the Student.
//
//   3. There's a real network in the loop. Every operation is async over
//      the wire (or to a local cache when offline — Firestore queues
//      writes during disconnects and replays them on reconnection).
//
// I'm using the same singleton pattern the SQLite service used, for parity.
// FirebaseFirestore.instance is itself a singleton internally, so this is
// mostly cosmetic.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // A "collection" in Firestore is the namespace for documents — close
  // analog to a SQL table.
  final CollectionReference<Map<String, dynamic>> _students =
      FirebaseFirestore.instance.collection('students');

  // ─────────── CREATE ───────────
  /// Add a new student. .add() generates the ID; we return a fresh Student
  /// with that ID set so the caller can immediately use it.
  Future<Student> insertStudent(Student student) async {
    final ref = await _students.add(student.toMap());
    return Student(
      id: ref.id,
      firstName: student.firstName,
      lastName: student.lastName,
    );
  }

  // ─────────── READ ALL ───────────
  /// One-shot fetch of every student. Used when populateData kicks off
  /// and for the search filter. The home screen uses studentStream
  /// instead, which is more idiomatic for Firestore.
  Future<List<Student>> students() async {
    final snap = await _students.orderBy('lastname').get();
    return snap.docs
        .map((d) => Student.fromMap(d.id, d.data()))
        .toList(growable: false);
  }

  // ─────────── REALTIME STREAM ───────────
  /// Firestore's killer feature: a Stream that fires every time the
  /// collection changes. Pair with StreamBuilder in the UI for automatic
  /// re-rendering — much cleaner than the setState-after-fetch pattern
  /// the SQLite version had to use.
  Stream<List<Student>> studentStream() {
    return _students.orderBy('lastname').snapshots().map(
          (snap) => snap.docs
              .map((d) => Student.fromMap(d.id, d.data()))
              .toList(growable: false),
        );
  }

  // ─────────── READ FILTERED ───────────
  /// Last-name prefix search. Firestore has no SQL LIKE; the standard
  /// trick is a range query bounded by the Unicode replacement character
  /// \uf8ff, which sorts after virtually every printable string. So
  /// "Br" matches everything from "Br" up to "Br\uf8ff" — i.e. anything
  /// starting with "Br".
  Future<List<Student>> findByName(String prefix) async {
    if (prefix.isEmpty) return students();
    final snap = await _students
        .where('lastname', isGreaterThanOrEqualTo: prefix)
        .where('lastname', isLessThan: '$prefix\uf8ff')
        .orderBy('lastname')
        .get();
    return snap.docs
        .map((d) => Student.fromMap(d.id, d.data()))
        .toList(growable: false);
  }

  // ─────────── UPDATE ───────────
  Future<void> updateStudent(Student student) async {
    if (student.id.isEmpty) {
      throw ArgumentError('Cannot update a student with no id');
    }
    await _students.doc(student.id).update(student.toMap());
  }

  // ─────────── DELETE ───────────
  Future<void> deleteStudent(String id) async {
    await _students.doc(id).delete();
  }

  // ─────────── seed sample data ───────────
  /// Insert a few starter students on first run, only if the collection
  /// is empty. Uses a batch write so the four samples land atomically —
  /// either they all succeed or none do.
  Future<void> populateData() async {
    final existing = await _students.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    const samples = [
      Student(id: '', firstName: 'Max', lastName: 'Mustermann'),
      Student(id: '', firstName: 'Anna', lastName: 'Schmidt'),
      Student(id: '', firstName: 'Lisa', lastName: 'Braun'),
      Student(id: '', firstName: 'Jonas', lastName: 'Bauer'),
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (final s in samples) {
      batch.set(_students.doc(), s.toMap());
    }
    await batch.commit();
  }
}
