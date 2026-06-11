import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/app_utils.dart';

class ReportState {
  final bool isLoading;
  final Map<String, dynamic> report;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportState({
    this.isLoading = false,
    this.report = const {},
    this.error,
    this.startDate,
    this.endDate,
  });

  ReportState copyWith({
    bool? isLoading,
    Map<String, dynamic>? report,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) =>
      ReportState(
        isLoading: isLoading ?? this.isLoading,
        report: report ?? this.report,
        error: error,
        startDate: clearDates ? null : (startDate ?? this.startDate),
        endDate: clearDates ? null : (endDate ?? this.endDate),
      );
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ApiService _api = ApiService();
  ReportNotifier() : super(const ReportState());

  Future<void> loadReport({DateTime? startDate, DateTime? endDate}) async {
    final from = startDate ?? state.startDate;
    final to = endDate ?? state.endDate;

    state = state.copyWith(
      isLoading: true,
      error: null,
      startDate: from,
      endDate: to,
    );

    try {
      String path = '/reports';
      final params = <String>[];
      if (from != null) {
        params.add('startDate=${from.toIso8601String()}');
      }
      if (to != null) {
        // End date: set to end of that day
        final endOfDay =
            DateTime(to.year, to.month, to.day, 23, 59, 59);
        params.add('endDate=${endOfDay.toIso8601String()}');
      }
      if (params.isNotEmpty) path += '?${params.join('&')}';

      final response = await _api.get(path);
      state = state.copyWith(
        isLoading: false,
        report: Map<String, dynamic>.from(response.data['data'] ?? {}),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load report');
    }
  }

  void clearDateFilter() {
    state = state.copyWith(clearDates: true);
    loadReport();
  }

  /// Generate and share a PDF report for the current data
  Future<void> generatePdf(BuildContext context) async {
    final r = state.report;
    if (r.isEmpty) return;

    final pdf = pw.Document();

    final from = state.startDate;
    final to = state.endDate;
    final dateRangeLabel = (from != null && to != null)
        ? '${AppUtils.formatDate(from.toIso8601String())} – ${AppUtils.formatDate(to.toIso8601String())}'
        : (from != null)
            ? 'From ${AppUtils.formatDate(from.toIso8601String())}'
            : (to != null)
                ? 'Until ${AppUtils.formatDate(to.toIso8601String())}'
                : 'All time';

    final primaryColor = PdfColor.fromHex('#2E7D32');
    final lightGreen = PdfColor.fromHex('#F1F8E9');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) => [
          // ── Header ──────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('GrazeTrack Farm Report',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Period: $dateRangeLabel',
                    style: pw.TextStyle(
                        color: PdfColors.grey300, fontSize: 12)),
                pw.Text(
                    'Generated: ${AppUtils.formatDate(DateTime.now().toIso8601String())}',
                    style: pw.TextStyle(
                        color: PdfColors.grey300, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Summary Cards ────────────────────────────────────
          pw.Text('Farm Summary',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor)),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _pdfStatBox('Total Revenue',
                AppUtils.formatCurrency((r['totalRevenue'] ?? 0).toDouble()),
                primaryColor, lightGreen),
            pw.SizedBox(width: 8),
            _pdfStatBox('Total Costs',
                AppUtils.formatCurrency((r['totalCosts'] ?? 0).toDouble()),
                PdfColor.fromHex('#F57C00'), PdfColor.fromHex('#FFF3E0')),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _pdfStatBox('Net Profit',
                AppUtils.formatCurrency((r['totalProfit'] ?? 0).toDouble()),
                (r['totalProfit'] ?? 0) >= 0
                    ? PdfColor.fromHex('#388E3C')
                    : PdfColor.fromHex('#C62828'),
                lightGreen),
            pw.SizedBox(width: 8),
            _pdfStatBox('Overall ROI', '${r['overallROI'] ?? 0}%',
                primaryColor, lightGreen),
          ]),
          pw.SizedBox(height: 20),

          // ── Sales Summary ────────────────────────────────────
          pw.Text('Sales Summary',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
            children: [
              _pdfTableHeader(['Metric', 'Value'], primaryColor),
              _pdfTableRow(['Total Animals Sold', '${r['animalsSold'] ?? 0}']),
              _pdfTableRow(
                  ['Profitable Sales', '${r['profitableAnimals'] ?? 0}']),
              _pdfTableRow(['Loss Sales', '${r['lossAnimals'] ?? 0}']),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Expense Breakdown ────────────────────────────────
          if ((r['expenseByType'] as Map?)?.isNotEmpty ?? false) ...[
            pw.Text('Expense Breakdown',
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
              children: [
                _pdfTableHeader(['Category', 'Amount'], primaryColor),
                ...(r['expenseByType'] as Map).entries.map((e) =>
                    _pdfTableRow([e.key, AppUtils.formatCurrency(
                        (e.value as num).toDouble())])),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // ── Loss Sales Detail ────────────────────────────────
          if ((r['lossSalesDetails'] as List?)?.isNotEmpty ?? false) ...[
            pw.Text('Loss Sales Detail',
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#C62828'))),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
              children: [
                _pdfTableHeader(
                    ['Animal', 'Sold For', 'Total Cost', 'Loss'], primaryColor),
                ...(r['lossSalesDetails'] as List).map((s) => _pdfTableRow([
                      '${s['animalType']} ${s['animalBreed']}',
                      AppUtils.formatCurrency((s['sellingPrice'] as num).toDouble()),
                      AppUtils.formatCurrency((s['totalCost'] as num).toDouble()),
                      AppUtils.formatCurrency((s['profit'] as num).toDouble().abs()),
                    ])),
              ],
            ),
          ],
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'grazetrack-report-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  pw.Widget _pdfStatBox(
      String label, String value, PdfColor color, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: color, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
      ),
    );
  }

  pw.TableRow _pdfTableHeader(List<String> cells, PdfColor bg) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ))
          .toList(),
    );
  }

  pw.TableRow _pdfTableRow(List<String> cells) {
    return pw.TableRow(
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c,
                    style: const pw.TextStyle(fontSize: 10)),
              ))
          .toList(),
    );
  }

  /// Generate and share a PDF critical incident report
  Future<void> generateIncidentPdf({
    required BuildContext context,
    required String animalName,
    required String animalType,
    required String incidentType,
    required String description,
    required DateTime date,
  }) async {
    final pdf = pw.Document();
    final redColor = PdfColor.fromHex('#C62828');
    final lightRed = PdfColor.fromHex('#FFEBEE');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: redColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('GrazeTrack — Critical Incident Report',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      'Generated: ${AppUtils.formatDate(date.toIso8601String())}',
                      style: const pw.TextStyle(
                          color: PdfColors.grey300, fontSize: 11)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Incident details box
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightRed,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: redColor, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Incident Details',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: redColor)),
                  pw.SizedBox(height: 10),
                  _pdfDetailRow('Incident Type', incidentType),
                  _pdfDetailRow('Animal', animalName),
                  _pdfDetailRow('Animal Category', animalType),
                  _pdfDetailRow(
                      'Date', AppUtils.formatDate(date.toIso8601String())),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Description
            pw.Text('Description',
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: redColor)),
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                description.isEmpty ? 'No description provided.' : description,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
            pw.SizedBox(height: 32),

            // Footer
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('This report was generated by GrazeTrack.',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'grazetrack-incident-${date.millisecondsSinceEpoch}.pdf',
    );
  }

  pw.Widget _pdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>(
  (ref) => ReportNotifier(),
);
