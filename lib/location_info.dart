import 'package:flutter/material.dart';

class LocationInfo extends StatelessWidget {
  final String coordinates;

  const LocationInfo({
    Key? key,
    required this.coordinates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Location Info',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(5.0),
        children: [
          const Icon(
            Icons.gps_not_fixed_outlined,
            color: Colors.green,
            size: 80.0,
          ),
          const SizedBox(
            height: 3.0,
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Coordinates:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(coordinates),
              contentPadding: const EdgeInsets.only(left: 7.0),
            ),
          ),
        ],
      ),
    );
  }
}
