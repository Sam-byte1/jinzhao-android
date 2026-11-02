import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/poem.dart';
import '../theme/app_colors.dart';

Future<void> showFeelSheet(BuildContext context, AppState state, Poem poem) {
  final controller = TextEditingController();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      return AnimatedBuilder(
        animation: state,
        builder: (ctx, _) {
          final notes = state.progressFor(poem.id).notes.reversed.toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 36, height: 4, decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 10),
                  Text('写感受 · ${poem.title}',
                      style: TextStyle(fontFamily: 'serif', fontSize: 16, color: c.ink)),
                  const SizedBox(height: 2),
                  Text('读完之后，留下此刻的想法', style: TextStyle(fontSize: 11.5, color: c.inkSoft)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    style: TextStyle(color: c.ink, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '写下你的感受……',
                      hintStyle: TextStyle(color: c.inkFaint),
                      filled: true,
                      fillColor: c.bgCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: c.seal),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        state.addNote(poem.id, text);
                        controller.clear();
                      },
                      child: const Text('保存'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: notes.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text('还没有感受记录', style: TextStyle(color: c.inkFaint, fontSize: 12)),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: notes.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final n = notes[i];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                                decoration: BoxDecoration(
                                  color: c.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: c.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(n.date, style: TextStyle(fontSize: 10.5, color: c.gold)),
                                        GestureDetector(
                                          onTap: () => state.deleteNote(poem.id, n.id),
                                          child: Text('删除', style: TextStyle(fontSize: 11, color: c.inkFaint)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(n.text, style: TextStyle(fontSize: 12.5, color: c.inkSoft, height: 1.5)),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
