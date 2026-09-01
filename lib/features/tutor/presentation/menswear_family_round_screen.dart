import 'package:flutter/material.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/db/database.dart';
import 'lean_round_screen.dart';
import 'menswear_charter_screen.dart';

/// Runs ≥2 household members through one menswear lean round apiece, all
/// under the same shared [roundId], with a "pass the phone" handoff
/// interstitial between members. Lands on the shared [MenswearCharterScreen]
/// once the last member finishes.
///
/// Additive to the legacy multi-member flow (`MembersScreen` →
/// `RoundController` → `RoundScreen` → `CharterScreen`) — mirrors its shape
/// but never touches it.
class MenswearFamilyRoundScreen extends StatefulWidget {
  const MenswearFamilyRoundScreen(
      {super.key, required this.members, required this.roundId});

  /// The members taking part, in the order they'll be run. Must have at
  /// least 2 entries.
  final List<MemberRow> members;
  final String roundId;

  @override
  State<MenswearFamilyRoundScreen> createState() =>
      _MenswearFamilyRoundScreenState();
}

class _MenswearFamilyRoundScreenState
    extends State<MenswearFamilyRoundScreen> {
  int _index = 0;
  bool _handoff = false;

  /// Fired when the member at [_index] finishes their lean round. Advances
  /// to the next member behind a handoff interstitial, or — on the last
  /// member — replaces this screen with the shared House Charter.
  void _advance() {
    if (_index < widget.members.length - 1) {
      setState(() {
        _index++;
        _handoff = true;
      });
    } else {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MenswearCharterScreen(roundId: widget.roundId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.members[_index];

    if (_handoff) {
      final theme = Theme.of(context);
      return Scaffold(
        body: OhPage(
          padding: EdgeInsets.zero,
          child: Center(
            child: Padding(
              padding: OhSpacing.insetLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.titleLarge,
                      children: [
                        const TextSpan(text: 'Pass the phone to '),
                        TextSpan(
                          text: member.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OhSpacing.lg),
                  FilledButton(
                    key: const Key('family-handoff-continue'),
                    onPressed: () => setState(() => _handoff = false),
                    child: const Text('I’m ready'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // The ValueKey forces a fresh LeanRoundScreen subtree per member, so
    // each member gets its own controller/session rather than reusing the
    // previous member's disposed state.
    return LeanRoundScreen(
      key: ValueKey(member.id),
      memberId: member.id,
      roundId: widget.roundId,
      onComplete: _advance,
    );
  }
}
