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
    rtf.Paragraph(align: rtf.Align.right, style: 'Heading 1', children: [
      rtf.Text('Test text',
          style: rtf.TextStyle(variations: [rtf.StyleVariation.italic])),
      rtf.Text(' Continuos test text',
          style: rtf.TextStyle(
              font: 'Normal', variations: [rtf.StyleVariation.underline]))
    ]),
    rtf.NewLine(),
    rtf.Paragraph(style: 'Normal', children: [rtf.Text('Second test text')]),
    rtf.NewLine(),
    rtf.SkipPage(),
    rtf.Text('Third test text'),
  ];
  ByteData? bd = await _loadImageAsByteData('image.png');
  rtf.Document doc = rtf.Document(el,
      hdLeft: rtf.PageNo(),
      hdCenter: bd == null ? null : rtf.Image(bd),
      styles: [
        rtf.Style('Normal', rtf.FontFamily.swiss, 'Arial', 9),
        rtf.Style('Heading 1', rtf.FontFamily.swiss, 'Arial', 14,
            [rtf.StyleVariation.bold]),
        rtf.Style('Heading 2', rtf.FontFamily.swiss, 'Arial', 12,
            [rtf.StyleVariation.bold])
      ]);
  await doc.save(File('result.rtf'));
}
