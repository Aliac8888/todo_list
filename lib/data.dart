import 'package:hive_flutter/adapters.dart';
part 'data.g.dart';

@HiveType(typeId: 0)
class TaskEntity extends HiveObject {
  @HiveField(0)
  String name = '';
  @HiveField(1)
  bool isCompleted = false;
  @HiveField(2)
  Priority priority = Priority.LOW;
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  LOW,
  @HiveField(1)
  MEDIUM,
  @HiveField(2)
  HIGH
}
