import 'package:flutter/material.dart';
import 'package:server_mobile/server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Server'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String h = "Start Server";
  String link = "http not start yet";
  bool k = true;
  Color colorbutton = Colors.green.shade700;
  Color colorwrite = Colors.red.shade700;
  static TextEditingController myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Server.IP();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child:
                  Text(link, style: TextStyle(fontSize: 20, color: colorwrite)),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    readOnly: true,
                    controller: myController,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder())),
              ),
            ),
            ElevatedButton(
              child: Text(h),
              style: ElevatedButton.styleFrom(primary: colorbutton),
              onPressed: () {
                if (k) {
                  Server.start();
                  setState(() {
                    h = "Stop Server";
                    link = "http://" + Server.ip + ":8080";
                    colorbutton = Colors.red.shade700;
                    colorwrite = Colors.green.shade700;
                  });
                } else {
                  Server.stop();
                  setState(() {
                    h = "Start Server";
                    link = "http not start yet";
                    colorbutton = Colors.green.shade700;
                    colorwrite = Colors.red.shade700;
                  });
                }
                k = !k;
              },
            )
          ],
        ),
      ),
    );
  }
}
