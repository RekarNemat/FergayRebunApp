import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:reboon_academy/data/courses_data.dart';
import 'package:reboon_academy/data/home_content_data.dart';
import 'package:reboon_academy/data/library_teachers_data.dart';
import 'package:reboon_academy/services/remote_cms_service.dart';
import 'package:reboon_academy/state/app_state.dart';

void main() {
  test('RemoteCmsService exports all 16 sections and applies add/edit/delete cleanly', () {
    final appState = AppState();
    final exported = RemoteCmsService.exportCurrentData(appState);

    // Export default_data.json if EXPORT_CMS_DEFAULT=1
    if (Platform.environment['EXPORT_CMS_DEFAULT'] == '1') {
      final outFile = File('web/DataEntry/default_data.json');
      outFile.parent.createSync(recursive: true);
      outFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(exported),
        encoding: utf8,
      );
    }

    // Verify all 16 sections exist and are populated
    expect((exported['dailyLearning'] as List).isNotEmpty, isTrue);
    expect((exported['sciences'] as List).isNotEmpty, isTrue);
    expect((exported['courses'] as List).isNotEmpty, isTrue);
    expect((exported['webinars'] as List).isNotEmpty, isTrue);
    expect((exported['pdfBooks'] as List).isNotEmpty, isTrue);
    expect((exported['guidance'] as List).isNotEmpty, isTrue);
    expect((exported['articles'] as List).isNotEmpty, isTrue);
    expect((exported['teachers'] as List).isNotEmpty, isTrue);
    expect((exported['sanad'] as List).isNotEmpty, isTrue);
    expect((exported['generalLevels'] as List).isNotEmpty, isTrue);
    expect((exported['specializedSciences'] as List).isNotEmpty, isTrue);
    expect((exported['resources'] as List).isNotEmpty, isTrue);
    expect((exported['projects'] as List).isNotEmpty, isTrue);
    expect((exported['quizzes'] as Map).isNotEmpty, isTrue);
    expect((exported['notifications'] as List).isNotEmpty, isTrue);
    expect((exported['organization'] as Map).isNotEmpty, isTrue);

    // Clone and test Add + Edit + Delete round-trip
    final originalBooksCount = pdfBooksDatabase.length;
    final originalArticlesCount = articlesContentList.length;
    final modified = jsonDecode(jsonEncode(exported)) as Map<String, dynamic>;

    (modified['pdfBooks'] as List).add({
      'id': 999,
      'title': 'کتێبی تاقیکردنەوەی ڕاستەوخۆ',
      'author': 'فێرگەی ڕێبوون',
      'category': 'aqeedah',
      'pages': 120,
      'size': '2.5 MB',
      'icon': '📗',
      'desc': 'تاقیکردنەوەی زیادکردن لە داشبۆردەوە',
      'coverColorHex': '#15686C',
      'pdfUrl': 'https://example.com/book.pdf',
      'coverImageUrl': 'https://example.com/cover.jpg',
    });
    ((modified['courses'] as List).first as Map)['pdfUrl'] =
        'https://example.com/course.pdf';
    ((((modified['courses'] as List).first as Map)['episodes'] as List).first
        as Map)['videoUrl'] = 'https://example.com/ep1.mp4';
    ((((modified['courses'] as List).first as Map)['episodes'] as List).first
        as Map)['audioUrl'] = 'https://example.com/ep1.mp3';
    ((((modified['courses'] as List).first as Map)['episodes'] as List).first
        as Map)['attachmentUrl'] = 'https://example.com/ep1.pdf';
    (modified['articles'] as List).removeLast();

    RemoteCmsService.applyPayload(modified, appState);
    expect(pdfBooksDatabase.length, originalBooksCount + 1);
    expect(pdfBooksDatabase.last.title, 'کتێبی تاقیکردنەوەی ڕاستەوخۆ');
    expect(pdfBooksDatabase.last.pdfUrl, 'https://example.com/book.pdf');
    expect(pdfBooksDatabase.last.coverImageUrl, 'https://example.com/cover.jpg');
    expect(courseCatalog.values.first.pdfUrl, 'https://example.com/course.pdf');
    expect(courseCatalog.values.first.episodes.first.videoUrl, 'https://example.com/ep1.mp4');
    expect(courseCatalog.values.first.episodes.first.audioUrl, 'https://example.com/ep1.mp3');
    expect(courseCatalog.values.first.episodes.first.attachmentUrl, 'https://example.com/ep1.pdf');
    expect(articlesContentList.length, originalArticlesCount - 1);
    expect(appState.cmsLastSyncTime, isNotNull);

    // Restore original data so other tests are unaffected
    RemoteCmsService.applyPayload(exported, appState);
    expect(courseCatalog.isNotEmpty, isTrue);
    expect(pdfBooksDatabase.length, originalBooksCount);
    expect(articlesContentList.length, originalArticlesCount);
  });
}
