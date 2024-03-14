import 'package:isar/isar.dart';

import 'order.dart';
part 'orderer.g.dart';

@collection
class Orderer {
  Id? id;

  late String name;

  String? idNumber;

  String? phoneNumber;
  late final orders = IsarLinks<Order>();
}
