import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../../core/llm/llm_output_sanitizer.dart';
import '../../shared/widgets/instruction_banner.dart';

class ConversationPage extends StatefulWidget {
  final String npcId;
  const ConversationPage({super.key, required this.npcId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  String? _streamingRawText;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text, {String? suggestedQuestionId}) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _streamingRawText = '';
    });

    final controller = GameProvider.of(context);
    _textController.clear();

    await controller.sendMessage(
      npcId: widget.npcId,
      text: text,
      suggestedQuestionId: suggestedQuestionId,
      onToken: (token) {
        if (mounted) {
          setState(() {
            _streamingRawText = (_streamingRawText ?? '') + token;
          });
          _scrollToBottom();
        }
      }
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _streamingRawText = null;
      });
      _scrollToBottom();
    }
  }

  Future<void> _presentEvidence() async {
    final controller = GameProvider.of(context);
    final state = controller.state!;
    final caseData = controller.caseData;
    final evidenceIds = state.discoveredEvidenceIds.toList();

    if (evidenceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('突きつける証拠を持っていません')),
      );
      return;
    }

    final selectedEvidenceId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('証拠を突きつける'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: evidenceIds.length,
              itemBuilder: (ctx, index) {
                final ev = caseData.evidence
                    .firstWhere((e) => e.id == evidenceIds[index]);
                return ListTile(
                  title: Text(ev.name),
                  onTap: () => Navigator.of(ctx).pop(ev.id),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );

    if (selectedEvidenceId != null && mounted) {
      setState(() {
        _isLoading = true;
        _streamingRawText = '';
      });

      final reaction = await controller.presentEvidence(
        npcId: widget.npcId,
        evidenceId: selectedEvidenceId,
        onToken: (token) {
          if (mounted) {
            setState(() {
              _streamingRawText = (_streamingRawText ?? '') + token;
            });
            _scrollToBottom();
          }
        }
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _streamingRawText = null;
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('反応'),
            content: Text(reaction.text),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'))
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final state = controller.state!;
    final npc = controller.caseData.npcs.firstWhere((n) => n.id == widget.npcId);
    final trust = state.npcTrust[widget.npcId] ?? 0;

    final logs = state.conversationLogs
        .where((log) => log.npcId == widget.npcId)
        .toList();
    final suggestedQuestions = controller.getSuggestedQuestions(widget.npcId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${npc.name} との会話'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _presentEvidence,
            icon: const Icon(Icons.gavel),
            label: const Text('証拠を突きつける'),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const InstructionBanner(
              text: 'おすすめ質問を使うか、自由に質問できます。証拠を見つけたら突きつけて反応を見ましょう。',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text(npc.name[0]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${npc.name} / ${npc.role}', style: Theme.of(context).textTheme.titleMedium),
                        Text(npc.personality, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('信頼度', style: TextStyle(fontSize: 12)),
                      Text('$trust', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: logs.length + (_streamingRawText != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_streamingRawText != null && index == logs.length) {
                    final masked = LlmOutputSanitizer.maskThinkingProcess(_streamingRawText!);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withAlpha(100), width: 1),
                        ),
                        child: Text(
                          masked.isEmpty
                              ? '思考中… (思考内容は伏せ字で表示されます)'
                              : masked,
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final log = logs[index];
                  final isPlayer = log.speaker == 'player';
                  final isSystem = log.speaker == 'system';
                  
                  if (isSystem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          log.text,
                          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  
                  return Align(
                    alignment:
                        isPlayer ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isPlayer
                            ? Colors.blue.withAlpha(51)
                            : Colors.grey.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(log.text),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (suggestedQuestions.isNotEmpty)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: suggestedQuestions.length,
                  itemBuilder: (context, index) {
                    final q = suggestedQuestions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(q.text),
                        onPressed: _isLoading
                            ? null
                            : () => _sendMessage(q.text,
                                suggestedQuestionId: q.id),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: '自由に発言する...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _isLoading ? null : (val) => _sendMessage(val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
