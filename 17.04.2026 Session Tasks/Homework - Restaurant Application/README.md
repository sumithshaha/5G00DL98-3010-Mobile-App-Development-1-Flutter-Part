# Aurora Spice — Restaurant App (Unit 6 Homework)

This is my submission for the Week 3 / Unit 6 homework: a multi-screen Flutter
restaurant app demonstrating navigation, data passing, lists, modularization,
and a custom theme.

The fictional restaurant is **Aurora Spice** — a Finnish-Bangladeshi fusion
bistro in Tampere. I picked this concept because it matched our team's
cross-border story, but the structure works for any restaurant — replace the
content in `lib/data/restaurant_data.dart` and `lib/data/menu_data.dart` to
re-skin it.

## How this maps to the brief

The technical-requirements slide asks for five things. Here's where each one
lives:

**Multiple screens & navigation.** Three screens, navigated via
`Navigator.push` and `Navigator.pop`:
- `HomeScreen` (restaurant info) → pushes `MenuScreen`
- `MenuScreen` (categorized list) → pushes `DishDetailsScreen` per dish tap
- `DishDetailsScreen` → pops back, optionally with a result

**Data passing between screens.** Two directions, both demonstrated:
- *Forward* (constructor argument): `DishDetailsScreen(dish: dish)` — the
  whole `Dish` object is handed to the details screen.
- *Backward* (`Navigator.pop` result): tapping "Add to order" pops with a
  `DishDetailsResult` value; the menu screen awaits this and shows a
  `SnackBar` confirming the order. The "Back to menu" button pops with `null`,
  and the menu correctly handles both cases.

**Lists.** `MenuScreen` uses `ListView.builder` (lazy construction) inside
each tab. I went with `ListView` rather than `GridView` because dish rows
have two-line descriptions that read better full-width, but I demonstrate
`GridView.builder` separately in the companion exercise project
`ex4_grid_flipcards`.

**Modularization.** Project layout:
```
lib/
├── main.dart                       ← thin entry point
├── theme/app_theme.dart            ← custom theme
├── models/
│   ├── dish.dart                   ← Dish + DishCategory
│   └── restaurant.dart             ← Restaurant + OpeningHours
├── data/
│   ├── restaurant_data.dart        ← hardcoded restaurant info
│   └── menu_data.dart              ← hardcoded list of 12 dishes
├── screens/
│   ├── home_screen.dart
│   ├── menu_screen.dart            ← TabBar + 4× ListView
│   └── dish_details_screen.dart
└── widgets/
    └── dish_list_tile.dart         ← reusable list row
```
File names use snake_case as the unit explicitly requires.

**Custom theme.** `lib/theme/app_theme.dart` defines:
- a warm terracotta seed color (`#B65431`) driving the entire M3 ColorScheme
- two-font typography stack via `google_fonts`: Playfair Display for titles,
  Inter for body text — gives the app a "food magazine" feel
- light + dark variants, switching automatically with the OS setting
- custom AppBarTheme, CardTheme, ChipTheme, FilledButtonTheme, TabBarTheme

## Beyond the requirements

A few things I added because they made the app feel more real:
- `SliverAppBar` with collapsing hero image on the details screen
- Dietary tags (vegetarian, spicy) that show in both the list tile and the
  details screen
- `errorBuilder` on every `Image.asset` so the app runs without any photos —
  missing images fall back to the dish's category emoji on a colored
  background
- Strongly-typed `DishDetailsResult` for the pop value, instead of a bare
  `bool`

## Running

```bash
flutter pub get
flutter run            # picks up Chrome / emulator / connected device
```

## Customizing

1. Replace the restaurant info in `lib/data/restaurant_data.dart`.
2. Replace dishes in `lib/data/menu_data.dart` (keep the category enum, free
   to add more dishes).
3. Drop your own dish photos into `assets/images/` matching the `imageAsset`
   paths. If a photo is missing, the app keeps running with emoji fallbacks.
4. To change the visual identity, edit `lib/theme/app_theme.dart` — swap the
   seed color or change the Google Fonts.

## Submission

Per the brief: push to Git, email the link.
