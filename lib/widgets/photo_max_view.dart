import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class InsidePhotoMax extends StatefulWidget {
  const InsidePhotoMax({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<InsidePhotoMax> createState() => _InsidePhotoMaxState();
}

class _InsidePhotoMaxState extends State<InsidePhotoMax> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_scale != 1.0) _scale = _scale - 1.0;
              });
            },
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _scale = _scale + 1.0;
              });
            },
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(widget.url),
          scaleStateController: PhotoViewScaleStateController(),
          customSize: MediaQuery.of(context).size,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialScale: _scale,
          // minScale: 0.1,
          // maxScale: 3.0,
          enableRotation: true,
          loadingBuilder: (context, event) {
            if (event == null) return const SizedBox();
            final progress =
                event.cumulativeBytesLoaded / event.expectedTotalBytes!;
            return Center(
              child: CircularProgressIndicator(
                value: progress,
              ),
            );
          },
        ),
      ),
    );
  }
}
