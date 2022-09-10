class allStocks {
  final List<Stock> all;

  allStocks(this.all);
   
}


class Stock
{
  final String symbol;
  final String urlImage;
  final String name;

  const Stock({
    required this.symbol,
    required this.name,
    required this.urlImage,
  });
  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
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
