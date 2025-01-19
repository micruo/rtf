<h1>A minimal Rtf creation library for dart/flutter</h1>

## Features

The library can create RTF file 
In this release was introduced the Paragraph Widget: it defines a <i>style</i>, and contains one or more Text Widget, each one
possibly with its own <i>font</i>. So, TextStyle.style was deprecated: use TextStyle.font instead

## Installing
In order to use this rtf library, follow the steps above:
<ol>
  <li>Add this package to your package's pubspec.yaml file as described on the installation tab</li>
  <li>Import the library</li>
</ol>

```dart

  import 'package:rtf/rtf.dart' as rtf;

```

## Examples


Create a document in Rich Text Format.
Use Arial as font writing some lines with different styles and alignments.

PAY ATTENTION: Document.addFont was deprecated: use Document.styles instead

```dart

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
  rtf.Document doc = rtf.Document(el, hdLeft: rtf.PageNo(),
      styles: [
      rtf.Style('Normal', rtf.FontFamily.swiss, 'Arial', 9),
      rtf.Style('Heading 1', rtf.FontFamily.swiss, 'Arial', 14,
          [rtf.StyleVariation.bold]),
      rtf.Style('Heading 2', rtf.FontFamily.swiss, 'Arial', 12,
          [rtf.StyleVariation.bold])
  ]);
  await doc.save(File('result.rtf'));

```

See also <a href="https://github.com/micruo/rtf/tree/main/example">example directory</a>


## Features and bugs 

Please file feature requests and bugs at the <a href="https://github.com/micruo/rtf/issues">issue tracker</a>.
