import 'package:equatable/equatable.dart';

class Person extends Equatable {
  const Person({
    required this.name,
    required this.id,
    required this.gender,
    required this.heightCm,
    this.birthday,
  });

  final String name;
  final String id;
  final String gender;
  final double heightCm;
  final DateTime? birthday;

  /// Full years at [date], or null when the birthday is unknown.
  int? ageAt(DateTime date) {
    final b = birthday;
    if (b == null) return null;
    var age = date.year - b.year;
    if (date.month < b.month || (date.month == b.month && date.day < b.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [name, id, gender, heightCm, birthday];
}
