class AlarmModel {
  final DateTime createdTime;
  final String type;
  final String answeredBy;
  final DateTime? answeredTime;

  AlarmModel({
    DateTime? createdTime,
    String? answeredBy,
    required this.type,
    this.answeredTime,
  }) :  createdTime = createdTime ?? DateTime.now(),
        answeredBy = answeredBy ?? "nobody";

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      createdTime: json["createdTime"],
      type: json["type"],
      answeredBy: json["answeredBy"],
      answeredTime: json["answeredTime"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "createdTime": createdTime,
      "type": type,
      "answeredBy": answeredBy,
      "answeredTime": answeredTime,
    };
  }
}
