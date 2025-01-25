import 'dart:async';

import 'package:bigworks_project/colors/colors.dart';
import 'package:bigworks_project/icons/icon.dart';
import 'package:bigworks_project/models/weather_api.dart';
import 'package:bigworks_project/pages/loading_page.dart';
import 'package:bigworks_project/services/weather_services.dart';
import 'package:bigworks_project/widgets/forcast_card.dart';
import 'package:bigworks_project/widgets/header.dart';
import 'package:bigworks_project/widgets/info_card.dart';
import 'package:flutter/material.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  WeatherService weatherService = WeatherService();
  Weather weather = Weather();
  TextEditingController _cityController = TextEditingController();
  String image = '';
  Color defaultColor = Colors.black;
  int hour = 0;
  bool isday = false;
  bool isNight = false;
  String icon = '';
  bool _isLoading = true;String city = 'Kochi';

  Future getWeather() async {
    weather = await weatherService.getWeatherData(city);
    setState(() {
      getWeather();
      _isLoading = false;
    });
  }
  void searchCity() async {
    if (_cityController.text.isNotEmpty) {
      city = _cityController.text;
      setState(() {
        _isLoading = true;
      });
      await getWeather();
    } else {
      // Handle empty input
      print('Please enter a city');
    }
  }

  void setday() async {
    if (weather.date.isNotEmpty) {
      List datetime = weather.date.split(' ');

      // Ensure that there are at least two elements in datetime
      if (datetime.length > 1) {
        var hours = datetime[1].split(':');

        // Ensure that hours is not empty
        if (hours.isNotEmpty) {
          var turnInt = int.parse(hours[0]);

          if (turnInt >= 19 || turnInt <= 5) {
            print(turnInt);
            setState(() {
              isday = false;
              isNight = true;
              defaultColor = nightappbarcolor;
            });
          } else if (turnInt > 5 && turnInt < 19) {
            setState(() {
              isNight = false;
              isday = true;
              defaultColor = dayappbarcolor;
            });
          }
        } else {
          print("Error: Invalid time format in weather.date");
        }
      } else {
        print("Error: Invalid date format in weather.date");
      }
    } else {
      print("Error: weather.date is empty or null");
    }
  }

  void day() async {
    setState(() {
      defaultColor = dayappbarcolor;
    });
    if (weather.text == 'Sunny') {
      setState(() {
        loadingIcon = sunnyIcon;
      });
    }
    if (weather.text == 'Overcast') {
      setState(() {
        loadingIcon = overcastDayIcon;
      });
    }
    if (weather.text == 'Partly cloud') {
      setState(() {
        loadingIcon = partlyCloudDayIcon;
      });
    }
  }

  void night() async {
    setState(() {
      defaultColor = nightappbarcolor;
    });

    if (weather.text == 'Partly Cloud') {
      setState(() {
        loadingIcon = partlyCloudyIconNight;
      });
    }
    if (weather.text == 'Clear') {
      setState(() {
        loadingIcon = clearNightIcon;
      });
    }
  }

  void gethour() {
    if (weather.date.isNotEmpty) {
      List datetime = weather.date.split(' ');
      if (datetime.length > 1) {
        var hours = datetime[1].split(':');
        if (hours.isNotEmpty) {
          var turnInt = int.parse(hours[0]);
          setState(() {
            hour = turnInt;
          });
        }
      }
    }
  }

  @override
  void initState() {
    getWeather();
    Timer.periodic(Duration(seconds: 2), (timer) {
      setday();
    });
    Timer.periodic(Duration(seconds: 3), (timer) {
      isday ? day() : night();
    });
    Timer.periodic(Duration(seconds: 3), (timer) {
      gethour();
    });
    Future.delayed(Duration(seconds: 2), () async {
      await weatherService.getWeatherData;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _isLoading
      ? LoadingPage()
      : Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(300),
              child: Header(
                  backgroundColor: defaultColor,
                  city_name: weather.city,
                  description: weather.text,
                  descriptionIMG: loadingIcon,
                  state_name: weather.state,
                  temp: weather.temp)),
          body: Container(
            decoration: BoxDecoration(
                gradient: isday
                    ? LinearGradient(
                        begin: const Alignment(-1.5, 8),
                        end: const Alignment(-1.5, -0.5),
                        colors: [Colors.white, defaultColor])
                    : LinearGradient(
                        begin: const Alignment(-1.5, 8),
                        end: const Alignment(-1.5, -0.5),
                        colors: [Colors.white, defaultColor])),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    color: Color.fromARGB(0, 255, 255, 255),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      itemCount: (weather.forecast.length > hour)
                          ? weather.forecast.length - hour - 1
                          : 0,
                      itemBuilder: (context, index) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 5),
                        child: Center(
                          // child: ForecastCard(
                          //     hour: weather.forecast[hour + index]['time']
                          //         .toString()
                          //         .split(' ')[1],
                          //     averageTemp: weather.forecast[hour + index]
                          //         ['temp_c'],
                          //     description: weather.forecast[hour + index]
                          //         ['condition']['text'],
                          //     descriptionIMG: weather.forecast[hour + index]
                          //             ['condition']['icon']
                          //         .toString()
                          //         .replaceAll('//', 'http://'))
                          child: ForecastCard(
                            hour: weather.forecast.isNotEmpty
                                ? weather.forecast[hour + index]['time']
                                    .toString()
                                    .split(' ')[1]
                                : '',
                            averageTemp: weather.forecast.isNotEmpty
                                ? weather.forecast[hour + index]['temp_c']
                                : 0,
                            description: weather.forecast.isNotEmpty
                                ? weather.forecast[hour + index]['condition']
                                    ['text']
                                : '',
                            descriptionIMG: weather.forecast.isNotEmpty
                                ? weather.forecast[hour + index]['condition']
                                        ['icon']
                                    .toString()
                                    .replaceAll('//', 'http://')
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: InformartionsCard(
                      humidity: weather.humidity,
                      uvIndex: weather.uvIndex,
                      wind: weather.wind),
                )
              ],
            ),
          ),
        );
}
