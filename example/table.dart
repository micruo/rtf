import 'dart:io';

import 'package:rtf/rtf.dart' as rtf;

Future<void> main() async {
  List<List<rtf.Widget>> c = List.generate(
      3, (index) => List.generate(2, (c) => rtf.Text('Cell$index$c')));
  c.first.first = rtf.Column(children: [rtf.Text('1'), rtf.Text('alfa')]);
  var el = [
    rtf.Table(
        [
          rtf.Text('First column',
              style:
                  rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
          rtf.Text('Second column',
              style:
                  rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
        ],
        c,
        colWidths: [100, 200],
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
  await doc.save(File('result.rtf'));
}
