/// Роли в приложении. Расширяемо: при необходимости легко добавить
/// новые роли, не трогая экраны — они читают [UserRole] из провайдера.
enum UserRole { buyer, seller }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.buyer:
        return 'Покупатель';
      case UserRole.seller:
        return 'Продавец';
    }
  }

  String get tag {
    switch (this) {
      case UserRole.buyer:
        return 'ПОКУПАТЕЛЬ';
      case UserRole.seller:
        return 'ПРОДАВЕЦ';
    }
  }
}
