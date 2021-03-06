// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/memory.dart';
import 'package:test/test.dart';

import 'common_tests.dart';

void main() {
  group('MemoryFileSystem unix style', () {
    MemoryFileSystem fs;

    setUp(() {
      fs = MemoryFileSystem();
    });

    runCommonTests(
      () => fs,
      skip: <String>[
        'File > open', // Not yet implemented
      ],
    );

    group('toString', () {
      test('File', () {
        expect(fs.file('/foo').toString(), "MemoryFile: '/foo'");
      });

      test('Directory', () {
        expect(fs.directory('/foo').toString(), "MemoryDirectory: '/foo'");
      });

      test('Link', () {
        expect(fs.link('/foo').toString(), "MemoryLink: '/foo'");
      });
    });
  });

  group('MemoryFileSystem windows style', () {
    MemoryFileSystem fs;

    setUp(() {
      fs = MemoryFileSystem(style: FileSystemStyle.windows);
    });

    runCommonTests(
      () => fs,
      root: () => fs.style.root,
      skip: <String>[
        'File > open', // Not yet implemented
      ],
    );

    group('toString', () {
      test('File', () {
        expect(fs.file('C:\\foo').toString(), "MemoryFile: 'C:\\foo'");
      });

      test('Directory', () {
        expect(
            fs.directory('C:\\foo').toString(), "MemoryDirectory: 'C:\\foo'");
      });

      test('Link', () {
        expect(fs.link('C:\\foo').toString(), "MemoryLink: 'C:\\foo'");
      });
    });
  });

  test('MemoryFileSystem.test', () {
    final MemoryFileSystem fs =
        MemoryFileSystem.test(); // creates root directory
    fs.file('/test1.txt').createSync(); // creates file
    fs.file('/test2.txt').createSync(); // creates file
    expect(fs.directory('/').statSync().modified, DateTime(2000, 1, 1, 0, 1));
    expect(
        fs.file('/test1.txt').statSync().modified, DateTime(2000, 1, 1, 0, 2));
    expect(
        fs.file('/test2.txt').statSync().modified, DateTime(2000, 1, 1, 0, 3));
    fs.file('/test1.txt').createSync();
    fs.file('/test2.txt').createSync();
    expect(fs.file('/test1.txt').statSync().modified,
        DateTime(2000, 1, 1, 0, 2)); // file already existed
    expect(fs.file('/test2.txt').statSync().modified,
        DateTime(2000, 1, 1, 0, 3)); // file already existed
    fs.file('/test1.txt').writeAsStringSync('test'); // touches file
    expect(
        fs.file('/test1.txt').statSync().modified, DateTime(2000, 1, 1, 0, 4));
    expect(fs.file('/test2.txt').statSync().modified,
        DateTime(2000, 1, 1, 0, 3)); // didn't touch it
    fs.file('/test1.txt').copySync(
        '/test2.txt'); // creates file, then mutates file (so time changes twice)
    expect(fs.file('/test1.txt').statSync().modified,
        DateTime(2000, 1, 1, 0, 4)); // didn't touch it
    expect(
        fs.file('/test2.txt').statSync().modified, DateTime(2000, 1, 1, 0, 6));
  });
}
