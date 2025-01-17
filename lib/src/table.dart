import 'dart:io';

import 'widget.dart';

enum _Border { top, left, bottom, right, horizontal, vertical }

/// Define the border type
class TableBorder {
  final Color? _color;
  final bool _bDash;
  TableBorder({bool? dash, Color? color})
      : _bDash = dash ?? false,
        _color = color;
  TableBorder.standard()
      : _color = Color.black,
        _bDash = false;
  TableBorder.none()
      : _color = null,
        _bDash = false;
  String getBorder() {
    if (_color == null) {
      return '\\brdrn ';
    }
    StringBuffer sb = StringBuffer("\\brdrs\\brsp18\\brdrw12");
    if (_bDash) {
      sb.write("\\brdrdashsm");
    }
    sb
      ..write("\\brdrcf")
      ..write(_color.index + 1)
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
  final List<TableBorder> _borders;
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
  /// [_rows] is a List of List of Widget to display into each row. Any row with more elements than [_headers] length
  /// will be shrink to such a length
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
  Table(this._headers, this._rows,
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
      : assert(colWidths == null || colWidths.length == _headers.length),
        _colWidths = colWidths,
        _headerShade = headerShade,
        _oddShade = oddShade,
        _pairShade = pairShade,
        _height = height,
        _valign = valign ?? VAlign.center,
        _borders = [
          top ?? TableBorder.none(),
          left ?? TableBorder.none(),
          bottom ?? TableBorder.none(),
          right ?? TableBorder.none(),
          horizontalInside ?? TableBorder.none(),
          verticalInside ?? TableBorder.none()
        ];
  @override
  void draw(Document doc, IOSink out) {
    out.write('\\par ');
    _writeCells(doc, out, _headers, 0, -1);
    for (int i = 0; i < _rows.length; i++) {
      _writeCells(doc, out, _rows[i], 1 + i, _rows.length);
    }
  }

  void _writeCells(
      Document doc, IOSink out, List<Widget> c, int type, int max) {
    var page = doc.getPage();
    List<int> colWidths = _colWidths ??
        List.filled(
            _headers.length, (page.availableWidth / _headers.length).round());
    int w = 0;
    out.write("\\trowd ");
    if (type == 0) {
      out.write("\\trhdr");
    } else if (keep) {
      out.write("\\trkeep");
    }
    out.write("\\trgaph70\\trleft$w");
    if (_height != null && type > 0) {
      out.write("\\trrh-${(2 * dot * _height / inch).floor()}");
    }
    int k = 0;
    for (int col = 0; col < _headers.length; col++, k++) {
      if (k < c.length) {
        int l = c[k].col();
        while (--l > 0) {
          w += colWidths[col++] * um;
        }
      }
      for (_Border b in _Border.values.sublist(0, 4)) {
        TableBorder bd = _borders[(b == _Border.left && k > 0) ||
                (b == _Border.right && col < _headers.length - 1) ||
                (b == _Border.top && type > 1) ||
                (b == _Border.bottom && type < max)
            ? (b.index % 2 == 0
                ? _Border.horizontal.index
                : _Border.vertical.index)
            : b.index];
        out.write('\\clbrdr${b.name[0]}${bd.getBorder()}');
      }
      out.write(_valign._al);
      int? shading;
      if (type == 0) {
        shading = _headerShade?._sh;
      } else {
        shading = type % 2 == 0 ? _pairShade?._sh : _oddShade?._sh;
      }
      if (shading != null) {
        out.write("\\clcbpat8\\clshdng$shading");
      }
      w += colWidths[col] * um;
      out.write("\\cellx$w");
    }
    for (int col = 0; col < _headers.length; col++) {
      out.write("\\intbl{");
      if (col < c.length) {
        c[col].draw(doc, out);
      }
      out.write("\\cell }");
    }
    out.writeln("\\intbl{\\row }\\pard\\plain");
  }
}

class ColSpan extends SingleChildWidget {
  final int _nCol;
  ColSpan(this._nCol, {required super.child}) : assert(_nCol > 0);
  @override
  int col() => _nCol;
}
