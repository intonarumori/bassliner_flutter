import 'package:flutter/cupertino.dart';

class TextFieldPopup extends StatefulWidget {
  final String title;
  final String initialText;
  final String cancelTitle;
  final String confirmTitle;
  final Function(String text) onConfirmed;
  final Function() onCancel;
  const TextFieldPopup({
    super.key,
    required this.title,
    required this.initialText,
    required this.confirmTitle,
    required this.cancelTitle,
    required this.onConfirmed,
    required this.onCancel,
  });

  @override
  State<TextFieldPopup> createState() => _TextFieldPopupState();
}

class _TextFieldPopupState extends State<TextFieldPopup> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final text = widget.initialText;
    _controller.text = text;
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }

  void _save() {
    final text = _controller.text;
    Navigator.of(context).pop();
    widget.onConfirmed(text);
  }

  void _cancel() {
    Navigator.of(context).pop();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(widget.title),
      ),
      content: Column(
        children: [
          CupertinoTextField(
            controller: _controller,
            autofocus: true,
          ),
        ],
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: _cancel,
          child: Text(widget.cancelTitle),
        ),
        CupertinoDialogAction(
          onPressed: _save,
          isDefaultAction: true,
          child: Text(widget.confirmTitle),
        ),
      ],
    );
  }
}
