import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {

  late String location;
  late String time;
  late String flag;
  late String url; // Location url for API endpoint
  late bool isDaytime;

  // This is the constructor
  WorldTime({ required this.location, required this.flag, required this.url });

  Future<void> getTime() async {

    try {
      var uri = Uri.http('worldtimeapi.org', 'api/timezone/$url');
      Response response = await get(uri);
      Map data = jsonDecode(response.body);
      print(data.toString());
      String datetime = data['datetime'];
      bool hasPositiveOffset = data['utc_offset'].startsWith('+') ? true : false;
      String offset = data['utc_offset'].substring(1,3);

      DateTime now = DateTime.parse(datetime);
      Duration durationHours = Duration(hours: int.parse(offset));
      now = hasPositiveOffset ? now.add(durationHours) : now.subtract(durationHours);

      // Setting the time property
      print('The current hour is ${now.hour}');
      isDaytime = now.hour > 6 && now.hour < 20 ? true : false;
      time = DateFormat.jm().format(now);
    }
    catch (e) {
      print('caught error: $e');
      time = 'could not get time data';
    }
  }

}