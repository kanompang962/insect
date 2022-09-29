import 'dart:convert';

class InsectModel {
  String id;
  String img;
  String name;
  String details;
  String protect;
  String date;
  String time;
  String type;
  String lat;
  String lng;
  String id_user;
  InsectModel({
    required this.id,
    required this.img,
    required this.name,
    required this.details,
    required this.protect,
    required this.date,
    required this.time,
    required this.type,
    required this.lat,
    required this.lng,
    required this.id_user,
  });


  InsectModel copyWith({
    String? id,
    String? img,
    String? name,
    String? details,
    String? protect,
    String? date,
    String? time,
    String? type,
    String? lat,
    String? lng,
    String? id_user,
  }) {
    return InsectModel(
      id: id ?? this.id,
      img: img ?? this.img,
      name: name ?? this.name,
      details: details ?? this.details,
      protect: protect ?? this.protect,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      id_user: id_user ?? this.id_user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'img': img,
      'name': name,
      'details': details,
      'protect': protect,
      'date': date,
      'time': time,
      'type': type,
      'lat': lat,
      'lng': lng,
      'id_user': id_user,
    };
  }

  factory InsectModel.fromMap(Map<String, dynamic> map) {
    return InsectModel(
      id: map['id'] ?? '',
      img: map['img'] ?? '',
      name: map['name'] ?? '',
      details: map['details'] ?? '',
      protect: map['protect'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      type: map['type'] ?? '',
      lat: map['lat'] ?? '',
      lng: map['lng'] ?? '',
      id_user: map['id_user'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InsectModel.fromJson(String source) => InsectModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InsectModel(id: $id, img: $img, name: $name, details: $details, protect: $protect, date: $date, time: $time, type: $type, lat: $lat, lng: $lng, id_user: $id_user)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is InsectModel &&
      other.id == id &&
      other.img == img &&
      other.name == name &&
      other.details == details &&
      other.protect == protect &&
      other.date == date &&
      other.time == time &&
      other.type == type &&
      other.lat == lat &&
      other.lng == lng &&
      other.id_user == id_user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      img.hashCode ^
      name.hashCode ^
      details.hashCode ^
      protect.hashCode ^
      date.hashCode ^
      time.hashCode ^
      type.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      id_user.hashCode;
  }
}
