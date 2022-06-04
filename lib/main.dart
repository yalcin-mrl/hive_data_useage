import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_data_useage/model/ogrenci.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('uygulama');
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  }
  var encriptionKey =
      base64Url.decode(await secureStorage.read(key: 'key') ?? 'yalcin');
  var sifreBox = await Hive.openBox('ozel',
      encryptionCipher: HiveAesCipher(encriptionKey));
  await sifreBox.put('secret', 'Hive is cool');
  await sifreBox.put('password', '123456');
  print(sifreBox.get('secret'));
  print(sifreBox.get('sifre'));

  await Hive.openBox('testBox');
  Hive.registerAdapter(OgrenciAdapter());
  Hive.registerAdapter(GozRenkAdapter());
  await Hive.openBox<Ogrenci>('ogrenciler');
  await Hive.openLazyBox<int>('sayilar');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    var box = Hive.box('testBox');
    box.clear();
    box.add('yalcin');
    box.add('marul');
    box.add(123);

    await box.put('tc', '1209347844');
    await box.put('tema', 'dark');
    box.values.forEach((element) {
      debugPrint(element.toString());
    });
  }

  void _customData() async {
    var yalcin = Ogrenci(5, 'yalcin', GozRenk.MAVI);
    var yasin = Ogrenci(10, 'yasin', GozRenk.YESIL);
    var box = Hive.box<Ogrenci>('ogrenciler');
    await box.clear();
    box.add(yalcin);
    box.add(yasin);
    debugPrint(box.toMap().toString());
  }

  void _lazyBoxEx() async {
    var sayilar = Hive.lazyBox<int>('sayilar');
    for (int i = 0; i < 50; i++) {
      await sayilar.add(i);
    }
    for (int i = 0; i < 50; i++) {
      debugPrint((await sayilar.getAt(i)).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _customData,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
