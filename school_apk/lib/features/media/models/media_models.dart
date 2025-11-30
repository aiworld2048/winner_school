class MediaBanner {
  MediaBanner({
    required this.title,
    required this.image,
    required this.description,
  });

  final String title;
  final String image;
  final String? description;

  factory MediaBanner.fromJson(Map<String, dynamic> json) {
    return MediaBanner(
      title: json['title']?.toString() ?? 'Banner',
      image: (json['image'] ?? json['img'] ?? '').toString(),
      description: json['description'] as String?,
    );
  }
}

class PromotionItem {
  PromotionItem({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  factory PromotionItem.fromJson(Map<String, dynamic> json) {
    return PromotionItem(
      title: json['title']?.toString() ?? 'Promotion',
      body: json['description']?.toString() ?? '',
    );
  }
}

class ContactInfo {
  ContactInfo({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      label: json['title']?.toString() ?? 'Contact',
      value: json['value']?.toString() ?? '',
    );
  }
}

