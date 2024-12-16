class Models {
  final String? title;

  Models({required this.title});

  factory Models.fromJson(json) {
    return Models(title: json['title']);
  }
}
