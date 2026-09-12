import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

// ------------------------------------------------------------
// MAIN APP
// ------------------------------------------------------------

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

// ------------------------------------------------------------
// HOME PAGE
// ------------------------------------------------------------

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  // Text controller for city search
  final TextEditingController cityController =
      TextEditingController(text: 'Chennai');

  // Weather information
  String cityName = 'Chennai';
  String country = 'India';

  double? temperature;
  double? humidity;
  double? windSpeed;

  String weatherDescription = 'Loading...';
  String weatherIcon = '☀️';

  bool isLoading = false;
  String? errorMessage;

  // ------------------------------------------------------------
  // INITIALIZATION
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Load weather after the screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchWeather();
    });
  }

  // ------------------------------------------------------------
  // SEARCH WEATHER
  // ------------------------------------------------------------

  Future<void> searchWeather() async {
    final city = cityController.text.trim();

    // Check empty city
    if (city.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name.';
      });
      return;
    }

    // Show loading
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // --------------------------------------------------------
      // STEP 1: FIND CITY COORDINATES
      // --------------------------------------------------------

      final geocodingUrl = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {
          'name': city,
          'count': '1',
          'language': 'en',
          'format': 'json',
        },
      );

      final geoResponse = await http
          .get(geocodingUrl)
          .timeout(const Duration(seconds: 10));

      if (geoResponse.statusCode != 200) {
        throw Exception('Location service error');
      }

      final dynamic geoData = jsonDecode(geoResponse.body);

      if (geoData is! Map<String, dynamic>) {
        throw Exception('Invalid location response');
      }

      final results = geoData['results'];

      if (results == null ||
          results is! List ||
          results.isEmpty) {
        throw Exception('City not found');
      }

      final firstResult = results.first;

      if (firstResult is! Map<String, dynamic>) {
        throw Exception('Invalid city information');
      }

      // Get latitude
      final latitudeValue = firstResult['latitude'];

      // Get longitude
      final longitudeValue = firstResult['longitude'];

      if (latitudeValue is! num || longitudeValue is! num) {
        throw Exception('Coordinates not available');
      }

      final double latitude = latitudeValue.toDouble();
      final double longitude = longitudeValue.toDouble();

      // Get city name
      final String foundCity =
          firstResult['name']?.toString() ?? city;

      // Get country
      final String foundCountry =
          firstResult['country']?.toString() ?? '';

      // --------------------------------------------------------
      // STEP 2: GET WEATHER
      // --------------------------------------------------------

      final weatherUrl = Uri.https(
        'api.open-meteo.com',
        '/v1/forecast',
        {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current':
              'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
      );

      final weatherResponse = await http
          .get(weatherUrl)
          .timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode != 200) {
        throw Exception('Weather service error');
      }

      final dynamic weatherData = jsonDecode(weatherResponse.body);

      if (weatherData is! Map<String, dynamic>) {
        throw Exception('Invalid weather response');
      }

      final current = weatherData['current'];

      if (current is! Map<String, dynamic>) {
        throw Exception('Current weather not available');
      }

      // --------------------------------------------------------
      // GET WEATHER VALUES
      // --------------------------------------------------------

      final temperatureValue = current['temperature_2m'];
      final humidityValue = current['relative_humidity_2m'];
      final windValue = current['wind_speed_10m'];
      final weatherCodeValue = current['weather_code'];

      if (temperatureValue is! num ||
          humidityValue is! num ||
          windValue is! num ||
          weatherCodeValue is! num) {
        throw Exception('Weather information is incomplete');
      }

      final double currentTemperature =
          temperatureValue.toDouble();

      final double currentHumidity =
          humidityValue.toDouble();

      final double currentWind =
          windValue.toDouble();

      final int weatherCode =
          weatherCodeValue.toInt();

      // --------------------------------------------------------
      // UPDATE SCREEN
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        cityName = foundCity;
        country = foundCountry;

        temperature = currentTemperature;
        humidity = currentHumidity;
        windSpeed = currentWind;

        weatherDescription =
            getWeatherDescription(weatherCode);

        weatherIcon =
            getWeatherIcon(weatherCode);

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to get weather.\n'
            'Please check your internet connection '
            'and city name.';
      });
    }
  }

  // ------------------------------------------------------------
  // WEATHER DESCRIPTION
  // ------------------------------------------------------------

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';

      case 1:
      case 2:
        return 'Partly Cloudy';

      case 3:
        return 'Overcast';

      case 45:
      case 48:
        return 'Foggy';

      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'Drizzle';

      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'Rain';

      case 71:
      case 73:
      case 75:
      case 77:
        return 'Snow';

      case 80:
      case 81:
      case 82:
        return 'Rain Showers';

      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';

      default:
        return 'Unknown Weather';
    }
  }

  // ------------------------------------------------------------
  // WEATHER ICON
  // ------------------------------------------------------------

  String getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return '☀️';

      case 1:
        return '🌤️';

      case 2:
        return '⛅';

      case 3:
        return '☁️';

      case 45:
      case 48:
        return '🌫️';

      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return '🌦️';

      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return '🌧️';

      case 71:
      case 73:
      case 75:
      case 77:
        return '❄️';

      case 80:
      case 81:
      case 82:
        return '🌧️';

      case 95:
      case 96:
      case 99:
        return '⛈️';

      default:
        return '🌤️';
    }
  }

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                        textInputAction:
                            TextInputAction.search,
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

                    // Search button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        onPressed:
                            isLoading ? null : searchWeather,
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF1565C0),
                        ),
                        iconSize: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ------------------------------------------------
                // ERROR MESSAGE
                // ------------------------------------------------

                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    margin:
                        const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.25),
                      borderRadius:
                          BorderRadius.circular(15),
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                cityName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
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

        // Weather icon
        Text(
          weatherIcon,
          style: const TextStyle(
            fontSize: 90,
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 40),

        // --------------------------------------------------------
        // INFORMATION CARDS
        // --------------------------------------------------------

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

        // --------------------------------------------------------
        // REFRESH BUTTON
        // --------------------------------------------------------

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed:
                isLoading ? null : searchWeather,
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
              foregroundColor:
                  const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
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
            textAlign: TextAlign.center,
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

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }
}
