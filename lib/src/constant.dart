import 'dart:io';

const um = 20;
const double inch = 2.54;
const dot = 72.0;
late IOSink out;

void write(String s) => out.write(s);
