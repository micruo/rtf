## 0.0.1

* Implements a minimal library to produce an RTF document, readable by several word processors

## 0.0.2

* Added a Line widget that show a line
* Added a Listing widget that show a list

## 0.0.3

* Added the Section widget that show its children in one or more columns
* Changed the way to define document header/footer
* Added some examples

## 0.0.4

* Reengineered code
* Added a parameter to Column widget to omit newLine after last child
* Added a ColSpan widget to span a cell on more columns

## 0.0.5

* Added FontFamily enum and introduced Document.addStyle()
* Deprecated Row widget, substituting it with Paragraph
* Added StyleVariation (italic, bold, etc.)
* In TextStyle, deprecated align, style field and added font, variations and color
* Added new example