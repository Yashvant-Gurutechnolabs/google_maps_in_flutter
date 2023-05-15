import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class CustomMarker {
  Future<BitmapDescriptor> loadCustomMarker() async {
    const double radius = 40.0;
    const double strokeWidth = 15.0;
    const Color strokeColor = Colors.white;

    final response =
        await http.get(Uri.parse('https://i.pinimg.com/originals/51/e0/d5/51e0d5aa27808ce689e3dd5a5cd7685a.png'));
    final Uint8List bytes = response.bodyBytes;

    final ByteData byteData = ByteData.view(bytes.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List(), targetWidth: 150);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomRight: const Radius.circular(radius),
        bottomLeft: Radius.zero,
      ));

    canvas.clipPath(path);
    canvas.drawImage(image, Offset.zero, Paint());
    canvas.drawPath(path, paint);

    final picture = recorder.endRecording();
    final imageByteData = await picture.toImage(image.width, image.height);
    final pngBytes = await imageByteData.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes != null
        ? BitmapDescriptor.fromBytes(pngBytes.buffer.asUint8List())
        : BitmapDescriptor.defaultMarker;
  }
}
