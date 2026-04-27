import 'watch_model.dart';

class Order {

  final String id;
  final List<Watch> items;
  final double total;

  Order({
    required this.id,
    required this.items,
    required this.total,
  });
}