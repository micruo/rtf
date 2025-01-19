import 'dart:io';

import 'package:rtf/rtf.dart' as rtf;

Future<void> main() async {
  rtf.Document doc = rtf.Document([
    rtf.Section(2, children: List.generate(100, (index) => rtf.Text('first'))),
    rtf.Column(children: List.generate(100, (index) => rtf.Text('second'))),
    rtf.Section(1, children: [
      rtf.Text('start'),
      rtf.Section(2,
          children: List.generate(100, (index) => rtf.Text('third'))),
      rtf.Text('fourth')
    ]),
  ], styles: [
    rtf.Style('Normal', rtf.FontFamily.roman, 'Times New Roman', 9),
    rtf.Style('Heading 1', rtf.FontFamily.roman, 'Times New Roman', 14,
        [rtf.StyleVariation.bold]),
    rtf.Style('Heading 2', rtf.FontFamily.roman, 'Times New Roman', 12,
        [rtf.StyleVariation.bold])
  ]);
  await doc.save(File('result.rtf'));
}
