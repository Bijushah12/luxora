class AuthService {

  static String? registeredEmail;
  static String? registeredPassword;

  /// SIGNUP
  static bool signup(String email, String password) {

    registeredEmail = email;
    registeredPassword = password;

    return true;
  }

  /// LOGIN
  static bool login(String email, String password) {

    if (email == registeredEmail &&
        password == registeredPassword) {
      return true;
    }

    return false;
  }

}