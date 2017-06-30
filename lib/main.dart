import 'package:flutter/material.dart';
import 'package:spyfall/location/location.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(
          title: 'Flutter Demo Home Page'
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationManager locationManager;

  _MyHomePageState() {
    RegExp locationPattern = new RegExp(r"[A-z]");
    RegExp singleRolePattern = new RegExp(r"\*[A-z]");
    String multiRolePattern = "**";
    locationManager = new LocationManager(new LocationInputFormat(
        locationPattern, singleRolePattern, multiRolePattern));
    locationManager.parseFile();
  }

  void _setLocationManager() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Text(
          "${locationManager?.location}",
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _setLocationManager,
        tooltip: 'Get New Location',
        child: new Icon(Icons.add),
      ),
    );
  }
}
