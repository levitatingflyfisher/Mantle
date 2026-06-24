// lib/features/reveal/presentation/charter_pdf.dart
//
// Builds a printable PDF document from a saved Charter row.

import 'dart:convert';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/db/database.dart';

pw.Document buildCharterPdf(Charter charter) {
  final doc = pw.Document();

  final spineIds =
      List<String>.from(jsonDecode(charter.spineItemIds) as List);
  final throughlines =
      List<String>.from(jsonDecode(charter.throughlines) as List);
  final contestedIds =
      List<String>.from(jsonDecode(charter.contestedItemIds) as List);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (charter.houseName.isNotEmpty)
            pw.Text(
              'House ${charter.houseName}',
              style: pw.TextStyle(
                  fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
          if (charter.motto.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              '"${charter.motto}"',
              style: pw.TextStyle(
                  fontSize: 16, fontStyle: pw.FontStyle.italic),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            'Our Spine',
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${spineIds.length} shared images form the thread of this house.',
          ),
          if (throughlines.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Named Through-Lines',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(throughlines.join(' · ')),
          ],
          if (contestedIds.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Where the House Argues',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('${contestedIds.length} images we see differently.'),
          ],
          pw.Spacer(),
          pw.Text(
            'Created with Mantle · OpenHearth',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    ),
  );

  return doc;
}
