class Student {
  final int id;
  final String firstName;
  final String lastName;

  const Student({required this.id, required this.firstName, required this.lastName});

  Map<String, Object?> toMap() {
    var map = <String, dynamic>{
      'firstname': firstName,
      'lastname': lastName,
    };

    if (id != 0) map['id'] = id;

    return map;
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int,
      firstName: map['firstname'] as String,
      lastName: map['lastname'] as String,
    );
  }
}
