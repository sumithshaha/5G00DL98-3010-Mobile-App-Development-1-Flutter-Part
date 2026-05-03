// lib/student.dart
//
// Firestore-flavored Student. Two changes from the SQLite version:
//
//   1. `id` is a String now (Firestore document IDs are strings). For new
//      students we let Firestore auto-generate the ID via .add(); id is
//      empty until the document has actually been written.
//
//   2. The id is NOT stored inside the document body — Firestore tracks
//      the doc ID separately as a reference. So toMap returns just the
//      data fields, and fromMap takes the id as a separate argument.

class Student {
  final String id;
  final String firstName;
  final String lastName;

  const Student({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toMap() => {
        'firstname': firstName,
        'lastname': lastName,
      };

  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id,
      firstName: (map['firstname'] as String?) ?? '',
      lastName: (map['lastname'] as String?) ?? '',
    );
  }

  Student copyWith({String? firstName, String? lastName}) => Student(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
      );
}
