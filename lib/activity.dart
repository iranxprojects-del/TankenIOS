import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 0)
class Activity extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String status;

  @HiveField(2)
  late DateTime date;

  // سازنده (Constructor) بدون پارامتر برای سازگاری با Hive
  Activity(); 
}