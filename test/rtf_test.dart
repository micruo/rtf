import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rtf/rtf.dart' as rtf;

void main() {
  test('create a minimal document', () async {
    var el = [
      rtf.Text('Test text',
          style: rtf.TextStyle(style: 'heading 1', align: rtf.Align.right)),
      rtf.NewLine(),
      rtf.Text('Second test text', style: rtf.TextStyle(style: 'Normal')),
    ];
    rtf.Document doc = rtf.Document(el);
    doc.addFont('Normal', 'roman', 'Times New Roman', rtf.FontStyle.regular, 9);
    doc.addFont(
        'heading 1', 'roman', 'Times New Roman', rtf.FontStyle.bold, 14);
    doc.addFont(
        'heading 2', 'roman', 'Times New Roman', rtf.FontStyle.bold, 12);
    doc.setHf(rtf.HF.hdLeft, rtf.PageNo());
    await doc.save(File('../table.rtf'));
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
    doc.addFont(
        'heading 1', 'roman', 'Times New Roman', rtf.FontStyle.bold, 14);
    doc.addFont(
        'heading 2', 'roman', 'Times New Roman', rtf.FontStyle.bold, 12);
    await doc.save(File('../line.rtf'));
  });
}
