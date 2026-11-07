class Subject {
  final String id;
  String name;

  Subject({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Subject.fromJson(Map<String, dynamic> j) =>
      Subject(id: j['id'], name: j['name']);
}
