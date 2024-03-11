import 'package:isar/isar.dart';

import 'order.dart';
import 'recipient.dart';
part 'assigned_order.g.dart';

@collection
class AssignedOrder {
  Id? id;

  final order = IsarLink<Order>();

  DateTime? date;

  int amount = 0;

  double cost = 0.0;

  @Backlink(to: 'assignedOrders')
  final recipient = IsarLink<Recipient>();
}
