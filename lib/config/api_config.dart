// Apify Ultimate News Scraper API
// Provide APIFY_TOKEN at build time: --dart-define=APIFY_TOKEN=your_token
const String apifyToken = String.fromEnvironment(
  'APIFY_TOKEN',
  defaultValue: 'APIFY_TOKEN_NOT_SET',
);
const String apifyActorId = 'glitch_404~ultimate-news-scraper';
const String apifyBaseUrl = 'https://api.apify.com/v2';
const String defaultCountry = 'us';
