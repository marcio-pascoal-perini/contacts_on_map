import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfo extends StatefulWidget {
  final Map<dynamic, dynamic> record;
  final String coordinates;

  const ContactInfo({
    Key? key,
    required this.record,
    required this.coordinates,
  }) : super(key: key);

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  String _getAddress() {
    if (widget.record['first_coordinates'] == widget.coordinates) {
      return widget.record['first_address'];
    }
    if (widget.record['second_coordinates'] == widget.coordinates) {
      return widget.record['second_address'];
    }
    if (widget.record['third_coordinates'] == widget.coordinates) {
      return widget.record['third_address'];
    }
    return '';
  }

  Uint8List _getBytes() {
    Uint8List _result = widget.record['thumbnail2'];
    if (widget.record['thumbnail1'].isNotEmpty) {
      _result = widget.record['thumbnail1'];
    }
    return _result;
  }

  Column _getEmails() {
    final List<Widget> _rowsList = [];

    void _addInRowList({required String email}) {
      final List<Widget> _widgetList = [];
      IconButton _iconButton = IconButton(
        icon: const Icon(
          Icons.mail,
          color: Colors.green,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(0.0),
        onPressed: () {
          _sendEmail(email: email);
        },
      );
      final Text _text = Text(email);
      _widgetList.add(_iconButton);
      _widgetList.add(_text);
      _rowsList.add(
        Row(
          children: _widgetList,
        ),
      );
    }

    if (widget.record['first_email'].isNotEmpty) {
      _addInRowList(email: widget.record['first_email']);
    }
    if (widget.record['second_email'].isNotEmpty) {
      _addInRowList(email: widget.record['second_email']);
    }
    if (widget.record['third_email'].isNotEmpty) {
      _addInRowList(email: widget.record['third_email']);
    }
    return Column(children: _rowsList);
  }

  Column _getNumbers() {
    final List<Widget> _rowsList = [];

    void _addInRowList({required String number}) {
      final List<Widget> _widgetList = [];
      IconButton _iconButtonPhone = IconButton(
        icon: const Icon(
          Icons.phone,
          color: Colors.green,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(0.0),
        onPressed: () {
          _makeCall(number: number);
        },
      );
      IconButton _iconButtonSMS = IconButton(
        icon: const Icon(
          Icons.sms_outlined,
          color: Colors.green,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(0.0),
        onPressed: () {
          _sendSMS(number: number);
        },
      );
      final Text _text = Text(number);
      _widgetList.add(_iconButtonPhone);
      _widgetList.add(_iconButtonSMS);
      _widgetList.add(_text);
      _rowsList.add(
        Row(
          children: _widgetList,
        ),
      );
    }

    if (widget.record['first_number'].isNotEmpty) {
      _addInRowList(number: widget.record['first_number']);
    }
    if (widget.record['second_number'].isNotEmpty) {
      _addInRowList(number: widget.record['second_number']);
    }
    if (widget.record['third_number'].isNotEmpty) {
      _addInRowList(number: widget.record['third_number']);
    }
    return Column(children: _rowsList);
  }

  Future<void> _makeCall({required String number}) async {
    if (await canLaunch('tel:$number')) {
      await launch('tel:$number');
    } else {
      _showMessage(
        message: 'Could not launch $number.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _sendEmail({required String email}) async {
    if (await canLaunch('mailto:$email')) {
      await launch('mailto:$email');
    } else {
      _showMessage(
        message: 'Could not launch $email.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _sendSMS({required String number}) async {
    if (await canLaunch('sms:$number')) {
      await launch('sms:$number');
    } else {
      _showMessage(
        message: 'Could not launch $number.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showMessage({
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Contact Info',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(5.0),
        children: [
          Image.memory(
            _getBytes(),
            height: 80.0,
            width: 80.0,
          ),
          const SizedBox(
            height: 3.0,
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Name:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(widget.record['name']),
              contentPadding: const EdgeInsets.only(left: 7.0),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Number(s):',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              subtitle: _getNumbers(),
              contentPadding: const EdgeInsets.only(left: 7.0),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Email(s):',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              subtitle: _getEmails(),
              contentPadding: const EdgeInsets.only(left: 7.0),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Address:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(_getAddress()),
              contentPadding: const EdgeInsets.only(left: 7.0),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Coordinates:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(widget.coordinates),
              contentPadding: const EdgeInsets.only(left: 7.0),
            ),
          ),
        ],
      ),
    );
  }
}
