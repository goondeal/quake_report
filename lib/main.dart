import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'src/earthquake.dart';
import 'src/used_colors.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Future<List<Earthquake>> getEarthquakes;

  @override
  void initState() {
    super.initState();
    getEarthquakes = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primaryColor: Colors.white, accentColor: Colors.redAccent),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 0.0,
          title: Text(
            'Quack Report',
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: getEarthquakes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildEarthquakes(snapshot.data);
            } else if (snapshot.hasError) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    'Connection error...Please check your INTERNET connection'),
              ));
            }
            return const Center(child: const CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildEarthquakes(List<Earthquake> earthquakes) {
    return RefreshIndicator(
      onRefresh: () => getEarthquakes = fetchData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        children: earthquakes.map((e) => _itemBuilder(e)).toList(),
      ),
    );
  }

  Widget _itemBuilder(Earthquake e) {
    final bool containsOf = e.location.contains('of');
    final date = DateTime.fromMillisecondsSinceEpoch(e.time);
    final _mStyle = const TextStyle(color: Colors.grey, fontSize: 14.0);
    const double MAG_CIRCLE_RADIUS = 46.0;

    return Column(
      children: <Widget>[
        InkWell(
          splashColor: Colors.redAccent,
          onTap: () => _launchURL(e.url),
          child: ListTile(
              leading: Container(
                width: MAG_CIRCLE_RADIUS,
                height: MAG_CIRCLE_RADIUS,
                decoration: BoxDecoration(
                  border: null,
                  borderRadius: BorderRadius.circular(0.5 * MAG_CIRCLE_RADIUS),
                  color: UsedColors.choose(e.magnitude),
                ),
                child: Center(
                  child: Text(
                    e.magnitude.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                      containsOf
                          ? e.location
                              .substring(0, e.location.indexOf('of') + 2)
                              .toUpperCase()
                          : 'NEAR THE',
                      style: _mStyle),
                  SizedBox(height: 4),
                  Text(
                    containsOf
                        ? e.location.substring(e.location.indexOf('of') + 2)
                        : e.location,
                    style: TextStyle(fontSize: 18.0),
                  )
                ],
              ),
              trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: _mStyle,
                    ),
                    Text(
                      date.hour <= 12
                          ? '${date.hour}:${date.minute.toString().padLeft(2, '0')} AM'
                          : '${date.hour - 12}:${date.minute.toString().padLeft(2, '0')} PM',
                      style: _mStyle,
                    )
                  ])),
        ),
        const Divider(),
        // FutureBuilder(future: _myFuture, builder: _launchStatus)
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Something wrong happened';
    }
  }

  Future<List<Earthquake>> fetchData() async {
    const String USGS_URL =
        "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&orderby=time&minmag=6&limit=10";
    http.Response response = await http.get(USGS_URL);
    return parseEarthquakes(response.body);
  }

  List<Earthquake> parseEarthquakes(String responseBody) {
    final features = json.decode(responseBody)['features'];
    return features
        .map<Earthquake>((e) => Earthquake.fromJson(e['properties']))
        .toList();
  }
}
