class Transaction {
  final String id;
  final String type;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}