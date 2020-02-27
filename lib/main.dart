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
  Future<void> _myFuture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(     
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.redAccent
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Quack Report',style: const TextStyle(color: Colors.red)),
          centerTitle: true,
        ),
        
        body: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return _buildEarthquakes(snapshot.data);
            }
            else if (snapshot.hasError){
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Connection error...Please check your INTERNET connection'),
                )
              );
            }

            return const Center(child: const CircularProgressIndicator());

          },
        ),
      ),
    );
  }



  Widget _buildEarthquakes(List<Earthquake> earthquakes) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: earthquakes.map( (e) => _itemBuilder(e)).toList(),
      );


  }


  Widget _itemBuilder(Earthquake e) {
    final bool ofIn = e.location.contains('of');
    final date = DateTime.fromMillisecondsSinceEpoch(e.time);
    final _mStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 12.0      
    );
    
    return Column(
      children: <Widget>[
        
          InkWell(
            splashColor: Colors.redAccent,
              onTap: (){
                setState(() {
                 _myFuture = _launchURL(e.url);
                });
              },
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  
                  Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: null,
                      borderRadius: BorderRadius.circular(16),
                      color: UsedColors.choose(e.magnitude),
                    ),

                    child: Center(
                      child: Text(
                      e.magnitude.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ),


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[
                        Text(
                          ofIn?
                           e.location.substring(0, e.location.indexOf('of')+2).toUpperCase() : 'NEAR THE',
                           style: _mStyle
                           ),
                        SizedBox(height: 2),

                        Text(
                          ofIn ?
                          e.location.substring(e.location.indexOf('of') + 2) : e.location,
                          style: TextStyle(fontSize: 18.0),
                        )   
                      ],
                      ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('${date.day}/${date.month}/${date.year}',style: _mStyle,),
                      SizedBox(height: 4.0),
                      Text(
                        date.hour <= 12 ?
                        '${date.hour}:${date.minute} AM':
                        '${date.hour - 12}:${date.minute.toString().padLeft(2,'0')} PM',
                        style: _mStyle,
                        )
                    ],
                  )
                ],
              ),
            ),
          ),
        const Divider(),
        FutureBuilder(future: _myFuture, builder: _launchStatus)
      ],
    );

  }

    Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) { await launch(url); }
    else{throw'Something wrong happened';}
}

Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

   Future<List<Earthquake>> fetchData() async{
    final String USGS_URL = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&orderby=time&minmag=6&limit=10";
    http.Response response = await http.get(USGS_URL);
      return parseEarthquakes(response.body);
    }

    List<Earthquake> parseEarthquakes(String responseBody){
      final features = json.decode(responseBody)['features'];
      return features.map<Earthquake>( (e) => 
                Earthquake.fromJson(e['properties']) ).toList();
    }

  }





