import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:weather/Coordinate.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  List<City> _cities = [];
  List<Forecast> _forecasts = [];

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
                            height: 32.0,
                            child: Text(forecast.name,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14))),
                        Container(
                            width: 72.0,
                            height: 32.0,
                            child: Text('${forecast.todayTemperature} C',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.blue))),
                        Container(
                            width: 72.0,
                            height: 32.0,
                            child: Text('${forecast.tomorrowTemperature} C',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 14))),
                        Container(
                            width: 72.0,
                            height: 32.0,
                            child: Text(
                                '${forecast.afterTomorrowTemperature} C',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 14))),
                      ],
                    ));
              }),
        ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          City city = await showSearch<City>(
              context: context, delegate: CitySearchDelegate());
          if (city != null) {
            _cities.add(city);
            _forecasts.add(await getForecast(city));
          }
          setState(() {
            for (var i in _forecasts) {
              print(i.name);
              print(i.todayTemperature);
              print(i.tomorrowTemperature);
              print(i.afterTomorrowTemperature);
            }
          });
        },
        tooltip: 'Weather',
        child: Icon(Icons.cloud),
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
              longitude: block['longitude'],
              latitude: block['latitude'])
        )
      );
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
      todayTemperature: timeSeries[0]['data']['instant']['details']['air_temperature'],
      tomorrowTemperature: timeSeries[24]['data']['instant']['details']['air_temperature'],
      afterTomorrowTemperature: timeSeries[48]['data']['instant']['details']['air_temperature']);
}
