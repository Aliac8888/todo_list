import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_list/data.dart';
import 'package:todo_list/edit.dart';

const taskBoxName = "tasks";
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryContainer));
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794CCF);
const Color primaryContainer = Color(0xff794CCF);
const Color secondaryTextColor = Color.fromARGB(255, 127, 134, 143);
const Color highPriorityColor = primaryColor;
const Color mediumPriorityColor = Color(0xffF09819);
const Color lowPriorityColor = Color(0xff3BE1F1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
            headlineSmall:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(color: secondaryTextColor),
            border: InputBorder.none,
            iconColor: secondaryTextColor),
        colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            primaryContainer: primaryContainer,
            secondary: primaryColor,
            onSecondary: Colors.white,
            background: Color(0xffF3F5F8),
            onBackground: primaryTextColor,
            onSurface: primaryTextColor),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');

  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditTaskScreen(
                        task: TaskEntity(),
                      )));
            },
            label: const Row(
              children: [
                Text("Add New Task"),
                SizedBox(
                  width: 4,
                ),
                Icon(CupertinoIcons.add)
              ],
            )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                themeData.colorScheme.primary,
                themeData.colorScheme.primaryContainer,
              ])),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "To Do List",
                          style: themeData.textTheme.headlineSmall!
                              .apply(color: themeData.colorScheme.onPrimary),
                        ),
                        Icon(
                          CupertinoIcons.share,
                          color: themeData.colorScheme.onPrimary,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20),
                        ],
                      ),
                      child: TextField(
                          onChanged: (value) {
                            searchKeywordNotifier.value = controller.text;
                          },
                          controller: controller,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.search),
                              label: Text("search tasks..."))),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: searchKeywordNotifier,
                builder: (context, value, index) {
                  return ValueListenableBuilder<Box<TaskEntity>>(
                    valueListenable: box.listenable(),
                    builder: (context, box, index) {
                      final List<TaskEntity> items;
                      if (controller.text.isEmpty) {
                        items = box.values.toList();
                      } else {
                        items = box.values
                            .where((task) => task.name
                                .toLowerCase()
                                .contains(controller.text))
                            .toList();
                      }
                      if (items.isNotEmpty) {
                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Today",
                                          style: themeData
                                              .textTheme.headlineSmall!
                                              .apply(fontSizeFactor: 0.9),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 4),
                                          width: 100,
                                          height: 3,
                                          decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(1.5)),
                                        )
                                      ]),
                                  MaterialButton(
                                    color: const Color(0xffEAEFF5),
                                    textColor: secondaryTextColor,
                                    elevation: 0,
                                    onPressed: () {
                                      box.clear();
                                    },
                                    child: const Row(
                                      children: [
                                        Text("Delete All"),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(
                                          CupertinoIcons.delete_solid,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            } else {
                              final TaskEntity task =
                                  items[index - 1]; //box.getAt(index);
                              return TaskItem(task: task);
                            }
                          },
                        );
                      } else {
                        return const EmptyState();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/empty_state.svg",
          height: 200,
          width: 120,
        ),
        const SizedBox(height: 14),
        const Text("You currently have no tasks")
      ],
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double taskContainerHeight = 84;
  static const double containerBorderRadius = 8;
  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;

    switch (widget.task.priority) {
      case Priority.HIGH:
        priorityColor = highPriorityColor;
        break;
      case Priority.MEDIUM:
        priorityColor = mediumPriorityColor;
        break;
      case Priority.LOW:
        priorityColor = lowPriorityColor;
        break;
      default:
        priorityColor = lowPriorityColor;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task)));
      },
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TaskItem.containerBorderRadius),
            color: themeData.colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
            ]),
        height: TaskItem.taskContainerHeight,
        margin: EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              width: 5,
              height: TaskItem.taskContainerHeight,
              decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(TaskItem.containerBorderRadius),
                    topLeft: Radius.circular(TaskItem.containerBorderRadius),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;
  final GestureTapCallback onTap;

  const MyCheckBox({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              !value ? Border.all(color: secondaryTextColor, width: 2) : null,
          color: value ? primaryColor : null,
        ),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                size: 16,
                color: themeData.colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }
}
