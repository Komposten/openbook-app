import 'package:flutter/cupertino.dart';

class TextAutocompletionService {
  TextAutocompletionResult checkTextForAutocompletion(
      TextEditingController textController) {
    int cursorPosition = textController.selection.baseOffset;

    if (cursorPosition >= 1) {
      String lastWord =
          _getWordBeforeCursor(textController.text, cursorPosition);

      if (lastWord.startsWith('@')) {
        String searchQuery = lastWord.substring(1);
        return TextAutocompletionResult(
            isAutocompleting: true,
            autocompleteQuery: searchQuery,
            type: TextAutocompletionType.account);
      } else if (lastWord.startsWith('/c/')) {
        String searchQuery = lastWord.substring(3);
        return TextAutocompletionResult(
            isAutocompleting: true,
            autocompleteQuery: searchQuery,
            type: TextAutocompletionType.community);
      }
    }

    return TextAutocompletionResult(isAutocompleting: false);
  }

  void autocompleteTextWithUsername(
      TextEditingController textController, String username) {
    String text = textController.text;
    int cursorPosition = textController.selection.baseOffset;
    String lastWord = _getWordBeforeCursor(text, cursorPosition);

    if (!lastWord.startsWith('@')) {
      throw 'Tried to autocomplete text with username without @';
    }

    var newText = text.substring(0, cursorPosition - lastWord.length) +
        '@$username ' +
        text.substring(cursorPosition);
    var newSelection = TextSelection.collapsed(
        offset: cursorPosition - lastWord.length + username.length + 2);

    textController.value =
        TextEditingValue(text: newText, selection: newSelection);
  }

  void autocompleteTextWithCommunityName(
      TextEditingController textController, String communityName) {
    String text = textController.text;
    int cursorPosition = textController.selection.baseOffset;
    String lastWord = _getWordBeforeCursor(text, cursorPosition);

    if (!lastWord.startsWith('/c/')) {
      throw 'Tried to autocomplete text with community name without /c/';
    }

    var newText = text.substring(0, cursorPosition - lastWord.length) +
        '/c/$communityName ' +
        text.substring(cursorPosition);
    var newSelection = TextSelection.collapsed(
        offset: cursorPosition - lastWord.length + communityName.length + 4);

    textController.value =
        TextEditingValue(text: newText, selection: newSelection);
  }

  String _getWordBeforeCursor(String text, int cursorPosition) {
    if (text.isNotEmpty) {
      var start = text.lastIndexOf(RegExp(r'\s'), cursorPosition - 1);
      return text.substring(start + 1, cursorPosition);
    } else {
      return text;
    }
  }
}

class TextAutocompletionResult {
  final bool isAutocompleting;
  final String autocompleteQuery;
  final TextAutocompletionType type;

  TextAutocompletionResult(
      {@required this.isAutocompleting, this.type, this.autocompleteQuery});
}

enum TextAutocompletionType { account, community }
