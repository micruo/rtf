import 'dart:io';

import 'package:rtf/rtf.dart' as rtf;

Future<void> main() async {
  rtf.Document doc = rtf.Document([
    rtf.Text('Test'),
    rtf.NewLine(),
    rtf.Line(20),
    rtf.NewLine(),
    rtf.Listing([rtf.Text('a'), rtf.Text('b')], true),
    rtf.Listing([rtf.Text('A'), rtf.Text('B')], false)
  ], styles: [
    rtf.Style('Normal', rtf.FontFamily.roman, 'Times New Roman', 9),
    rtf.Style('Heading 1', rtf.FontFamily.roman, 'Times New Roman', 14,
        [rtf.StyleVariation.bold]),
    rtf.Style('Heading 2', rtf.FontFamily.roman, 'Times New Roman', 12,
        [rtf.StyleVariation.bold])
  ]);
  await doc.save(File('result.rtf'));
}
