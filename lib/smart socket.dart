import 'package:flutter/material.dart';
class smart_socket extends StatefulWidget {
  const smart_socket({super.key});

  @override
  State<smart_socket> createState() => _smart_socketState();
}

class _smart_socketState extends State<smart_socket> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Socket",
        style: TextStyle(
            fontWeight: FontWeight.bold
        ),
      ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios)

        ),
      ),

    );
  }
}
