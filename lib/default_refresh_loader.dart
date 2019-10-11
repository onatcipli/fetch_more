import 'package:flutter/material.dart';

class DefaultRefreshLoader extends StatelessWidget {
  const DefaultRefreshLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
