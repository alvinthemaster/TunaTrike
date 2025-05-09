class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String birthday;
  final String address;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.birthday,
    required this.address,
  });

  // Method to convert JSON to Member
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      password: json['password'],
      birthday: json['birthday'],
      address: json['address'],
    );
  }

  // Method to convert Member to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'password': password,
      'birthday': birthday,
      'address': address,
    };
  }
}
