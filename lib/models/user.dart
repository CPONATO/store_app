import 'dart:convert';

class User {
  //define fields
  final String id;
  final String fullName;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String password;
  final String token;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.password,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      'fullName': fullName,
      'email': email,
      'state': state,
      'city': city,
      'locality': locality,
      'password': password,
      'token': token,
    };
  }
  //serialization:conver map to a json String
  //this method directly encodes the data from the map into jspn String

  //the json.encode() funtion converts a dart object into a json String reprensentation, making it suitable for communication between different systems
  String toJson() => json.encode(toMap());

  //deserialization:conver a map to a User object
  //purpose - manipulation and User: once the data is converted to a User object it can be easily manipulacted and use within the application
  //
  factory User.fromMap(Map<String, dynamic> map) {
    print("Dữ liệu người dùng từ map: $map");
    print("ID từ map: ${map['_id']}");

    return User(
      id: map['_id'] as String? ?? "",
      fullName: map['fullName'] as String? ?? "",
      email: map['email'] as String? ?? "",
      state: map['state'] as String? ?? "",
      city: map['city'] as String? ?? "",
      locality: map['locality'] as String? ?? "",
      password: map['password'] as String? ?? "",
      token: map['token'] as String? ?? "",
    );
  }

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
