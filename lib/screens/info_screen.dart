import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipo'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'movie app', 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 50),
              
              // info de Adrian
              const CircleAvatar(
                radius: 65,
                backgroundColor: Color(0xFF2EFEEA),
                child: CircleAvatar(
                  radius: 62,
                  backgroundImage: NetworkImage('https://i.postimg.cc/XYv1Vbh9/IMG-1300.jpg'), // foto de Adrian
                  backgroundColor: Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 15),
              const Text('Adrian Andrade', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Desarrollador', style: TextStyle(color: Color(0xFF2EFEEA), fontSize: 16)),
              
              const SizedBox(height: 40),

              // info de Jose
              const CircleAvatar(
                radius: 65,
                backgroundColor: Color(0xFF2EFEEA),
                child: CircleAvatar(
                  radius: 62,
                  backgroundImage: NetworkImage('https://i.postimg.cc/3xwfKT6j/Whats-App-Image-2026-07-14-at-2-59-11-AM.jpg'), // foto de Jose
                  backgroundColor: Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 15),
              const Text('José Gomez', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Desarrollador', style: TextStyle(color: Color(0xFF2EFEEA), fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}