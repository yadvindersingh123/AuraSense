import 'package:flutter/material.dart';
class smart_speaker extends StatefulWidget {
  const smart_speaker({super.key});

  @override
  State<smart_speaker> createState() => _smart_speakerState();
}

class _smart_speakerState extends State<smart_speaker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Speaker",
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
