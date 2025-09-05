// lib/src/app/utils/validators.dart
String? validateEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) return 'Email requis';
  final reg = RegExp(r'^[\w\.\-\+]+@[\w\.\-]+\.[a-zA-Z]{2,}$');
  if (!reg.hasMatch(email)) return 'Email invalide';
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return 'Mot de passe requis';
  if (value.length < 6) return 'Min. 6 caractères';
  return null;
}
