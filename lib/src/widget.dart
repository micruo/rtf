import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _list = [0, 23, 255];
const _bullet = [8226, 9702, 9642];
const um = 20;
const double inch = 2.54;
const dot = 72.0;

/// Page orientation: landscape or portrait (the default)
enum PageOrientation {
  landscape('\\landscape'),
  portrait('');

  final String _rtf;
  const PageOrientation(this._rtf);
}

enum _Status { starting, normal, exit }

/// Color that can be used as border color in a Table
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

  final int _color;
  const Color(this._color);

  int _red() {
    return (_color >> 16) & 0xff;
  }

  int _green() {
    return (_color >> 8) & 0xff;
  }

  int _blue() {
    return _color & 0xff;
  }
}

/// Define the format of all the document pages
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
  late IOSink _out;

  /// the widgets list
  final List<Widget> _elements;
  final List<Style> _styles;
  final List<String> _mStyles = [];
  final List<String> _mFonts = [];
  final List<Widget?> _hfValues;
  final bool _interleave;
  final PageOrientation _orientation;
  final PageFormat _pageFormat;
  _Status _status = _Status.starting;
  bool _continuos = false;
  final List<Section> _sections = [];

  /// Warning: if an Image widget will be added in header/footer
  /// and its height is too big, an invalid document could be generated
  Document(this._elements,
      {PageFormat pageFormat = PageFormat.a4,

      /// document orientation
      PageOrientation orientation = PageOrientation.portrait,
      bool interleave = false,

      /// header left object
      Widget? hdLeft,

      /// header center object
      Widget? hdCenter,

      /// header right object
      Widget? hdRight,

      /// footer left object
      Widget? ftLeft,

      /// footer center object
      Widget? ftCenter,

      /// footer right object
      Widget? ftRight,

      /// styles defined for this Document. It has to be not empty
      List<Style> styles = const []})
      : assert(styles.isNotEmpty),
        _pageFormat = pageFormat,
        _orientation = orientation,
        _interleave = interleave,
        _styles = styles,
        _hfValues = [hdLeft, hdCenter, hdRight, ftLeft, ftCenter, ftRight];
  void _newWidget() {
    if (_status == _Status.exit) {
      Section? s = _sections.lastOrNull;
      _newSection(s?._nCols ?? 1, s?._spCol ?? 36);
    }
    _status = _Status.normal;
  }

  void _newSection(int nCols, int spCol) {
    if (_status != _Status.starting) _out.write('\\sect');
    _status = _Status.normal;
    var l = um * spCol;
    _out.writeln('\\cols$nCols\\colsx$l');
  }

  /// save this Document on a file
  Future<void> save(File f, {int charset = 1252, int lang = 1040}) async {
    _out = f.openWrite(encoding: latin1);
    _defineDoc(charset, lang);
    _defineFonts();

    _defineColors();

    _defineStyles(lang);
    _defineListTables();
    _defineHeader();

    _hf(false);
    _hf(true);
    for (var r in _elements) {
      r.draw(this, _out);
    }
    _out.writeln("\\pard}");
    await _out.close();
  }

  /// returns the current PageFormat
  PageFormat getPage() {
    var page = _pageFormat;
    if (_orientation == PageOrientation.landscape) {
      page = page.copyWith(width: page.height, height: page.width);
    }
    return page;
  }

  String _text(String str) {
    StringBuffer txt = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      txt.write(switch (str[i]) {
        '\n' => '\\par',
        '\\' => '\\\\',
        '{' => '\\{',
        '}' => '\\}',
        '\t' => '\\tab ',
        _ => str.codeUnits[i] < 0x100 ? str[i] : '\\u${str.codeUnitAt(i)}\\\'3f'
      });
    }
    return txt.toString();
  }

  void _defineDoc(int charset, int lang) {
    _out.write("{\\rtf1\\ansi\\ansicpg$charset");
    _out.write("\\uc1 \\deff0\\deflang$lang");
    _out.write("\\deflangfe$lang");
  }

  void _defineListTables() {
    _out.write('{\\*\\listtable');
    for (int i = 1; i <= _list.length; i++) {
      _out.writeln('{\\list\\listtemplateid$i');
      for (int lvl = 0; lvl < 8; lvl++) {
        _out.write(
            '{\\listlevel\\levelnfc${_list[i - 1]}\\leveljc0\\levelstartat1\\levelfollow${i == 3 ? 2 : 0}{\\leveltext ');
        _out.write(switch (i) {
          1 => '\\\'02\\\'0$lvl.;}',
          2 => '\\\'01\\u${_bullet[lvl % _bullet.length]};}',
          3 => '\\\'00;}',
          _ => ''
        });
        _out.write('{\\levelnumbers${i == 1 ? '\\\'01' : ''};}');
        if (i == _list.length) {
          _out.writeln('\\fi0\\li0}');
        } else {
          _out.writeln('\\fi-360\\li${720 + 360 * lvl}}');
        }
      }
      _out.write('\\listid$i}');
    }
    _out.write('}');
    _out.write('{\\listoverridetable');
    for (int i = 1; i <= _list.length; i++) {
      _out.write('{\\listoverride\\listid$i\\listoverridecount0\\ls$i}');
    }
    _out.writeln('}');
  }

  void _defineFonts() {
    _out.write("{\\fonttbl");
    for (int idx = 0; idx < _styles.length; idx++) {
      _out.write("{\\f$idx");
      _out.write("\\f${_styles[idx]._family.name}");
      _out.write("\\fcharset0\\fprq2 ${_styles[idx]._fontName};}");
    }
    _out.write("}");
  }

  void _defineColors() {
    _out.write("{\\colortbl;");
    for (Color bc in Color.values) {
      _out.write('\\red${bc._red()}\\green${bc._green()}\\blue${bc._blue()};');
    }
    _out.writeln("\\red255\\green255\\blue255;}");
  }

  void _defineStyles(int lang) {
    _out.write("{\\stylesheet");
    for (int index = 0; index < _styles.length; index++) {
      Style f = _styles[index];

      String styleName = f._name;
      StringBuffer str = StringBuffer();
      if (styleName != 'Normal') {
        str
          ..write("\\s$index")
          ..write("\\sb240\\sa60");
      } else if (_interleave) {
        str.write("\\sa240");
      }
      String font =
          '\\f$index${f._style.isEmpty ? '\\plain' : f._style.map((e) => e._start).join()}\\fs${(2 * f._size).floor()}';
      _mFonts.add(font);
      str
        ..write("\\keepn\\adjustright")
        ..write(font)
        ..write("\\language$lang");
      _mStyles.add(str.toString());
      str.write(' ');
      if (_mStyles.length > 1) {
        str.write('\\sbasedon0 ');
      }
      str.write('\\snext0 $styleName;}');
      _out.write('{$str');
    }
    _out.write("}");
  }

  void _defineHeader() {
    var page = getPage();
    _out.writeln(
        "\\paperw${(um * page.width).round()}\\paperh${(um * page.height).round()}\\margl${(um * page.marginLeft).round()}\\margr${(um * page.marginRight).round()}\\margt${(um * page.marginTop).round()}\\margb${(um * page.marginBottom).round()}${_orientation._rtf}");
    _out.write(
        "\\widowctrl\\ftnbj\\aenddoc\\hyphcaps0\\viewkind1\\viewscale90");
    _out.write("\\fet0\\sectd ");
    _out.write("\\linex0");
    _out.write("\\headery500");
    if (_hfValues.sublist(3).where((element) => element != null).isNotEmpty) {
      _out.write("\\footery600");
    }
    _out.write("\\sectdefaultcl \\pard\\plain ");
  }

  Style? _setStyle(String font) {
    int idx = _styles.indexWhere((e) => e._name == font);
    if (idx < 0) return null;
    _out.write('${_continuos ? '' : '\\pard\\plain'}${_mStyles[idx]}');
    return _styles[idx];
  }

  void _setFont(String font) {
    int idx = _styles.indexWhere((e) => e._name == font);
    if (idx >= 0) _out.write(_mFonts[idx]);
  }

  void _hf(bool bFooter) {
    double l = 10.0 * getPage().availableWidth;
    List<Widget?> styles = _hfValues.sublist(bFooter ? 3 : 0, 3);
    if (!styles.any((s) => s != null)) {
      return;
    }
    _out.write(bFooter ? "{\\footer " : "{\\header ");
    // don't round before multiply, otherwise you loose some decimals
    _out.write(
        "\\pard\\plain \\tqc\\tx${l.round()}\\tqr\\tx${(2 * l).round()}\\adjustright {");
    _out.write("\\b\\qj ");
    for (int j = 0; j < styles.length; j++) {
      if (j > 0) {
        _out.write("\\tab ");
      }
      var s = styles[j];
      if (s != null) {
        s.draw(this, _out);
      }
    }
    _out.write("\\par }}");
  }

  void _insertImage(
      ByteData data, int dpi, bool share, int? width, int? height) {
    if (share) {
      _out.write("{");
      _out.write("\\*\\shppict ");
    }
    _out.write("{");
    _out.write("\\pict ");
    _out.write("\\pngblip ");

    int mult = 1440 ~/ dpi;
    if (width != null) {
      _out.write("\\picwgoal${(width * mult)} ");
    }
    if (height != null) {
      _out.write("\\pichgoal${(height * mult)} ");
    }
    for (int i = 0; i < data.buffer.lengthInBytes; i++) {
      int iData = data.getInt8(i);

      // Make positive byte
      if (iData < 0) {
        iData += 256;
      }
      if (iData < 16) {
        // Set leading zero and append
        _out.write("0");
      }
      _out.write(iData.toRadixString(16));
    }

    _out.write("}");
    _out.write("}");
  }
}

/// Font Families allowed
enum FontFamily {
  nil,

  ///Unknown or default fonts (the default)
  roman,

  ///	Roman, proportionally spaced serif fonts. Example: Times New Roman, Palatino
  swiss,

  ///	Swiss, proportionally spaced sans serif fonts. Example:	Arial
  modern,

  ///	Fixed-pitch serif and sans serif fonts. Example: Courier New, Pica
  script,

  ///	Script fonts. Example: Cursive
  decor,

  ///	Decorative fonts. Example: Old English, ITC Zapf Chancery
  tech,

  ///	Technical, symbol, and mathematical fonts. Example: Symbol
  bidi,

  /// Arabic, Hebrew, or other bidirectional font. Example: Miriam
}

/// Define a style with its font
class Style {
  final String _name;
  final String _fontName;
  final Set<StyleVariation> _style;
  final double _size;
  final FontFamily _family;

  Style(this._name, this._family, this._fontName, this._size,
      [List<StyleVariation> variations = const []])
      : _style = Set.from(variations.where((e) => e._end.isEmpty));
}

/// the Widget class
abstract class Widget {
  /// write the widget belonging to [doc] on [out]
  void draw(Document doc, IOSink out);

  /// number of columns: can be more than 1 in ColSpan Widget
  int col() => 1;
}

/// abstract Widget with a single widget as child
abstract class SingleChildWidget extends Widget {
  /// the only [child]
  Widget child;
  SingleChildWidget({required this.child});
  @override
  void draw(Document doc, IOSink out) {
    child.draw(doc, out);
  }
}

abstract class _MultipleChildrenWidget extends Widget {
  /// the children widgets list
  final List<Widget> children;
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

/// possibile style variation, like 'italic', 'bold', and so on
enum StyleVariation {
  italic('\\i', ''),
  bold('\\b', ''),
  superscript('\\super', '\\nosupersub'),
  subscript('\\sub', '\\nosupersub'),
  underline('\\ul', ''),
  doubleUnderline('\\uldb', ''),
  dottedUnderline('\\uld', '');

  final String _start;
  final String _end;
  const StyleVariation(this._start, this._end);
}

/// Define the Text's widget style
class TextStyle {
  final String? _font;
  final Color? _color;
  final double? _fontSize;
  final Set<StyleVariation> _variations;
  TextStyle(
      {
      /// font name: one of the Document styles
      String? font,

      /// color
      Color? color,

      /// font size
      double? fontSize,

      /// Style varations
      List<StyleVariation> variations = const []})
      : _font = font,
        _color = color,
        _fontSize = fontSize,
        _variations = Set.from(variations);
}

/// A Widget to insert a new page break
class SkipPage extends Widget {
  @override
  void draw(Document doc, IOSink out) {
    out.writeln("\\pard\\plain \\page");
  }
}

/// A widget to show page number
class PageNo extends Widget {
  /// show 'page number' / 'number of pages'; otherwise, show 'page number' only
  final bool nofPages;
  PageNo({this.nofPages = true});
  @override
  void draw(Document doc, IOSink out) {
    if (nofPages) {
      out.write(
          "{\\field{\\*\\fldinst { PAGE }}{\\fldrslt { 1}}}/{\\field{\\*\\fldinst { NUMPAGES    \\* MERGEFORMAT }}{\\fldrslt { 1}}}");
    } else {
      out.write("{\\field{\\*\\fldinst { PAGE }}{\\fldrslt { 1}}}");
    }
  }
}

/// A Widget to insert a new line break
class NewLine extends Widget {
  @override
  void draw(Document doc, IOSink out) {
    doc._newWidget();
    out.write("\\par ");
  }
}

/// A Widget that shows all its children separated by a newline
class Column extends _MultipleChildrenWidget {
  /// if false, omit newLine after last child
  final bool lastNL;
  Column({required super.children, this.lastNL = true});
  @override
  void draw(Document doc, IOSink out) {
    for (var c in children) {
      c.draw(doc, out);
      if (lastNL || c != children.last) {
        out.write('\\par ');
      }
    }
  }
}

/// A Widget that shows all its children on the same rows
class Paragraph extends _MultipleChildrenWidget {
  final String? _style;
  final Align? _align;

  Paragraph(
      {required super.children,

      /// one of the Document styles
      String? style,

      /// paragraph Alignment
      Align? align})
      : _style = style,
        _align = align;
  @override
  void draw(Document doc, IOSink out) {
    doc._continuos = true;
    if (_style != null) doc._setStyle(_style);
    out.write(_align?._al ?? '');
    for (var c in children) {
      c.draw(doc, out);
    }
    doc._continuos = false;
  }
}

/// A widget that shows its children in one or more columns
class Section extends Column {
  final int _nCols;
  final int _spCol;

  /// [spCol] is the space between columns
  Section(this._nCols, {required super.children, int? spCol})
      : _spCol = spCol ?? 36;
  @override
  void draw(Document doc, IOSink out) {
    doc._sections.add(this);
    doc._newSection(_nCols, _spCol);
    super.draw(doc, out);
    doc._sections.removeLast();
    doc._status = _Status.exit;
  }
}

/// A Widget to show a Text with its style
class Text extends Widget {
  final String _txt;
  final TextStyle? _style;
  Text(this._txt, {TextStyle? style}) : _style = style;

  @override
  void draw(Document doc, IOSink out) {
    doc._newWidget();
    String s = '';
    String e = '';
    String cf = '';
    String fs = '';
    if (_style != null) {
      if (_style._font != null) doc._setFont(_style._font);
      if (_style._fontSize != null) {
        fs = '\\fs${(2 * _style._fontSize).floor()}';
      }
      s = _style._variations.map((s) => s._start).join();
      e = _style._variations.map((s) => s._end).join();
      if (_style._color != null) cf = '\\cf${_style._color.index + 1}';
    }
    out.write('$s$fs$cf{${doc._text(_txt)}}$e');
  }
}

/// A Widget to show an Image
class Image extends Widget {
  final ByteData _data;
  final int _dpi;
  final bool _share;
  final int? _width;
  final int? _height;
  Image(

      /// [_data] contains the image data
      this._data,
      {
      /// dot per inch
      int dpi = 72,

      /// Share image, default is true
      bool share = true,

      /// image's width
      int? width,

      /// image's height
      int? height})
      : _dpi = dpi,
        _share = share,
        _width = width,
        _height = height;
  @override
  void draw(Document doc, IOSink out) {
    doc._newWidget();
    doc._insertImage(_data, _dpi, _share, _width, _height);
  }
}

/// Widget to draw a Line
class Line extends Widget {
  /// the line's width, in 20th of the available page width
  final double w;
  Line([this.w = 1]);
  @override
  void draw(Document doc, IOSink out) {
    doc._newWidget();
    double width = doc.getPage().availableWidth;
    double wd = w * width;
    double mg = (um * width - wd) / 2;
    out.write(
        "\\pard\\plain {\\shp{\\*\\shpinst\\shpleft${mg.round()}\\shptop180\\shpright${(mg + wd).round()}\\shpbottom180\\shpfhdr0\\shpbxcolumn\\shpbxignore\\shpbypara\\shpbyignore\\shpwr3\\shpwrk0\\shpfblwtxt0\\shpz0\\shplid1028{\\sp{\\sn shapeType}{\\sv 20}}{\\sp{\\sn fFlipH}{\\sv 0}}{\\sp{\\sn fFlipV}{\\sv 0}}{\\sp{\\sn shapePath}{\\sv 4}}{\\sp{\\sn fFillOK}{\\sv 0}}{\\sp{\\sn fFilled}{\\sv 0}}{\\sp{\\sn fArrowheadsOK}{\\sv 1}}{\\sp{\\sn fLayoutInCell}{\\sv 1}}}{\\shprslt{\\*\\do\\dobxcolumn\\dobypara\\dodhgt8192\\dpline\\dpptx0\\dppty0\\dpptx9900\\dppty0\\dpx0\\dpy0\\dpxsize\\dpysize0\\dplinew15\\dplinecor0\\dplinecog0\\dplinecob0}}}");
  }
}

/// A widget to show a List
class Listing extends Widget {
  final List<Widget> _elements;

  /// if true, a numbered list will be shown
  final bool _numbered;
  Listing(this._elements, this._numbered);
  @override
  void draw(Document doc, IOSink out) {
    doc._newWidget();
    for (int i = 0; i < _elements.length; i++) {
      String c = _numbered ? '$i.)' : '\\u8226\\\'95';
      out.write(
          '{\\listtext\\pard\\plain $c\\tab}\\ilvl0\\ls${_numbered ? 1 : 2}');
      _elements[i].draw(doc, out);
      out.write('\\par');
    }
  }
}
