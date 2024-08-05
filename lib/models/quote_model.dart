class QuoteModel {
  String? id;
  String? showSignature;
  String? imageName;
  String? cta;
  String? engText;
  String? mp3Link;
  String? altTag;
  String? langText;
  String? announcement;
  DateTime? date;

  QuoteModel({
    this.id,
    this.showSignature,
    this.imageName,
    this.cta,
    this.engText,
    this.mp3Link,
    this.altTag,
    this.langText,
    this.announcement,
    this.date,
  });

  QuoteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    showSignature = json['show_signature'] as String?;
    imageName = json['image_name'] as String?;
    cta = json['cta'] as String?;
    engText = json['eng_text'] as String?;
    mp3Link = json['mp3_link'] as String?;
    altTag = json['alt_tag'] as String?;
    langText = json['lang_text'] as String?;
    announcement = json['announcement'] as String?;
    date = json['date'] != null ? DateTime.parse(json['date'] as String) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['show_signature'] = showSignature;
    data['image_name'] = imageName;
    data['cta'] = cta;
    data['eng_text'] = engText;
    data['mp3_link'] = mp3Link;
    data['alt_tag'] = altTag;
    data['lang_text'] = langText;
    data['announcement'] = announcement;
    data['date'] = date?.toIso8601String();
    return data;
  }
}
