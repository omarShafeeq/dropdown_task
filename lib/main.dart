import 'package:dropdown_example/dropdown.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DropdownExample());
}

class DropdownExample extends StatelessWidget {
  const DropdownExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dropdown(),
    );
  }
}
