import 'dart:convert';

class InsectTypeModel {
  String id;
  String name;
  String nameTH;
  InsectTypeModel({
    required this.id,
    required this.name,
    required this.nameTH,
  });

  InsectTypeModel copyWith({
    String? id,
    String? name,
    String? nameTH,
  }) {
    return InsectTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameTH: nameTH ?? this.nameTH,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameTH': nameTH,
    };
  }

  factory InsectTypeModel.fromMap(Map<String, dynamic> map) {
    return InsectTypeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameTH: map['nameTH'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InsectTypeModel.fromJson(String source) =>
      InsectTypeModel.fromMap(json.decode(source));

  @override
  String toString() => 'InsectTypeModel(id: $id, name: $name, nameTH: $nameTH)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InsectTypeModel &&
        other.id == id &&
        other.name == name &&
        other.nameTH == nameTH;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ nameTH.hashCode;
}
