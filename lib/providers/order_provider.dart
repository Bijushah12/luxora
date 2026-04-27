import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/watch_model.dart';

class OrderProvider extends ChangeNotifier {

  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void placeOrder(List<Watch> cartItems, double total) {

    _orders.add(
      Order(
        id: DateTime.now().toString(),
        items: cartItems,
        total: total,
      ),
    );

    notifyListeners();
  }
}