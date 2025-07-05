import 'package:flutter/material.dart';
import 'pdf_manager.dart'; // adjust to your path

class FlashingGridPage extends StatefulWidget {
  const FlashingGridPage({super.key});

  @override
  FlashingGridPageState createState() => FlashingGridPageState();
}

class FlashingGridPageState extends State<FlashingGridPage> {
  final _manager = PdfManager();

  @override
  Widget build(BuildContext context) {
    final images = _manager.images;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.pop();
            }),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Your Flashings',
          style: TextStyle(
            fontFamily: 'Kanit',
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: images.isEmpty
            ? const Text(
                'NO FLASHINGS ADDED YET.',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),
              )
            : SizedBox(
                width: 1024,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1, // 1:1 ratio → square
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, idx) {
                    final imgBytes = images[idx];
                    return Stack(
                      children: [
                        // thumbnail square
                        SizedBox(
                          width: 1024,
                          height: 1024,
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            color: Colors.white,
                            elevation: 8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                imgBytes,
                                fit: BoxFit.contain,
                                width: 1024,
                                height: 1024,
                              ),
                            ),
                          ),
                        ),
                        // delete button
                        Positioned(
                          top: 32,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _manager.removeImageAt(idx);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: () {
          PdfManager pdfManager = PdfManager();
          if (pdfManager.images.isNotEmpty) {
            pdfManager.saveAndDownload(context);
          }
        },
        child: const Text(
          'DOWNLOAD PDF',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }
}
