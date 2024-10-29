class ColorRecommendation {
  final String skinTone;
  final String shirtColor;
  final String pantsColor;
  final String matchStatus;
  final String recommendation;

  ColorRecommendation({
    required this.skinTone,
    required this.shirtColor,
    required this.pantsColor,
    required this.matchStatus,
    required this.recommendation,
  });

  factory ColorRecommendation.fromJson(Map<String, dynamic> json) {
    return ColorRecommendation(
      skinTone: json['skin_tone'] ?? '', 
      shirtColor: json['shirt_color'] ?? '',
      pantsColor: json['pants_color'] ?? '',
      matchStatus: json['match_status'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }
}
