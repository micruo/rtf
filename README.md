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

Create a table:

```dart

    List<List<rtf.Widget>> c = List.generate(3, (index) => List.generate(2, (c) => rtf.Text('Cell$index$c')));
    c.first.first = rtf.Column(children: [rtf.Text('1'), rtf.Text('alfa')]);
    var el = [
      rtf.Text('Test text', style: rtf.TextStyle(style: 'heading 1', align: rtf.Align.right)),
      rtf.NewLine(),
      rtf.Text('Second test text', style: rtf.TextStyle(style: 'Normal')),
      rtf.NewLine(),
      rtf.SkipPage(),
      rtf.Text('Third test text'),
      rtf.Table([
        rtf.Text('First column', style: rtf.TextStyle(style: 'heading 2', align: rtf.Align.center)),
        rtf.Text('Second column', style: rtf.TextStyle(style: 'heading 2', align: rtf.Align.center))
      ], c,
      colWidths: [100,200],
        headerShade: rtf.Shade.dark,
        pairShade: rtf.Shade.normal,
        oddShade: rtf.Shade.light,
        height: 20,
          valign: rtf.VAlign.bottom,
          left: rtf.TableBorder(),
          right: rtf.TableBorder(),
          top: rtf.TableBorder(),
          bottom: rtf.TableBorder(),
          horizontalInside: rtf.TableBorder(dash: true))
    ];
    var doc = rtf.Document(el);
    doc.addFont('Normal', 'Arial-Regular-9');
    doc.addFont('heading 1', 'Arial-Bold-14');
    doc.addFont('heading 2', 'Arial-Bold-12');
    doc.setHf(rtf.HF.hdCenter, await PlatformAssetBundle().load("assets/retro.png"));
    doc.setHf(rtf.HF.hdLeft, "%Page");
    await doc.save(File('result.rtf'));

```
