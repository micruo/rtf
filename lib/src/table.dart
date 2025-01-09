import 'widget.dart';
import 'constant.dart';

enum _Border { top, left, right, bottom, horizontal, vertical }

final String _nullBorder = TableBorder(color: Color.white).getBorder();

/// Define the border type
class TableBorder {
  final int _color;
  final bool _bDash;
  TableBorder({bool? dash, Color? color})
      : _bDash = dash ?? false,
        _color = (color?.index ?? 0) + (color != null ? 1 : 0);
  String getBorder() {
    StringBuffer sb = StringBuffer("\\brdrs\\brsp18\\brdrw12");
    if (_bDash) {
      sb.write("\\brdrdashsm");
    }
    sb
      ..write("\\brdrcf")
      ..write(_color)
      ..write(' ');
    return sb.toString();
  }
}

/// Vertical alignments
enum VAlign {
  top('\\clvertalt'),
  center('\\clvertalc'),
  bottom('\\clvertalb');

  final String _al;
  const VAlign(this._al);
}

/// Shade tpyes
enum Shade {
  light(500),
  normal(1000),
  dark(1500);

  final int _sh;
  const Shade(this._sh);
}

/// Define the Widget to represent a Table
class Table extends Widget {
  final bool keep = true;
  final List<TableBorder?> _borders;
  final List<int>? _colWidths;
  final List<Widget> _headers;
  final List<List<Widget>> _rows;
  final VAlign _valign;
  final Shade? _headerShade;
  final Shade? _oddShade;
  final Shade? _pairShade;
  final int? _height;
  /// Create a Table widget
  /// 
  /// [_headers] is a List of Widget to display into the header
  /// 
  /// [_rows] is a List of List of Widget to display into each row
  /// 
  /// [_colWidths] contains columns' width
  /// 
  /// [headerShade] is the header's shade
  /// 
  /// [oddShade] is the header's shade for odd rows
  /// 
  /// [pairShade] is the header's shade for pair rows
  /// 
  /// [height] is the optional height for the rows
  /// 
  /// [left], [top], [right], [bottom], [horizontalInside], [verticalInside] are the TableBorder definition for each
  /// side and for internal border
  Table(
    this._headers,
    this._rows,
      {List<int>? colWidths,
      VAlign? valign,
      Shade? headerShade,
      Shade? oddShade,
      Shade? pairShade,
      int? height,
      TableBorder? left,
      TableBorder? top,
      TableBorder? right,
      TableBorder? bottom,
      TableBorder? horizontalInside,
      TableBorder? verticalInside})
      : _colWidths = colWidths,
        _headerShade = headerShade,
        _oddShade = oddShade,
        _pairShade = pairShade,
        _height = height,
        _valign = valign ?? VAlign.center,
        _borders = [left, right, top, bottom, horizontalInside, verticalInside];
  @override
  draw(Document doc) {
    write('\\par ');
    _writeCells(doc, _headers, 0);
    for (int i = 0; i < _rows.length; i++) {
      _writeCells(doc, _rows[i], 1 + i % 2);
    }
  }

  void _writeCells(Document doc, List<Widget> c, int type) {
    var page = doc.getPage();
    List<int> colWidths = _colWidths ?? List.filled(_headers.length, (page.availableWidth / _headers.length).round());
    int w = 0;
    write("\\trowd ");
    if (type == 0) {
      write("\\trhdr");
    } else if (keep) {
      write("\\trkeep");
    }
    write("\\trgaph70\\trleft$w");
    if (_height != null && type > 0) {
      write("\\trrh-${(2 * dot * _height / inch).floor()}");
    }
    for (int col = 0; col <= _headers.length; col++) {
      if (col > 0) {
        write("\\cellx$w");
      }
      if (col < _headers.length) {
        for (_Border b in _Border.values.sublist(0, 4)) {
          TableBorder? bd =
              _borders[((b == _Border.left && col > 0) || (b == _Border.top && type > 0) ? 4 : 0) + b.index];
          write('\\clbrdr${b.name[0]}${bd?.getBorder() ?? _nullBorder}');
        }
        write(_valign._al);
        int? shading;
        switch (type) {
          case 0:
            shading = _headerShade?._sh;
            break;
          case 1:
            shading = _oddShade?._sh;
            break;
          case 2:
            shading = _pairShade?._sh;
            break;
        }
        if (shading != null) {
          write("\\clcbpat8\\clshdng$shading");
        }
        w += colWidths[col] * um;
      }
    }
    for (int col = 0; col < _headers.length; col++) {
      write("\\intbl{");
      c[col].draw(doc);
      write("\\cell }");
    }
    write("\\intbl{\\row }\\pard\\plain\r\n");
  }
}
