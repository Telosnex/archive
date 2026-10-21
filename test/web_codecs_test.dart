@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:archive_40/archive.dart';
import 'package:test/test.dart';

// The web codecs are selected by dart.library.js_interop, which is true on
// both dart2js and dart2wasm. dart.library.js is false on dart2wasm, so the
// stubs threw "Cannot create a zlib encoder without dart:html or dart:io".
//
// Zip entries are raw deflate; the web zlib decoder used to ignore raw and
// decoded them to nothing. The web gzip encoder used to write big-endian.
void main() {
  final data = Uint8List.fromList(
      List<int>.generate(10000, (i) => (i * 7 + i ~/ 13) & 0xff));

  test('zlib round trip', () {
    final encoded = const ZLibEncoder().encodeBytes(data);
    expect(const ZLibDecoder().decodeBytes(encoded), data);
  });

  test('gzip round trip', () {
    final encoded = const GZipEncoder().encodeBytes(data);
    expect(encoded.sublist(0, 2), [0x1f, 0x8b]);
    expect(const GZipDecoder().decodeBytes(encoded, verify: true), data);
  });

  test('raw deflate round trip', () {
    final encoded = Deflate(data).getBytes();
    expect(const ZLibDecoder().decodeBytes(encoded, raw: true), data);
  });

  test('zip round trip with compression', () {
    final archive = Archive()..addFile(ArchiveFile.bytes('a.bin', data));
    final zipped = ZipEncoder().encodeBytes(archive);
    final file = ZipDecoder().decodeBytes(zipped).findFile('a.bin')!;
    expect(file.readBytes(), data);
  });
}
