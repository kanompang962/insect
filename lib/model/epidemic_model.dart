import 'dart:convert';

class EpidemicModel {
  
  final String id;
  final String img;
  final String name;
  final String date;
  final String time;
  final String county;
  final String district;
  final String province;
  final String lat;
  final String long;
  final String id_user;
  EpidemicModel({
    required this.id,
    required this.img,
    required this.name,
    required this.date,
    required this.time,
    required this.county,
    required this.district,
    required this.province,
    required this.lat,
    required this.long,
    required this.id_user,
  });

  EpidemicModel copyWith({
    String? id,
    String? img,
    String? name,
    String? date,
    String? time,
    String? county,
    String? district,
    String? province,
    String? lat,
    String? long,
    String? id_user,
  }) {
    return EpidemicModel(
      id: id ?? this.id,
      img: img ?? this.img,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      county: county ?? this.county,
      district: district ?? this.district,
      province: province ?? this.province,
      lat: lat ?? this.lat,
      long: long ?? this.long,
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
      'long': long,
      'id_user': id_user,
    };
  }

  factory EpidemicModel.fromMap(Map<String, dynamic> map) {
    return EpidemicModel(
      id: map['id'] ?? '',
      img: map['img'] ?? '',
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      county: map['county'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
      lat: map['lat'] ?? '',
      long: map['long'] ?? '',
      id_user: map['id_user'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EpidemicModel.fromJson(String source) => EpidemicModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Epidemic(id: $id, img: $img, name: $name, date: $date, time: $time, county: $county, district: $district, province: $province, lat: $lat, long: $long, id_user: $id_user)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is EpidemicModel &&
      other.id == id &&
      other.img == img &&
      other.name == name &&
      other.date == date &&
      other.time == time &&
      other.county == county &&
      other.district == district &&
      other.province == province &&
      other.lat == lat &&
      other.long == long &&
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
      long.hashCode ^
      id_user.hashCode;
  }
}
