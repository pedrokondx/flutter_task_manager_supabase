import 'dart:io';
import 'package:mocktail/mocktail.dart';

class FakeFile extends Fake implements File {
  @override
  String get path => 'fake/path.jpg';
}
