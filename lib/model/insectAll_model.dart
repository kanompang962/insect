import 'dart:convert';

class InsectAllModel {
  final String usID;
  final String usName;
  final String usImg;
  final String usEmail;
  final String usType;
  final String inID;
  final String inImg;
  final String inName;
  final String inDetails;
  final String inProtect;
  final String inType;
  final String inLat;
  final String inLng;
  InsectAllModel({
    required this.usID,
    required this.usName,
    required this.usImg,
    required this.usEmail,
    required this.usType,
    required this.inID,
    required this.inImg,
    required this.inName,
    required this.inDetails,
    required this.inProtect,
    required this.inType,
    required this.inLat,
    required this.inLng,
  });

  InsectAllModel copyWith({
    String? usID,
    String? usName,
    String? usImg,
    String? usEmail,
    String? usType,
    String? inID,
    String? inImg,
    String? inName,
    String? inDetails,
    String? inProtect,
    String? inType,
    String? inLat,
    String? inLng,
  }) {
    return InsectAllModel(
      usID: usID ?? this.usID,
      usName: usName ?? this.usName,
      usImg: usImg ?? this.usImg,
      usEmail: usEmail ?? this.usEmail,
      usType: usType ?? this.usType,
      inID: inID ?? this.inID,
      inImg: inImg ?? this.inImg,
      inName: inName ?? this.inName,
      inDetails: inDetails ?? this.inDetails,
      inProtect: inProtect ?? this.inProtect,
      inType: inType ?? this.inType,
      inLat: inType ?? this.inLat,
      inLng: inType ?? this.inLng,
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
      'inDetails': inDetails,
      'inProtect': inProtect,
      'inType': inType,
      'inLat': inLat,
      'inLng': inLng,
    };
  }

  factory InsectAllModel.fromMap(Map<String, dynamic> map) {
    return InsectAllModel(
      usID: map['usID'] ?? '',
      usName: map['usName'] ?? '',
      usImg: map['usImg'] ?? '',
      usEmail: map['usEmail'] ?? '',
      usType: map['usType'] ?? '',
      inID: map['inID'] ?? '',
      inImg: map['inImg'] ?? '',
      inName: map['inName'] ?? '',
      inDetails: map['inDetails'] ?? '',
      inProtect: map['inProtect'] ?? '',
      inType: map['inType'] ?? '',
      inLat: map['inLat'] ?? '',
      inLng: map['inLng'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InsectAllModel.fromJson(String source) =>
      InsectAllModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InsectAllModel(usID: $usID, usName: $usName, usImg: $usImg, usEmail: $usEmail, usType: $usType, inID: $inID, inImg: $inImg, inName: $inName, inDetails: $inDetails, inProtect: $inProtect, inType: $inType), inLat: $inLat), inLng: $inLng)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InsectAllModel &&
        other.usID == usID &&
        other.usName == usName &&
        other.usImg == usImg &&
        other.usEmail == usEmail &&
        other.usType == usType &&
        other.inID == inID &&
        other.inImg == inImg &&
        other.inName == inName &&
        other.inDetails == inDetails &&
        other.inProtect == inProtect &&
        other.inType == inType &&
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
        inDetails.hashCode ^
        inProtect.hashCode ^
        inType.hashCode ^
        inLat.hashCode ^
        inLng.hashCode;
  }
}
