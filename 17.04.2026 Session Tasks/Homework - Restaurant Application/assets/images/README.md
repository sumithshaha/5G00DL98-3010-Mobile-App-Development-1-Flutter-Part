# assets/images

The app expects the following image files, but **runs perfectly fine
without any of them** — every `Image.asset` has an `errorBuilder` that
shows a category emoji on a colored gradient as a fallback.

Add your own photos with these filenames if you want real imagery:

```
restaurant_hero.jpg              ← hero image on Home screen
dish_salmon_bhel.jpg
dish_beet_pakora.jpg
dish_reindeer_samosa.jpg
dish_lohikeitto.jpg
dish_karjalan_biryani.jpg
dish_mushroom_korma.jpg
dish_blueberry_tart.jpg
dish_rasmalai.jpg
dish_korvapuusti_jamun.jpg
dish_salmiakki_lassi.jpg
dish_cardamom_cold_brew.jpg
dish_sea_buckthorn_lassi.jpg
```

JPG, PNG, or WebP all work. After adding files, run a hot **restart**
(not just hot reload) — asset bundle changes require restart.
