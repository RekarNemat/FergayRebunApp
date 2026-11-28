import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/courses_data.dart';
import '../data/home_content_data.dart';
import '../data/library_teachers_data.dart';
import '../data/quizzes_data.dart';
import '../data/sanad_data.dart';
import '../models/academy_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Live Cloud Mock API CMS synchronization service.
/// Connects the Flutter App directly to the zero-backend DataEntry Dashboard
/// via a persistent CORS-enabled JSON Mock API endpoint (`npoint.io`).
class RemoteCmsService {
  static const String defaultApiUrl =
      'https://api.npoint.io/84b19991c621186ebc56';

  static String colorToHex(Color c) {
    final rgb = c.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static Color hexToColor(dynamic raw, Color fallback) {
    if (raw is! String || raw.trim().isEmpty) return fallback;
    final clean = raw.trim().replaceFirst('#', '');
    if (clean.length == 6) {
      final parsed = int.tryParse('FF$clean', radix: 16);
      if (parsed != null) return Color(parsed);
    } else if (clean.length == 8) {
      final parsed = int.tryParse(clean, radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return fallback;
  }

  static IconData _scienceIconForId(String id) {
    switch (id) {
      case 'tafseer':
        return Icons.menu_book_rounded;
      case 'hadith':
        return Icons.history_edu_rounded;
      case 'aqeedah':
        return Icons.verified_user_rounded;
      case 'fiqh':
        return Icons.balance_rounded;
      case 'nahw':
        return Icons.edit_note_rounded;
      case 'usul_fiqh':
        return Icons.account_balance_rounded;
      case 'seerah':
        return Icons.mosque_rounded;
      case 'sarf':
        return Icons.translate_rounded;
      case 'logic':
        return Icons.psychology_rounded;
      case 'balagha':
        return Icons.auto_awesome_rounded;
      case 'quran_sciences':
        return Icons.import_contacts_rounded;
      case 'tazkiyah':
        return Icons.spa_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  static IconData _guidanceIconForId(String id) {
    switch (id) {
      case 'guid_1':
        return Icons.visibility_rounded;
      case 'guid_2':
        return Icons.accessibility_new_rounded;
      case 'guid_3':
        return Icons.event_note_rounded;
      case 'guid_4':
        return Icons.favorite_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  /// Exports ALL 16 live sections into one JSON map matching the /DataEntry schema.
  static Map<String, dynamic> exportCurrentData(AppState appState) {
    final featuredKeys = featuredRecordedBooks.map((e) => e.key).toSet();
    return {
      'schemaVersion': 1,
      'updatedAt': DateTime.now().toIso8601String(),
      'dailyLearning': dailyLearningEntries
          .map((e) => {
                'id': e.id,
                'badge': e.badge,
                'title': e.title,
                'arabicQuote': e.arabicQuote,
                'kurdishExplanation': e.kurdishExplanation,
                'source': e.source,
                'imageUrl': e.imageUrl,
                'audioUrl': e.audioUrl,
              })
          .toList(),
      'sciences': homeSciencesList
          .map((s) => {
                'id': s.id,
                'arabicName': s.arabicName,
                'kurdishName': s.kurdishName,
                'colorHex': colorToHex(s.color),
                'iconUrl': s.iconUrl,
              })
          .toList(),
      'courses': courseCatalog.values
          .map((c) => {
                'key': c.key,
                'title': c.title,
                'instructor': c.instructor,
                'category': c.category,
                'summary': c.summary,
                'accentColorHex': colorToHex(c.accentColor),
                'featured': featuredKeys.contains(c.key),
                'coverImageUrl': c.coverImageUrl,
                'pdfUrl': c.pdfUrl,
                'episodes': c.episodes
                    .map((ep) => {
                          'id': ep.id,
                          'title': ep.title,
                          'duration': ep.duration,
                          'videoUrl': ep.videoUrl,
                          'audioUrl': ep.audioUrl,
                          'attachmentUrl': ep.attachmentUrl,
                        })
                    .toList(),
              })
          .toList(),
      'webinars': webinarsContentList
          .map((w) => {
                'id': w.id,
                'title': w.title,
                'duration': w.duration,
                'speaker': w.speaker,
                'desc': w.desc,
                'categoryLabel': w.categoryLabel,
                'colorStartHex': colorToHex(w.colorStart),
                'colorEndHex': colorToHex(w.colorEnd),
                'videoUrl': w.videoUrl,
                'audioUrl': w.audioUrl,
                'thumbnailUrl': w.thumbnailUrl,
                'attachmentUrl': w.attachmentUrl,
              })
          .toList(),
      'pdfBooks': pdfBooksDatabase
          .map((b) => {
                'id': b.id,
                'title': b.title,
                'author': b.author,
                'category': b.category,
                'pages': b.pages,
                'size': b.size,
                'icon': b.icon,
                'desc': b.desc,
                'coverColorHex': colorToHex(b.coverColor),
                'pdfUrl': b.pdfUrl,
                'coverImageUrl': b.coverImageUrl,
              })
          .toList(),
      'guidance': guidanceVideosList
          .map((g) => {
                'id': g.id,
                'title': g.title,
                'specialist': g.specialist,
                'duration': g.duration,
                'summary': g.summary,
                'keyTips': g.keyTips,
                'colorHex': colorToHex(g.color),
                'videoUrl': g.videoUrl,
                'audioUrl': g.audioUrl,
                'thumbnailUrl': g.thumbnailUrl,
                'attachmentUrl': g.attachmentUrl,
              })
          .toList(),
      'articles': articlesContentList
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'author': a.author,
                'badge': a.badge,
                'excerpt': a.excerpt,
                'fullContent': a.fullContent,
                'colorHex': colorToHex(a.color),
                'imageUrl': a.imageUrl,
                'audioUrl': a.audioUrl,
                'attachmentUrl': a.attachmentUrl,
              })
          .toList(),
      'teachers': academyTeachersDatabase
          .map((t) => {
                'id': t.id,
                'name': t.name,
                'title': t.title,
                'specialty': t.specialty,
                'bio': t.bio,
                'booksCount': t.booksCount,
                'lessonsCount': t.lessonsCount,
                'studentsCount': t.studentsCount,
                'books': t.books,
                'colorStartHex': colorToHex(t.colorStart),
                'colorEndHex': colorToHex(t.colorEnd),
                'photoUrl': t.photoUrl,
                'cvUrl': t.cvUrl,
              })
          .toList(),
      'sanad': sanadItemsList
          .map((sn) => {
                'key': sn.key,
                'shortTitle': sn.shortTitle,
                'title': sn.title,
                'science': sn.science,
                'book': sn.book,
                'description': sn.description,
                'teacherName': sn.teacherName,
                'reqTitle': sn.reqTitle,
                'reqText': sn.reqText,
                'iconEmoji': sn.iconEmoji,
                'colorHex': colorToHex(sn.color),
                'imageUrl': sn.imageUrl,
                'audioUrl': sn.audioUrl,
                'videoUrl': sn.videoUrl,
                'pdfUrl': sn.pdfUrl,
                'chain': sn.chain
                    .map((n) => {'name': n.name, 'title': n.title})
                    .toList(),
              })
          .toList(),
      'generalLevels': generalLevelsData
          .map((lvl) => {
                'levelNumber': lvl.levelNumber,
                'badgeText': lvl.badgeText,
                'title': lvl.title,
                'badgeColorHex': colorToHex(lvl.badgeColor),
                'courses': lvl.courses
                    .map((c) => {
                          'courseKey': c.courseKey,
                          'scienceBadge': c.scienceBadge,
                          'title': c.title,
                          'mainBook': c.mainBook,
                          'supportBook': c.supportBook,
                          'instructorShort': c.instructorShort,
                          'instructorFull': c.instructorFull,
                          'colorHex': colorToHex(c.color),
                        })
                    .toList(),
              })
          .toList(),
      'specializedSciences': specializedSciencesData
          .map((sc) => {
                'id': sc.id,
                'emoji': sc.emoji,
                'title': sc.title,
                'subtitle': sc.subtitle,
                'colorHex': colorToHex(sc.color),
                'stages': sc.stages
                    .map((st) => {
                          'courseKey': st.courseKey,
                          'stageLabel': st.stageLabel,
                          'title': st.title,
                          'mainBook': st.mainBook,
                          'supportBook': st.supportBook,
                          'instructorFull': st.instructorFull,
                        })
                    .toList(),
              })
          .toList(),
      'resources': usefulResourcesDatabase
          .map((r) => {
                'id': r.id,
                'title': r.title,
                'url': r.url,
                'category': r.category,
                'desc': r.desc,
                'icon': r.icon,
                'badge': r.badge,
                'attachmentUrl': r.attachmentUrl,
              })
          .toList(),
      'projects': reboonProjectsList
          .map((p) => {
                'id': p.id,
                'title': p.title,
                'subtitle': p.subtitle,
                'badge': p.badge,
                'icon': p.icon,
                'linkText': p.linkText,
                'url': p.url,
                'desc': p.desc,
                'isFeatured': p.isFeatured,
                'accentColorHex': colorToHex(p.accentColor),
                'imageUrl': p.imageUrl,
                'attachmentUrl': p.attachmentUrl,
              })
          .toList(),
      'quizzes': independentQuizBank.map(
        (scienceId, list) => MapEntry(
          scienceId,
          list
              .map((q) => {
                    'question': q.question,
                    'options': q.options,
                    'correctIndex': q.correctIndex,
                    'explanation': q.explanation,
                  })
              .toList(),
        ),
      ),
      'notifications': appState.notifications
          .map((n) => {
                'id': n.id,
                'title': n.title,
                'text': n.text,
                'time': n.time,
                'icon': n.icon,
              })
          .toList(),
      'organization': {
        'orgNameKu': OrganizationInfo.orgNameKu,
        'orgSubtitleKu': OrganizationInfo.orgSubtitleKu,
        'orgNameAr': OrganizationInfo.orgNameAr,
        'orgNameEn': OrganizationInfo.orgNameEn,
        'slogan': OrganizationInfo.slogan,
        'definition': OrganizationInfo.definition,
        'workAreas': OrganizationInfo.workAreas,
        'logoUrl': OrganizationInfo.logoUrl,
        'brochureUrl': OrganizationInfo.brochureUrl,
        'academyGoals': academyGoalsList
            .map((g) => {
                  'title': g.title,
                  'desc': g.desc,
                  'colorHex': colorToHex(g.color),
                })
            .toList(),
      },
    };
  }

  /// Fetches live JSON from the Cloud Mock API and applies it across the app.
  static Future<bool> fetchAndApply(
    AppState appState, {
    String? apiUrl,
  }) async {
    final target = (apiUrl != null && apiUrl.trim().isNotEmpty)
        ? apiUrl.trim()
        : defaultApiUrl;
    try {
      final sep = target.contains('?') ? '&' : '?';
      final uri = Uri.parse(
        '$target${sep}t=${DateTime.now().millisecondsSinceEpoch}',
      );
      final resp = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 7));
      if (resp.statusCode != 200) return false;

      final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
      if (decoded is! Map<String, dynamic>) return false;
      if (decoded['initialized'] == false) return false;

      applyPayload(decoded, appState);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Applies a decoded CMS JSON payload in-place to all app data collections.
  static void applyPayload(Map<String, dynamic> data, AppState appState) {
    // 1. Daily Learning
    if (data['dailyLearning'] is List &&
        (data['dailyLearning'] as List).isNotEmpty) {
      final list = (data['dailyLearning'] as List).whereType<Map>().map((m) {
        return DailyLearningEntry(
          id: '${m['id'] ?? 'daily_${DateTime.now().millisecondsSinceEpoch}'}',
          badge: '${m['badge'] ?? 'فێربوونی ڕۆژانە'}',
          title: '${m['title'] ?? 'فێربوونی ڕۆژانە'}',
          arabicQuote: '${m['arabicQuote'] ?? ''}',
          kurdishExplanation: '${m['kurdishExplanation'] ?? ''}',
          source: '${m['source'] ?? ''}',
          imageUrl: '${m['imageUrl'] ?? ''}',
          audioUrl: '${m['audioUrl'] ?? ''}',
        );
      }).toList();
      if (list.isNotEmpty) {
        dailyLearningEntries
          ..clear()
          ..addAll(list);
      }
    }

    // 2. Sciences
    if (data['sciences'] is List && (data['sciences'] as List).isNotEmpty) {
      final list = (data['sciences'] as List).whereType<Map>().map((m) {
        final id = '${m['id'] ?? 'custom'}';
        return ScienceCategoryItem(
          id: id,
          arabicName: '${m['arabicName'] ?? ''}',
          kurdishName: '${m['kurdishName'] ?? ''}',
          icon: _scienceIconForId(id),
          color: hexToColor(m['colorHex'], AppColors.teal800),
          iconUrl: '${m['iconUrl'] ?? ''}',
        );
      }).toList();
      if (list.isNotEmpty) {
        homeSciencesList
          ..clear()
          ..addAll(list);
      }
    }

    // 3. Courses + Featured Recorded Books
    if (data['courses'] is List && (data['courses'] as List).isNotEmpty) {
      final newCatalog = <String, CourseDetail>{};
      final newFeatured = <CourseDetail>[];
      for (final raw in (data['courses'] as List).whereType<Map>()) {
        final key = '${raw['key'] ?? raw['title'] ?? ''}';
        if (key.isEmpty) continue;
        final rawEps = (raw['episodes'] is List) ? raw['episodes'] as List : [];
        final episodes = rawEps.isEmpty
            ? [const Episode(id: 1, title: 'ئەڵقەی ١')]
            : rawEps.asMap().entries.map((entry) {
                final ep = entry.value is Map ? entry.value as Map : {};
                return Episode(
                  id: (ep['id'] is int) ? ep['id'] as int : entry.key + 1,
                  title: '${ep['title'] ?? 'ئەڵقەی ${entry.key + 1}'}',
                  duration: '${ep['duration'] ?? '٢٥ خولەک'}',
                  videoUrl: '${ep['videoUrl'] ?? ''}',
                  audioUrl: '${ep['audioUrl'] ?? ''}',
                  attachmentUrl: '${ep['attachmentUrl'] ?? ''}',
                );
              }).toList();
        final detail = CourseDetail(
          key: key,
          title: '${raw['title'] ?? key}',
          instructor: '${raw['instructor'] ?? 'ئەکادیمیای ڕێبوون'}',
          episodesCount: episodes.length,
          category: '${raw['category'] ?? 'وانەی شەرعی'}',
          summary: '${raw['summary'] ?? ''}',
          accentColor: hexToColor(raw['accentColorHex'], AppColors.teal700),
          episodes: episodes,
          coverImageUrl: '${raw['coverImageUrl'] ?? ''}',
          pdfUrl: '${raw['pdfUrl'] ?? ''}',
        );
        newCatalog[key] = detail;
        if (raw['featured'] == true) {
          newFeatured.add(detail);
        }
      }
      if (newCatalog.isNotEmpty) {
        courseCatalog
          ..clear()
          ..addAll(newCatalog);
        featuredRecordedBooks
          ..clear()
          ..addAll(newFeatured.isNotEmpty
              ? newFeatured
              : newCatalog.values.take(10));
      }
    }

    // 4. Webinars
    if (data['webinars'] is List) {
      final list = (data['webinars'] as List).whereType<Map>().map((m) {
        return VideoContentItem(
          id: '${m['id'] ?? 'web_${DateTime.now().millisecondsSinceEpoch}'}',
          title: '${m['title'] ?? ''}',
          duration: '${m['duration'] ?? '٣٠:٠٠ خولەک'}',
          speaker: '${m['speaker'] ?? ''}',
          desc: '${m['desc'] ?? ''}',
          categoryLabel: '${m['categoryLabel'] ?? 'وێبینار'}',
          isVerticalReel: false,
          colorStart: hexToColor(m['colorStartHex'], AppColors.teal700),
          colorEnd: hexToColor(m['colorEndHex'], AppColors.teal900),
          videoUrl: '${m['videoUrl'] ?? ''}',
          audioUrl: '${m['audioUrl'] ?? ''}',
          thumbnailUrl: '${m['thumbnailUrl'] ?? ''}',
          attachmentUrl: '${m['attachmentUrl'] ?? ''}',
        );
      }).toList();
      webinarsContentList
        ..clear()
        ..addAll(list);
    }

    // 5. PDF Library Books
    if (data['pdfBooks'] is List) {
      final list = (data['pdfBooks'] as List).whereType<Map>().toList().asMap().entries.map((entry) {
        final m = entry.value;
        return PdfBookData(
          id: (m['id'] is int) ? m['id'] as int : entry.key + 1,
          title: '${m['title'] ?? ''}',
          author: '${m['author'] ?? ''}',
          category: '${m['category'] ?? 'aqeedah'}',
          pages: (m['pages'] is num) ? (m['pages'] as num).toInt() : 64,
          size: '${m['size'] ?? '3.0 MB'}',
          icon: '${m['icon'] ?? '📖'}',
          desc: '${m['desc'] ?? ''}',
          coverColor: hexToColor(m['coverColorHex'], AppColors.teal800),
          pdfUrl: '${m['pdfUrl'] ?? ''}',
          coverImageUrl: '${m['coverImageUrl'] ?? ''}',
        );
      }).toList();
      pdfBooksDatabase
        ..clear()
        ..addAll(list);
    }

    // 6. Guidance Videos
    if (data['guidance'] is List) {
      final list = (data['guidance'] as List).whereType<Map>().map((m) {
        final id = '${m['id'] ?? 'guid'}';
        final tips = (m['keyTips'] is List)
            ? (m['keyTips'] as List).map((e) => '$e').where((e) => e.trim().isNotEmpty).toList()
            : <String>[];
        return GuidanceVideoItem(
          id: id,
          title: '${m['title'] ?? ''}',
          specialist: '${m['specialist'] ?? ''}',
          duration: '${m['duration'] ?? '١٠:٠٠ خولەک'}',
          summary: '${m['summary'] ?? ''}',
          keyTips: tips,
          icon: _guidanceIconForId(id),
          color: hexToColor(m['colorHex'], AppColors.teal800),
          videoUrl: '${m['videoUrl'] ?? ''}',
          audioUrl: '${m['audioUrl'] ?? ''}',
          thumbnailUrl: '${m['thumbnailUrl'] ?? ''}',
          attachmentUrl: '${m['attachmentUrl'] ?? ''}',
        );
      }).toList();
      guidanceVideosList
        ..clear()
        ..addAll(list);
    }

    // 7. Articles
    if (data['articles'] is List) {
      final list = (data['articles'] as List).whereType<Map>().map((m) {
        return ArticleContentItem(
          id: '${m['id'] ?? 'art'}',
          title: '${m['title'] ?? ''}',
          author: '${m['author'] ?? 'فێرگەی ڕێبوون'}',
          badge: '${m['badge'] ?? 'بابەتی نووسراو'}',
          excerpt: '${m['excerpt'] ?? ''}',
          fullContent: '${m['fullContent'] ?? ''}',
          color: hexToColor(m['colorHex'], AppColors.teal700),
          imageUrl: '${m['imageUrl'] ?? ''}',
          audioUrl: '${m['audioUrl'] ?? ''}',
          attachmentUrl: '${m['attachmentUrl'] ?? ''}',
        );
      }).toList();
      articlesContentList
        ..clear()
        ..addAll(list);
    }

    // 8. Teachers
    if (data['teachers'] is List) {
      final list = (data['teachers'] as List).whereType<Map>().toList().asMap().entries.map((entry) {
        final m = entry.value;
        final books = (m['books'] is List)
            ? (m['books'] as List).map((e) => '$e').where((e) => e.trim().isNotEmpty).toList()
            : <String>[];
        return TeacherData(
          id: (m['id'] is int) ? m['id'] as int : entry.key + 1,
          name: '${m['name'] ?? ''}',
          title: '${m['title'] ?? ''}',
          colorStart: hexToColor(m['colorStartHex'], AppColors.teal600),
          colorEnd: hexToColor(m['colorEndHex'], AppColors.teal800),
          booksCount: '${m['booksCount'] ?? '١'}',
          lessonsCount: '${m['lessonsCount'] ?? '١٠'}',
          studentsCount: '${m['studentsCount'] ?? '١٠٠'}',
          specialty: '${m['specialty'] ?? ''}',
          bio: '${m['bio'] ?? ''}',
          books: books,
          photoUrl: '${m['photoUrl'] ?? ''}',
          cvUrl: '${m['cvUrl'] ?? ''}',
        );
      }).toList();
      academyTeachersDatabase
        ..clear()
        ..addAll(list);
    }

    // 9. Sanad Items
    if (data['sanad'] is List && (data['sanad'] as List).isNotEmpty) {
      final list = (data['sanad'] as List).whereType<Map>().map((m) {
        final rawChain = (m['chain'] is List) ? m['chain'] as List : [];
        final chain = rawChain.whereType<Map>().map((n) {
          return SanadChainNode(
            name: '${n['name'] ?? ''}',
            title: '${n['title'] ?? ''}',
          );
        }).toList();
        return SanadItemData(
          key: '${m['key'] ?? 'sanad'}',
          shortTitle: '${m['shortTitle'] ?? ''}',
          title: '${m['title'] ?? ''}',
          science: '${m['science'] ?? ''}',
          book: '${m['book'] ?? ''}',
          description: '${m['description'] ?? ''}',
          teacherName: '${m['teacherName'] ?? ''}',
          reqTitle: '${m['reqTitle'] ?? ''}',
          reqText: '${m['reqText'] ?? ''}',
          iconEmoji: '${m['iconEmoji'] ?? '📖'}',
          color: hexToColor(m['colorHex'], AppColors.teal700),
          chain: chain,
          imageUrl: '${m['imageUrl'] ?? ''}',
          audioUrl: '${m['audioUrl'] ?? ''}',
          videoUrl: '${m['videoUrl'] ?? ''}',
          pdfUrl: '${m['pdfUrl'] ?? ''}',
        );
      }).toList();
      sanadItemsList
        ..clear()
        ..addAll(list);
    }

    // 10. General Levels
    if (data['generalLevels'] is List && (data['generalLevels'] as List).isNotEmpty) {
      final list = (data['generalLevels'] as List).whereType<Map>().toList().asMap().entries.map((entry) {
        final m = entry.value;
        final rawCourses = (m['courses'] is List) ? m['courses'] as List : [];
        final courses = rawCourses.whereType<Map>().map((c) {
          return GeneralCourseCardData(
            courseKey: '${c['courseKey'] ?? ''}',
            scienceBadge: '${c['scienceBadge'] ?? ''}',
            title: '${c['title'] ?? ''}',
            mainBook: '${c['mainBook'] ?? ''}',
            supportBook: '${c['supportBook'] ?? ''}',
            instructorShort: '${c['instructorShort'] ?? ''}',
            instructorFull: '${c['instructorFull'] ?? ''}',
            color: hexToColor(c['colorHex'], AppColors.teal700),
          );
        }).toList();
        return GeneralLevelData(
          levelNumber: (m['levelNumber'] is num)
              ? (m['levelNumber'] as num).toInt()
              : entry.key + 1,
          badgeText: '${m['badgeText'] ?? 'ئاستی ${entry.key + 1}'}',
          title: '${m['title'] ?? ''}',
          badgeColor: hexToColor(m['badgeColorHex'], AppColors.teal700),
          courses: courses,
        );
      }).toList();
      generalLevelsData
        ..clear()
        ..addAll(list);
    }

    // 11. Specialized Sciences
    if (data['specializedSciences'] is List &&
        (data['specializedSciences'] as List).isNotEmpty) {
      final list = (data['specializedSciences'] as List).whereType<Map>().map((m) {
        final rawStages = (m['stages'] is List) ? m['stages'] as List : [];
        final stages = rawStages.whereType<Map>().map((st) {
          return SpecializedStageData(
            courseKey: '${st['courseKey'] ?? ''}',
            stageLabel: '${st['stageLabel'] ?? ''}',
            title: '${st['title'] ?? ''}',
            mainBook: '${st['mainBook'] ?? ''}',
            supportBook: '${st['supportBook'] ?? ''}',
            instructorFull: '${st['instructorFull'] ?? ''}',
          );
        }).toList();
        return SpecializedScienceData(
          id: '${m['id'] ?? 'sci'}',
          emoji: '${m['emoji'] ?? '📖'}',
          title: '${m['title'] ?? ''}',
          subtitle: '${m['subtitle'] ?? ''}',
          color: hexToColor(m['colorHex'], AppColors.teal700),
          stages: stages,
        );
      }).toList();
      specializedSciencesData
        ..clear()
        ..addAll(list);
    }

    // 12. Useful Resources
    if (data['resources'] is List) {
      final list = (data['resources'] as List).whereType<Map>().toList().asMap().entries.map((entry) {
        final m = entry.value;
        return ResourceItemData(
          id: (m['id'] is int) ? m['id'] as int : entry.key + 1,
          title: '${m['title'] ?? ''}',
          url: '${m['url'] ?? ''}',
          category: '${m['category'] ?? 'libraries'}',
          desc: '${m['desc'] ?? ''}',
          icon: '${m['icon'] ?? '🌐'}',
          badge: '${m['badge'] ?? ''}',
          attachmentUrl: '${m['attachmentUrl'] ?? ''}',
        );
      }).toList();
      usefulResourcesDatabase
        ..clear()
        ..addAll(list);
    }

    // 13. Reboon Projects
    if (data['projects'] is List) {
      final list = (data['projects'] as List).whereType<Map>().map((m) {
        return ReboonProjectItem(
          id: '${m['id'] ?? 'proj'}',
          title: '${m['title'] ?? ''}',
          subtitle: '${m['subtitle'] ?? ''}',
          badge: '${m['badge'] ?? ''}',
          icon: '${m['icon'] ?? '⭐'}',
          linkText: '${m['linkText'] ?? 'زانیاری زیاتر'}',
          url: '${m['url'] ?? ''}',
          desc: '${m['desc'] ?? ''}',
          isFeatured: m['isFeatured'] == true,
          accentColor: hexToColor(m['accentColorHex'], AppColors.teal700),
          imageUrl: '${m['imageUrl'] ?? ''}',
          attachmentUrl: '${m['attachmentUrl'] ?? ''}',
        );
      }).toList();
      reboonProjectsList
        ..clear()
        ..addAll(list);
    }

    // 14. Quizzes (powers both Independent Quiz & Self-Assessment)
    if (data['quizzes'] is Map) {
      final qMap = data['quizzes'] as Map;
      for (final entry in qMap.entries) {
        final key = '${entry.key}';
        if (entry.value is List) {
          final parsed = (entry.value as List).whereType<Map>().map((q) {
            final opts = (q['options'] is List)
                ? (q['options'] as List).map((e) => '$e').toList()
                : <String>[];
            return QuizQuestion(
              question: '${q['question'] ?? ''}',
              options: opts.isEmpty ? ['وەڵامی ١', 'وەڵامی ٢'] : opts,
              correctIndex:
                  (q['correctIndex'] is num) ? (q['correctIndex'] as num).toInt() : 0,
              explanation: '${q['explanation'] ?? ''}',
            );
          }).toList();
          if (parsed.isNotEmpty) {
            independentQuizBank[key] = parsed;
          }
        }
      }
      // Refresh first 12 self-assessment topics to point to updated banks
      final bankKeys = [
        'aqeedah',
        'fiqh',
        'hadith',
        'tafseer',
        'nahw',
        'seerah',
        'usul_fiqh',
        'history',
        'tazkiyah',
        'logic',
        'balagha',
        'terms',
      ];
      for (int i = 0; i < bankKeys.length && i < selfAssessmentTopicsList.length; i++) {
        final bank = independentQuizBank[bankKeys[i]];
        if (bank != null && bank.isNotEmpty) {
          final old = selfAssessmentTopicsList[i];
          selfAssessmentTopicsList[i] = AssessmentTopicData(
            id: old.id,
            title: old.title,
            category: old.category,
            questionCount: bank.length,
            level: old.level,
            sampleQuestions: bank,
          );
        }
      }
    }

    // 15. Notifications
    if (data['notifications'] is List) {
      final list = (data['notifications'] as List).whereType<Map>().toList().asMap().entries.map((entry) {
        final m = entry.value;
        final id = (m['id'] is int) ? m['id'] as int : entry.key + 1;
        final alreadyRead = appState.notifications
            .any((existing) => existing.id == id && existing.read);
        return AppNotification(
          id: id,
          title: '${m['title'] ?? ''}',
          text: '${m['text'] ?? ''}',
          time: '${m['time'] ?? 'نوێ'}',
          read: alreadyRead,
          icon: '${m['icon'] ?? '🔔'}',
        );
      }).toList();
      appState.notifications
        ..clear()
        ..addAll(list);
    }

    // 16. Organization & Academy Goals
    if (data['organization'] is Map) {
      final org = data['organization'] as Map;
      if (org['orgNameKu'] != null) OrganizationInfo.orgNameKu = '${org['orgNameKu']}';
      if (org['orgSubtitleKu'] != null) OrganizationInfo.orgSubtitleKu = '${org['orgSubtitleKu']}';
      if (org['orgNameAr'] != null) OrganizationInfo.orgNameAr = '${org['orgNameAr']}';
      if (org['orgNameEn'] != null) OrganizationInfo.orgNameEn = '${org['orgNameEn']}';
      if (org['slogan'] != null) OrganizationInfo.slogan = '${org['slogan']}';
      if (org['definition'] != null) OrganizationInfo.definition = '${org['definition']}';
      if (org['workAreas'] is List) {
        OrganizationInfo.workAreas =
            (org['workAreas'] as List).map((e) => '$e').where((e) => e.trim().isNotEmpty).toList();
      }
      if (org['logoUrl'] != null) OrganizationInfo.logoUrl = '${org['logoUrl']}';
      if (org['brochureUrl'] != null) OrganizationInfo.brochureUrl = '${org['brochureUrl']}';
      if (org['academyGoals'] is List && (org['academyGoals'] as List).isNotEmpty) {
        const goalIcons = [
          Icons.school_rounded,
          Icons.lightbulb_rounded,
          Icons.verified_rounded,
          Icons.bolt_rounded,
        ];
        final goals = (org['academyGoals'] as List).whereType<Map>().toList().asMap().entries.map((entry) {
          final g = entry.value;
          return AcademyGoalItem(
            title: '${g['title'] ?? ''}',
            desc: '${g['desc'] ?? ''}',
            icon: goalIcons[entry.key % goalIcons.length],
            color: hexToColor(g['colorHex'], AppColors.teal700),
          );
        }).toList();
        academyGoalsList
          ..clear()
          ..addAll(goals);
      }
    }

    appState.markCmsSynced();
  }
}
