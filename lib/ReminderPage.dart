import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant/CancelPage.dart';
import 'package:plant/Complete.dart';
import 'package:plant/InProgress.dart';
import 'package:plant/Ongoing.dart'; // Using lucide_icons for high-quality icons

class Reminderpage extends StatefulWidget {
  const Reminderpage({super.key});

  @override
  State<Reminderpage> createState() => _ReminderpageState();
}

class _ReminderpageState extends State<Reminderpage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF3F5F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: screenWidth,
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text.rich(
                            TextSpan(
                              text: "Set ",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: "Reminder",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                    color: Color(0xFF4C6B44),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio:
                        2.2, // Adjusted aspect ratio to make cards taller
                    children: [
                      TaskStatusCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Ongoing()),
                          );
                        },
                        title: "Ongoing",
                        color: Color(0xFFA07E8D),
                        icon: Icons.sync,
                      ),
                      TaskStatusCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Inprogress(),
                            ),
                          );
                        },
                        title: "In progress",
                        color: Color(0xFFE2A571),
                        icon: Icons.access_time_outlined,
                      ),
                      TaskStatusCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Complete()),
                          );
                        },
                        title: "Complete",
                        color: Color(0xFF4C6B44),
                        icon: Icons.check_circle_outline,
                      ),
                      TaskStatusCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CancelPage(),
                            ),
                          );
                        },
                        title: "Cancel",
                        color: Color(0xFFD85C5C),
                        icon: Icons.cancel_outlined,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Task Status Cards
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            TimeOfDay selectedTime = TimeOfDay.now();
                            List<bool> selectedDays = List.generate(
                              7,
                              (index) => false,
                            );
                            TextEditingController taskController =
                                TextEditingController();

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  content: Container(
                                    width: double.infinity,
                                    height: 350,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Select time",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () async {
                                            final TimeOfDay? picked =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime: selectedTime,
                                                );
                                            if (picked != null &&
                                                picked != selectedTime) {
                                              setState(() {
                                                selectedTime = picked;
                                              });
                                            }
                                          },
                                          child: Text(
                                            selectedTime.format(context),
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: [
                                            for (int i = 0; i < 6; i++)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedDays[i] =
                                                        !selectedDays[i];
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      selectedDays[i]
                                                          ? Color(0xFF4C6B44)
                                                          : Colors
                                                              .grey
                                                              .shade200,
                                                  child: Text(
                                                    [
                                                      'S',
                                                      'M',
                                                      'T',
                                                      'W',
                                                      'T',
                                                      'F',
                                                    ][i],
                                                    style: TextStyle(
                                                      color:
                                                          selectedDays[i]
                                                              ? Colors.white
                                                              : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 30),
                                        Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller: taskController,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: "Your task",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              tasks.add({
                                                'title': taskController.text,
                                                'time': selectedTime.format(
                                                  context,
                                                ),
                                                'icon': Icons.access_time,
                                              });
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF4C6B44),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            width: 50,
                                            child: Center(
                                              child: Text(
                                                "Done",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "Add Task",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.add_circle,
                            color: Color(0xFF4C6B44),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "All tasks",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),

          // Task List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskItem(
                    title: tasks[index]['title'],
                    time: tasks[index]['time'],
                    icon: tasks[index]['icon'],
                    height: 70, // Increased height
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Task Status Card Widget
class TaskStatusCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final GestureTapCallback? onTap;

  const TaskStatusCard({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// Task Item Widget
class TaskItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final double height;

  const TaskItem({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.black54, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
