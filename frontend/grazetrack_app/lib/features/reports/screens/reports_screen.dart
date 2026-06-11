import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/report_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../animals/providers/animal_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReport();
      ref.read(animalProvider.notifier).loadAnimals();
    });
  }

  // ─── Date range picker + load filtered report ────────────────────────────
  Future<void> _pickDateRange() async {
    final state = ref.read(reportProvider);
    final initialRange = (state.startDate != null && state.endDate != null)
        ? DateTimeRange(start: state.startDate!, end: state.endDate!)
        : DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      ref.read(reportProvider.notifier).loadReport(
            startDate: picked.start,
            endDate: picked.end,
          );
    }
  }

  // ─── Critical incident report dialog ────────────────────────────────────
  Future<void> _showIncidentReportDialog() async {
    final animals = ref.read(animalProvider).animals;

    await showDialog(
      context: context,
      builder: (ctx) => _IncidentReportDialog(animals: animals),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);
    final r = state.report;
    final hasDateFilter = state.startDate != null || state.endDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportProvider.notifier).loadReport(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(reportProvider.notifier).loadReport(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Action buttons row ─────────────────────
                        Row(
                          children: [
                            // PDF with date range
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.picture_as_pdf_outlined,
                                label: 'Generate PDF',
                                sublabel: hasDateFilter
                                    ? '${AppUtils.formatDate(state.startDate!.toIso8601String())} – ${AppUtils.formatDate(state.endDate!.toIso8601String())}'
                                    : 'All time',
                                color: AppTheme.primaryGreen,
                                onTap: () async {
                                  await _pickDateRange();
                                  if (!mounted) return;
                                  if (ref
                                      .read(reportProvider)
                                      .report
                                      .isNotEmpty) {
                                    // ignore: use_build_context_synchronously
                                    ref
                                        .read(reportProvider.notifier)
                                        .generatePdf(context);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Critical incident report
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.warning_amber_rounded,
                                label: 'Report Incident',
                                sublabel: 'Log incident in the system',
                                color: Colors.red[700]!,
                                onTap: _showIncidentReportDialog,
                              ),
                            ),
                          ],
                        ),

                        // ─── Date filter chip ───────────────────────
                        if (hasDateFilter) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.filter_alt_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Filtered: ${AppUtils.formatDate(state.startDate?.toIso8601String() ?? '')} – ${AppUtils.formatDate(state.endDate?.toIso8601String() ?? '')}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => ref
                                    .read(reportProvider.notifier)
                                    .clearDateFilter(),
                                icon: const Icon(Icons.close,
                                    size: 14, color: Colors.grey),
                                label: const Text('Clear',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ─── Summary Cards ──────────────────────────
                        const _SectionTitle('Farm Summary'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _SummaryCard(
                              'Total Revenue',
                              AppUtils.formatCurrency(
                                  (r['totalRevenue'] ?? 0).toDouble()),
                              Icons.trending_up,
                              Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _SummaryCard(
                              'Total Costs',
                              AppUtils.formatCurrency(
                                  (r['totalCosts'] ?? 0).toDouble()),
                              Icons.trending_down,
                              AppTheme.warningOrange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SummaryCard(
                              'Net Profit',
                              AppUtils.formatCurrency(
                                  (r['totalProfit'] ?? 0).toDouble()),
                              Icons.account_balance_wallet_outlined,
                              (r['totalProfit'] ?? 0) >= 0
                                  ? AppTheme.profitGreen
                                  : AppTheme.lossRed,
                            ),
                            const SizedBox(width: 12),
                            _SummaryCard(
                              'Overall ROI',
                              '${r['overallROI'] ?? 0}%',
                              Icons.pie_chart_outline,
                              AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SummaryCard(
                              'Profitable Sales',
                              '${r['profitableAnimals'] ?? 0}',
                              Icons.check_circle_outline,
                              AppTheme.profitGreen,
                            ),
                            const SizedBox(width: 12),
                            _SummaryCard(
                              'Loss Sales',
                              '${r['lossAnimals'] ?? 0}',
                              Icons.cancel_outlined,
                              AppTheme.lossRed,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ─── Monthly Trend Chart ────────────────────
                        const _SectionTitle('Monthly Revenue vs Expenses'),
                        const SizedBox(height: 8),
                        _MonthlyChart(
                            monthlyTrend: r['monthlyTrend'] as List? ?? []),

                        const SizedBox(height: 24),

                        // ─── Expense Breakdown ──────────────────────
                        const _SectionTitle('Expense Breakdown'),
                        const SizedBox(height: 8),
                        _ExpenseBreakdown(
                            expenseByType: r['expenseByType'] as Map? ?? {}),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ─── Action button card ───────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: color)),
              Text(sublabel,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Critical Incident Report dialog ─────────────────────────────────────
class _IncidentReportDialog extends ConsumerStatefulWidget {
  final List animals;
  const _IncidentReportDialog({required this.animals});

  @override
  ConsumerState<_IncidentReportDialog> createState() =>
      _IncidentReportDialogState();
}

class _IncidentReportDialogState extends ConsumerState<_IncidentReportDialog> {
  String _incidentType = 'Deceased';
  String? _selectedAnimalId;
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitIncident() async {
    if (_selectedAnimalId == null) {
      AppUtils.showSnackBar(context, 'Please select an animal', isError: true);
      return;
    }
    setState(() => _submitting = true);
    final animal = widget.animals.firstWhere(
      (a) => a.id == _selectedAnimalId,
      orElse: () => null,
    );
    final selectedAnimalName = animal != null
        ? (animal.name.isNotEmpty ? animal.name : animal.type)
        : 'Unknown';
    final selectedAnimalType = animal?.type ?? '';

    final incidentDescription = _descController.text.trim();
    final reportDetails = incidentDescription.isEmpty
        ? 'Incident type: $_incidentType'
        : 'Incident type: $_incidentType. $incidentDescription';

    final healthSuccess = await ref.read(healthProvider.notifier).createHealth({
      'animalId': _selectedAnimalId!,
      'type': 'Other',
      'vaccination': '',
      'status': 'Critical',
      'description': reportDetails,
      'medicine': '',
      'cost': 0,
      'vet': '',
      'date': DateTime.now().toIso8601String(),
      'incidentType': _incidentType,
      'incidentAnimalName': selectedAnimalName,
      'incidentAnimalType': selectedAnimalType,
    });

    if (healthSuccess && _incidentType == 'Deceased') {
      await ref.read(animalProvider.notifier).updateAnimal(
        _selectedAnimalId!,
        {'status': 'deceased'},
      );
      await ref.read(animalProvider.notifier).loadAnimals();
    }

    setState(() => _submitting = false);

    if (!mounted) return;

    if (healthSuccess) {
      Navigator.of(context).pop();
      AppUtils.showSnackBar(
        context,
        'Incident reported for $selectedAnimalName',
      );
    } else {
      AppUtils.showSnackBar(
        context,
        'Failed to report incident',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 22),
          const SizedBox(width: 8),
          const Text('Report Incident'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident type
              const Text('Incident Type',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _incidentType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.warning_outlined),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  'Deceased',
                  'Critical Illness',
                  'Injury',
                  'Missing',
                  'Other',
                ]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _incidentType = v!),
              ),
              const SizedBox(height: 12),

              // Animal selector
              const Text('Select Animal',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _selectedAnimalId,
                hint: const Text('Choose an animal…'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.pets),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: widget.animals
                    .map<DropdownMenuItem<String>>((a) => DropdownMenuItem(
                          value: a.id as String,
                          child: Text(
                            a.name.isNotEmpty
                                ? '${a.name} (${a.type})'
                                : a.type,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAnimalId = v),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select an animal'
                    : null,
              ),
              const SizedBox(height: 12),

              // Description
              const Text('Description',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe the incident…',
                  prefixIcon: Icon(Icons.notes),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          onPressed: _submitting
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _submitIncident();
                  }
                },
          icon: _submitting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.report_outlined, size: 16),
          label: const Text('Submit Report'),
        ),
      ],
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold));
  }
}

// ─── Summary card ──────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─── Monthly chart ─────────────────────────────────────────────────────────
class _MonthlyChart extends StatelessWidget {
  final List monthlyTrend;
  const _MonthlyChart({required this.monthlyTrend});

  @override
  Widget build(BuildContext context) {
    if (monthlyTrend.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
              child: Text('No data yet', style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    final revenues = monthlyTrend
        .map((m) => (m['revenue'] as num?)?.toDouble() ?? 0)
        .toList();
    final expenses = monthlyTrend
        .map((m) => (m['expenses'] as num?)?.toDouble() ?? 0)
        .toList();
    final maxY =
        [...revenues, ...expenses].fold<double>(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend
            const Row(
              children: [
                _LegendDot(AppTheme.primaryGreen, 'Revenue'),
                SizedBox(width: 16),
                _LegendDot(AppTheme.warningOrange, 'Expenses'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx < 0 || idx >= monthlyTrend.length) {
                            return const SizedBox.shrink();
                          }
                          final month = (monthlyTrend[idx]['month'] as String?)
                                  ?.substring(5) ??
                              '';
                          return Text(month,
                              style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                  ),
                  maxY: maxY * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: revenues
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primaryGreen,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: expenses
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.warningOrange,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// ─── Expense breakdown ──────────────────────────────────────────────────────
class _ExpenseBreakdown extends StatelessWidget {
  final Map expenseByType;
  const _ExpenseBreakdown({required this.expenseByType});

  @override
  Widget build(BuildContext context) {
    if (expenseByType.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
              child: Text('No expenses yet',
                  style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    final colors = [
      AppTheme.primaryGreen,
      AppTheme.warningOrange,
      Colors.blue,
      Colors.purple,
      Colors.red,
    ];

    final entries = expenseByType.entries.toList();
    final total =
        entries.fold<double>(0, (s, e) => s + (e.value as num).toDouble());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: entries.asMap().entries.map((entry) {
            final idx = entry.key;
            final type = entry.value.key;
            final amount = (entry.value.value as num).toDouble();
            final pct = total > 0 ? (amount / total * 100) : 0;
            final color = colors[idx % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(type)),
                  Text(AppUtils.formatCurrency(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('${pct.toStringAsFixed(1)}%',
                      style: TextStyle(color: color, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
