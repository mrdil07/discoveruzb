import 'package:discoveruzb/view_models/comment_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTextField extends StatefulWidget {
  final VoidCallback? onPressed;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final FormFieldValidator? validator;
  const CustomTextField(
      {Key? key,
      required this.hintText,
      this.keyboardType,
      required this.controller,
      this.validator,
      this.onPressed,
      this.maxLines = 1})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommentVM>(context, listen: true);
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
      child: TextFormField(
        controller: widget.controller,
        style: const TextStyle(color: Colors.black),
        keyboardType: widget.keyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        minLines: 1,
        maxLines: widget.maxLines,
        onChanged: (input) {
          setState(() {
            provider.comment = input;
          });
        },
        decoration: InputDecoration(
            labelText: widget.hintText,
            suffixIcon: IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                Icons.send,
                color: provider.comment.isNotEmpty ? Colors.blue : Colors.grey,
              ),
            )),
        validator: widget.validator,
      ),
    );
  }
}
