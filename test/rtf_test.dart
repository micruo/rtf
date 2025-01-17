import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rtf/rtf.dart' as rtf;

void main() {
  test('create a minimal document', () async {
    var el = [
      rtf.Text('Test text', style: rtf.TextStyle(style: 'heading 1', align: rtf.Align.right)),
      rtf.NewLine(),
      rtf.Text('Second test text', style: rtf.TextStyle(style: 'Normal')),
    ];
    rtf.Document doc = rtf.Document(el, hdLeft: rtf.PageNo());
    doc.addFont('Normal', 'roman', 'Times New Roman', rtf.FontStyle.regular, 9);
    doc.addFont('heading 1', 'roman', 'Times New Roman', rtf.FontStyle.bold, 14);
    doc.addFont('heading 2', 'roman', 'Times New Roman', rtf.FontStyle.bold, 12);
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
    ]);
    doc.addFont('Normal', 'roman', 'Times New Roman', rtf.FontStyle.regular, 9);
    doc.addFont('heading 1', 'roman', 'Times New Roman', rtf.FontStyle.bold, 14);
    doc.addFont('heading 2', 'roman', 'Times New Roman', rtf.FontStyle.bold, 12);
    await doc.save(File('../line.rtf'));
  });
  test('draw a Row', () async {
    rtf.Document doc = rtf.Document([
      rtf.Section(2, children: List.generate(100, (index) => rtf.Text('kkkk'))),
      rtf.Column(children: List.generate(100, (index) => rtf.Text('aaaa'))),
      rtf.Section(1, children: [
        rtf.Text('start'),
        rtf.Section(2, children: List.generate(100, (index) => rtf.Text('jjjj'))),
        rtf.Text('fff')
      ]),
    ]);
    doc.addFont('Normal', 'roman', 'Times New Roman', rtf.FontStyle.regular, 9);
    doc.addFont('heading 1', 'roman', 'Times New Roman', rtf.FontStyle.bold, 14);
    doc.addFont('heading 2', 'roman', 'Times New Roman', rtf.FontStyle.bold, 12);
    await doc.save(File('../row.rtf'));
  });
  test('write a table', () async {
    List<List<rtf.Widget>> c = List.generate(3, (index) => List.generate(4, (c) => rtf.Text('Cell$index$c', style: rtf.TextStyle(style: 'Normal'))));
    c.first.first = rtf.Column( lastNL: false, children: [rtf.Text('1', style: rtf.TextStyle(style: 'Normal')), rtf.Text('alfa', style: rtf.TextStyle(style: 'Normal'))]);
    c.last.removeLast();
    c.last[1] = rtf.ColSpan(2, child: rtf.Text('Span', style: rtf.TextStyle(align: rtf.Align.center)));
    var el = [
      rtf.Table(
          [
            rtf.Text('First column', style: rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
            rtf.Text('Second column', style: rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
            rtf.Text('Third column', style: rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
            rtf.Text('Fourth column', style: rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
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
    rtf.Document doc = rtf.Document(el);
    doc.addFont('Normal', 'swiss', 'Arial', rtf.FontStyle.regular, 9);
    doc.addFont('heading 1', 'swiss', 'Arial', rtf.FontStyle.bold, 14);
    doc.addFont('heading 2', 'swiss', 'Arial', rtf.FontStyle.bold, 12);
    await doc.save(File('../table.rtf'));
  });
}
