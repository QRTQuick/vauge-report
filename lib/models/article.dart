class Article {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime? publishedAt;
  final String content;
  final String author;

  const Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.content,
    required this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final sourceJson = json['source'] as Map<String, dynamic>?;
    return Article(
      title: (json['title'] as String?)?.trim() ?? 'Untitled',
      description: (json['description'] as String?)?.trim() ?? '',
      url: (json['url'] as String?)?.trim() ?? '',
      imageUrl: (json['urlToImage'] as String?)?.trim() ?? '',
      source: (sourceJson?['name'] as String?)?.trim() ?? 'Unknown',
      publishedAt: _parseDate(json['publishedAt']),
      content: (json['content'] as String?)?.trim() ?? '',
      author: (json['author'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'source': <String, dynamic>{'name': source},
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'author': author,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
