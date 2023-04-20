import 'dart:convert';

class InsectLiteModel {
  final String id;
  final String img;
  final String name;
  final String date;
  final String time;
  final String county;
  final String district;
  final String province;
  final String lat;
  final String lng;
  final String id_user;
  InsectLiteModel({
    required this.id,
    required this.img,
    required this.name,
    required this.date,
    required this.time,
    required this.county,
    required this.district,
    required this.province,
    required this.lat,
    required this.lng,
    required this.id_user,
  });

  InsectLiteModel copyWith({
    String? id,
    String? img,
    String? name,
    String? date,
    String? time,
    String? county,
    String? district,
    String? province,
    String? lat,
    String? lng,
    String? id_user,
  }) {
    return InsectLiteModel(
      id: id ?? this.id,
      img: img ?? this.img,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      county: county ?? this.county,
      district: district ?? this.district,
      province: province ?? this.province,
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
      'date': date,
      'time': time,
      'county': county,
      'district': district,
      'province': province,
      'lat': lat,
      'lng': lng,
      'id_user': id_user,
    };
  }

  factory InsectLiteModel.fromMap(Map<String, dynamic> map) {
    return InsectLiteModel(
      id: map['id'] ?? '',
      img: map['img'] ?? '',
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      county: map['county'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
      lat: map['lat'] ?? '',
      lng: map['lng'] ?? '',
      id_user: map['id_user'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InsectLiteModel.fromJson(String source) =>
      InsectLiteModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InsectLiteModel(id: $id, img: $img, name: $name, date: $date, time: $time, county: $county, district: $district, province: $province, lat: $lat, lng: $lng, id_user: $id_user)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InsectLiteModel &&
        other.id == id &&
        other.img == img &&
        other.name == name &&
        other.date == date &&
        other.time == time &&
        other.county == county &&
        other.district == district &&
        other.province == province &&
        other.lat == lat &&
        other.lng == lng &&
        other.id_user == id_user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        img.hashCode ^
        name.hashCode ^
        date.hashCode ^
        time.hashCode ^
        county.hashCode ^
        district.hashCode ^
        province.hashCode ^
        lat.hashCode ^
        lng.hashCode ^
        id_user.hashCode;
  }
}
