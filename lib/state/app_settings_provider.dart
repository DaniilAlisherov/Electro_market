import 'package:flutter/material.dart';

enum AppLanguage { russian, kyrgyz }

class AppSettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.russian;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) { if (_themeMode == mode) return; _themeMode = mode; notifyListeners(); }
  void setLanguage(AppLanguage language) { if (_language == language) return; _language = language; notifyListeners(); }
  void setNotifications(bool value) { if (_notificationsEnabled == value) return; _notificationsEnabled = value; notifyListeners(); }
}

class AppStrings {
  AppStrings._();
  static bool _ky(AppLanguage l) => l == AppLanguage.kyrgyz;

  static String appName(AppLanguage l) => 'ЭлектроМаркет';
  static String catalog(AppLanguage l) => _ky(l) ? 'Каталог' : 'Каталог';
  static String search(AppLanguage l) => _ky(l) ? 'Издөө' : 'Поиск';
  static String cart(AppLanguage l) => _ky(l) ? 'Себет' : 'Корзина';
  static String profile(AppLanguage l) => _ky(l) ? 'Профиль' : 'Профиль';
  static String settings(AppLanguage l) => _ky(l) ? 'Жөндөөлөр' : 'Настройки';
  static String editProfile(AppLanguage l) => _ky(l) ? 'Профилди түзөтүү' : 'Редактировать профиль';
  static String support(AppLanguage l) => _ky(l) ? 'Жардам керек' : 'Нужна помощь';
  static String chats(AppLanguage l) => _ky(l) ? 'Чаттар' : 'Чаты';
  static String logout(AppLanguage l) => _ky(l) ? 'Чыгуу' : 'Выйти';
  static String orders(AppLanguage l) => _ky(l) ? 'Менин буйрутмаларым' : 'Мои заказы';
  static String ordersTab(AppLanguage l) => _ky(l) ? 'Буйрутмалар' : 'Заказы';
  static String favorites(AppLanguage l) => _ky(l) ? 'Тандалгандар' : 'Избранное';
  static String addresses(AppLanguage l) => _ky(l) ? 'Жеткирүү даректери' : 'Адреса доставки';
  static String returns(AppLanguage l) => _ky(l) ? 'Тарых жана кайтаруулар' : 'История и возвраты';
  static String myProducts(AppLanguage l) => _ky(l) ? 'Менин товарларым' : 'Мои товары';
  static String analytics(AppLanguage l) => _ky(l) ? 'Сатуу жана аналитика' : 'Продажи и аналитика';
  static String sellerOrders(AppLanguage l) => _ky(l) ? 'Кардарлардын буйрутмалары' : 'Заказы покупателей';
  static String productReviews(AppLanguage l) => _ky(l) ? 'Товарлар жөнүндө пикирлер' : 'Отзывы о товарах';
  static String leaveReview(AppLanguage l) => _ky(l) ? 'Пикир калтыруу' : 'Оставить отзыв';
  static String yourRating(AppLanguage l) => _ky(l) ? 'Сиздин баа' : 'Ваша оценка';
  static String reviewCommentHint(AppLanguage l) => _ky(l) ? 'Товар жөнүндө пикириңиз (милдеттүү эмес)' : 'Ваш комментарий о товаре (необязательно)';
  static String submitReview(AppLanguage l) => _ky(l) ? 'Пикирди жөнөтүү' : 'Отправить отзыв';
  static String reviewSubmitted(AppLanguage l) => _ky(l) ? 'Пикириңиз үчүн рахмат!' : 'Спасибо за отзыв!';
  static String selectRatingFirst(AppLanguage l) => _ky(l) ? 'Алгач баа коюңуз' : 'Сначала поставьте оценку';
  static String noReviewsYet(AppLanguage l) => _ky(l) ? 'Азырынча пикирлер жок' : 'Пока отзывов нет';
  static String reviewsWord(AppLanguage l) => _ky(l) ? 'пикир' : 'отзывов';

  static String theme(AppLanguage l) => _ky(l) ? 'Тема' : 'Тема';
  static String light(AppLanguage l) => _ky(l) ? 'Жарык' : 'Светлая';
  static String dark(AppLanguage l) => _ky(l) ? 'Караңгы' : 'Тёмная';
  static String interfaceLanguage(AppLanguage l) => _ky(l) ? 'Интерфейс тили' : 'Язык интерфейса';
  static String russian(AppLanguage l) => 'Русский';
  static String kyrgyz(AppLanguage l) => 'Кыргызча';
  static String notifications(AppLanguage l) => _ky(l) ? 'Билдирмелер' : 'Уведомления';
  static String privacy(AppLanguage l) => _ky(l) ? 'Купуялык' : 'Конфиденциальность';
  static String about(AppLanguage l) => _ky(l) ? 'Тиркеме жөнүндө' : 'О приложении';
  static String appearance(AppLanguage l) => _ky(l) ? 'СЫРТКЫ КӨРҮНҮШ' : 'ВНЕШНИЙ ВИД';
  static String languageSection(AppLanguage l) => _ky(l) ? 'ТИЛ' : 'ЯЗЫК';
  static String extra(AppLanguage l) => _ky(l) ? 'КОШУМЧА' : 'ДОПОЛНИТЕЛЬНО';

  static String security(AppLanguage l) => _ky(l) ? 'КООПСУЗДУК' : 'БЕЗОПАСНОСТЬ';
  static String changePassword(AppLanguage l) => _ky(l) ? 'Сыр сөздү өзгөртүү' : 'Изменить пароль';
  static String changePasswordHint(AppLanguage l) => _ky(l) ? 'SMS-код аркылуу сырсөздү жаңыртыңыз' : 'Сменить пароль после подтверждения по SMS';
  static String payments(AppLanguage l) => _ky(l) ? 'Төлөм ыкмалары' : 'Способы оплаты';
  static String addCard(AppLanguage l) => _ky(l) ? 'Карта кошуу' : 'Добавить карту';
  static String checkout(AppLanguage l) => _ky(l) ? 'Төлөм' : 'Оплата';
  static String cardNumber(AppLanguage l) => _ky(l) ? 'Картанын номери' : 'Номер карты';
  static String cardHolder(AppLanguage l) => _ky(l) ? 'Карта ээсинин аты' : 'Имя владельца';
  static String expiry(AppLanguage l) => _ky(l) ? 'Мөөнөтү' : 'Срок действия';
  static String cvv(AppLanguage l) => 'CVV';
  static String payNow(AppLanguage l) => _ky(l) ? 'Төлөө' : 'Оплатить';
  static String online(AppLanguage l) => _ky(l) ? 'Онлайн төлөм' : 'Онлайн оплата';
  static String cash(AppLanguage l) => _ky(l) ? 'Накталай / жеткирүүдө' : 'Наличными при получении';
  static String noOwnProductCart(AppLanguage l) => _ky(l) ? 'Бул сиздин товарыңыз, аны себетке кошо албайсыз' : 'Вы не можете добавить этот товар в корзину, потому что это ваш товар';
  static String sellerAddOrder(AppLanguage l) => _ky(l) ? 'Буйрутма кошуу' : 'Добавить заказ';
  static String productAddedOrder(AppLanguage l) => _ky(l) ? 'Буйрутмага кошулду' : 'Добавлено в заказ';
  static String smsCode(AppLanguage l) => _ky(l) ? 'SMS-код' : 'SMS-код';
  static String verifyCode(AppLanguage l) => _ky(l) ? 'Кодду текшерүү' : 'Проверить код';
  static String newPassword(AppLanguage l) => _ky(l) ? 'Жаңы сыр сөз' : 'Новый пароль';
  static String repeatPassword(AppLanguage l) => _ky(l) ? 'Сыр сөздү кайталаңыз' : 'Повторите пароль';

  static String editPhoto(AppLanguage l) => _ky(l) ? 'Сүрөттү өзгөртүү' : 'Изменить фото';
  static String name(AppLanguage l) => _ky(l) ? 'АТЫ' : 'ИМЯ';
  static String storeName(AppLanguage l) => _ky(l) ? 'АТЫ / ДҮКӨНДҮН АТАЛЫШЫ' : 'ИМЯ / НАЗВАНИЕ МАГАЗИНА';
  static String phone(AppLanguage l) => _ky(l) ? 'ТЕЛЕФОН НОМЕРИ' : 'НОМЕР ТЕЛЕФОНА';
  static String email(AppLanguage l) => _ky(l) ? 'ЭЛЕКТРОНДУК ПОЧТА' : 'ЭЛЕКТРОННАЯ ПОЧТА';
  static String city(AppLanguage l) => _ky(l) ? 'ШААР' : 'ГОРОД';
  static String aboutMe(AppLanguage l) => _ky(l) ? 'ӨЗҮМ ЖӨНҮНДӨ' : 'О СЕБЕ';
  static String save(AppLanguage l) => _ky(l) ? 'Сактоо' : 'Сохранить';
  static String nameHint(AppLanguage l) => _ky(l) ? 'Башкалар сизди кандай көрөт' : 'Как вас видят другие';
  static String cityHint(AppLanguage l) => _ky(l) ? 'Бишкек' : 'Бишкек';
  static String bioHint(AppLanguage l) => _ky(l) ? 'Кыскача маалымат' : 'Коротко о себе или магазине';
  static String invalidPhone(AppLanguage l) => _ky(l) ? 'Телефон номерин туура киргизиңиз' : 'Введите корректный номер телефона';
  static String invalidEmail(AppLanguage l) => _ky(l) ? 'Электрондук почтаны туура киргизиңиз' : 'Введите корректный email';
  static String required(AppLanguage l) => _ky(l) ? 'Талааны толтуруңуз' : 'Заполните поле';
  static String profileUpdated(AppLanguage l) => _ky(l) ? 'Профиль жаңыртылды' : 'Профиль обновлён';
  static String buyer(AppLanguage l) => _ky(l) ? 'Сатып алуучу' : 'Покупатель';
  static String seller(AppLanguage l) => _ky(l) ? 'Сатуучу' : 'Продавец';
  static String buyerTag(AppLanguage l) => _ky(l) ? 'САТЫП АЛУУЧУ' : 'ПОКУПАТЕЛЬ';
  static String sellerTag(AppLanguage l) => _ky(l) ? 'САТУУЧУ' : 'ПРОДАВЕЦ';
  static String categoryName(AppLanguage l, String id, String fallback) {
    if (!_ky(l)) return fallback;
    const names = {
      'panels': 'Электр калкандары', 'breakers': 'Автоматтар', 'rcd': 'УЗО', 'cable': 'Кабельдер',
      'relay': 'Релелер', 'din': 'DIN-рейка', 'sockets': 'Розеткалар', 'switches': 'Өчүргүчтөр', 'lights': 'Жарыктар',
    };
    return names[id] ?? fallback;
  }
}
