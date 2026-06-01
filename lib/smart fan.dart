import 'package:flutter/material.dart';
class smart_fan extends StatefulWidget {
  const smart_fan({super.key});

  @override
  State<smart_fan> createState() => _smart_fanState();
}

class _smart_fanState extends State<smart_fan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Fan",
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
