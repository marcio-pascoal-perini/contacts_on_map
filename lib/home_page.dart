import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:contacts_on_map/contact_info.dart';
import 'package:contacts_on_map/db.dart';
import 'package:contacts_on_map/geocoding_api.dart';
import 'package:contacts_on_map/location_info.dart';
import 'package:contacts_on_map/slide_right_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoogleMapController _controller;
  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(23.113062, -30.106429),
    zoom: 0,
  );
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  String _selectedMapType = '';
  BitmapDescriptor _currentLocationMarkerColor =
      BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRed,
  );
  String _selectedLocationMarkerColor = '';

  @override
  void initState() {
    _getSettings();
    super.initState();
  }

  Future<Uint8List> _generateThumbnail({required String name}) async {
    Color _backgroundColor = Color.fromRGBO(
      Random().nextInt(128),
      Random().nextInt(128),
      Random().nextInt(128),
      1,
    );
    String _initials = '';
    if (name.isNotEmpty) {
      _initials = name.trim();
      _initials = _initials.split(RegExp(' +')).map((s) => s[0]).take(2).join();
      _initials = _initials.toUpperCase();
    }
    final ui.PictureRecorder _pictureRecorder = ui.PictureRecorder();
    final Canvas _canvas = Canvas(_pictureRecorder);
    final Paint _paint = Paint()..color = _backgroundColor;
    _canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(0.0, 0.0, 100.0, 100.0),
      ),
      _paint,
    );
    TextPainter _painter = TextPainter(textDirection: TextDirection.ltr);
    _painter.text = TextSpan(
      text: _initials,
      style: const TextStyle(
        fontSize: 40.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    const int _width = 100;
    const int _height = 100;
    _painter.layout();
    _painter.paint(
      _canvas,
      Offset(
        (_width * 0.5) - _painter.width * 0.5,
        (_height * 0.5) - _painter.height * 0.5,
      ),
    );
    final _image = await _pictureRecorder.endRecording().toImage(
          _width,
          _height,
        );
    final _data = await _image.toByteData(format: ui.ImageByteFormat.png);
    return _data!.buffer.asUint8List();
  }

  Future<void> _getSettings() async {
    _selectedMapType = await DB.getCurrentMapType();
    setState(() {
      _currentMapType = _stringToMapType(
        value: _selectedMapType,
      );
    });
    _selectedLocationMarkerColor = await DB.getLocationMarkerColor();
    _currentLocationMarkerColor = _stringToBitmapDescriptor(
      value: _selectedLocationMarkerColor,
    );
  }

  Future<void> _showMessage({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    int seconds = 5,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(
          seconds: seconds,
        ),
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 7.0),
                  title: const Text(
                    'Map type:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      value: _selectedMapType,
                      items: [
                        'Hybrid',
                        'None',
                        'Normal',
                        'Satellite',
                        'Terrain',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMapType = newValue.toString();
                          _currentMapType = _stringToMapType(
                            value: _selectedMapType,
                          );
                        });
                        DB.setCurrentMapType(_selectedMapType);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 7.0),
                  title: const Text(
                    'Location marker color:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      value: _selectedLocationMarkerColor,
                      items: [
                        'Blue',
                        'Green',
                        'Orange',
                        'Red',
                        'Violet',
                        'Yellow',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        _selectedLocationMarkerColor = newValue.toString();
                        _currentLocationMarkerColor = _stringToBitmapDescriptor(
                          value: _selectedLocationMarkerColor,
                        );
                        _updateLocation();
                        DB.setLocationMarkerColor(_selectedLocationMarkerColor);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BitmapDescriptor _stringToBitmapDescriptor({required String value}) {
    BitmapDescriptor _result;
    switch (value.toLowerCase()) {
      case 'blue':
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        );
        break;
      case 'green':
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        );
        break;
      case 'orange':
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
        break;
      case 'red':
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
        break;
      case 'violet':
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
        break;
      case 'yellow':
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
        break;
      default:
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
    }
    return _result;
  }

  MapType _stringToMapType({required String value}) {
    MapType _result = MapType.values.firstWhere(
      (e) => e.toString() == 'MapType.' + value.toLowerCase(),
    );
    return _result;
  }

  Future<void> _updateCoordinates() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      _showMessage(
        message: 'The App is currently not allowed to access the contact list.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    final List<Contact>? _contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: true,
    );
    if (_contacts!.isEmpty) {
      _showMessage(
        message: 'The contact list is empty.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      DB.deleteAllFromContactsTable();
      return;
    }
    int _counter;
    List<String> _addresses = [];
    List<String> _emails = [];
    List<String> _numbers = [];
    await DB.resetContactsTableControl();
    for (Contact contact in _contacts) {
      _counter = 0;
      _addresses = ['', '', ''];
      for (Address address in contact.addresses) {
        _addresses[_counter] = address.address;
        _counter++;
        if (_counter >= 3) break;
      }
      bool _hasAddress = false;
      for (String element in _addresses) {
        if (element.isNotEmpty) {
          _hasAddress = true;
          break;
        }
      }
      _counter = 0;
      _emails = ['', '', ''];
      for (Email email in contact.emails) {
        _emails[_counter] = email.address;
        _counter++;
        if (_counter >= 3) break;
      }
      _counter = 0;
      _numbers = ['', '', ''];
      for (Phone phone in contact.phones) {
        _numbers[_counter] = phone.number;
        _counter++;
        if (_counter >= 3) break;
      }
      if (_hasAddress) {
        String _id = contact.id.trim();
        String _name = contact.displayName.trim();
        String _firstCoordinates = '';
        String _secondCoordinates = '';
        String _thirdCoordinates = '';
        var _records = await DB.getContactsByID(id: _id);
        Uint8List _thumbnail1 = contact.thumbnail ?? Uint8List.fromList([]);
        Uint8List _thumbnail2 = await _generateThumbnail(name: _name);
        if (_records.isEmpty) {
          _firstCoordinates = await GeocodingAPI.getCoordinates(
            address: _addresses[0],
          );
          _secondCoordinates = await GeocodingAPI.getCoordinates(
            address: _addresses[1],
          );
          _thirdCoordinates = await GeocodingAPI.getCoordinates(
            address: _addresses[2],
          );
          await DB.insertInContactsTable(
            id: _id,
            name: _name,
            thumbnail1: _thumbnail1,
            thumbnail2: _thumbnail2,
            firstAddress: _addresses[0],
            secondAddress: _addresses[1],
            thirdAddress: _addresses[2],
            firstEmail: _emails[0],
            secondEmail: _emails[1],
            thirdEmail: _emails[2],
            firstNumber: _numbers[0],
            secondNumber: _numbers[1],
            thirdNumber: _numbers[2],
            firstCoordinates: _firstCoordinates,
            secondCoordinates: _secondCoordinates,
            thirdCoordinates: _thirdCoordinates,
            control: false,
          );
        } else {
          if (_records.first['name'].toString() == _name) {
            _thumbnail2 = _records.first['thumbnail2'];
          }
          if (_records.first['first_address'].toString() == _addresses[0]) {
            _firstCoordinates = _records.first['first_coordinates'];
          } else {
            _firstCoordinates = await GeocodingAPI.getCoordinates(
              address: _addresses[0],
            );
          }
          if (_records.first['second_address'].toString() == _addresses[1]) {
            _secondCoordinates = _records.first['second_coordinates'];
          } else {
            _secondCoordinates = await GeocodingAPI.getCoordinates(
              address: _addresses[1],
            );
          }
          if (_records.first['third_address'].toString() == _addresses[2]) {
            _thirdCoordinates = _records.first['third_coordinates'];
          } else {
            _thirdCoordinates = await GeocodingAPI.getCoordinates(
              address: _addresses[2],
            );
          }
          await DB.updateContactTable(
            id: _id,
            name: _name,
            thumbnail1: _thumbnail1,
            thumbnail2: _thumbnail2,
            firstAddress: _addresses[0],
            secondAddress: _addresses[1],
            thirdAddress: _addresses[2],
            firstEmail: _emails[0],
            secondEmail: _emails[1],
            thirdEmail: _emails[2],
            firstNumber: _numbers[0],
            secondNumber: _numbers[1],
            thirdNumber: _numbers[2],
            firstCoordinates: _firstCoordinates,
            secondCoordinates: _secondCoordinates,
            thirdCoordinates: _thirdCoordinates,
            control: false,
          );
        }
      }
    }
    await DB.deleteAllFromContactsTableByControl();
  }

  Future<void> _updateLocation() async {
    final PermissionStatus _permissionStatus = await Location().hasPermission();
    final double _latitude;
    final double _longitude;

    if (_permissionStatus != PermissionStatus.granted) {
      _showMessage(
        message:
            'The App is currently not allowed to access the fine location.',
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
      );
      return;
    }
    LocationData _locationData = await Location().getLocation();
    if (_locationData.latitude == null) {
      _showMessage(
        message: 'Problems accessing the fine location.',
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
      );
      return;
    }
    if (_locationData.longitude == null) {
      _showMessage(
        message: 'Problems accessing the fine location.',
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
      );
      return;
    }
    _latitude = _locationData.latitude!;
    _longitude = _locationData.longitude!;
    final LatLng _latLng = LatLng(_latitude, _longitude);
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _latLng,
          zoom: 10,
        ),
      ),
    );
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('-1,-1,-1'),
          position: _latLng,
          infoWindow: InfoWindow(
            title: 'You are here!',
            snippet: '👉 Tap here for more info',
            onTap: () {
              Navigator.push(
                context,
                SlideRightRoute(
                  page: LocationInfo(
                    coordinates: '${_latLng.latitude},${_latLng.longitude}',
                  ),
                ),
              );
            },
          ),
          icon: _currentLocationMarkerColor,
        ),
      );
    });
  }

  Future<void> _updateMap() async {
    setState(() {
      _showMessage(
        message: 'Updating the Map...',
        backgroundColor: Colors.green,
        textColor: Colors.black,
        seconds: 10,
      );
    });
    await _updateCoordinates();
    await _updateMarkes();
    await _updateLocation();
  }

  Future<void> _updateMarkes() async {
    LatLng _getLatLng({required String coordinates}) {
      var _coordinates = coordinates.split(',');
      double _latitude = double.parse(_coordinates[0]);
      double _longitude = double.parse(_coordinates[1]);
      return LatLng(_latitude, _longitude);
    }

    BitmapDescriptor _getIcon({
      required Uint8List thumbnail1,
      required Uint8List thumbnail2,
    }) {
      BitmapDescriptor _result;
      if (thumbnail1.isNotEmpty) {
        _result = BitmapDescriptor.fromBytes(thumbnail1);
      } else if (thumbnail2.isNotEmpty) {
        _result = BitmapDescriptor.fromBytes(thumbnail2);
      } else {
        _result = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
      }
      return _result;
    }

    Marker _getMarker({required var record, required String coordinates}) {
      return Marker(
        markerId: MarkerId('${record['id'].trim()},$coordinates'),
        position: _getLatLng(coordinates: coordinates),
        infoWindow: InfoWindow(
          title: record['name'],
          snippet: '👉 Tap here for more info',
          onTap: () {
            Navigator.push(
              context,
              SlideRightRoute(
                page: ContactInfo(
                  record: record,
                  coordinates: coordinates,
                ),
              ),
            );
          },
        ),
        icon: _getIcon(
          thumbnail1: record['thumbnail1'],
          thumbnail2: record['thumbnail2'],
        ),
      );
    }

    _markers.clear();
    var _records = await DB.getAllFromContactsTable();
    for (var record in _records) {
      if (record['first_coordinates'].toString().isNotEmpty) {
        _markers.add(_getMarker(
          record: record,
          coordinates: record['first_coordinates'].toString(),
        ));
      }
      if (record['second_coordinates'].toString().isNotEmpty) {
        _markers.add(_getMarker(
          record: record,
          coordinates: record['second_coordinates'].toString(),
        ));
      }
      if (record['third_coordinates'].toString().isNotEmpty) {
        _markers.add(_getMarker(
          record: record,
          coordinates: record['third_coordinates'].toString(),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Contacts on Map',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Update Map',
            onPressed: _updateMap,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Options',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: GoogleMap(
        mapType: _currentMapType,
        zoomControlsEnabled: true,
        initialCameraPosition: _cameraPosition,
        markers: _markers,
        onMapCreated: (GoogleMapController c) {
          _controller = c;
          _updateMap();
        },
      ),
    );
  }
}
