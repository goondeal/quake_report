
class Earthquake{
  final double magnitude;
  final String location;
  final String url;
  final int time;

  const Earthquake({this.magnitude, this.location, this.time, this.url});

  factory Earthquake.fromJson(Map<String, dynamic> json){
    return Earthquake(
      magnitude: double.parse(json['mag'].toString()) ,
      location: json['place'] as String,
      time: json['time'] as int,
      url: json['url'] as String,
    );
  }

}

