# Exercise 3 — Migrate database_demo to Firebase

This is `database_demo` from week 4, with the local SQLite layer replaced
by **Cloud Firestore**.

## What I changed

| Layer | Before (SQLite) | After (Firestore) |
|---|---|---|
| Model | `Student.id` was an `int` (auto-increment from SQLite) | `Student.id` is a `String` (Firestore document ID) |
| Service | `DatabaseService` opening `flutter_database.db` via `sqflite` | `FirestoreService` talking to `FirebaseFirestore.instance.collection('students')` |
| List screen | `setState`-after-fetch on every change | `StreamBuilder` subscribed to `studentStream()` — realtime |
| Search | SQL `WHERE lastname LIKE 'X%'` server-side | Range query on the live snapshot, plus client-side filter for instant typing feedback |
| Init | None (SQLite is local) | `WidgetsFlutterBinding.ensureInitialized()` and `Firebase.initializeApp(...)` before `runApp` |
| Dependencies | `sqflite`, `path` | `firebase_core`, `cloud_firestore` |

The home screen, details screen, add dialog, and delete-by-swipe UX are
identical to the SQLite version — the only real architectural change in
the screens is that the home list now uses `StreamBuilder` instead of
`FutureBuilder`/`setState`. That move enables realtime: open the same
project in two emulators, add a student in one, watch it appear in the
other without refreshing.

## Running it — one-time Firebase setup

These steps have to happen on your machine; I cannot do them for you.

### 1. Install the FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Make sure the pub cache `bin/` is on your PATH. On Windows that's
`%USERPROFILE%\AppData\Local\Pub\Cache\bin`. Verify with:

```bash
flutterfire --version
```

### 2. Create a Firebase project

Go to https://console.firebase.google.com → **Add project** → name it
something like `tamk-firebase-demo` → accept the defaults → wait for
provisioning → **Build → Firestore Database → Create database** → start
in *test mode* (this lets reads/writes work without authentication for
30 days, which is plenty for this exercise) → pick a region close to you
(e.g. `eur3 (europe-west)`).

### 3. Connect this Flutter project to that Firebase project

From this directory (the one containing `pubspec.yaml`):

```bash
flutterfire configure
```

The CLI will:

- Ask you to pick the Firebase project you just created.
- Ask which platforms (Android, iOS, Web). Pick at least Android.
- Generate `lib/firebase_options.dart` with your project's API keys.
- Drop platform-specific config files into `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.

Re-run this command any time you want to add another platform or
re-generate the keys.

### 4. Pub get and run

```bash
flutter pub get
flutter run
```

If you get `[core/no-app] No Firebase App '[DEFAULT]' has been created`,
you skipped step 3.

## What changes when moving from a local to a cloud database?

The exercise asks me to reflect on this — so:

**Things that get easier**
- *Realtime sync for free.* `studentStream()` is one line; the SQLite
  equivalent would have meant rolling my own change-notification
  mechanism or polling on a Timer.
- *Cross-device data.* Two emulators, two browsers, my phone — all see
  the same data. With SQLite the database lives only on one device.
- *No schema migrations.* SQLite needed `CREATE TABLE` and an
  `onUpgrade` strategy when fields change. Firestore is schemaless.
- *Offline support.* Firestore caches writes locally and replays them
  on reconnect — better than SQLite for a flaky-network app, with no
  extra code from me.

**Things that get harder**
- *No transactions across collections by default.* SQLite's `BEGIN/COMMIT`
  is gone; Firestore has its own `runTransaction` with cost considerations.
- *Querying is more limited.* No `JOIN`, no `LIKE` (have to fake it with
  unicode-suffix range queries), composite filters need composite indexes
  you create in the console.
- *Costs scale with traffic.* Every read/write is a billable operation.
  An infinite scroll without pagination can run up a real bill.
- *Security rules are a real thing.* Firestore in test mode is open;
  before going live you have to write Security Rules (a small DSL) to
  control who can read/write what. SQLite has no equivalent — the file
  just lives on the device.
- *No more "delete the .db file to reset"*. Resetting now means logging
  into the Firebase console and deleting documents, or running
  programmatic cleanup.

**The architecture still matches the three-layer pattern**
- Presentation → screens (`home_screen.dart`, `details_screen.dart`)
- Logic / data access → `FirestoreService` (singleton, all CRUD ops)
- Data → Firestore (was SQLite)

The fact that swapping SQLite for Firestore was a ~90% rewrite of *one
file* (`database_service.dart` → `firestore_service.dart`) and a
~10-line tweak in the screens is the whole point of having that service
layer. If I'd been writing `db.execute(...)` directly inside `build()`,
this would have been a nightmare migration.

## AI tool prompts I used

The exercise asks me to log the prompts. Here are the ones that mattered:

1. *"Migrate this SQLite-backed Student CRUD app to Cloud Firestore.
   Keep the same three-layer architecture: rename DatabaseService to
   FirestoreService, change int IDs to string doc IDs, expose a
   realtime stream alongside the one-shot fetch."*
2. *"Replace the home screen's setState-after-fetch pattern with a
   StreamBuilder subscribed to FirestoreService.studentStream()."*
3. *"Show me the idiomatic prefix-search trick for Firestore since
   there's no LIKE."* — answer: range query bounded by `\uf8ff`.
4. *"Write a populateData function that uses a Firestore batch write
   so the four sample students land atomically."*
