import 'package:flutter/material.dart';
import '../../data/courses_data.dart';
import '../../data/home_content_data.dart';
import '../../data/library_teachers_data.dart';
import '../../models/academy_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/media_helpers.dart';
import '../modals/independent_quiz_sheet.dart';
import '../modals/lesson_study_sheet.dart';
import '../modals/live_stream_sheet.dart';
import '../modals/media_player_sheet.dart';
import '../modals/pdf_library_sheet.dart';
import '../modals/resources_sheet.dart';
import '../modals/self_assessment_sheet.dart';
import '../modals/teachers_sheet.dart';

class HomeTab extends StatefulWidget {
  final AppState appState;
  final VoidCallback onGoToAcademy;
  final VoidCallback onGoToSanad;
  final VoidCallback onGoToAccount;

  const HomeTab({
    super.key,
    required this.appState,
    required this.onGoToAcademy,
    required this.onGoToSanad,
    required this.onGoToAccount,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _bannerCtrl = PageController(viewportFraction: 1.0);
  int _bannerPage = 0;
  int _dailyIndex = 0;

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _openScienceHub(ScienceCategoryItem science) {
    final relatedCourses = courseCatalog.values
        .where((c) =>
            c.category.contains(science.kurdishName) ||
            c.category.contains(science.arabicName) ||
            c.title.contains(science.arabicName) ||
            c.title.contains(science.kurdishName))
        .toList();
    if (relatedCourses.isEmpty) {
      relatedCourses.addAll(courseCatalog.values.take(2));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: science.color,
                  child: Icon(science.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${science.arabicName} • ${science.kurdishName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const Text(
                        'وانە ڤیدیۆییەکان، مەتن، کتێبی PDF و تاقیکردنەوە',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(height: 22),
            const Text(
              '🎬 وانە ڤیدیۆییەکان و مەتنی زانستەکە:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...relatedCourses.take(4).map(
                  (c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: science.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: science.color,
                      ),
                    ),
                    title: Text(c.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: Text(
                        '${c.instructor} • ${toKurdishDigits(c.episodesCount)} ئەڵقە (ڤیدیۆ + مەتن)'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pop(ctx);
                      openLessonStudySheet(
                        context,
                        widget.appState,
                        c.key,
                        onOpenAccountTab: widget.onGoToAccount,
                      );
                    },
                  ),
                ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      openPdfLibrarySheet(
                        context,
                        widget.appState,
                        initialCategory:
                            ['aqeedah', 'fiqh', 'hadith', 'tafseer', 'nahw', 'seerah']
                                    .contains(science.id)
                                ? science.id
                                : 'all',
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('کتێبە PDFەکان'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      openIndependentQuizSheet(
                        context,
                        initialScienceId: science.id,
                      );
                    },
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: const Text('تاقیکردنەوەی زانست'),
                    style: FilledButton.styleFrom(
                      backgroundColor: science.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAllProjectsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'پڕۆژەکانی دیکەی ڕێبوون',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            ...reboonProjectsList.map(
              (p) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Text(p.icon, style: const TextStyle(fontSize: 24)),
                title: Text(
                  p.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                subtitle: Text(p.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  openProjectDetailSheet(context, p);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;

    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final daily = dailyLearningEntries.isEmpty
            ? null
            : dailyLearningEntries[_dailyIndex % dailyLearningEntries.length];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: RefreshIndicator(
              color: AppColors.teal800,
              onRefresh: () => s.syncRemoteCms(),
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 28),
                children: [
                  // 1. HERO BANNER CAROUSEL (Voice 6 + Image 6 + HTML Hero)
                  _buildHeroCarousel(),
                  const SizedBox(height: 14),

                  // 2. فێربوونی ڕۆژانە (Voice 6 + Image 6 — below Hero!)
                  if (daily != null) ...[
                    _buildDailyLearningCard(daily),
                    const SizedBox(height: 22),
                  ],

                // 3. زانستەکان (Image 6 circular teal badges horizontally)
                const SectionTitleHeader(title: 'زانستەکان'),
                const SizedBox(height: 12),
                _buildSciencesStrip(),
                const SizedBox(height: 24),

                // 4. ڕاڤەی پەرتووکی شەرعی (Image 6 + Voice 6 + HTML Courses)
                SectionTitleHeader(
                  title: 'ڕاڤەی پەرتووکی شەرعی',
                  actionLabel: 'ئەکادیمیا',
                  onActionTap: widget.onGoToAcademy,
                ),
                const SizedBox(height: 12),
                _buildRecordedBooksCarousel(s),
                const SizedBox(height: 24),

                // 5. وێبینار (Exact PSD mockup — removed short videos toggle per Voice 12)
                const SectionTitleHeader(title: 'وێبینار'),
                const SizedBox(height: 12),
                _buildWebinarsCarousel(s),
                const SizedBox(height: 24),

                // 6. کتێبخانە (Image 6 + HTML 29-book PDF library)
                SectionTitleHeader(
                  title: 'کتێبخانە',
                  actionLabel: 'بینینی هەمووی',
                  onActionTap: () => openPdfLibrarySheet(context, s),
                ),
                const SizedBox(height: 12),
                _buildLibraryPreviewStrip(s),
                const SizedBox(height: 24),

                // 7. ڕێنمایی (Voice 7 + Image 6 — health, spine, plan, mental wellness)
                const SectionTitleHeader(title: 'ڕێنمایی'),
                const SizedBox(height: 12),
                _buildGuidanceCarousel(s),
                const SizedBox(height: 26),

                // 8. خزمەتگوزارییە گشتییەکان (Image 3 + Voice 3: clean single horizontal row!)
                const SectionTitleHeader(title: 'بەشەکان و هەڵسەنگاندن'),
                const SizedBox(height: 12),
                _buildBottomActionStrip(s),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCarousel() {
    final screenW = MediaQuery.of(context).size.width;
    final bannerHeight = screenW >= 640 ? 235.0 : 210.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          SizedBox(
            height: bannerHeight,
            child: PageView(
              controller: _bannerCtrl,
              onPageChanged: (p) => setState(() => _bannerPage = p),
              children: [
                // Slide 1: Photorealistic library hero matching Image 6
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/hero_library_hd.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/hero_library.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.72),
                              Colors.black.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                '✨ پلاتفۆرمی فەرمیی فێرگەی ڕێبوون',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.teal900,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'بەخێربێن بۆ فێرگەی ڕێبوون',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                              ),
                            ),
                            const Text(
                              'فێربوونی زانستە شەرعییەکان بە سەنەدی گەیەنراو و مێتۆدی هاوچەرخ',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide 2: HTML Welcome Banner (Voice 6 explicitly suggested adding the HTML definition as a banner slide!)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.teal800,
                        AppColors.teal700,
                        AppColors.teal900,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'دەروازەی زانستە شەرعییەکان',
                        style: TextStyle(
                          color: AppColors.amber400,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'فێرگەی ڕێبوون بۆ زانستی سەنەددار',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'دوور لە دەمارگیری و پشتبەستوو بە بەڵگە صەحیحەکان بە سەنەدی گەیەنراو تا پێغەمبەری خوا ﷺ.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ElevatedButton(
                            onPressed: widget.onGoToAcademy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.teal900,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: const Text('🚀 دەستپێکردنی خوێندن'),
                          ),
                          OutlinedButton(
                            onPressed: widget.onGoToSanad,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: const Text('📜 سەنەدەکان'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Slide 3: Other Reboon Projects Banner (Voice 4: moved from home body into banner)
                InkWell(
                  onTap: _openAllProjectsSheet,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF134E4A), Color(0xFFB45309)],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '⭐ پڕۆژەکانی دیکەی ڕێبوون',
                          style: TextStyle(
                            color: AppColors.amber400,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'ئەپی سیرەی پێغەمبەر ﷺ و پڕۆژە دیجیتالەکان',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'کلیک بکە بۆ بینینی سەرجەم پڕۆژە و دەستپێشخەرییەکانی دیکەی ڕێکخراو و فێرگەی ڕێبوون.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _bannerPage == i ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _bannerPage == i
                      ? AppColors.teal700
                      : Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLearningCard(DailyLearningEntry daily) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFECE8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (dailyLearningEntries.isEmpty) return;
          setState(() {
            _dailyIndex = (_dailyIndex + 1) % dailyLearningEntries.length;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  daily.title,
                  style: TextStyle(
                    color: isDark ? AppColors.teal400 : AppColors.teal800,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.autorenew_rounded,
                  color: isDark ? AppColors.teal400 : AppColors.teal800,
                  size: 15,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              daily.arabicQuote,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.teal800,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${daily.kurdishExplanation} — ${daily.source}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.78)
                    : AppColors.teal800.withValues(alpha: 0.8),
                fontSize: 11.5,
              ),
            ),
            if (daily.imageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: SmartUploadedImage(
                    imageUrl: daily.imageUrl,
                    fallback: const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
            if (daily.audioUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              MediaAttachmentsBar(audioUrl: daily.audioUrl),
            ],
          ],
        ),
      ),
    );
  }

  static const Set<String> _scienceAssetIds = {
    'tafseer',
    'hadith',
    'aqeedah',
    'fiqh',
    'nahw',
    'usul_fiqh',
    'seerah',
    'sarf',
    'logic',
    'balagha',
  };

  Widget _buildSciencesStrip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconTint = isDark ? AppColors.teal400 : AppColors.teal800;
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: homeSciencesList.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, idx) {
          final item = homeSciencesList[idx];
          final hasExactAsset = _scienceAssetIds.contains(item.id);
          return InkWell(
            onTap: () => _openScienceHub(item),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: SmartUploadedImage(
                        imageUrl: item.iconUrl,
                        fit: BoxFit.contain,
                        fallback: hasExactAsset
                            ? Image.asset(
                                'assets/images/icons/sci_${item.id}.png',
                                width: 40,
                                height: 40,
                                color: iconTint,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              )
                            : Icon(
                                item.icon,
                                color: iconTint,
                                size: 36,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 20,
                    child: Center(
                      child: Text(
                        item.arabicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: iconTint,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static const List<String> _shariaBookAssets = [
    'assets/images/sharia_book_1.png',
    'assets/images/sharia_book_2.png',
  ];

  Widget _buildRecordedBooksCarousel(AppState s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 222,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: featuredRecordedBooks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, idx) {
          final book = featuredRecordedBooks[idx];
          final cardAsset = _shariaBookAssets[idx % _shariaBookAssets.length];
          return InkWell(
            onTap: () => openLessonStudySheet(
              context,
              s,
              book.key,
              onOpenAccountTab: widget.onGoToAccount,
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 176,
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Exact PSD visual photo (book cover + teacher portrait)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SmartUploadedImage(
                            imageUrl: book.coverImageUrl,
                            fallback: Image.asset(
                              cardAsset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: FavoriteHeartButton(
                                appState: s,
                                favoriteKey: 'course:${book.key}',
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.teal800,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    book.instructor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Exact PSD Webinar Cards: transparent teacher bust popping out above the #15686C teal card!
  Widget _buildWebinarsCarousel(AppState s) {
    final items = webinarsContentList;
    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, idx) {
          final v = items[idx];
          return InkWell(
            onTap: () => openVideoPlayerSheet(context, s, v, playlist: items),
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 152,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Rounded teal card body
                  Container(
                    height: 158,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.teal800,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal900.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  // Transparent cutout teacher bust popping out above top edge (exact PSD!)
                  Positioned(
                    top: -16,
                    left: 6,
                    right: 6,
                    child: SizedBox(
                      height: 130,
                      child: SmartUploadedImage(
                        imageUrl: v.thumbnailUrl,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        fallback: Image.asset(
                          'assets/images/webinar_teacher.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  // Subtle teal bottom gradient for crisp white title readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 11),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.teal800.withValues(alpha: 0.0),
                            AppColors.teal800.withValues(alpha: 0.94),
                            AppColors.teal800,
                          ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                      child: Text(
                        v.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  // Favorite heart top-left inside card
                  Positioned(
                    top: 34,
                    left: 6,
                    child: FavoriteHeartButton(
                      appState: s,
                      favoriteKey: 'video:${v.id}',
                      inactiveColor: Colors.white70,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static const List<String> _libraryCoverAssets = [
    'assets/images/book_cover_1.png',
    'assets/images/book_cover_2.png',
    'assets/images/book_cover_3.png',
  ];

  Widget _buildLibraryPreviewStrip(AppState s) {
    final previewBooks = <PdfBookData>[];
    if (pdfBooksDatabase.isNotEmpty) {
      // Show newly added books (id > 29) first so DataEntry additions appear immediately
      final newlyAdded = pdfBooksDatabase.where((b) => b.id > 29).toList().reversed;
      previewBooks.addAll(newlyAdded);
      for (final prefId in [28, 29, 17, 1, 11, 24]) {
        final match = pdfBooksDatabase.where((b) => b.id == prefId).firstOrNull;
        if (match != null && !previewBooks.any((x) => x.id == match.id)) {
          previewBooks.add(match);
        }
      }
      for (final b in pdfBooksDatabase) {
        if (previewBooks.length >= 6) break;
        if (!previewBooks.any((x) => x.id == b.id)) {
          previewBooks.add(b);
        }
      }
    }

    if (previewBooks.isEmpty) {
      return const SizedBox(height: 16);
    }

    return SizedBox(
      height: 186,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: previewBooks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, idx) {
          final b = previewBooks[idx];
          final coverAsset = _libraryCoverAssets[idx % _libraryCoverAssets.length];
          final isCustomAdded = b.id > 29;
          return InkWell(
            onTap: () => openPdfBookDetailSheet(context, s, b),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 124,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SmartUploadedImage(
                      imageUrl: b.coverImageUrl,
                      fallback: Image.asset(
                        coverAsset,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    if (isCustomAdded)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.0),
                                AppColors.teal900.withValues(alpha: 0.92),
                              ],
                            ),
                          ),
                          child: Text(
                            b.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static const List<String> _guidanceAssets = [
    'assets/images/guidance_1.png',
    'assets/images/guidance_2.png',
  ];

  Widget _buildGuidanceCarousel(AppState s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 182,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: guidanceVideosList.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, idx) {
          final g = guidanceVideosList[idx];
          final thumbAsset = _guidanceAssets[idx % _guidanceAssets.length];
          return InkWell(
            onTap: () => openGuidanceVideoSheet(context, s, g),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 264,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SmartUploadedImage(
                            imageUrl: g.thumbnailUrl,
                            fallback: Image.asset(
                              thumbAsset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.14),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: FavoriteHeartButton(
                              appState: s,
                              favoriteKey: 'guidance:${g.id}',
                              inactiveColor: Colors.white,
                              size: 16,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                g.duration,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          g.specialist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? AppColors.teal400 : AppColors.teal800,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Single Horizontal Scrollable Row matching PSD with strictly uniform icon baseline alignment (Voice 14)
  Widget _buildBottomActionStrip(AppState s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconTint = isDark ? AppColors.teal400 : AppColors.teal800;
    final actions = [
      (
        'بابەتی نووسراو',
        'assets/images/icons/act_articles.png',
        () => openArticlesListSheet(context, s),
      ),
      (
        'خۆهەڵسەنگاندن',
        'assets/images/icons/act_self_assess.png',
        () => openSelfAssessmentSheet(context),
      ),
      (
        'تاقیکردنەوەی سەربەخۆ',
        'assets/images/icons/act_quiz.png',
        () => openIndependentQuizSheet(context),
      ),
      (
        'پەخشی ڕاستەوخۆ',
        'assets/images/icons/act_live.png',
        () => openLiveStreamSheet(
              context,
              s,
              onOpenAccountTab: widget.onGoToAccount,
            ),
      ),
      (
        'مامۆستایانی فێرگە',
        'assets/images/icons/act_teachers.png',
        () => openAcademyTeachersSheet(context, s),
      ),
      (
        'سەرچاوە بەسوودەکان',
        'assets/images/icons/act_resources.png',
        () => openUsefulResourcesSheet(context),
      ),
    ];

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, idx) {
          final item = actions[idx];
          return InkWell(
            onTap: item.$3,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Fixed-height icon container so ALL 6 icons sit at exact same vertical level!
                  SizedBox(
                    height: 46,
                    child: Center(
                      child: Image.asset(
                        item.$2,
                        width: 42,
                        height: 42,
                        color: iconTint,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Center(
                      child: Text(
                        item.$1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: iconTint,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

