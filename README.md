# vauge-report

A polished Flutter news app with dark UI, tabs (Home/Recent/Video/News), search, saved stories, and headline notifications.

## Credits
Built by Chisom Life Eke  
Contact: chisomlifeeke@gmail.com  
GitHub: https://github.com/QRTQuick

## API key
The app reads the API key from a build-time define:

```
--dart-define=NEWS_API_KEY=your_key_here
```

If you do not set a key, the default in `lib/config/api_config.dart` is used.

## Notifications & caching
The app caches feeds and saved stories on-device. A local notification is sent when a new headline appears on the Home feed. On Android 13+, the app requests notification permission at runtime.

## GitHub Actions APK
The workflow `build-apk.yml` creates a fresh Flutter project on the runner, injects the app source, and builds a release APK. Add `NEWS_API_KEY` as a GitHub Secret to avoid hardcoding keys in CI logs.
