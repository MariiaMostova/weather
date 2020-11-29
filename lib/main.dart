import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:weather/Coordinate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'City.dart';
import 'CitySearchDelegate.dart';
import 'Forecast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  List<City> _cities = [];
  List<Forecast> _forecasts = [];

  bool _status = false;
  int _animationType = 1;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  int checkAnimationType(double temperature) {
    if (temperature <= 0.0) {
      _animationType = 1;
    } else if (temperature <= 10.0) {
      _animationType = 2;
    } else {
      _animationType = 3;
    }
    return _animationType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
      ),
      body: new Column(children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    width: 72.0,
                    height: 32.0,
                    child: Text('City name',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14))),
                Container(
                    width: 72.0,
                    height: 32.0,
                    child: Text('Today',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14, color: Colors.blue))),
                Container(
                    width: 72.0,
                    height: 32.0,
                    child: Text('Tomorrow',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14))),
                Container(
                    width: 72.0,
                    height: 32.0,
                    child: Text('2 day after',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14))),
              ],
            )),
        Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: Divider(
              color: Color(0xAA1976D2),
            )),
        new Expanded(
            child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
          child: ListView.builder(
              itemCount: _forecasts.length,
              itemBuilder: (BuildContext context, int i) {
                Forecast forecast = _forecasts[i];
                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            width: 72.0,
                            child: Text(forecast.name,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14))),
                        Container(
                          width: 72.0,
                          height: 72.0,
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(children: <Widget>[
                                  animationBuilder(
                                      _animationController,
                                      _status,
                                      checkAnimationType(
                                          forecast.todayTemperature)),
                                  Text('${forecast.todayTemperature} C',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.blue))
                                ])
                              ]),
                        ),
                        Container(
                          width: 72.0,
                          height: 72.0,
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(children: <Widget>[
                                   animationBuilder(
                                          _animationController,
                                          _status,
                                          checkAnimationType(
                                              forecast.tomorrowTemperature)),
                                  Text('${forecast.tomorrowTemperature} C',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 14)),
                                ])
                              ]),
                        ),
                        Container(
                            width: 72.0,
                            height: 72.0,
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(children: <Widget>[
                                    animationBuilder(
                                        _animationController,
                                        _status,
                                        checkAnimationType(
                                            forecast.afterTomorrowTemperature)),
                                    Text(
                                        '${forecast.afterTomorrowTemperature} C',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(fontSize: 14))
                                  ])
                                ])),
                      ],
                    ));
              }),
        )),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          City city = await showSearch<City>(
              context: context, delegate: CitySearchDelegate());
          if (city != null) {
            //   for (var i = 0; i < _cities.length; i++) {
            //     if (city.name != _cities[i].name) {
            _cities.add(city);
            _forecasts.add(await getForecast(city));
            //   }
            // }
          }
          setState(() {});
        },
        tooltip: 'Weather',
        child: Icon(Icons.playlist_add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<List<City>> getCities(String prefix) async {
  Uri uri = Uri.https(
      'wft-geo-db.p.rapidapi.com', '/v1/geo/cities', {'namePrefix': prefix});

  Response response = await get(uri, headers: {
    'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
    'x-rapidapi-key': '9c6a840687msh17546e68651240cp12c6c6jsn991cbe9bc4e6'
  });

  if (response.statusCode == 200) {
    List<City> cities = [];
    for (var block in jsonDecode(response.body)['data']) {
      cities.add(City(
          name: block['city'],
          coordinate: Coordinate(
              longitude: block['longitude'], latitude: block['latitude'])));
    }
    return cities;
  } else {
    throw Exception('Failed');
  }
}

Future<Forecast> getForecast(City city) async {
  Uri uri = Uri.https(
      "api.met.no", "/weatherapi/locationforecast/2.0/compact.json", {
    "lat": '${city.coordinate.latitude}',
    "lon": '${city.coordinate.longitude}'
  });

  Response response =
      await get(uri, headers: {'Content-type': 'application/json'});

  var timeSeries = jsonDecode(response.body)['properties']['timeseries'];
  return Forecast(
      name: city.name,
      todayTemperature: timeSeries[0]['data']['instant']['details']
          ['air_temperature'],
      tomorrowTemperature: timeSeries[24]['data']['instant']['details']
          ['air_temperature'],
      afterTomorrowTemperature: timeSeries[48]['data']['instant']['details']
          ['air_temperature']);
}

Widget animationBuilder(
    AnimationController animationController, bool status, int animationType) {
  if (animationType == 1) {
    return RotationTransition(
      turns: animationController,
      child: Container(
        width: 72.0,
        height: 32.0,
        child: SizeTransition(
          sizeFactor: animationController,
          axis: Axis.vertical,
          axisAlignment: 1,
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                Icons.ac_unit,
                color: Colors.lightBlue,
                size: 16.0,
              ))),
    ));
  } else if (animationType == 2) {
    Size size = new Size(24, 24);
    return SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.2, 0.0),
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticIn,
        )),
        child: ScaleTransition(
            scale: animationController,
            child: Icon(
              Icons.cloud,
              size: 32.0,
              color: Colors.blueAccent,
            )));
  } else {
    return SizeTransition(
      sizeFactor: animationController,
      axis: Axis.horizontal,
      axisAlignment: 1,
      child: RotationTransition(
          turns: animationController,
          child: Icon(
            Icons.wb_sunny,
            color: Colors.amber,
            size: 32.0,
          )),
    );
  }
}
