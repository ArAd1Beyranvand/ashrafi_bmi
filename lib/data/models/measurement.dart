import 'package:equatable/equatable.dart';

import 'segmental.dart';

class Measurement extends Equatable {
  const Measurement({
    required this.timestamp,
    required this.weight,
    required this.bmi,
    required this.visceralFat,
    required this.bodyFatPercent,
    required this.bodyFatMass,
    required this.smm,
    required this.leanMass,
    required this.bodyWaterPercent,
    required this.bodyAge,
    required this.bmr,
    required this.boneMass,
    required this.segmental,
  });

  final DateTime timestamp;
  final double weight;
  final double bmi;
  final double visceralFat;
  final double bodyFatPercent;
  final double bodyFatMass;
  final double smm;
  final double leanMass;
  final double bodyWaterPercent;
  final double bodyAge;
  final double bmr;
  final double boneMass;
  final Segmental segmental;

  @override
  List<Object?> get props => [
    timestamp,
    weight,
    bmi,
    visceralFat,
    bodyFatPercent,
    bodyFatMass,
    smm,
    leanMass,
    bodyWaterPercent,
    bodyAge,
    bmr,
    boneMass,
    segmental,
  ];
}
