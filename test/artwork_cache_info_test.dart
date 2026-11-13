import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/library/services/artwork_service.dart';

void main() {
  group('ArtworkCacheInfo', () {
    test('parses native cache statistics', () {
      final info = ArtworkCacheInfo.fromMap({
        'fileCount': 12,
        'totalBytes': 1536,
      });

      expect(info.fileCount, 12);
      expect(info.totalBytes, 1536);
      expect(info.formattedSize, '1.5 KB');
    });

    test('uses zero values when native fields are missing', () {
      final info = ArtworkCacheInfo.fromMap(const {});

      expect(info.fileCount, 0);
      expect(info.totalBytes, 0);
      expect(info.formattedSize, '0 B');
    });

    test('formats larger cache sizes in MB and GB', () {
      final megabytes = ArtworkCacheInfo.fromMap({
        'fileCount': 1,
        'totalBytes': 2 * 1024 * 1024,
      });
      final gigabytes = ArtworkCacheInfo.fromMap({
        'fileCount': 1,
        'totalBytes': 2 * 1024 * 1024 * 1024,
      });

      expect(megabytes.formattedSize, '2.00 MB');
      expect(gigabytes.formattedSize, '2.00 GB');
    });
  });
}
