<h1>A minimal Rtf creation library for dart/flutter</h1>

## Features

The library can create RTF file.

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

See also <a href="https://github.com/micruo/rtf/tree/main/example">directory</a>  for further examples.

## Migration from old releases

In previous releases, the following code's rows create a document:
<ul>
  <li>Define three fonts  through doc.addFont()</li>
  <li>Set the left part of header to show page number</li>
  <li>Write a right aligned text using 'heading 1' style</li>
  <li>Write a text using 'Normal' style, then skip to a new page and write a third text</li>
</ul>


```dart

 var el = [
    rtf.Text('Test text',
        style: rtf.TextStyle(style: 'heading 1', align: rtf.Align.right)),
    rtf.NewLine(),
    rtf.Text('Second test text', style: rtf.TextStyle(style: 'Normal')),
    rtf.NewLine(),
    rtf.SkipPage(),
    rtf.Text('Third test text'),
  ];
  rtf.Document doc = rtf.Document(el);
  doc.addFont('Normal', 'swiss', 'Arial', rtf.FontStyle.regular, 9);
  doc.addFont('heading 1', 'swiss', 'Arial', rtf.FontStyle.bold, 14);
  doc.addFont('heading 2', 'swiss', 'Arial', rtf.FontStyle.bold, 12);
  doc.setHf(rtf.HF.hdLeft, rtf.PageNo());

```

In that release, all deprecated methods was removed. So, there aren't the methods:
Document.addFont()
Document.setHF()
and TextStyle hasn't 'style' and 'align' field, that are moved to Paragraph class.
So, to obtain the same result use the rows above:

```dart

 var el = [
    rtf.Paragraph(align: rtf.Align.right, style: 'Heading 1', children: [
    rtf.Text('Test text')]),
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

```


## Features and bugs 

Please file feature requests and bugs at the <a href="https://github.com/micruo/rtf/issues">issue tracker</a>.
