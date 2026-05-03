# Team Profile App — Homework 2

A Flutter app introducing a team and its members, built for the Mobile
Applications course (TAMK × THWS, Unit 4 — Material UI).

## What it does

One screen, three sources of interaction:

1. **Team header** at the top — name, tagline, description, member count chip.
2. **Swipeable member cards** in the middle — one member per page,
   image / name / role / country / hobbies / motto.
3. **Navigation** at the bottom — Previous and Next icon buttons (Cupertino
   on iOS, Material everywhere else), a position indicator (`2 / 3`), and a
   dot indicator above. A "First" FAB appears once you leave the first member.

Tap the info icon in the AppBar to open an "About" bottom sheet that lists
every team member.

## Material widgets used

`MaterialApp`, `Scaffold`, `AppBar`, `IconButton`, `SafeArea`,
`SingleChildScrollView`, `Padding`, `Column`, `Row`, `Wrap`, `SizedBox`,
`Container`, `Card`, `ClipRRect`, `AspectRatio`, `Image.asset`, `Icon`,
`Text`, `Chip`, `Divider`, `PageView.builder`, `PageController`,
`FloatingActionButton.extended`, `ListTile`, `showModalBottomSheet`,
`Theme`, `ColorScheme.fromSeed`, `MediaQuery`.

Plus one Cupertino widget — `CupertinoButton` — selected at run time when
`Theme.of(context).platform == TargetPlatform.iOS`.

## Running it

```bash
flutter pub get
flutter run
```

Open DartDevTools (the URL prints in the terminal when `flutter run` starts)
and switch to the **Logging** tab — every navigation event is logged via the
`logger` package, including warnings when you tap Next at the last member.

## Customizing

Edit `lib/data/team_data.dart` and replace the placeholder members with your
real teammates. Drop their photos into `assets/images/` with the matching
file names. If a photo is missing, the card falls back to a generic avatar
icon (so the app still runs while you're collecting the photos).

## Project structure

```
lib/
├── main.dart                          ← entry point
├── data/
│   └── team_data.dart                 ← REPLACE THIS with your team
├── models/
│   ├── team.dart
│   └── team_member.dart
├── screens/
│   └── team_profile_screen.dart       ← the only screen
├── utils/
│   └── app_logger.dart                ← single shared Logger
└── widgets/
    ├── member_card.dart               ← stateless display card
    ├── platform_button.dart           ← Material-or-Cupertino picker
    └── team_header.dart
```

## Submission

Per the homework brief: push to Git and email the link.
