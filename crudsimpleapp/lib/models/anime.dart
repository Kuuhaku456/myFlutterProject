class Anime {
  final String id;
  final String title;
  final String description;

  Anime({required this.id, required this.title, required this.description});

  factory Anime.fromMap(Map<String, dynamic> map, String id) {
    return Anime(
      id: id,
      title: map['title'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }
}
