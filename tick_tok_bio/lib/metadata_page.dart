import 'package:flutter/material.dart';
import 'main.dart';

class MetadataSection extends StatefulWidget {
  const MetadataSection({Key key}) : super(key: key);

  @override
  _MetadataSectionState createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<MetadataSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        color: Colors.red,
        onPressed: () {
          return;
        },
      ),
    );
  }
}
