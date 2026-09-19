class HoroscopeType {
  final String id;
  final String title;
  final String description;
  final String icon;

  HoroscopeType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class HoroscopeResult {
  final String title;
  final String content;
  final String advice;
  final String? poem;

  HoroscopeResult({
    required this.title,
    required this.content,
    required this.advice,
    this.poem,
  });
}
