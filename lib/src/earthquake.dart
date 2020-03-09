
class Earthquake{
  final double magnitude;
  final String location;
  final String url;
  final int time;

  const Earthquake({this.magnitude, this.location, this.time, this.url});

  Earthquake.fromJson(Map<String, dynamic> json):
    magnitude =  double.parse(json['mag'].toString()),
    location = json['place'].toString(),
    time = int.parse(json['time'].toString()),
    url = json['url'].toString();

  

}

