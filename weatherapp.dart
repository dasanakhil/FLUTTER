import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController cityController =
      TextEditingController(text: 'Chennai');

  String cityName = 'Chennai';
  String country = 'India';

  double? temperature;
  double? humidity;
  double? windSpeed;

  String weatherDescription = 'Loading...';
  String weatherIcon = '☀️';

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchWeather();
    });
  }

  // ------------------------------------------------------------
  // SEARCH CITY
  // ------------------------------------------------------------

  Future<void> searchWeather() async {
    final city = cityController.text.trim();

    if (city.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // First find the city's latitude and longitude.
      final geocodingUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=${Uri.encodeComponent(city)}'
        '&count=1'
        '&language=en'
        '&format=json',
      );

      final geoResponse = await http.get(geocodingUrl);

      if (geoResponse.statusCode != 200) {
        throw Exception('Unable to find location');
      }

      final geoData = jsonDecode(geoResponse.body);

      if (geoData['results'] == null ||
          (geoData['results'] as List).isEmpty) {
        throw Exception('City not found');
      }

      final result = geoData['results'][0];

      final double latitude =
          (result['latitude'] as num).toDouble();

      final double longitude =
          (result['longitude'] as num).toDouble();

      final String foundCity =
          result['name'] ?? city;

      final String foundCountry =
          result['country'] ?? '';

      // ----------------------------------------------------------
      // GET WEATHER
      // ----------------------------------------------------------

      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
        '&timezone=auto',
      );

      final weatherResponse = await http.get(weatherUrl);

      if (weatherResponse.statusCode != 200) {
        throw Exception('Unable to get weather');
      }

      final weatherData = jsonDecode(weatherResponse.body);

      final current = weatherData['current'];

      final double currentTemperature =
          (current['temperature_2m'] as num).toDouble();

      final double currentHumidity =
          (current['relative_humidity_2m'] as num).toDouble();

      final double currentWind =
          (current['wind_speed_10m'] as num).toDouble();

      final int weatherCode =
          (current['weather_code'] as num).toInt();

      setState(() {
        cityName = foundCity;
        country = foundCountry;

        temperature = currentTemperature;
        humidity = currentHumidity;
        windSpeed = currentWind;

        weatherDescription =
            getWeatherDescription(weatherCode);

        weatherIcon = getWeatherIcon(weatherCode);

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to find weather. Check the city name and try again.';
      });
    }
  }

  // ------------------------------------------------------------
  // WEATHER DESCRIPTION
  // ------------------------------------------------------------

  String getWeatherDescription(int code) {
    if (code == 0) {
      return 'Clear Sky';
    }

    if (code == 1 || code == 2 || code == 3) {
      return 'Partly Cloudy';
    }

    if (code == 45 || code == 48) {
      return 'Foggy';
    }

    if (code >= 51 && code <= 57) {
      return 'Drizzle';
    }

    if (code >= 61 && code <= 67) {
      return 'Rain';
    }

    if (code >= 71 && code <= 77) {
      return 'Snow';
    }

    if (code >= 80 && code <= 82) {
      return 'Rain Showers';
    }

    if (code >= 95 && code <= 99) {
      return 'Thunderstorm';
    }

    return 'Unknown';
  }

  // ------------------------------------------------------------
  // WEATHER ICON
  // ------------------------------------------------------------

  String getWeatherIcon(int code) {
    if (code == 0) {
      return '☀️';
    }

    if (code == 1 || code == 2) {
      return '🌤️';
    }

    if (code == 3) {
      return '☁️';
    }

    if (code == 45 || code == 48) {
      return '🌫️';
    }

    if (code >= 51 && code <= 57) {
      return '🌦️';
    }

    if (code >= 61 && code <= 67) {
      return '🌧️';
    }

    if (code >= 71 && code <= 77) {
      return '❄️';
    }

    if (code >= 80 && code <= 82) {
      return '🌧️';
    }

    if (code >= 95 && code <= 99) {
      return '⛈️';
    }

    return '🌤️';
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Weather App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // SEARCH BOX
                  // ------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) {
                            searchWeather();
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter city name',
                            hintStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          onPressed: searchWeather,
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFF1565C0),
                          ),
                          iconSize: 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 45),

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),

                  // ------------------------------------------------
                  // LOADING
                  // ------------------------------------------------

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  else
                    buildWeatherContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // WEATHER CONTENT
  // ------------------------------------------------------------

  Widget buildWeatherContent() {
    return Column(
      children: [
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 5),
            Text(
              cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        Text(
          country,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 25),

        // Weather Icon
        Text(
          weatherIcon,
          style: const TextStyle(
            fontSize: 100,
          ),
        ),

        const SizedBox(height: 10),

        // Temperature
        Text(
          temperature == null
              ? '--°'
              : '${temperature!.round()}°C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 70,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Description
        Text(
          weatherDescription,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 40),

        // Information Cards
        Row(
          children: [
            Expanded(
              child: buildInfoCard(
                Icons.water_drop,
                'Humidity',
                humidity == null
                    ? '--'
                    : '${humidity!.round()}%',
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: buildInfoCard(
                Icons.air,
                'Wind',
                windSpeed == null
                    ? '--'
                    : '${windSpeed!.round()} km/h',
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // Refresh Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: searchWeather,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Refresh Weather',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Weather data powered by Open-Meteo',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // INFORMATION CARD
  // ------------------------------------------------------------

  Widget buildInfoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }
}
