import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/user_role.dart';
import '../models/payment_card.dart';

class UserProvider extends ChangeNotifier {
  UserRole? _role;
  String _name = '';
  String _phone = '';
  String _email = '';
  String _city = '';
  String _bio = '';
  Uint8List? _avatarBytes;
  Address? _address;
  final List<PaymentCard> _cards = [];
  String _password = '123456';

  static const _demoSellerCode = 'SELLER-2026';

  UserRole? get role => _role;
  bool get isAuthenticated => _role != null;
  String get phone => _phone;
  String get email => _email;
  String get city => _city;
  String get bio => _bio;
  Uint8List? get avatarBytes => _avatarBytes;
  Address? get address => _address;
  List<PaymentCard> get cards => List.unmodifiable(_cards);

  PaymentCard? get defaultCard {
    for (final card in _cards) {
      if (card.isDefault) return card;
    }
    return _cards.isEmpty ? null : _cards.first;
  }

  String get name {
    if (_name.trim().isNotEmpty) return _name;
    return _role == UserRole.seller ? 'Новый продавец' : 'Покупатель';
  }

  String get initials {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  String? loginAsSellerVerified(String phone, String password, String code) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return 'Введите корректный номер телефона';
    if (password.trim().length < 6) return 'Пароль должен содержать минимум 6 символов';
    if (code.trim().toUpperCase() != _demoSellerCode) return 'Неверный секретный код продавца';
    _role = UserRole.seller;
    _name = 'Новый продавец';
    _phone = phone.trim();
    _password = password.trim();
    notifyListeners();
    return null;
  }

  String? loginAsSeller(String code, String phone) {
    if (code.trim().toUpperCase() != _demoSellerCode) return 'Неверный секретный код продавца';
    _role = UserRole.seller;
    _name = 'Новый продавец';
    _phone = phone.trim();
    notifyListeners();
    return null;
  }

  String? loginAsBuyerVerified(String phone, String password) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return 'Введите корректный номер телефона';
    if (password.trim().length < 6) return 'Пароль должен содержать минимум 6 символов';
    _role = UserRole.buyer;
    _phone = phone.trim();
    _password = password.trim();
    _name = '';
    notifyListeners();
    return null;
  }

  String? loginAsBuyer(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return 'Введите корректный номер телефона';
    _role = UserRole.buyer;
    _phone = phone.trim();
    _name = '';
    notifyListeners();
    return null;
  }


  void addCard(PaymentCard card) {
    _cards.removeWhere((c) => c.id == card.id);
    if (card.isDefault) {
      _cards.clear();
    }
    _cards.add(card);
    notifyListeners();
  }

  void setDefaultCard(String id) {
    if (_cards.isEmpty) return;
    final updated = <PaymentCard>[];
    for (final c in _cards) {
      updated.add(PaymentCard(id: c.id, holder: c.holder, last4: c.last4, brand: c.brand, expiryMonth: c.expiryMonth, expiryYear: c.expiryYear, isDefault: c.id == id));
    }
    _cards
      ..clear()
      ..addAll(updated);
    notifyListeners();
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    if (_cards.isNotEmpty && !_cards.any((c) => c.isDefault)) {
      final c = _cards.first;
      _cards[0] = PaymentCard(id: c.id, holder: c.holder, last4: c.last4, brand: c.brand, expiryMonth: c.expiryMonth, expiryYear: c.expiryYear, isDefault: true);
    }
    notifyListeners();
  }

  bool verifySmsCode(String code) => code.trim() == '123456';

  String? changePassword(String newPassword, String repeatPassword) {
    if (newPassword.length < 6) return 'Пароль должен содержать минимум 6 символов';
    if (newPassword != repeatPassword) return 'Пароли не совпадают';
    _password = newPassword;
    notifyListeners();
    return null;
  }

  bool checkPassword(String password) => password == _password;

  void updateProfile({
    String? name,
    String? phone,
    String? email,
    String? city,
    String? bio,
    Uint8List? avatarBytes,
  }) {
    if (name != null) _name = name.trim();
    if (phone != null) _phone = phone.trim();
    if (email != null) _email = email.trim();
    if (city != null) _city = city.trim();
    if (bio != null) _bio = bio.trim();
    if (avatarBytes != null) _avatarBytes = avatarBytes;
    notifyListeners();
  }

  void setAddress(Address address) {
    _address = address;
    notifyListeners();
  }

  void clearAddress() {
    _address = null;
    _cards.clear();
    _password = '123456';
    notifyListeners();
  }

  void logout() {
    _role = null;
    _name = '';
    _phone = '';
    _email = '';
    _city = '';
    _bio = '';
    _avatarBytes = null;
    _address = null;
    _cards.clear();
    _password = '123456';
    notifyListeners();
  }
}
