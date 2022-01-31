class Band {
  final String id;
  final String name;
  final int votes;

  const Band({required this.id, required this.name, this.votes = 0});

  factory Band.fromSocket(Map<String, dynamic> json) {
    return Band(
      id: json["id"] ?? 'no-id', 
      name: json["name"] ?? 'no-name', 
      votes: json["votes"] ?? 'no-votes'
    );
  }

  Band copyWith({String? id,  String? name,  int? votes}) {
    return Band(
      id: id ?? this.id,
      name: name ?? this.name,
      votes: votes ?? this.votes
    );
  }

  static const bands = [
    Band(id: '1', name: 'Goku', votes: 0),
    Band(id: '2', name: 'Vegeta', votes: 0),
    Band(id: '3', name: 'Gohan', votes: 0),
    Band(id: '4', name: 'Trunks', votes: 0),
  ];
}