import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rtf/rtf.dart' as rtf;

void main() {
  test('create a minimal document', () async {
    var el = [
      rtf.Paragraph(style: 'Heading 1', align: rtf.Align.right, children: [
        rtf.Text('Test text',
            style: rtf.TextStyle(variations: [rtf.StyleVariation.italic])),
        rtf.Text(' Continuos test text',
            style: rtf.TextStyle(
                font: 'Normal', variations: [rtf.StyleVariation.underline]))
      ]),
      rtf.NewLine(),
      rtf.Paragraph(style: 'Normal', children: [rtf.Text('Second test text')]),
    ];
    rtf.Document doc = rtf.Document(el, hdLeft: rtf.PageNo(), styles: [
      rtf.Style('Normal', rtf.FontFamily.roman, 'Times New Roman', 9),
      rtf.Style('Heading 1', rtf.FontFamily.roman, 'Times New Roman', 14,
          [rtf.StyleVariation.bold]),
      rtf.Style('Heading 2', rtf.FontFamily.roman, 'Times New Roman', 12,
          [rtf.StyleVariation.bold])
    ]);
    await doc.save(File('../test.rtf'));
  });
  test('draw a Line', () async {
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
    await doc.save(File('../line.rtf'));
  });
  test('draw a Row', () async {
    rtf.Document doc = rtf.Document([
      rtf.Section(2, children: List.generate(100, (index) => rtf.Text('kkkk'))),
      rtf.Column(children: List.generate(100, (index) => rtf.Text('aaaa'))),
      rtf.Section(1, children: [
        rtf.Text('start'),
        rtf.Section(2,
            children: List.generate(100, (index) => rtf.Text('jjjj'))),
        rtf.Text('fff')
      ]),
    ], styles: [
      rtf.Style('Normal', rtf.FontFamily.roman, 'Times New Roman', 9),
      rtf.Style('Heading 1', rtf.FontFamily.roman, 'Times New Roman', 14,
          [rtf.StyleVariation.bold]),
      rtf.Style('Heading 2', rtf.FontFamily.roman, 'Times New Roman', 12,
          [rtf.StyleVariation.bold])
    ]);
    await doc.save(File('../row.rtf'));
  });
  test('write a table', () async {
    List<List<rtf.Widget>> c = List.generate(
        3,
        (index) => List.generate(
            4,
            (c) => rtf.Text('Cell$index$c',
                style: rtf.TextStyle(font: 'Normal'))));
    c.first.first = rtf.Column(lastNL: false, children: [
      rtf.Text('1', style: rtf.TextStyle(font: 'Normal')),
      rtf.Text('alfa', style: rtf.TextStyle(font: 'Normal'))
    ]);
    c.last.removeLast();
    c.last[1] = rtf.ColSpan(2,
        child: rtf.Paragraph(
            style: 'Normal',
            align: rtf.Align.center,
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
    await doc.save(File('../table.rtf'));
  });
}
