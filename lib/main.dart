import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'How Fast I Am',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  String name = '';
  late TextEditingController controller;
  late FocusNode focusNode;
  bool validate = false;
  late Timer timer;
  int countDown = 10;
  String start = 'Press button to start!';
  Map<String, int> sorted = <String, int>{};

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    getData();
    Future.delayed(Duration.zero, () => openDialog(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Fast as Fuck'),
          actions: [
            TextButton(
                onPressed: () {
                  openDialog(context);
                },
                child: Text(name,
                    style: const TextStyle(fontSize: 12, color: Colors.white)))
          ],
          leading: Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.emoji_events),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ))),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          SizedBox(
              height: .125 * MediaQuery.of(context).size.height,
              child: const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                      child: Center(
                          child: Text('Ranking',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20)))))),
          SizedBox(
              height: 0.05 * MediaQuery.of(context).size.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: Text('No.', style: TextStyle(fontSize: 15)))),
                  Expanded(
                      flex: 5,
                      child: Center(
                          child:
                              Text('Player', style: TextStyle(fontSize: 15)))),
                  Expanded(
                      flex: 2,
                      child: Center(
                          child: Text('Score', style: TextStyle(fontSize: 15))))
                ],
              )),
          SizedBox(
            height: .825 * MediaQuery.of(context).size.height,
            child: ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(thickness: 1),
              itemBuilder: (BuildContext context, int index) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 1, child: Center(child: Text('${index + 1}'))),
                      Expanded(
                          flex: 5,
                          child: Center(
                              child: Text(sorted.keys.elementAt(index)))),
                      Expanded(
                          flex: 2,
                          child: Center(
                              child: Text('${sorted.values.elementAt(index)}')))
                    ]);
              },
            ),
          )
        ]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Expanded(child: SizedBox()),
            Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: const Text('Timer:')),
            Expanded(
                child: Text('$countDown',
                    style: Theme.of(context).textTheme.headline5)),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Text(start),
            ),
            Expanded(
                child: Text(
              '$counter',
              style: Theme.of(context).textTheme.headline4,
            )),
            const Expanded(child: SizedBox()),
            Expanded(
                child: Ink(
              width: 120,
              decoration: const ShapeDecoration(
                  color: Colors.lightBlue, shape: CircleBorder()),
              child: IconButton(
                  onPressed: () {
                    if (counter == 0) {
                      startTimer();
                      setState(() {
                        start = 'You have pushed the button this many times:';
                      });
                    }
                    if (countDown != 0) {
                      setState(() {
                        counter++;
                      });
                    }
                  },
                  iconSize: 60,
                  icon: const Icon(Icons.add, color: Colors.white)),
            )),
            const Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }

  Future<String?> openDialog(BuildContext context) {
    return showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: const Text('Your Name'),
                  content: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Enter your name here',
                      errorText: validate == true
                          ? 'Your Name can\'t be empty!'
                          : null,
                    ),
                    controller: controller,
                    onSubmitted: (_) {
                      submit();
                    },
                    focusNode: focusNode,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          submit();
                        },
                        child: const Text('Submit',
                            style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ),
              ),
            ));
  }

  submit() {
    if (controller.text.isEmpty) {
      validate = true;
      focusNode.requestFocus();
    } else {
      setState(() {
        validate = false;
        Navigator.of(context).pop();
        name = controller.text;
        reSet();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
    }
    controller.clear();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (countDown == 0) {
          setState(() {
            timer.cancel();
          });
          comPare();
          reTry();
        } else {
          setState(() {
            countDown--;
          });
        }
      },
    );
  }

  void comPare() async {
    final data = await SharedPreferences.getInstance();
    int comPare = data.getInt(name) ?? 0;
    if (comPare < counter) {
      setState(() {
        start = 'Congratulation!\nNew High Score!';
        data.setInt(name, counter);
        getData();
      });
    } else if (comPare == counter) {
      setState(() {
        start = 'Almost got it!';
      });
    } else {
      setState(() {
        start = 'Try better next time!';
      });
    }
  }

  void reTry() {
    final snackBar = SnackBar(
      content: const Text('Retry?'),
      action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            setState(() {
              reSet();
            });
          }),
      duration: const Duration(days: 365),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void reSet() {
    countDown = 10;
    counter = 0;
    start = 'Press button to start!';
  }

  void getData() async {
    final data = await SharedPreferences.getInstance();
    final getKeys = data.getKeys();
    final dict = <String, int>{};
    for (String key in getKeys) {
      dict[key] = data.getInt(key) ?? 0;
    }
    sorted = Map.fromEntries(
        dict.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
  }
}
