import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'constant.dart';

const _list = [0, 23, 255];
const _bullet = [8226, 9702, 9642];

/// Header and footer possible positions
enum HF { hdLeft, hdCenter, hdRight, ftLeft, ftCenter, ftRight }

enum Color {
  black(0xff000000),
  blue(0xff0000ff),
  cyan(0xff00ffff),
  green(0xff00ff00),
  magenta(0xffff00ff),
  red(0xffff0000),
  yellow(0xffffff00),
  white(0xffffffff),
  darkBlue(0xff000080),
  darkCyan(0xff008080),
  darkGreen(0xff008000),
  purple(0xff800080),
  darkRed(0xff800000),
  darkYellow(0xff808000),
  ligthGray(0xffC0C0C0),
  darkGray(0xff808080);

  final int color;
  const Color(this.color);

  int _red() {
    return (color >> 16) & 0xff;
  }

  int _green() {
    return (color >> 8) & 0xff;
  }

  int _blue() {
    return color & 0xff;
  }
}

class PageFormat {
  final double width;
  final double height;

  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;
  static const double cm = dot / inch;
  const PageFormat(this.width, this.height,
      {double marginTop = 0.0,
      double marginBottom = 0.0,
      double marginLeft = 0.0,
      double marginRight = 0.0,
      double? marginAll})
      : marginTop = marginAll ?? marginTop,
        marginBottom = marginAll ?? marginBottom,
        marginLeft = marginAll ?? marginLeft,
        marginRight = marginAll ?? marginRight;

  static const PageFormat a3 =
      PageFormat(29.7 * cm, 42 * cm, marginAll: 2.0 * cm);
  static const PageFormat a4 =
      PageFormat(21.0 * cm, 29.7 * cm, marginAll: 2.0 * cm);
  static const PageFormat a5 =
      PageFormat(14.8 * cm, 21.0 * cm, marginAll: 2.0 * cm);
  static const PageFormat a6 =
      PageFormat(10.5 * cm, 14.8 * cm, marginAll: 1.0 * cm);
  static const PageFormat letter =
      PageFormat(8.5 * dot, 11.0 * dot, marginAll: dot);
  static const PageFormat legal =
      PageFormat(8.5 * dot, 14.0 * dot, marginAll: dot);

  PageFormat copyWith(
      {double? width,
      double? height,
      double? marginTop,
      double? marginBottom,
      double? marginLeft,
      double? marginRight}) {
    return PageFormat(width ?? this.width, height ?? this.height,
        marginTop: marginTop ?? this.marginTop,
        marginBottom: marginBottom ?? this.marginBottom,
        marginLeft: marginLeft ?? this.marginLeft,
        marginRight: marginRight ?? this.marginRight);
  }

  /// Total page width excluding margins
  double get availableWidth => width - marginLeft - marginRight;

  /// Total page height excluding margins
  double get availableHeight => height - marginTop - marginBottom;

  @override
  bool operator ==(Object other) {
    if (other is! PageFormat) {
      return false;
    }

    return other.width == width &&
        other.height == height &&
        other.marginLeft == marginLeft &&
        other.marginTop == marginTop &&
        other.marginRight == marginRight &&
        other.marginBottom == marginBottom;
  }

  @override
  int get hashCode => toString().hashCode;
}

/// RTF Document
class Document {
  final List<Widget> _root;
  final List<_Font> _fonts = [];
  final List<String> _mStyles = [];
  final List<Widget?> _hfValues = List.filled(HF.values.length, null);
  final bool _interleave;
  final int _orientation;
  final PageFormat _pageFormat;
  Document(this._root,
      {PageFormat pageFormat = PageFormat.a4,
      int orientation = 1,
      interleave = false})
      : _pageFormat = pageFormat,
        _orientation = orientation,
        _interleave = interleave;
  Future<void> save(File f, {int charset = 1252, int lang = 1040}) async {
    out = f.openWrite(encoding: latin1);
    write("{\\rtf1\\ansi\\ansicpg");
    write(charset.toString());
    write("\\uc1 \\deff0\\deflang$lang");
    write("\\deflangfe$lang");
    write("{\\fonttbl");
    _defineFonts();
    write("}");

    _defineColors();

    write("{\\stylesheet");
    for (int index = 0; index < _fonts.length; index++) {
      _defineStyle(_fonts[index], index, lang);
    }
    write("}");
    _defineListTables();
    _defineHeader();

    _hf(false);
    _hf(true);
    for (var r in _root) {
      r.draw(this);
    }
    write("\\pard}\r\n");
    await out.close();
  }

  PageFormat getPage() {
    var page = _pageFormat;
    if (_orientation == 0) {
      page = page.copyWith(width: page.height, height: page.width);
    }
    return page;
  }

  void addFont(String name, String family, String fontName, FontStyle style,
          double size) =>
      _fonts.add(_Font(name, family, fontName, style, size));
  void setHf(HF what, Widget value) => _hfValues[what.index] = value;
  String _text(String str) {
    StringBuffer txt = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      switch (str[i]) {
        case '\n':
          txt.write("\\par ");
          break;
        case '\\':
          txt.write("\\\\");
          break;
        case '{':
          txt.write("\\{");
          break;
        case '}':
          txt.write("\\}");
          break;
        case '&':
          if (i < str.length - 2 && str[i + 1] == '#') {
            bool bCode = true;
            switch (str[i + 2]) {
              case 'b':
                txt.write("\\b ");
                break;
              case 'i':
                txt.write("\\i ");
                break;
              case 'u':
                txt.write("\\ul ");
                break;
              case 'p':
                txt
                  ..write("\\pard\\plain")
                  ..write(_mStyles.first)
                  ..write(' ');
                break;
              default:
                txt.write("\$");
                bCode = false;
                break;
            }
            if (bCode) {
              i += 2;
            }
          } else {
            txt.write("\$");
          }
          break;
        case '\t':
          txt.write("\\tab ");
          break;
        default:
          if (str.codeUnits[i] < 0x100) {
            txt.write(str[i]);
          } else {
            txt
              ..write("\\u")
              ..write(str.codeUnitAt(i))
              ..write("\\'3f");
          }
          break;
      }
    }
    return txt.toString();
  }

  void _defineListTables() {
    write('{\\*\\listtable');
    for (int i = 1; i <= _list.length; i++) {
      write('{\\list\\listtemplateid$i\n');
      for (int lvl = 0; lvl < 8; lvl++) {
        write(
            '{\\listlevel\\levelnfc${_list[i - 1]}\\leveljc0\\levelstartat1\\levelfollow${i == 3 ? 2 : 0}{\\leveltext ');
        //if (i == 1) {
        switch (i) {
          case 1:
            write('\\\'02\\\'0$lvl.;}');
            break;
          case 2:
            write('\\\'01\\u${_bullet[lvl % _bullet.length]};}');
            break;
          case 3:
            write('\\\'00;}');
            break;
        }
        write('{\\levelnumbers${i == 1 ? '\\\'01' : ''};}');
        if (i == _list.length) {
          write('\\fi0\\li0}\n');
        } else {
          write('\\fi-360\\li${720 + 360 * lvl}}\n');
        }
      }
      write('\\listid$i}');
    }
    write('}');
    write('{\\listoverridetable');
    for (int i = 1; i <= _list.length; i++) {
      write('{\\listoverride\\listid$i\\listoverridecount0\\ls$i}');
    }
    write('}');
  }

  void _defineFonts() {
    for (int idx = 0; idx < _fonts.length; idx++) {
      write("{\\f$idx");
      write("\\f${_fonts[idx]._family}");
      write("\\fcharset0\\fprq2 ${_fonts[idx]._fontName};}");
    }
  }

  void _defineColors() {
    write("{\\colortbl;");
    for (Color bc in Color.values) {
      write('\\red${bc._red()}\\green${bc._green()}\\blue${bc._blue()};');
    }
    write("\\red255\\green255\\blue255;}\r\n");
  }

  void _defineStyle(_Font f, int index, int lang) {
    String styleName = f._name;
    StringBuffer str = StringBuffer();
    if (styleName != 'Normal') {
      str
        ..write("\\s")
        ..write(index.toString())
        ..write("\\sb240\\sa60");
    } else if (_interleave) {
      str.write("\\sa240");
    }
    str
      ..write("\\keepn\\nowidctlpar\\widctlpar\\adjustright \\f$index")
      ..write(f._style == FontStyle.bold ? '\\b' : '\\plain')
      ..write("\\fs")
      ..write((2 * f._size).floor().toString())
      ..write("\\language$lang");
    _mStyles.add(str.toString());
    str.write(' ');
    if (_mStyles.length > 1) {
      str.write('\\sbasedon0 ');
    }
    str.write('\\snext0 $styleName;}');
    write('{$str');
  }

  void _defineHeader() {
    var page = getPage();
    write(
        "\\paperw${(um * page.width).round()}\\paperh${(um * page.height).round()}\\margl${(um * page.marginLeft).round()}\\margr${(um * page.marginRight).round()}\\margt${(um * page.marginTop).round()}\\margb${(um * page.marginBottom).round()}${_orientation == 0 ? "\\landscape" : ""} \n\\widowctrl\\ftnbj\\aenddoc\\hyphcaps0\\viewkind1\\viewscale90");
    write("\\fet0");
    write("\\sectd ");
    write("\\linex0");
    write("\\headery500");
    if (_hfValues[HF.ftLeft.index] != null) {
      write("\\footery600");
    }
    write("\\sectdefaultcl \\pard\\plain ");
  }

  _Font _setStyle(String font) {
    int idx = _fonts.indexWhere((e) => e._name == font);
    write('\\pard\\plain${_mStyles[idx]}');
    return _fonts[idx];
  }

  void _hf(bool bFooter) {
    double l = 10.0 * getPage().availableWidth;
    List<Widget?> styles = _hfValues.sublist(bFooter ? 3 : 0, 3);
    if (!styles.any((s) => s != null)) {
      return;
    }
    write(bFooter ? "{\\footer " : "{\\header ");
    // don't round before multiply, otherwise you loose some decimals
    write(
        "\\pard\\plain \\nowidctlpar\\widctlpar\\tqc\\tx${l.round()}\\tqr\\tx${(2 * l).round()}\\adjustright {");
    write("\\b\\qj ");
    for (int j = 0; j < styles.length; j++) {
      if (j > 0) {
        write("\\tab ");
      }
      var s = styles[j];
      if (s != null) {
        s.draw(this);
      }
    }
    write("\\par }}");
  }

  void _insertImage(
      ByteData data, int dpi, bool share, int? width, int? height) {
    if (share) {
      write("{");
      write("\\*\\shppict ");
    }
    write("{");
    write("\\pict ");
    write("\\pngblip ");

    int mult = 1440 ~/ dpi;
    if (width != null) {
      write("\\picwgoal ${(width * mult)} ");
    }
    if (height != null) {
      write("\\pichgoal${(height * mult)} ");
    }
    for (int i = 0; i < data.buffer.lengthInBytes; i++) {
      int iData = data.getInt8(i);

      // Make positive byte
      if (iData < 0) {
        iData += 256;
      }
      if (iData < 16) {
        // Set leading zero and append
        write("0");
      }
      write(iData.toRadixString(16));
    }

    write("}");
    write("}");
  }
}

enum FontStyle { regular, bold, italic }

class _Font {
  final String _name;
  final String _fontName;
  final FontStyle _style;
  final double _size;
  final String _family;

  const _Font(
      this._name, this._family, this._fontName, this._style, this._size);
}

/// the Widget class
abstract class Widget {
  void draw(Document doc);
}

/*
abstract class _SingleChildWidget extends Widget {
  Widget child;
  _SingleChildWidget({required this.child});
  @override
  void draw(Document doc) {
    child.draw(doc);
  }
}*/

abstract class _MultipleChildrenWidget extends Widget {
  List<Widget> children;
  _MultipleChildrenWidget({required this.children});
}

/// Horizontal alignments
enum Align {
  left('\\ql '),
  center('\\qc '),
  right("\\qr "),
  justify('\\qc ');

  final String _al;
  const Align(this._al);
}

/// Define the Text's widget style
class TextStyle {
  final String _style;
  final Align? _align;
  TextStyle({String style = 'Normal', Align? align})
      : _style = style,
        _align = align;
}

/// Widget to insert a new page break
class SkipPage extends Widget {
  @override
  void draw(Document doc) {
    write("\\pard\\plain \\page \r\n");
  }
}

/// A widget to show page number
class PageNo extends Widget {
  /// show 'page number' / 'number of pages'; otherwise, show 'page number' only
  final bool nofPages;
  PageNo({this.nofPages = true});
  @override
  void draw(Document doc) {
    if (nofPages) {
      write(
          "{\\field{\\*\\fldinst { PAGE }}{\\fldrslt { 1}}}/{\\field{\\*\\fldinst { NUMPAGES    \\* MERGEFORMAT }}{\\fldrslt { 1}}}");
    } else {
      write("{\\field{\\*\\fldinst { PAGE }}{\\fldrslt { 1}}}");
    }
  }
}

/// Widget to insert a new line break
class NewLine extends Widget {
  @override
  void draw(Document doc) {
    write("\\par ");
  }
}

/// this widget show all its children separated by a newline
class Column extends _MultipleChildrenWidget {
  Column({required super.children});
  @override
  void draw(Document doc) {
    for (var c in children) {
      c.draw(doc);
      if (c != children.last) write('\\par ');
    }
  }
}

class Row extends _MultipleChildrenWidget {
  Row({required super.children});
  @override
  void draw(Document doc) {
    for (var c in children) {
      c.draw(doc);
    }
  }
}

/// a Widget to show a Text with its style
class Text extends Widget {
  final String _txt;
  final TextStyle? _style;
  Text(this._txt, {TextStyle? style}) : _style = style;

  @override
  void draw(Document doc) {
    String a = '';
    if (_style != null) {
      doc._setStyle(_style._style);
      a = _style._align?._al ?? '';
    }
    write('{$a${doc._text(_txt)}}');
  }
}

/// Widget to show an Image
class Image extends Widget {
  /// [_data] contains the image data
  final ByteData _data;

  /// dot per inch
  final int dpi;

  /// Share image, default is true
  final bool share;

  /// image's width
  final int? width;

  /// image's height
  final int? height;
  Image(this._data,
      {this.dpi = 72, this.share = true, this.width, this.height});
  @override
  void draw(Document doc) {
    doc._insertImage(_data, dpi, share, width, height);
  }
}

/// Widget to draw a Line
class Line extends Widget {
  /// the line's width, in 20th of the available page width
  final double w;
  Line([this.w = 1]);
  @override
  void draw(Document doc) {
    double width = doc.getPage().availableWidth;
    double wd = w * width;
    double mg = (um * width - wd) / 2;
    write(
        "\\pard\\plain {\\shp{\\*\\shpinst\\shpleft${mg.round()}\\shptop180\\shpright${(mg + wd).round()}\\shpbottom180\\shpfhdr0\\shpbxcolumn\\shpbxignore\\shpbypara\\shpbyignore\\shpwr3\\shpwrk0\\shpfblwtxt0\\shpz0\\shplid1028{\\sp{\\sn shapeType}{\\sv 20}}{\\sp{\\sn fFlipH}{\\sv 0}}{\\sp{\\sn fFlipV}{\\sv 0}}{\\sp{\\sn shapePath}{\\sv 4}}{\\sp{\\sn fFillOK}{\\sv 0}}{\\sp{\\sn fFilled}{\\sv 0}}{\\sp{\\sn fArrowheadsOK}{\\sv 1}}{\\sp{\\sn fLayoutInCell}{\\sv 1}}}{\\shprslt{\\*\\do\\dobxcolumn\\dobypara\\dodhgt8192\\dpline\\dpptx0\\dppty0\\dpptx9900\\dppty0\\dpx0\\dpy0\\dpxsize\\dpysize0\\dplinew15\\dplinecor0\\dplinecog0\\dplinecob0}}}");
  }
}

/// A widget to show a List
class Listing extends Widget {
  final List<Widget> _elements;
  final bool _numbered;
  Listing(this._elements, this._numbered);
  @override
  void draw(Document doc) {
    for (int i = 0; i < _elements.length; i++) {
      String c = _numbered ? '$i.)' : '\\u8226\\\'95';
      write('{\\listtext\\pard\\plain $c\\tab}\\ilvl0\\ls${_numbered ? 1 : 2}');
      _elements[i].draw(doc);
      write('\\par');
    }
  }
}
