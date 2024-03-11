import 'package:isar/isar.dart';

import 'assigned_order.dart';
import 'orderer.dart';
// import 'recipient.dart';

part 'order.g.dart';

@collection
class Order {
  Id? id;

  late String title;

  int? amount;

  double? cost;

  @Backlink(to: 'orders')
  final author = IsarLink<Orderer>();

  @Backlink(to: 'order')
  final assignedOrders = IsarLinks<AssignedOrder>();
}
