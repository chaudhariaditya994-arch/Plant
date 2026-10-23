import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AiInput extends StatelessWidget {
  final String message;
  final bool isLoading;

  const AiInput({super.key, required this.message, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, right: 36.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5F0),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: const Color(0xFF3F6F4C),
                    size: 26,
                  ),
                )
              else ...[
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1E2822),
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Copied to clipboard"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
