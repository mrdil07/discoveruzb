import 'package:flutter/material.dart';

class ListTile1 extends StatelessWidget {
  String? title;
  IconData? titleIcon;
  String? suffixText;
  IconData? icon;
  ListTile1({Key? key, this.title, this.icon, this.suffixText, this.titleIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(titleIcon, color: Theme.of(context).iconTheme.color),
      minLeadingWidth: 5,
      title: Text(
        title ?? '...',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(suffixText ?? '...',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(width: 10),
            icon != null
                ? Icon(
                    icon,
                    size: 17,
                    color: Theme.of(context).iconTheme.color,
                  )
                : Switch(value: true, onChanged: (input) {}),
          ],
        ),
      ),
    );
  }
}
