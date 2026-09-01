// lib/features/reveal/presentation/charter_pdf.dart
//
// Builds a printable PDF document from a saved Charter row.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/db/database.dart';
import '../../content/domain/deck_image.dart';

/// One plate as the printed Charter shows it: the deck title as caption and
/// the image bytes (null when the image could not be loaded; the caption
/// still prints).
class CharterPlate {
  const CharterPlate({required this.title, this.bytes});
  final String title;
  final Uint8List? bytes;
}

/// Loads the deck image and title for each of [ids], for [buildCharterPdf].
Future<Map<String, CharterPlate>> loadCharterPlates(
  Map<String, DeckImage> deckById,
  Iterable<String> ids,
) async {
  final plates = <String, CharterPlate>{};
  for (final id in ids) {
    final deck = deckById[id];
    Uint8List? bytes;
    if (deck != null) {
      try {
        bytes = (await rootBundle.load(deck.assetPath)).buffer.asUint8List();
      } on Object {
        bytes = null;
      }
    }
    plates[id] = CharterPlate(title: deck?.title ?? id, bytes: bytes);
  }
  return plates;
}

/// The Charter prints in Lora, the app's own serif, rather than the PDF
/// default Helvetica.
Future<pw.ThemeData> loadCharterPdfTheme() async {
  Future<pw.Font> font(String file) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));
  return pw.ThemeData.withFont(
    base: await font('Lora-Regular.ttf'),
    bold: await font('Lora-Bold.ttf'),
    italic: await font('Lora-Italic.ttf'),
  );
}

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', //
  'August', 'September', 'October', 'November', 'December',
];

/// "Made on 26 September 2026": the Charter is an heirloom, so it says when.
String charterDateLine(DateTime d) =>
    'Made on ${d.day} ${_months[d.month - 1]} ${d.year}';

pw.Document buildCharterPdf(
  Charter charter, {
  Map<String, String> labels = const {},
  Map<String, CharterPlate> plates = const {},
  pw.ThemeData? theme,
  bool compress = true,
}) {
  final doc = pw.Document(theme: theme, compress: compress);

  final spineIds = List<String>.from(jsonDecode(charter.spineItemIds) as List);
  final throughlines =
      List<String>.from(jsonDecode(charter.throughlines) as List)
          .map((k) => labels[k] ?? k)
          .toList();
  final contestedIds =
      List<String>.from(jsonDecode(charter.contestedItemIds) as List);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => [
        if (charter.houseName.isNotEmpty)
          pw.Text(
            'House ${charter.houseName}',
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
          ),
        if (charter.motto.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            '“${charter.motto}”',
            style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic),
          ),
        ],
        pw.SizedBox(height: 4),
        pw.Text(
          charterDateLine(charter.createdAt),
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Our Spine',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text('The images we agree on.'),
        pw.SizedBox(height: 8),
        _plateGrid(spineIds, plates, width: 120),
        if (throughlines.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          pw.Text(
            'Named Through-Lines',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(throughlines.join(' · ')),
        ],
        if (contestedIds.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          // One block, so the heading moves to the next page with its plates
          // rather than being left alone at the foot of a page.
          pw.Inseparable(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Where the House Argues',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Images we see differently.'),
                pw.SizedBox(height: 8),
                _plateGrid(contestedIds, plates, width: 90),
              ],
            ),
          ),
        ],
        pw.SizedBox(height: 24),
        pw.Text(
          'Created with Mantle · OpenHearth',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  return doc;
}

/// The plates in reading order, each captioned with its deck title. A plate
/// whose image is missing still prints its caption in an outlined box.
pw.Widget _plateGrid(
  List<String> ids,
  Map<String, CharterPlate> plates, {
  required double width,
}) {
  return pw.Wrap(
    spacing: 8,
    runSpacing: 10,
    children: [
      for (final id in ids)
        pw.SizedBox(
          width: width,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: width,
                height: width,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                ),
                child: plates[id]?.bytes != null
                    ? pw.Image(pw.MemoryImage(plates[id]!.bytes!),
                        fit: pw.BoxFit.cover)
                    : null,
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                plates[id]?.title ?? id,
                style: const pw.TextStyle(fontSize: 8),
                maxLines: 2,
              ),
            ],
          ),
        ),
    ],
  );
}
