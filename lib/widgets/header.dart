import 'package:bigworks_project/icons/icon.dart';
import 'package:bigworks_project/services/weather_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; 
import 'package:lottie/lottie.dart';
  String city = 'Los Angeles';
class Header extends StatefulWidget {
  Header(
      {super.key,
      required this.backgroundColor,
      required this.city_name,
      required this.description,
      required this.descriptionIMG,
      required this.state_name,
      required this.temp});

  String city_name;
  String state_name;
  double temp;
  String descriptionIMG;
  String description;
  Color backgroundColor;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  WeatherService weatherService = WeatherService();
  IconData textfieldClearIcon = Icons.clear;
  var _textfieldController = TextEditingController();
  bool _isLoadinf = false;
  bool notFound = false;

  String _formattedTime = '';

  @override
  void initState() {
    super.initState();
    _getCurrentTime(); // Call this to fetch the current time when the widget initializes

    // Optionally update the time every minute (you can customize this interval)
    Timer.periodic(Duration(minutes: 1), (timer) {
      _getCurrentTime();  // Update time periodically if needed
    });
  }

  // Function to get the current time
  void _getCurrentTime() {
    DateTime now = DateTime.now(); // Get the current date and time
     _formattedTime = DateFormat('hh:mm a').format(now); // Format it as HH:mm
    setState(() {});  // Update the state to refresh the UI
  }

  loadingFunc() async {
    await weatherService.getWeatherData(city);
    setState(() {
      _isLoadinf = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: MediaQuery.of(context).size.height / 3,
      backgroundColor: widget.backgroundColor,
      title: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            _isLoadinf
                ? Lottie.network(rainyIcon, height: 50)
                : Container(
                    width: 700,
                    height: 50,
                    child: TextField(
                      controller: _textfieldController,
                      onSubmitted: (value) {
                        setState(() {
                          _isLoadinf = true;
                          city = value;
                          Future.delayed(Duration(seconds: 1), () {
                            loadingFunc();
                            _textfieldController.clear();
                          });
                        });
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              _textfieldController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            icon: Icon(textfieldClearIcon)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        hintText: 'Search for  cities',
                        hintStyle: TextStyle(
                            color: Color.fromARGB(133, 255, 255, 255)),
                        filled: true,
                        fillColor: Color.fromARGB(18, 255, 255, 255),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15)),
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
            SizedBox(height: 25),
            notFound
                ? Text('not found')
                : Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [  
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.temp.toString() + '°C',
                              style: const TextStyle(
                                  fontSize: 55, fontWeight: FontWeight.w200),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.city_name,
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.state_name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),SizedBox(
                            width: 100,
                            child: Text(
                              _formattedTime,  
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Container(
                          width: 120,
                          height: 150,
                          child: Column(
                            children: [
                              Lottie.network(widget.descriptionIMG.toString(),
                                  fit: BoxFit.cover),
                              Text(
                                widget.description,
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}