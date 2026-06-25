/// Карточка-мысль: цитата / совет / мантра.
class Quote {
  final String id;
  final String text;
  final String? author;
  final String theme; // id темы (см. MoodTheme)

  const Quote({
    required this.id,
    required this.text,
    this.author,
    required this.theme,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    id: json['id'] as String,
    text: json['text'] as String,
    author: json['author'] as String?,
    theme: json['theme'] as String,
  );
}
