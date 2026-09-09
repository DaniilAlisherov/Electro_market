import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/review.dart';

/// Категории каталога. Добавление новой категории (например, "Кабельные
/// каналы" или "Светодиодные ленты") — это всего одна новая строка здесь,
/// без изменений в экранах или моделях.
final List<ProductCategory> mockCategories = [
  const ProductCategory(id: 'panels', name: 'Щиты и корпуса', icon: Icons.dashboard_customize_outlined, family: CategoryFamily.protection),
  const ProductCategory(id: 'breakers', name: 'Автоматы', icon: Icons.toggle_on_outlined, family: CategoryFamily.protection),
  const ProductCategory(id: 'rcd', name: 'УЗО и Дифавтоматы', icon: Icons.shield_outlined, family: CategoryFamily.protection),
  const ProductCategory(id: 'cable', name: 'Кабель и провод', icon: Icons.cable_outlined, family: CategoryFamily.wiring),
  const ProductCategory(id: 'relay', name: 'Реле', icon: Icons.memory_outlined, family: CategoryFamily.protection),
  const ProductCategory(id: 'din', name: 'DIN-рейки', icon: Icons.view_week_outlined, family: CategoryFamily.wiring),
  const ProductCategory(id: 'sockets', name: 'Розетки', icon: Icons.power_outlined, family: CategoryFamily.fitting),
  const ProductCategory(id: 'switches', name: 'Выключатели', icon: Icons.light_mode_outlined, family: CategoryFamily.fitting),
  const ProductCategory(id: 'lights', name: 'Светильники', icon: Icons.emoji_objects_outlined, family: CategoryFamily.fitting),
];

const _demoSellerId = 'demo-seller';
const _demoSellerName = 'ТД «Электрокомплект»';

/// Тестовые товары каталога.
///
/// Этот список является источником данных для CatalogProvider. ID `c16` и
/// `yzo25a` используются также в mockReviews, поэтому они должны присутствовать
/// здесь.
final List<Product> mockProducts = [
  const Product(
    id: 'c16',
    name: 'Автомат C16 1П Voltrix Pro',
    categoryId: 'breakers',
    type: 'Автоматический выключатель',
    price: 280,
    oldPrice: 320,
    stock: 42,
    specs: [
      ProductSpec('Номинальный ток', '16 А'),
      ProductSpec('Характеристика', 'C'),
      ProductSpec('Полюсов', '1P'),
      ProductSpec('Напряжение', '230 В'),
    ],
    description: 'Однополюсный автоматический выключатель для защиты бытовых и коммерческих электрических цепей.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.8,
    reviewsCount: 24,
    fallbackIcon: Icons.toggle_on_outlined,
  ),
  const Product(
    id: 'yzo25a',
    name: 'УЗО 25А 30мА Voltrix',
    categoryId: 'rcd',
    type: 'Устройство защитного отключения',
    price: 1340,
    stock: 18,
    specs: [
      ProductSpec('Номинальный ток', '25 А'),
      ProductSpec('Ток утечки', '30 мА'),
      ProductSpec('Полюсов', '2P'),
      ProductSpec('Напряжение', '230 В'),
    ],
    description: 'УЗО для дополнительной защиты людей от поражения электрическим током и защиты от токов утечки.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.9,
    reviewsCount: 18,
    fallbackIcon: Icons.shield_outlined,
  ),
  const Product(
    id: 'c25',
    name: 'Автомат C25 1П Voltrix Pro',
    categoryId: 'breakers',
    type: 'Автоматический выключатель',
    price: 310,
    stock: 31,
    specs: [
      ProductSpec('Номинальный ток', '25 А'),
      ProductSpec('Характеристика', 'C'),
      ProductSpec('Полюсов', '1P'),
      ProductSpec('Напряжение', '230 В'),
    ],
    description: 'Надёжный автоматический выключатель для защиты групповых линий.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.7,
    reviewsCount: 15,
    fallbackIcon: Icons.toggle_on_outlined,
  ),
  const Product(
    id: 'vvg-3x25',
    name: 'Кабель ВВГнг 3x2.5',
    categoryId: 'cable',
    type: 'Силовой кабель',
    price: 78,
    stock: 240,
    specs: [
      ProductSpec('Сечение', '3x2.5 мм²'),
      ProductSpec('Материал жилы', 'Медь'),
      ProductSpec('Изоляция', 'ПВХ'),
      ProductSpec('Цена', 'за метр'),
    ],
    description: 'Медный силовой кабель ВВГнг для стационарной прокладки электрических сетей.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.8,
    reviewsCount: 31,
    fallbackIcon: Icons.cable_outlined,
  ),
  const Product(
    id: 'din-35',
    name: 'DIN-рейка 35 мм, 1 м',
    categoryId: 'din',
    type: 'Монтажная рейка',
    price: 190,
    stock: 75,
    specs: [
      ProductSpec('Ширина', '35 мм'),
      ProductSpec('Длина', '1 м'),
      ProductSpec('Материал', 'Оцинкованная сталь'),
    ],
    description: 'Стандартная DIN-рейка для установки модульного электрооборудования в щитах.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.6,
    reviewsCount: 9,
    fallbackIcon: Icons.view_week_outlined,
  ),
  const Product(
    id: 'socket-schuko',
    name: 'Розетка с заземлением',
    categoryId: 'sockets',
    type: 'Розетка',
    price: 420,
    stock: 56,
    specs: [
      ProductSpec('Номинальный ток', '16 А'),
      ProductSpec('Напряжение', '250 В'),
      ProductSpec('Заземление', 'Есть'),
    ],
    description: 'Надёжная розетка с защитными контактами для бытовых и коммерческих помещений.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.7,
    reviewsCount: 12,
    fallbackIcon: Icons.power_outlined,
  ),
  const Product(
    id: 'switch-1g',
    name: 'Выключатель одноклавишный',
    categoryId: 'switches',
    type: 'Выключатель',
    price: 350,
    stock: 48,
    specs: [
      ProductSpec('Количество клавиш', '1'),
      ProductSpec('Номинальный ток', '10 А'),
      ProductSpec('Напряжение', '250 В'),
    ],
    description: 'Одноклавишный выключатель для управления освещением.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.6,
    reviewsCount: 8,
    fallbackIcon: Icons.light_mode_outlined,
  ),
  const Product(
    id: 'relay-16a',
    name: 'Реле напряжения 16А',
    categoryId: 'relay',
    type: 'Реле контроля напряжения',
    price: 890,
    stock: 22,
    specs: [
      ProductSpec('Номинальный ток', '16 А'),
      ProductSpec('Контроль', '160–280 В'),
      ProductSpec('Монтаж', 'DIN-рейка'),
    ],
    description: 'Реле контроля напряжения с установкой на DIN-рейку.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.9,
    reviewsCount: 14,
    fallbackIcon: Icons.memory_outlined,
  ),
  const Product(
    id: 'panel-12m',
    name: 'Щит навесной на 12 модулей',
    categoryId: 'panels',
    type: 'Щит распределительный',
    price: 760,
    stock: 16,
    specs: [
      ProductSpec('Количество модулей', '12'),
      ProductSpec('Монтаж', 'Навесной'),
      ProductSpec('Материал', 'Пластик'),
    ],
    description: 'Компактный распределительный щит для модульного оборудования.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.5,
    reviewsCount: 7,
    fallbackIcon: Icons.dashboard_customize_outlined,
  ),
  const Product(
    id: 'light-led-18',
    name: 'Светильник LED 18 Вт',
    categoryId: 'lights',
    type: 'LED-светильник',
    price: 620,
    oldPrice: 690,
    stock: 34,
    specs: [
      ProductSpec('Мощность', '18 Вт'),
      ProductSpec('Цветовая температура', '4000 К'),
      ProductSpec('Световой поток', '1600 лм'),
    ],
    description: 'Экономичный светодиодный светильник для офисных и бытовых помещений.',
    sellerId: _demoSellerId,
    sellerName: _demoSellerName,
    rating: 4.7,
    reviewsCount: 11,
    fallbackIcon: Icons.emoji_objects_outlined,
  ),
];

final List<BuyerOrder> mockBuyerOrders = [
  BuyerOrder(
    id: '10482',
    summary: '3 товара',
    total: 3424,
    status: OrderStatus.transit,
    createdAt: DateTime(2026, 9, 4),
    itemCount: 3,
  ),
  BuyerOrder(
    id: '10471',
    summary: '1 товар',
    total: 1340,
    status: OrderStatus.delivered,
    createdAt: DateTime(2026, 9, 2),
    itemCount: 1,
  ),
  BuyerOrder(
    id: '10455',
    summary: '5 товаров',
    total: 6210,
    status: OrderStatus.delivered,
    createdAt: DateTime(2026, 9, 1),
    itemCount: 5,
  ),
  BuyerOrder(
    id: '10402',
    summary: '2 товара',
    total: 980,
    status: OrderStatus.cancelled,
    createdAt: DateTime(2026, 8, 30),
    itemCount: 2,
  ),
];

/// Заказы, которые видит продавец.
/// Используется та же модель BuyerOrder, потому что заказ
/// содержит данные покупателя и продавца.
final List<BuyerOrder> mockSellerOrders = [
  BuyerOrder(
    id: '10482',
    summary: 'Автомат C16 x2, УЗО x1',
    total: 3424,
    status: OrderStatus.pending,
    buyerName: 'Игорь Петров',
    buyerPhone: '+996 555 123 456',
    createdAt: DateTime(2026, 9, 4),
    itemCount: 3,
    address: 'г. Бишкек, ул. Ахунбаева 12, кв. 45',
  ),
  BuyerOrder(
    id: '10479',
    summary: 'Кабель ВВГнг 3x2.5, 40м',
    total: 3120,
    status: OrderStatus.transit,
    buyerName: 'Алина Ким',
    buyerPhone: '+996 700 234 567',
    createdAt: DateTime(2026, 9, 3),
    itemCount: 1,
    address: 'г. Бишкек, ул. Чуй 128',
  ),
  BuyerOrder(
    id: '10471',
    summary: 'УЗО 25А 30мА x1',
    total: 1340,
    status: OrderStatus.delivered,
    buyerName: 'Марат Сыдыков',
    buyerPhone: '+996 777 345 678',
    createdAt: DateTime(2026, 9, 2),
    itemCount: 1,
    address: 'г. Бишкек, мкр. Асанбай 7-15',
  ),
  BuyerOrder(
    id: '10455',
    summary: 'Автомат C25 x3, DIN-рейка x2',
    total: 6210,
    status: OrderStatus.delivered,
    buyerName: 'Алексей Иванов',
    buyerPhone: '+996 500 456 789',
    createdAt: DateTime(2026, 9, 1),
    itemCount: 5,
    address: 'г. Бишкек, ул. Токтогула 89',
  ),
  BuyerOrder(
    id: '10402',
    summary: 'Розетка x2',
    total: 980,
    status: OrderStatus.cancelled,
    buyerName: 'Нурбек Алиев',
    buyerPhone: '+996 550 567 890',
    createdAt: DateTime(2026, 8, 30),
    itemCount: 2,
    address: 'г. Бишкек, ул. Манаса 34',
  ),
];

final List<Review> mockReviews = [
  Review(
    id: 'rv1',
    productId: 'c16',
    buyerName: 'Игорь Петров',
    rating: 5,
    comment:
        'Автомат отработал чётко, срабатывает без ложных отключений.',
  ),
  Review(
    id: 'rv2',
    productId: 'c16',
    buyerName: 'Алина Ким',
    rating: 4,
    comment:
        'Хорошее качество, но доставка заняла на день дольше обещанного.',
  ),
  Review(
    id: 'rv3',
    productId: 'yzo25a',
    buyerName: 'Марат Сыдыков',
    rating: 5,
    comment:
        'Именно то УЗО, что искал — селективное, не выбивает лишний раз.',
  ),
];

final List<ReturnRequest> mockReturns = [
  ReturnRequest(
    orderId: '10402',
    reason: 'Брак товара',
    amount: 980,
    status: OrderStatus.pending,
  ),
  ReturnRequest(
    orderId: '10233',
    reason: 'Не подошёл размер',
    amount: 350,
    status: OrderStatus.delivered,
  ),
];

// У покупателя ровно один адрес.
// Он хранится в UserProvider.address,
// а не в mock_data.dart.