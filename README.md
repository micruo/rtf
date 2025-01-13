<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

<h1>A minimal Rtf creation library for dart/flutter</h1>

## Features

The library can create RTF file 

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


Create a document (use Times New Roman as font)

```dart

    var el = [
      rtf.Text('Test text', style: rtf.TextStyle(style: 'heading 1', align: rtf.Align.right)),
      rtf.NewLine(),
      rtf.Text('Second test text', style: rtf.TextStyle(style: 'Normal')),
      rtf.NewLine(),
      rtf.SkipPage(),
      rtf.Text('Third test text'),
    ];
    rtf.Document doc = rtf.Document(el, hdLeft: rtf.PageNo());
    doc.addFont('Normal', 'roman', 'Times New Roman', rtf.FontStyle.regular, 9);
    doc.addFont('heading 1', 'roman', 'Times New Roman', rtf.FontStyle.bold, 14);
    doc.addFont('heading 2', 'roman', 'Times New Roman', rtf.FontStyle.bold, 12);
    await doc.save(File('result.rtf'));

```

See also example directory
