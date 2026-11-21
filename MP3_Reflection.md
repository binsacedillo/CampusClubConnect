# MP3 Reflection

`URLSession` with `Codable` serves the same purpose as Retrofit with Gson: it requests remote data and converts JSON into typed model values, although iOS exposes the request and main-thread UI handoff more directly. `PHPickerViewController` is similar to the Android Photo Picker because both return a user-selected image without requiring broad photo-library access. `CLLocationManager` and Android's `FusedLocationProviderClient` both require runtime authorization and deliver location updates asynchronously through platform-specific callbacks. In both platforms, defensive error handling and updating interface elements on the main thread are essential.

Published JSON URL: https://raw.githubusercontent.com/binsacedillo/CampusClubConnect/main/clubs.json
