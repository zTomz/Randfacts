import 'package:hive/hive.dart';

part 'fact.g.dart';

@HiveType(typeId: 1)
class Fact {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final String uuid;
  @HiveField(2, defaultValue: "")
  String? categorie;
  @HiveField(3)
  bool isLiked;

  Fact({
    required this.text,
    required this.uuid,
    this.categorie = "",
    this.isLiked = false,
  });
}
