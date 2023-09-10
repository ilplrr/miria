import 'package:flutter/material.dart';
import 'package:miria/model/input_completion_type.dart';

extension TextEditingControllerExtension on TextEditingController {
  String? get textBeforeSelection {
    final baseOffset = selection.baseOffset;
    if (baseOffset < 0) {
      return null;
    }
    return text.substring(0, baseOffset);
  }

  String? get emojiQuery {
    final textBeforeSelection = this.textBeforeSelection;
    if (textBeforeSelection == null) {
      return null;
    }
    final lastColonIndex = textBeforeSelection.lastIndexOf(":");
    if (lastColonIndex < 0) {
      return null;
    }
    if (RegExp(r':[a-zA-z_0-9]+?:$')
        .hasMatch(text.substring(0, lastColonIndex + 1))) {
      return null;
    } else {
      return textBeforeSelection.substring(lastColonIndex + 1);
    }
  }

  InputCompletionType get inputCompletionType {
    final emojiQuery = this.emojiQuery;
    if (emojiQuery != null) {
      return Emoji(emojiQuery);
    }
    return Basic();
  }

  void insert(String insertText, {String? afterText}) {
    final currentPosition = selection.base.offset;
    final before = text.isEmpty ? "" : text.substring(0, currentPosition);
    final after = (currentPosition == text.length || currentPosition == -1)
        ? ""
        : text.substring(currentPosition, text.length);

    value = TextEditingValue(
        text: "$before$insertText${afterText ?? ""}$after",
        selection: TextSelection.collapsed(
            offset: (currentPosition == -1 ? 0 : currentPosition) +
                insertText.length));
  }
}
