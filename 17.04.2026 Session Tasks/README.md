# Unit 6 — All Exercises and Homework

Five Flutter projects, one per exercise from Unit 6 of the Mobile Applications
course. They build on each other in pedagogical order:

| # | Project | What it teaches |
|---|---------|----------------|
| 1 | `ex1_navigation` | Two screens, `Navigator.push` / `Navigator.pop` — the absolute minimum |
| 2 | `ex2_data_passing` | Forward data via constructor, return data via `Navigator.pop(value)` |
| 3 | `ex3_modularized` | Same app as #2, but properly split into `screens/` + thin `main.dart` |
| 4 | `ex4_grid_flipcards` | `GridView.builder` with animated 3D flip cards |
| 5 | `homework_restaurant` | Everything combined — 3 screens, TabBar, ListView, modular files, custom theme |

## Reading order

If you're going through these to learn the unit's content, read them in
the order above. Each one introduces exactly one new concept on top of
the previous, so the diff between #1 and #2 shows you the data-passing
mechanic in isolation, the diff between #2 and #3 shows you the
modularization mechanic in isolation, and so on.

## Running any of them

The procedure is identical for each:

```bash
cd <project-folder>
flutter pub get
flutter run               # Chrome / emulator / connected device
```

If you cloned the repo and the platform folders (`android/`, `web/`,
`windows/`, …) aren't there yet, run `flutter create .` once first.

## Notes specific to particular projects

**Exercise 4 (flip cards) and the homework** declare `assets/images/`
in their pubspec but the actual photos aren't included. Both apps use
`Image.asset(...).errorBuilder` to fall back to a placeholder, so they
run out of the box without any image files. Add real photos by dropping
JPG/PNG files into the matching paths — see each project's
`assets/images/README.md` for the expected filenames.

**Exercise 5 (homework)** depends on `google_fonts` for the Playfair
Display + Inter typography stack. First `flutter pub get` will download
both font files. If you're running offline, `google_fonts` falls back
silently to the closest system font.
