import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/base/custom_snackbar.dart';
import 'package:reminder_app/model/reminder_model.dart';
import 'package:reminder_app/services/audio_services.dart';

import '../data/app_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDay = "Monday";
  String selectedTime = DateFormat.jm().format(DateTime.now().toLocal());
  String selectedActivity = "Wake up";

  List<ReminderModel> reminderList = [];
  late Timer reminderTimer;

  void setReminder(String day, String time, String activity) {
    SystemSound.play(SystemSoundType.alert);
    final newReminder = ReminderModel(activity: activity, day: day, time: time);
    reminderList.add(newReminder);
    selectedTime = DateFormat.jm().format(DateTime.now().toLocal()); // Reset selectedTime
  }

  void checkReminders() async {
    final currentTime = DateFormat.jm().format(DateTime.now().toLocal());
    final currentDay = DateFormat("EEEE").format(DateTime.now().toLocal());

    for (int i = 0; i < reminderList.length; i++) {
      final reminderTime = reminderList[i].time;
      final reminderDay = reminderList[i].day;

      if (currentTime == reminderTime && currentDay == reminderDay && reminderList[i].isReminded == false) {
        setState(() {
          reminderList[i].isReminded = true;
        });
        AudioServices.playAudio('alert_audio.mp3');
        showCustomSnackBar(context, 'Reminder: It\'s time to ${reminderList[i].activity}');
        break;
      }
    }
  }

  @override
  void initState() {
    const checkInterval = Duration(seconds: 1);
    reminderTimer = Timer.periodic(checkInterval, (timer) {
      checkReminders();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reminders"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    reminderList.clear();
                  });
                },
                icon: const Icon(
                  Icons.clear_all,
                  size: 32,
                )),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 6, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Reminder',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                height: 50,
                width: 600,
                decoration:
                    BoxDecoration(color: Colors.white, border: Border.all(width: 0.3), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: selectedDay,
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value!;
                        });
                      },
                      underline: const SizedBox(),
                      items: AppData.days.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const VerticalDivider(
                      color: Colors.black,
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          final dateTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            time.hour,
                            time.minute,
                          );

                          setState(() {
                            selectedTime = DateFormat.jm().format(dateTime);
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black,
                              )),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                    const VerticalDivider(
                      color: Colors.black,
                    ),
                    DropdownButton(
                      value: selectedActivity,
                      onChanged: (newValue) {
                        setState(() {
                          selectedActivity = newValue!;
                        });
                      },
                      underline: const SizedBox(),
                      items: AppData.activities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    setReminder(selectedDay, selectedTime, selectedActivity);
                  });
                },
                child: const Text("Set Reminder"),
              ),
              const SizedBox(height: 10),
              const Text(
                'Upcoming Tasks',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
              ),
              const SizedBox(height: 10),
              reminderList.isEmpty
                  ? const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'No Upcoming task',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: reminderList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              height: 100,
                              width: 600,
                              decoration: BoxDecoration(
                                  color: reminderList[reminderList.length - index - 1].isReminded ? Colors.green : Colors.indigo,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        reminderList[reminderList.length - index - 1].activity,
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 26, color: Colors.white),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
                                        child: Center(
                                          child: Text(
                                            reminderList[reminderList.length - index - 1].day,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: reminderList[reminderList.length - index - 1].isReminded
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${reminderList[reminderList.length - index - 1].time} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                      reminderList[reminderList.length - index - 1].isReminded
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 32,
                                            )
                                          : SizedBox()
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
