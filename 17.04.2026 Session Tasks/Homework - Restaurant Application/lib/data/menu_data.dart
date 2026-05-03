// lib/data/menu_data.dart
//
// Hardcoded list of dishes. Twelve dishes total — three per category —
// which gives the menu enough volume to demonstrate ListView scrolling
// without becoming tedious to scroll past.
//
// Pricing is in EUR because the restaurant is in Finland. I've kept it
// realistic for a mid-range Tampere bistro: starters around €8–12, mains
// €18–26, desserts €7–10, drinks €4–9.

import '../models/dish.dart';

const List<Dish> menu = [
  // ───────── STARTERS ─────────
  Dish(
    id: 's1',
    name: 'Smoked Salmon Bhel',
    description: 'Finnish smoked salmon, puffed rice, mint chutney',
    longDescription:
        'A Nordic twist on the classic Mumbai street snack. Cold-smoked '
        'Finnish salmon meets puffed rice, crisp red onion, and a zingy '
        'tamarind-mint chutney. Served chilled in a small bowl.',
    price: 11.50,
    category: DishCategory.starters,
    imageAsset: 'assets/images/dish_salmon_bhel.jpg',
    ingredients: ['Smoked salmon', 'Puffed rice', 'Mint', 'Tamarind', 'Red onion', 'Sev'],
    isSpicy: true,
    prepMinutes: 8,
  ),
  Dish(
    id: 's2',
    name: 'Roasted Beet Pakora',
    description: 'Pirkanmaa beets, chickpea batter, dill yoghurt',
    longDescription:
        'Local beetroot fritters in a spiced chickpea batter, fried until '
        'crisp and served with a cool dill-yoghurt dip. A vegetarian '
        'showcase of how Indian frying technique elevates Finnish roots.',
    price: 9.00,
    category: DishCategory.starters,
    imageAsset: 'assets/images/dish_beet_pakora.jpg',
    ingredients: ['Beetroot', 'Chickpea flour', 'Dill', 'Yoghurt', 'Cumin'],
    isVegetarian: true,
    prepMinutes: 12,
  ),
  Dish(
    id: 's3',
    name: 'Reindeer Samosa',
    description: 'Slow-braised reindeer, juniper, hot lingonberry',
    longDescription:
        'Lapland reindeer slow-braised with juniper and warming spices, '
        'wrapped in a flaky samosa pastry, with a hot-sweet lingonberry '
        'chutney. Genuinely unique to us.',
    price: 12.50,
    category: DishCategory.starters,
    imageAsset: 'assets/images/dish_reindeer_samosa.jpg',
    ingredients: ['Reindeer', 'Juniper', 'Lingonberry', 'Pastry', 'Garam masala'],
    isSpicy: true,
    prepMinutes: 15,
  ),

  // ───────── MAIN COURSES ─────────
  Dish(
    id: 'm1',
    name: 'Lohikeitto Curry',
    description: 'Finnish salmon-leek soup, gently spiced as a curry',
    longDescription:
        'A radical re-imagining of the national salmon soup. Same dill, '
        'leek, and potatoes you grew up with, finished with a delicate '
        'coconut-milk curry base and curry leaves. Served with basmati.',
    price: 22.00,
    category: DishCategory.mains,
    imageAsset: 'assets/images/dish_lohikeitto.jpg',
    ingredients: ['Salmon', 'Leek', 'Potato', 'Dill', 'Coconut milk', 'Curry leaves'],
    prepMinutes: 25,
  ),
  Dish(
    id: 'm2',
    name: 'Karjalanpaisti Biryani',
    description: 'Karelian stew meets Bangladeshi long-grain rice',
    longDescription:
        'Slow-cooked Karelian three-meat stew (beef, pork, lamb) layered '
        'with saffron-perfumed long-grain rice and slow-fried onions, '
        'then steamed sealed in the pot. A 4-hour process, served with '
        'raita and pickled cucumber.',
    price: 26.50,
    category: DishCategory.mains,
    imageAsset: 'assets/images/dish_karjalan_biryani.jpg',
    ingredients: ['Beef', 'Pork', 'Lamb', 'Saffron', 'Basmati rice', 'Cardamom'],
    isSpicy: true,
    prepMinutes: 35,
  ),
  Dish(
    id: 'm3',
    name: 'Forest Mushroom Korma',
    description: 'Wild Finnish mushrooms, cashew cream, saffron rice',
    longDescription:
        'Hand-foraged chanterelles, ceps, and trumpets in a luxurious '
        'cashew-cream korma. Vegan when ordered without the saffron rice '
        '(we use a cardamom pilaf instead). Mild, aromatic, and deeply '
        'savoury.',
    price: 19.50,
    category: DishCategory.mains,
    imageAsset: 'assets/images/dish_mushroom_korma.jpg',
    ingredients: ['Chanterelles', 'Ceps', 'Cashew cream', 'Saffron', 'Garam masala'],
    isVegetarian: true,
    prepMinutes: 22,
  ),

  // ───────── DESSERTS ─────────
  Dish(
    id: 'd1',
    name: 'Cardamom Mustikkapiirakka',
    description: 'Blueberry tart with cardamom-rose cream',
    longDescription:
        'The Finnish blueberry tart you know, finished with a whipped '
        'cream perfumed with green cardamom and a single drop of rose '
        'water. The Bangladeshi-Finnish dessert we are proudest of.',
    price: 8.50,
    category: DishCategory.desserts,
    imageAsset: 'assets/images/dish_blueberry_tart.jpg',
    ingredients: ['Wild blueberries', 'Butter pastry', 'Cardamom', 'Rose water', 'Cream'],
    isVegetarian: true,
    prepMinutes: 6,
  ),
  Dish(
    id: 'd2',
    name: 'Birch-Syrup Rasmalai',
    description: 'Cottage-cheese dumplings in birch-cardamom syrup',
    longDescription:
        'Soft homemade ricotta-style dumplings (chhena) bathed in a warm '
        'syrup of Finnish birch sap, cardamom, and a touch of saffron. '
        'Served chilled, garnished with pistachios.',
    price: 9.00,
    category: DishCategory.desserts,
    imageAsset: 'assets/images/dish_rasmalai.jpg',
    ingredients: ['Cottage cheese', 'Birch syrup', 'Cardamom', 'Saffron', 'Pistachio'],
    isVegetarian: true,
    prepMinutes: 8,
  ),
  Dish(
    id: 'd3',
    name: 'Korvapuusti Gulab Jamun',
    description: 'Cinnamon roll dough fried, soaked in cardamom syrup',
    longDescription:
        'Traditional korvapuusti dough rolled into small balls, deep-fried, '
        'and soaked overnight in cardamom-rose sugar syrup. Comfort food '
        'on both continents, fused into one bite.',
    price: 7.50,
    category: DishCategory.desserts,
    imageAsset: 'assets/images/dish_korvapuusti_jamun.jpg',
    ingredients: ['Korvapuusti dough', 'Cardamom', 'Rose syrup', 'Sugar'],
    isVegetarian: true,
    prepMinutes: 10,
  ),

  // ───────── DRINKS ─────────
  Dish(
    id: 'b1',
    name: 'Salmiakki Lassi',
    description: 'Salty liquorice yoghurt drink — surprisingly addictive',
    longDescription:
        'Sweet-salty Finnish salmiakki blended into traditional Indian '
        'yoghurt lassi. Sounds wrong, tastes fantastic. Order with '
        'caution if you have not had salmiakki before.',
    price: 5.50,
    category: DishCategory.drinks,
    imageAsset: 'assets/images/dish_salmiakki_lassi.jpg',
    ingredients: ['Yoghurt', 'Salmiakki', 'Sugar', 'Cardamom'],
    isVegetarian: true,
    prepMinutes: 3,
  ),
  Dish(
    id: 'b2',
    name: 'Cardamom Cold Brew',
    description: 'Finnish single-origin coffee, slow-steeped with cardamom',
    longDescription:
        'Twelve-hour cold brew using a Finnish single-origin Ethiopian '
        'roast, steeped with crushed green cardamom pods. Served black '
        'over ice, with optional oat milk.',
    price: 4.50,
    category: DishCategory.drinks,
    imageAsset: 'assets/images/dish_cardamom_cold_brew.jpg',
    ingredients: ['Coffee', 'Cardamom', 'Water', 'Ice'],
    isVegetarian: true,
    prepMinutes: 1,
  ),
  Dish(
    id: 'b3',
    name: 'Sea-Buckthorn Mango Lassi',
    description: 'Pirkanmaa sea-buckthorn berries blended with Alphonso mango',
    longDescription:
        'Tart, vivid orange Finnish sea-buckthorn balanced against the '
        'sweetness of Alphonso mango pulp. A proper celebration of the '
        'two cuisines we draw from.',
    price: 6.50,
    category: DishCategory.drinks,
    imageAsset: 'assets/images/dish_sea_buckthorn_lassi.jpg',
    ingredients: ['Sea buckthorn', 'Mango', 'Yoghurt', 'Honey'],
    isVegetarian: true,
    prepMinutes: 3,
  ),
];

/// Convenience filter — used by MenuScreen to populate each tab.
List<Dish> dishesIn(DishCategory cat) =>
    menu.where((d) => d.category == cat).toList(growable: false);
