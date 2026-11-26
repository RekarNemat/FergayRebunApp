import 'package:flutter/material.dart';
import '../data/courses_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AcademyProgressChart extends StatelessWidget {
  final AppState appState;
  final String track; // 'general' or 'specific'

  const AcademyProgressChart({
    super.key,
    required this.appState,
    this.track = 'general',
  });

  int _calcCourseSetPct(Iterable<String> courseKeys, {int fallbackBase = 0}) {
    int doneEps = 0;
    int totalEps = 0;
    for (final key in courseKeys) {
      final detail = courseCatalog[key];
      final count = detail?.episodes.length ?? 6;
      totalEps += count;
      doneEps += appState.getCompletedEpisodes(key).length;
    }
    if (totalEps == 0) return fallbackBase;
    final dynamicPct = ((doneEps / totalEps) * 100).round();
    return dynamicPct > 0 ? dynamicPct.clamp(0, 100) : fallbackBase;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isGeneral = track == 'general';

    final String chartTitle = isGeneral
        ? 'ئاماری پێشکەوتنی مەنهەجی گشتی'
        : 'ئاماری پێشکەوتنی مەنهەجی پسپۆڕی';

    final String chartSubtitle = isGeneral
        ? 'ڕێژەی پێشکەوتنت لە هەر ٥ ئاستەکەی مەنهەجی گشتیدا'
        : 'ڕێژەی پێشکەوتنت لە هەر ٥ زانستەکەی مەنهەجی پسپۆڕیدا';

    final List<(String, int)> items = isGeneral
        ? generalLevelsData.map((lvl) {
            final isDone = appState.completedLevels[lvl.levelNumber] == true;
            final pct = isDone
                ? 100
                : _calcCourseSetPct(
                    lvl.courses.map((c) => c.courseKey),
                    fallbackBase: lvl.levelNumber == 1 ? 35 : 0,
                  );
            return ('ئاستی ${toKurdishDigits(lvl.levelNumber)}', pct);
          }).toList()
        : specializedSciencesData.asMap().entries.map((entry) {
            final idx = entry.key;
            final sci = entry.value;
            const shortLabels = ['عەقیدە', 'فیقهـ', 'فەرموودە', 'تەفسیر', 'زمان'];
            const fallbackBases = [55, 30, 40, 20, 15];
            final pct = _calcCourseSetPct(
              sci.stages.map((st) => st.courseKey),
              fallbackBase: idx < fallbackBases.length ? fallbackBases[idx] : 10,
            );
            return (
              idx < shortLabels.length ? shortLabels[idx] : 'بەشی ${toKurdishDigits(idx + 1)}',
              pct,
            );
          }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal500.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.teal800,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chartTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      chartSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 196,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                final label = item.$1;
                final pct = item.$2;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${toKurdishDigits(pct)}٪',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal400 : AppColors.teal800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: pct / 100.0),
                              duration: const Duration(milliseconds: 650),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) {
                                return FractionallySizedBox(
                                  heightFactor: value.clamp(0.06, 1.0),
                                  widthFactor: 0.62,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: pct == 0
                                            ? [
                                                Colors.grey.shade400,
                                                Colors.grey.shade300,
                                              ]
                                            : const [
                                                AppColors.teal800,
                                                AppColors.teal400,
                                              ],
                                      ),
                                      boxShadow: pct == 0
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: AppColors.teal500
                                                    .withValues(alpha: 0.25),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
