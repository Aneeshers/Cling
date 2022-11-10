class QtyPerTime {
  QtyPerTime({required this.date, required this.close});

  final DateTime date;
  final double close;

  QtyPerTime.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        close = json['close'].toDouble();
}
