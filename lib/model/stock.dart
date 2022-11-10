class allStocks {
  final List<Asset> all;

  allStocks(this.all);
}

class Asset {
  final String symbol;
  final String urlImage;
  final String name;

  const Asset({
    required this.symbol,
    required this.name,
    required this.urlImage,
  });
  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        symbol: json['symbol'],
        name: json['name'],
        urlImage: json['urlImage'],
      );

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'urlImage': urlImage,
      };
}
