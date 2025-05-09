import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TunaTrike",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/sikad.png",
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                "This app is developed by TunaTrike thesis group.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _buildImageGallery(),

            const SizedBox(
              height: 10,
            ),

            Image.asset(
              "assets/images/Dodong.png",
            ),

            const SizedBox(height: 5),

            const Text(
              "Alvin A. Tampus Jr.",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "In case of any misuse or any report please contact admin at tunatrike@gmail.com",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final List<Map<String, String>> images = [
      {"path": "assets/images/Coco.jpg", "name": "Celso Onnele Arancon"},
      {"path": "assets/images/Ariel.jpg", "name": "Ariel Guerra Jr."},
      {"path": "assets/images/Dren2.jpg", "name": "Adrian D. Macaculop"},
      {"path": "assets/images/Pinoy.jpg", "name": "Raffy Simon"},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Image.asset(images[index]["path"]!),
              const SizedBox(height: 5),
              Text(
                images[index]["name"]!,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
