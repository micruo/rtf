import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:rtf/rtf.dart' as rtf;

Future<ByteData?> _loadImageAsByteData(String filePath) async {
  try {
    final file = File(filePath);
    final imageBytes = await file.readAsBytes();

    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData;
  } catch (e) {
    return null;
  }
}

Future<void> main() async {
  var el = [
    rtf.Text('Test text',
        style: rtf.TextStyle(style: 'heading 1', align: rtf.Align.right)),
    rtf.NewLine(),
    rtf.Text('Second test text', style: rtf.TextStyle(style: 'Normal')),
    rtf.NewLine(),
    rtf.SkipPage(),
    rtf.Text('Third test text'),
  ];
  ByteData? bd = await _loadImageAsByteData('image.png');
  rtf.Document doc = rtf.Document(el, hdLeft: rtf.PageNo(), hdCenter : bd == null ? null : rtf.Image(bd));
  doc.addFont('Normal', 'swiss', 'Arial', rtf.FontStyle.regular, 9);
  doc.addFont('heading 1', 'swiss', 'Arial', rtf.FontStyle.bold, 14);
  doc.addFont('heading 2', 'swiss', 'Arial', rtf.FontStyle.bold, 12);
  await doc.save(File('result.rtf'));
}
