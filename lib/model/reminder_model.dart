// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReminderModel {
  final String activity;
  final String day;
  final String time;
  bool isReminded;
  ReminderModel({required this.activity, required this.day, required this.time, this.isReminded = false});
}
