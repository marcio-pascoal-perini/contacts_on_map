import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

const String _key = 'YOUR API KEY';

class GeocodingAPI {
  static Future<String> getAddress({required String coordinates}) async {
    if (coordinates.isEmpty) return '';
    try {
      String _api = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=';
      Uri _uri = Uri.parse(_api + coordinates + '&key=' + _key);
      http.Response _response = await http.get(_uri);
      if (_response.statusCode != 200) return '';
      var _data = convert.jsonDecode(_response.body);
      if (_data['status'].toString().toLowerCase() != 'ok') return '';
      return _data['results'][0]['formatted_address'].toString();
    } on Exception catch (_) {
      return '';
    }
  }

  static Future<String> getCoordinates({required String address}) async {
    if (address.isEmpty) return '';
    try {
      String _api =
          'https://maps.googleapis.com/maps/api/geocode/json?address=';
      Uri _uri = Uri.parse(_api + address + '&key=' + _key);
      http.Response _response = await http.get(_uri);
      if (_response.statusCode != 200) return '';
      var _data = convert.jsonDecode(_response.body);
      if (_data['status'].toString().toLowerCase() != 'ok') return '';
      double _lat = _data['results'][0]['geometry']['location']['lat'];
      double _lng = _data['results'][0]['geometry']['location']['lng'];
      return '${_lat.toString()},${_lng.toString()}';
    } on Exception catch (_) {
      return '';
    }
  }
}
