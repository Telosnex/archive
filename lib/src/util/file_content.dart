import 'dart:typed_data';

import 'input_memory_stream.dart';
import 'input_stream.dart';
import 'output_stream.dart';

/// Used by [ArchiveFile] to abstract the content of a file within an archive
/// file, either in memory, or a position within a file on disk.
abstract class FileContent {
  /// Get the InputStream for reading the file content.
  InputStream getStream({bool decompress = true});

  /// Write the contents of the file to the given [output].
  void write(OutputStream output);

  /// Close the file content asynchronously.
  Future<void> close();

  /// Close the file content synchronously.
  void closeSync();

  /// Read the file content into memory and return the read bytes.
  Uint8List readBytes() {
    final stream = getStream();
    return stream.toUint8List();
  }

  /// Decompress the file content and write out the decompressed bytes to
  /// the [output] stream.
  void decompress(OutputStream output) {
    output.writeStream(getStream());
  }

  /// True if the file content is compressed.
  bool get isCompressed => false;
}

/// A [FileContent] that is resident in memory.
class FileContentMemory extends FileContent {
  final Uint8List bytes;

  FileContentMemory(List<int> data)
      : bytes = data is Uint8List ? data : Uint8List.fromList(data);

  @override
  InputStream getStream({bool decompress = true}) => InputMemoryStream(bytes);

  @override
  void write(OutputStream output) => output.writeBytes(bytes);

  @override
  Future<void> close() async {}

  @override
  void closeSync() {}
}

/// A [FileContent] that is stored in a disk file.
class FileContentStream extends FileContent {
  final InputStream stream;

  FileContentStream(this.stream);

  @override
  InputStream getStream({bool decompress = true}) => stream;

  @override
  void write(OutputStream output) => output.writeStream(stream);

  @override
  Future<void> close() async => stream.close();

  @override
  void closeSync() => stream.closeSync();
}
