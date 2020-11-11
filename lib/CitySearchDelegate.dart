import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'City.dart';
import 'main.dart';

class CitySearchDelegate extends SearchDelegate<City> {
  City _city;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        this.close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
          GestureDetector(
              onTap: () {
                this.close(context, _city);
              },
              child: Container(
                width: 328.0,
                height: 32.0,
                child: Text(this.query,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
              )),
          Container(
            width: 328.0,
            padding: EdgeInsets.all(4.0),
            child: Text('*tap on city name to add',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 10)),
          ),
        ])));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context).textTheme.subhead;
    return FutureBuilder<List<City>>(
        future: getCities(query),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.hasData ? snapshot.data.length : 0,
            itemBuilder: (BuildContext context, int i) {
              final City chosenCity = snapshot.data[i];
              return ListTile(
                title: RichText(
                  text: TextSpan(
                    text: chosenCity.name.substring(0, query.length),
                    style: theme.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                    children: <TextSpan>[
                      TextSpan(
                          text: chosenCity.name.substring(query.length),
                          style: theme),
                    ],
                  ),
                ),
                onTap: () {
                  this.query = chosenCity.name;
                  this._city = chosenCity;
                  showResults(context);
                },
              );
            },
          );
        });
  }
}
