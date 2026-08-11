enum UserRole { patient, doctor, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

class LoginFormModel {
  String email;
  String password;

  LoginFormModel({this.email = 'pasien@mail.com', this.password = '123'});

  bool get isValid => email.trim().isNotEmpty && password.isNotEmpty;
}

class RegisterFormModel {
  String name;
  String email;
  String password;

  RegisterFormModel({this.name = '', this.email = '', this.password = ''});

  bool get isValid => name.trim().isNotEmpty && email.trim().isNotEmpty && password.isNotEmpty;
}
