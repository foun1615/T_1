class Queue {
  int? id;
  String customerName, zone;
  int pax;
  DateTime createdAt;

  Queue({
    this.id,
    required this.customerName,
    required this.pax,
    required this.zone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'pax': pax,
      'zone': zone,
      'createdAt': createdAt.toString(),
    };
  }
}