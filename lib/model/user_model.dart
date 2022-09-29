import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String password;
  final String name;
  final String img;
  final String email;
  final String phone;
  final String county;
  final String district;
  final String province;
  final String type;
  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.img,
    required this.email,
    required this.phone,
    required this.county,
    required this.district,
    required this.province,
    required this.type,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    String? avatar,
    String? email,
    String? phone,
    String? county,
    String? district,
    String? province,
    String? type,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      img: avatar ?? this.img,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      county: county ?? this.county,
      district: district ?? this.district,
      province: province ?? this.province,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'avatar': img,
      'email': email,
      'phone': phone,
      'county': county,
      'district': district,
      'province': province,
      'type': type,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      img: map['img'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      county: map['county'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
      type: map['type'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, password: $password, name: $name, img: $img, email: $email, phone: $phone, county: $county, district: $district, province: $province, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.username == username &&
      other.password == password &&
      other.name == name &&
      other.img == img &&
      other.email == email &&
      other.phone == phone &&
      other.county == county &&
      other.district == district &&
      other.province == province &&
      other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      username.hashCode ^
      password.hashCode ^
      name.hashCode ^
      img.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      county.hashCode ^
      district.hashCode ^
      province.hashCode ^
      type.hashCode;
  }
}
