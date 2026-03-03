// GNews API
// Provide GNEWS_API_KEY at build time: --dart-define=GNEWS_API_KEY=your_key
const String gnewsApiKey = String.fromEnvironment(
  'GNEWS_API_KEY',
  defaultValue: 'GNEWS_API_KEY_NOT_SET',
);
const String gnewsBaseUrl = 'https://gnews.io/api/v4';
const String defaultCountry = 'us';
const String defaultLanguage = 'en';
const int defaultMaxResults = 10;
