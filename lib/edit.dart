import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data.dart';
import 'package:todo_list/main.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskEntity task;

  EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.task.name);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        title: Text("Edit Task"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            onPressed: () {
              widget.task.name = _controller.text;
              widget.task.priority = widget.task.priority;
              if (widget.task.isInBox) {
                widget.task.save();
              } else {
                final Box<TaskEntity> box = Hive.box(taskBoxName);
                box.add(widget.task);
              }
              Navigator.of(context).pop();
            },
            label: const Row(
              children: [
                Text("Save Changes"),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  CupertinoIcons.check_mark,
                  size: 18,
                )
              ],
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                    flex: 1,
                    child: PriorityCheckbox(
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.HIGH;
                        });
                      },
                      label: "High",
                      color: highPriorityColor,
                      isSelected: widget.task.priority == Priority.HIGH,
                    )),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                    flex: 1,
                    child: PriorityCheckbox(
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.MEDIUM;
                        });
                      },
                      label: "Medium",
                      color: mediumPriorityColor,
                      isSelected: widget.task.priority == Priority.MEDIUM,
                    )),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                    flex: 1,
                    child: PriorityCheckbox(
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.LOW;
                        });
                      },
                      label: "Low",
                      color: lowPriorityColor,
                      isSelected: widget.task.priority == Priority.LOW,
                    )),
              ],
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                label: Text(
                  "Add A New Task",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .apply(fontSizeFactor: 1.2),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PriorityCheckbox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback onTap;

  const PriorityCheckbox(
      {super.key,
      required this.label,
      required this.color,
      required this.isSelected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    // final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            border: Border.all(
                width: 2, color: secondaryTextColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(4)),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CheckboxShape(
                  value: isSelected,
                  color: color,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CheckboxShape extends StatelessWidget {
  final bool value;
  final Color color;

  const _CheckboxShape({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              size: 12,
              color: themeData.colorScheme.onPrimary,
            )
          : null,
    );
  }
}
