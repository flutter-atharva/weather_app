import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/api.dart';
import 'hourly_Forecast_item.dart';
import 'additional_info.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  String cityName = "London";

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherApiKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "An unexpected error occured";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    weather = getCurrentWeather();
                  });
                },
                tooltip: "Refresh",
                icon: const Icon(Icons.refresh)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final pressure = data['list'][0]['main']['pressure'];
          final windSpeed = data['list'][0]['wind']['speed'];
          final humidity = data['list'][0]['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                "$cityName",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "$currentTemp K",
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text('$currentSky', style: const TextStyle(fontSize: 20))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //weather forecast cards
                const Text(
                  "Weather Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height: 150,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
    
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        
                        final HourlyForcast = data['list'][index + 1];
                        final HourlySky = data['list'][index + 1]['weather'][0]['main'];
                        final time = DateTime.parse(HourlyForcast['dt_txt']);
                        return HourlyForcastItem(time: DateFormat.j().format(time), icon: HourlySky == 'Clouds' || HourlySky == 'Rain' ? Icons.cloud : Icons.sunny, temperature: HourlyForcast['main']['temp'].toString());
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
                //additional information
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(icon: Icons.water_drop, label: "Humidity", value: humidity.toString()),
                    AdditionalInfoItem(icon: Icons.air, label: "Windspeed", value: windSpeed.toString()),
                    AdditionalInfoItem(icon: Icons.speed, label: "Pressure", value: pressure.toString())
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
