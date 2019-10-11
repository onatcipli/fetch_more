import 'package:flutter/material.dart';

class DefaultErrorBuilder extends StatelessWidget {
  const DefaultErrorBuilder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Failed to fetch posts'),
    );
  }
}
