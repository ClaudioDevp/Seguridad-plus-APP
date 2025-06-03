
import 'package:seguridad_plus/models/alarm_model.dart';
import 'package:seguridad_plus/models/location_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String municipalityId;
  final LocationModel location;
  final bool activeAlarm;
  final bool answeredAlarm;
  final AlarmModel? alarm;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.municipalityId,
    required this.location,
    required this.activeAlarm,
    required this.answeredAlarm,
    this.alarm,
  });

  // JSON → UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      municipalityId: json['municipality_id'],
      location: LocationModel.fromJson(json['location']),
      activeAlarm: json['active_alarm'],
      answeredAlarm: json['answered_alarm'],
      alarm: json['alarm'] != null ? AlarmModel.fromJson(json['alarm']) : null,
    );
  }

  // UserModel → JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'municipality_id': municipalityId,
      'location': location.toJson(),
      'active_alarm': activeAlarm,
      'answered_alarm': answeredAlarm,
      'alarm': alarm?.toJson(),
    };
  }
}
