import 'package:equatable/equatable.dart';

/// One value per body segment (kg, %, or a level code depending on use).
class SegmentalValues extends Equatable {
  const SegmentalValues({
    required this.trunk,
    required this.rightArm,
    required this.leftArm,
    required this.rightLeg,
    required this.leftLeg,
  });

  final double trunk;
  final double rightArm;
  final double leftArm;
  final double rightLeg;
  final double leftLeg;

  @override
  List<Object?> get props => [trunk, rightArm, leftArm, rightLeg, leftLeg];
}

/// Segmental muscle/fat data of one measurement. Levels are optional (see OPEN_QUESTIONS Q5).
class Segmental extends Equatable {
  const Segmental({
    required this.muscle,
    required this.fat,
    this.fatPercent,
    this.fatLevel,
    this.leanLevel,
  });

  final SegmentalValues muscle; // kg
  final SegmentalValues fat; // kg
  final SegmentalValues? fatPercent; // %
  final SegmentalValues? fatLevel; // raw device grade
  final SegmentalValues? leanLevel; // raw device grade

  @override
  List<Object?> get props => [muscle, fat, fatPercent, fatLevel, leanLevel];
}
