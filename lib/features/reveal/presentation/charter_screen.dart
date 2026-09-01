// lib/features/reveal/presentation/charter_screen.dart
//
// Editable Charter — house name, motto, spine grid (read-only), and PDF export.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:printing/printing.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/theme_preference.dart';
import '../../../widgets/image_placeholder_tile.dart';
import '../../content/domain/deck_image.dart';
// Deferred: the PDF layout and its embedded-font support are only needed
// when someone taps Print, so on web they load then instead of with the app.
import 'charter_pdf.dart' deferred as charter_pdf;

// ── Screen ────────────────────────────────────────────────────────────────────

class CharterScreen extends ConsumerStatefulWidget {
  const CharterScreen({super.key, required this.charter});

  final Charter charter;

  @override
  ConsumerState<CharterScreen> createState() => _CharterScreenState();
}

class _CharterScreenState extends ConsumerState<CharterScreen> {
  late final TextEditingController _houseNameCtrl;
  late final TextEditingController _mottoCtrl;

  // Deck lookup — loaded once in initState.
  Map<String, DeckImage> _deckById = {};
  bool _deckLoaded = false;

  // Through-line key → human label, loaded in initState. The charter stores raw
  // keys (slugs); the screen and PDF must show the labels.
  Map<String, String> _labels = {};

  // Export guard — prevents double-fire from rapid taps.
  bool _exporting = false;

  // Parsed JSON fields from the charter.
  late final List<String> _spineIds;
  late final List<String> _throughlineKeys;

  @override
  void initState() {
    super.initState();
    _houseNameCtrl =
        TextEditingController(text: widget.charter.houseName);
    _mottoCtrl = TextEditingController(text: widget.charter.motto);

    _spineIds = List<String>.from(
        jsonDecode(widget.charter.spineItemIds) as List);
    _throughlineKeys = List<String>.from(
        jsonDecode(widget.charter.throughlines) as List);

    _loadDeck();
  }

  Future<void> _loadDeck() async {
    final repo = ref.read(contentRepositoryProvider);
    final deck = await repo.deck();
    final throughlines = await repo.throughlines();
    if (mounted) {
      setState(() {
        _deckById = {for (final d in deck) d.id: d};
        _labels = {for (final t in throughlines) t.key: t.label};
        _deckLoaded = true;
      });
    }
  }

  /// The human label for a through-line key, falling back to the key itself
  /// while labels load or if the key is unknown.
  String _label(String key) => _labels[key] ?? key;

  @override
  void dispose() {
    _houseNameCtrl.dispose();
    _mottoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dao = ref.read(chartersDaoProvider);
    await dao.updateCharter(
      id: widget.charter.id,
      houseName: _houseNameCtrl.text,
      motto: _mottoCtrl.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Charter saved.')),
      );
    }
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      // Re-fetch latest charter to get any saved edits included in PDF.
      final dao = ref.read(chartersDaoProvider);
      await dao.updateCharter(
        id: widget.charter.id,
        houseName: _houseNameCtrl.text,
        motto: _mottoCtrl.text,
      );
      final updated = await dao.byId(widget.charter.id);
      if (updated == null) return;
      final ids = [
        ...List<String>.from(jsonDecode(updated.spineItemIds) as List),
        ...List<String>.from(jsonDecode(updated.contestedItemIds) as List),
      ];
      if (!_deckLoaded) await _loadDeck();
      await charter_pdf.loadLibrary();
      final plates = await charter_pdf.loadCharterPlates(_deckById, ids);
      final pdfTheme = await charter_pdf.loadCharterPdfTheme();
      final doc = charter_pdf.buildCharterPdf(
        updated,
        labels: _labels,
        plates: plates,
        theme: pdfTheme,
      );
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'House Charter',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Charter'),
        actions: [
          const MantleThemeToggle(),
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Print'),
            onPressed: _exporting ? null : _export,
          ),
        ],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Padding(
            padding: OhSpacing.insetPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── House name ─────────────────────────────────────────────────
                TextField(
                  controller: _houseNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name your House',
                    hintText: 'e.g. Thornwood',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: OhSpacing.md),

                // ── Motto ──────────────────────────────────────────────────────
                TextField(
                  controller: _mottoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your motto',
                    hintText: 'e.g. Built to last.',
                  ),
                ),
                const SizedBox(height: OhSpacing.lg),

                // ── Spine section ──────────────────────────────────────────────
                Text('Your House Spine', style: theme.textTheme.headlineSmall),
                const SizedBox(height: OhSpacing.sm),
                _buildSpineGrid(),
                const SizedBox(height: OhSpacing.lg),

                // ── Through-lines ──────────────────────────────────────────────
                if (_throughlineKeys.isNotEmpty) ...[
                  Text('Named Through-Lines',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: OhSpacing.sm),
                  Text(
                    _throughlineKeys.map(_label).join(' · '),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: OhSpacing.lg),
                ],

                // ── Save button ────────────────────────────────────────────────
                ElevatedButton(
                  key: const Key('charter-save-button'),
                  onPressed: _save,
                  child: const Text('Save Charter'),
                ),
                const SizedBox(height: OhSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpineGrid() {
    if (!_deckLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      key: const Key('charter-spine'),
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: OhSpacing.xs,
      crossAxisSpacing: OhSpacing.xs,
      children: [
        for (final id in _spineIds) _buildSpineTile(id),
      ],
    );
  }

  Widget _buildSpineTile(String id) {
    final deck = _deckById[id];
    if (deck == null) {
      return ImagePlaceholderTile(imageId: id);
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Image.asset(
        deck.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ImagePlaceholderTile(imageId: id),
      ),
    );
  }
}
