import 'dart:io';

import 'package:rtf/rtf.dart' as rtf;

Future<void> main() async {
  List<List<rtf.Widget>> c = List.generate(
      3,
      (index) => List.generate(
          4,
          (c) =>
              rtf.Text('Cell$index$c', style: rtf.TextStyle(font: 'Normal'))));
  c.first.first = rtf.Column(lastNL: false, children: [
    rtf.Text('1', style: rtf.TextStyle(font: 'Normal')),
    rtf.Text('alfa', style: rtf.TextStyle(font: 'Normal'))
  ]);
  c.last.removeLast();
  c.last[1] = rtf.ColSpan(2,
      child: rtf.Paragraph(
          align: rtf.Align.center,
          style: 'Normal',
          children: [rtf.Text('Span')]));
  var el = [
    rtf.Table(
        [
          rtf.Paragraph(
              style: 'Heading 2',
              align: rtf.Align.center,
              children: [rtf.Text('First column')]),
          rtf.Paragraph(
              style: 'Heading 2',
              align: rtf.Align.center,
              children: [rtf.Text('Second column')]),
          rtf.Paragraph(
              style: 'Heading 2',
              align: rtf.Align.center,
              children: [rtf.Text('Third column')]),
          rtf.Paragraph(
              style: 'Heading 2',
              align: rtf.Align.center,
              children: [rtf.Text('Fourth column')]),
        ],
        c,
        colWidths: [100, 150, 100, 100],
        headerShade: rtf.Shade.dark,
        pairShade: rtf.Shade.normal,
        oddShade: rtf.Shade.light,
        valign: rtf.VAlign.bottom,
        left: rtf.TableBorder.standard(),
        right: rtf.TableBorder.standard(),
        top: rtf.TableBorder.standard(),
        bottom: rtf.TableBorder.standard())
  ];
  rtf.Document doc = rtf.Document(el, styles: [
    rtf.Style('Normal', rtf.FontFamily.swiss, 'Arial', 9),
    rtf.Style('Heading 1', rtf.FontFamily.swiss, 'Arial', 14,
        [rtf.StyleVariation.bold]),
    rtf.Style('Heading 2', rtf.FontFamily.swiss, 'Arial', 12,
        [rtf.StyleVariation.bold])
  ]);
  await doc.save(File('result.rtf'));
}
