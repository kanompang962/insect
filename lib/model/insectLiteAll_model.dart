import 'dart:convert';

class InsectLiteAllModel {
  final String usID;
  final String usName;
  final String usImg;
  final String usEmail;
  final String usType;
  final String inID;
  final String inImg;
  final String inName;
  final String inDate;
  final String inTime;
  final String inCounty;
  final String inDistrict;
  final String inProvince;
  final String inLat;
  final String inLng;
  InsectLiteAllModel({
    required this.usID,
    required this.usName,
    required this.usImg,
    required this.usEmail,
    required this.usType,
    required this.inID,
    required this.inImg,
    required this.inName,
    required this.inDate,
    required this.inTime,
    required this.inCounty,
    required this.inDistrict,
    required this.inProvince,
    required this.inLat,
    required this.inLng,
  });

  InsectLiteAllModel copyWith({
    String? usID,
    String? usName,
    String? usImg,
    String? usEmail,
    String? usType,
    String? inID,
    String? inImg,
    String? inName,
    String? inDate,
    String? inTime,
    String? inCounty,
    String? inDistrict,
    String? inProvince,
    String? inLat,
    String? inLng,
  }) {
    return InsectLiteAllModel(
      usID: usID ?? this.usID,
      usName: usName ?? this.usName,
      usImg: usImg ?? this.usImg,
      usEmail: usEmail ?? this.usEmail,
      usType: usType ?? this.usType,
      inID: inID ?? this.inID,
      inImg: inImg ?? this.inImg,
      inName: inName ?? this.inName,
      inDate: inDate ?? this.inDate,
      inTime: inTime ?? this.inTime,
      inCounty: inCounty ?? this.inCounty,
      inDistrict: inDistrict ?? this.inDistrict,
      inProvince: inProvince ?? this.inProvince,
      inLat: inLat ?? this.inLat,
      inLng: inLng ?? this.inLng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usID': usID,
      'usName': usName,
      'usImg': usImg,
      'usEmail': usEmail,
      'usType': usType,
      'inID': inID,
      'inImg': inImg,
      'inName': inName,
      'inDate': inDate,
      'inTime': inTime,
      'inCounty': inCounty,
      'inDistrict': inDistrict,
      'inProvince': inProvince,
      'inLat': inLat,
      'inLng': inLng,
    };
  }

  factory InsectLiteAllModel.fromMap(Map<String, dynamic> map) {
    return InsectLiteAllModel(
      usID: map['usID'] ?? '',
      usName: map['usName'] ?? '',
      usImg: map['usImg'] ?? '',
      usEmail: map['usEmail'] ?? '',
      usType: map['usType'] ?? '',
      inID: map['inID'] ?? '',
      inImg: map['inImg'] ?? '',
      inName: map['inName'] ?? '',
      inDate: map['inDate'] ?? '',
      inTime: map['inTime'] ?? '',
      inCounty: map['inCounty'] ?? '',
      inDistrict: map['inDistrict'] ?? '',
      inProvince: map['inProvince'] ?? '',
      inLat: map['inLat'] ?? '',
      inLng: map['inLng'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InsectLiteAllModel.fromJson(String source) =>
      InsectLiteAllModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InsectLiteAllModel(usID: $usID, usName: $usName, usImg: $usImg, usEmail: $usEmail, usType: $usType, inID: $inID, inImg: $inImg, inName: $inName, inDate: $inDate, inTime: $inTime, inCounty: $inCounty, inDistrict: $inDistrict, inProvince: $inProvince, inLat: $inLat, inLng: $inLng)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InsectLiteAllModel &&
        other.usID == usID &&
        other.usName == usName &&
        other.usImg == usImg &&
        other.usEmail == usEmail &&
        other.usType == usType &&
        other.inID == inID &&
        other.inImg == inImg &&
        other.inName == inName &&
        other.inDate == inDate &&
        other.inTime == inTime &&
        other.inCounty == inCounty &&
        other.inDistrict == inDistrict &&
        other.inProvince == inProvince &&
        other.inLat == inLat &&
        other.inLng == inLng;
  }

  @override
  int get hashCode {
    return usID.hashCode ^
        usName.hashCode ^
        usImg.hashCode ^
        usEmail.hashCode ^
        usType.hashCode ^
        inID.hashCode ^
        inImg.hashCode ^
        inName.hashCode ^
        inDate.hashCode ^
        inTime.hashCode ^
        inCounty.hashCode ^
        inDistrict.hashCode ^
        inProvince.hashCode ^
        inLat.hashCode ^
        inLng.hashCode;
  }
}
