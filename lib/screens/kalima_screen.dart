import 'package:flutter/material.dart';

class KalimaScreen extends StatelessWidget {
  const KalimaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5 Kalimas of Islam')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildKalimaItem(
            context,
            'Kalima Tayyibah',
            'لَا إِلٰهَ إِلَّا اللهُ مُحَمَّدٌ رَسُولُ اللهِ',
            'There is no god but Allah, Muhammad is the Messenger of Allah.',
          ),
          const SizedBox(height: 20),
          _buildKalimaItem(
            context,
            'Kalima Shahadah',
            'أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
            'I bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and Messenger.',
          ),
          const SizedBox(height: 20),
          _buildKalimaItem(
            context,
            'Kalima Tamjeed',
            'سُبْحَانَ اللهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلٰهَ إِلَّا اللهُ وَاللهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ الْعَلِيِّ الْعَظِيمِ',
            'Glory be to Allah, and all praise is due to Allah, and there is no god but Allah, and Allah is the Greatest. There is no power and no strength except with Allah, the Most High, the Most Great.',
          ),
          const SizedBox(height: 20),
          _buildKalimaItem(
            context,
            'Kalima Tawheed',
            'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ حَيٌّ لَا يَمُوتُ أَبَدًا أَبَدًا ذُو الْجَلَالِ وَالْإِكْرَامِ بِيَدِهِ الْخَيْرُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
            'There is no god but Allah, alone, without partner. To Him belongs the dominion and to Him belongs all praise. He gives life and causes death, and He is alive and does not die, ever, ever. Possessor of majesty and honor. In His hand is all good, and He is over all things competent.',
          ),
          const SizedBox(height: 20),
          _buildKalimaItem(
            context,
            'Kalima Radd-e-Kufr',
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ أَنْ أُشْرِكَ بِكَ شَيْئًا وَأَنَا أَعْلَمُ وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ إِنَّكَ أَنْتَ عَلَّامُ الْغُيُوبِ',
            'O Allah, I seek refuge in You from associating anything with You knowingly, and I seek Your forgiveness for what I do not know. Indeed, You are the Knower of the unseen.',
          ),
        ],
      ),
    );
  }

  Widget _buildKalimaItem(
    BuildContext context,
    String title,
    String arabic,
    String translation,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              arabic,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(translation, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
