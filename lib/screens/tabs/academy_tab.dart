import 'package:flutter/material.dart';
import '../../data/courses_data.dart';
import '../../models/academy_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/progress_chart.dart';
import '../../widgets/reboon_logo.dart';
import '../modals/lesson_study_sheet.dart';
import '../modals/quiz_sheet.dart';

class AcademyTab extends StatefulWidget {
  final AppState appState;
  final VoidCallback onGoToAccount;

  const AcademyTab({
    super.key,
    required this.appState,
    required this.onGoToAccount,
  });

  @override
  State<AcademyTab> createState() => _AcademyTabState();
}

class _AcademyTabState extends State<AcademyTab> {
  int? _selectedGeneralLevel;
  String? _selectedSpecializedId;

  static const List<IconData> _levelIcons = [
    Icons.looks_one_rounded,
    Icons.looks_two_rounded,
    Icons.looks_3_rounded,
    Icons.looks_4_rounded,
    Icons.looks_5_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final isGeneral = s.academyTrack == 'general';

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                // Header Title
                Text(
                  'ئەکادیمیای ڕێبوون',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'هەڵبژاردەی نێوان دوو ڕێڕەوی خوێندن بۆ ئەوەی بەو شێوازەی دەتەوێت قووڵ ببیتەوە لە زانستەکاندا.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Track Toggle Buttons: side-by-side Row with clean short names (Voices 4 & 6)
                Row(
                  children: [
                    Expanded(
                      child: _TrackToggleButton(
                        label: 'مەنهەجی گشتی',
                        active: isGeneral,
                        onTap: () {
                          setState(() => _selectedGeneralLevel = null);
                          s.setAcademyTrack('general');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TrackToggleButton(
                        label: 'مەنهەجی پسپۆڕی',
                        active: !isGeneral,
                        onTap: () {
                          setState(() => _selectedSpecializedId = null);
                          s.setAcademyTrack('specific');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                if (isGeneral)
                  _buildGeneralTrack(context, s)
                else
                  _buildSpecializedTrack(context, s),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Clean structured General Track (Voice 3):
  /// 1) Overview shows 5 clean clickable Level Cards + dedicated General Track Progress Chart.
  /// 2) Tapping a Level opens ONLY that level's courses cleanly with a Back button!
  Widget _buildGeneralTrack(BuildContext context, AppState s) {
    if (_selectedGeneralLevel != null) {
      final lvl = generalLevelsData.firstWhere(
        (l) => l.levelNumber == _selectedGeneralLevel,
        orElse: () => generalLevelsData.first,
      );
      final unlocked = s.isLevelUnlocked(lvl.levelNumber);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedGeneralLevel = null),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('گەڕانەوە بۆ لیستی ئاستەکان'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.teal800,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          _buildGeneralLevelDetailCard(context, s, lvl, unlocked),
        ],
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Track Overview Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.teal800, AppColors.teal900],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal600.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '٥ ئاستی پلەبەپلە / ناچاری 🔒',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'مەنهەجی گشتی',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ئەم ڕێڕەوە بۆ فێرخوازانی سەرەتا، مامناوەند و پێشکەوتوو داڕێژراوە؛ کلیکی هەر ئاستێک بکە بۆ بینینی وانەکانی ئەو ئاستە بە جیا و بە ڕێکوپێکی.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => openBookPdfPreviewSheet(
                  context,
                  'مەنهەجی گشتی',
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('داگرتنی گشتی مەنهەج بە PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.teal900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 5 Clean Clickable Level Selector Cards (Voice 3)
        ...generalLevelsData.map((lvl) {
          final unlocked = s.isLevelUnlocked(lvl.levelNumber);
          final iconData = _levelIcons[(lvl.levelNumber - 1).clamp(0, 4)];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedGeneralLevel = lvl.levelNumber);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: unlocked
                        ? lvl.badgeColor.withValues(alpha: 0.45)
                        : Colors.grey.withValues(alpha: 0.25),
                    width: unlocked ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (unlocked ? lvl.badgeColor : Colors.grey)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        unlocked ? iconData : Icons.lock_outline_rounded,
                        color: unlocked ? lvl.badgeColor : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: lvl.badgeColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lvl.badgeText,
                                  style: TextStyle(
                                    color: lvl.badgeColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                unlocked ? '🔓 کراوەیە' : '🔒 بە قفڵ بەستراوە',
                                style: TextStyle(
                                  color: unlocked
                                      ? AppColors.emerald600
                                      : Colors.grey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lvl.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${toKurdishDigits(lvl.courses.length)} وانەی سەرەکی • تاقیکردنەوە و PDF',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: unlocked ? AppColors.teal800 : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 10),
        // Separate Progress Chart dedicated to General Track (Voice 2)
        AcademyProgressChart(appState: s, track: 'general'),
      ],
    );
  }

  Widget _buildGeneralLevelDetailCard(
    BuildContext context,
    AppState s,
    GeneralLevelData lvl,
    bool unlocked,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.72,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: unlocked
                ? lvl.badgeColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: lvl.badgeColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                lvl.badgeText,
                style: TextStyle(
                  color: lvl.badgeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${lvl.title} ${unlocked ? '(ناچاری / 🔓 کراوەیە)' : '(ناچاری / 🔒 بە قفڵ بەستراوە)'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    if (!unlocked) {
                      showReboonToast(
                        context,
                        'تکایە ئاستی پێش خۆی تەواو بکە ئینجا ئەم بەشەت بۆ کارا دەبێت',
                      );
                      return;
                    }
                    openBookPdfPreviewSheet(context, '${lvl.badgeText}: ${lvl.title}');
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('داگرتنی PDFی ئاست'),
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (!unlocked) {
                      showReboonToast(
                        context,
                        'تکایە ئاستی پێش خۆی تەواو بکە ئینجا ئەم بەشەت بۆ کارا دەبێت',
                      );
                      return;
                    }
                    openQuizSheet(
                      context,
                      s,
                      '${lvl.badgeText}: ${lvl.title}',
                      levelNumberToUnlock: lvl.levelNumber,
                    );
                  },
                  icon: const Icon(Icons.quiz_rounded, size: 16),
                  label: const Text('✍️ تاقیکردنەوەی ئاست'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal800,
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Responsive Grid of the 4 Courses in this level
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth >= 780
                    ? 4
                    : (constraints.maxWidth >= 500 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 274,
                  ),
                  itemCount: lvl.courses.length,
                  itemBuilder: (_, idx) {
                    final c = lvl.courses[idx];
                    return _CourseVisualCard(
                      appState: s,
                      courseKey: c.courseKey,
                      badge: c.scienceBadge,
                      title: c.title,
                      mainBook: c.mainBook,
                      supportBook: c.supportBook,
                      instructorFull: c.instructorFull,
                      color: c.color,
                      unlocked: unlocked,
                      onOpenStudy: () {
                        if (!unlocked) {
                          showReboonToast(
                            context,
                            'تکایە ئاستی پێش خۆی تەواو بکە ئینجا ئەم بەشەت بۆ کارا دەبێت',
                          );
                          return;
                        }
                        openLessonStudySheet(
                          context,
                          s,
                          c.courseKey,
                          onOpenAccountTab: widget.onGoToAccount,
                        );
                      },
                      onOpenPdf: () {
                        if (!unlocked) {
                          showReboonToast(
                            context,
                            'تکایە ئاستی پێش خۆی تەواو بکە ئینجا ئەم بەشەت بۆ کارا دەبێت',
                          );
                          return;
                        }
                        openBookPdfPreviewSheet(context, c.courseKey);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Clean structured Specialized Track (Voices 2 & 3):
  /// 1) Overview shows 5 clean clickable Science Cards + dedicated Specialized Track Progress Chart.
  /// 2) Tapping a Science opens ONLY its 4 stages cleanly with a Back button!
  Widget _buildSpecializedTrack(BuildContext context, AppState s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedSpecializedId != null) {
      final sci = specializedSciencesData.firstWhere(
        (sc) => sc.id == _selectedSpecializedId,
        orElse: () => specializedSciencesData.first,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedSpecializedId = null),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('گەڕانەوە بۆ لیستی زانستە پسپۆڕییەکان'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.teal800,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: sci.color.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: sci.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(sci.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sci.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            sci.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => openBookPdfPreviewSheet(context, sci.title),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('داگرتنی PDFی زانست'),
                      style: OutlinedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => openQuizSheet(context, s, sci.title),
                      icon: const Icon(Icons.quiz_rounded, size: 16),
                      label: const Text('✍️ تاقیکردنەوەی زانست'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal800,
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth >= 780
                        ? 4
                        : (constraints.maxWidth >= 500 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 274,
                      ),
                      itemCount: sci.stages.length,
                      itemBuilder: (_, idx) {
                        final st = sci.stages[idx];
                        return _CourseVisualCard(
                          appState: s,
                          courseKey: st.courseKey,
                          badge: st.stageLabel,
                          title: st.title,
                          mainBook: st.mainBook,
                          supportBook: st.supportBook,
                          instructorFull: st.instructorFull,
                          color: sci.color,
                          unlocked: true,
                          onOpenStudy: () => openLessonStudySheet(
                            context,
                            s,
                            st.courseKey,
                            onOpenAccountTab: widget.onGoToAccount,
                          ),
                          onOpenPdf: () =>
                              openBookPdfPreviewSheet(context, st.courseKey),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Specialized Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.teal700, AppColors.teal800],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal500.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '٥ زانستی سەرەکی / ٤ قۆناغ لە هەریەکەیاندا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'مەنهەجی پسپۆڕی',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ئەم ڕێڕەوە تایبەتە بەو فێرخوازانەی دەیانەوێت بە شێوازێکی قووڵ و ئەکادیمی لە زانستێکی دیاریکراودا پسپۆڕ بن؛ هەر زانستێک هەڵبژێرە بۆ بینینی قۆناغەکانی.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => openBookPdfPreviewSheet(
                  context,
                  'مەنهەجی پسپۆڕی',
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('داگرتنی گشتی مەنهەج بە PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.teal900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 5 Clean Clickable Science Selector Cards
        ...specializedSciencesData.map((sci) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedSpecializedId = sci.id),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sci.color.withValues(alpha: 0.35),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: sci.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(sci.emoji, style: const TextStyle(fontSize: 25)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sci.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sci.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.teal800,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 10),
        // Separate Progress Chart dedicated to Specialized Track (Voice 2)
        AcademyProgressChart(appState: s, track: 'specific'),
      ],
    );
  }
}

class _TrackToggleButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TrackToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.teal800 : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.teal800, width: 2),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : AppColors.teal800,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _CourseVisualCard extends StatelessWidget {
  final AppState appState;
  final String courseKey;
  final String badge;
  final String title;
  final String mainBook;
  final String supportBook;
  final String instructorFull;
  final Color color;
  final bool unlocked;
  final VoidCallback onOpenStudy;
  final VoidCallback onOpenPdf;

  const _CourseVisualCard({
    required this.appState,
    required this.courseKey,
    required this.badge,
    required this.title,
    required this.mainBook,
    required this.supportBook,
    required this.instructorFull,
    required this.color,
    required this.unlocked,
    required this.onOpenStudy,
    required this.onOpenPdf,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onOpenStudy,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkCard]
                : [color.withValues(alpha: 0.08), Colors.white],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  TeacherAvatarBubble(
                    name: instructorFull,
                    size: 40,
                    colorStart: color,
                    colorEnd: Color.lerp(color, Colors.black, 0.35) ?? color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          instructorFull,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  StylizedBookCover(
                    title: title,
                    color: color,
                    width: 44,
                    height: 58,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                FavoriteHeartButton(
                  appState: appState,
                  favoriteKey: 'course:$courseKey',
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سەرەکی: $mainBook',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'پاڵپشت: $supportBook',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onOpenStudy,
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('▶ خوێندن'),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: onOpenPdf,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('📄 PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
