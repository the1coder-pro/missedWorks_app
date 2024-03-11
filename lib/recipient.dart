import 'package:isar/isar.dart';

import 'assigned_order.dart';

part 'recipient.g.dart';

@collection
class Recipient {
  Id? id;

  late String name;

  String? idNumber;

  String? phoneNumber;

  final assignedOrders = IsarLinks<AssignedOrder>();
}
