import 'package:flutter/material.dart';
///dialog de delete
class StandardDeleteDialog extends StatelessWidget {
  ///construtor
  StandardDeleteDialog({super.key, required this.name, required this.function});
  ///nome que vai aparecer no dialog
  String name;
  ///funcao do dialog
  final Function() function;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(width: 0)),
      title: const Text(
        'Delete',
        style: TextStyle(color: Colors.red),
      ),
      content: Text(
        'Are you sure you want to delete the $name?',
        style: const TextStyle(color: Colors.black, fontSize: 15),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            function();
            Navigator.pop(context);
          },
          child: const Text('Yes', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
