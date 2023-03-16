import 'package:discoveruzb/view_models/comment_vm.dart';
import 'package:discoveruzb/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/places_model.dart';
import '../service/api_response.dart';
import 'components/home_header.dart';

class CommentPage extends StatefulWidget {
  final Place place;
  const CommentPage({Key? key, required this.place}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  @override
  void initState() {
    final provider = Provider.of<CommentVM>(context, listen: false);
    super.initState();
    Future.delayed(Duration.zero).then((value) => {
          provider.getComments(widget.place.id.toString()),
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommentVM>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fikrlar",
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Consumer<CommentVM>(builder: (context, data, child) {
                if (data.response.status == Status.HAVESHOPS) {
                  print("have");
                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    itemCount: data.response.data.length,
                    itemBuilder: (ctx, index) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircularProfileImg(width: 55, height: 55),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                maxLines: 10,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            "${data.response.data[index].users['fullname']} ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            ?.copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: data.response.data[index].comment,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            ?.copyWith(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ),
                              Text(
                                "12.12.2021",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    separatorBuilder: (ctx, index) => const Divider(
                      color: Colors.transparent,
                    ),
                  );
                } else if (data.response.status == Status.ERROR) {
                  print("error");
                  return Center(
                    child: Text(
                      data.response.message!,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  );
                } else if (data.response.status == Status.HAVENOTSHOPS) {
                  print("yoq");
                  return Center(
                    child: Text(
                      data.response.message!,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  );
                } else {
                  print("loading");
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            ),
          ),
          CustomTextField(
            hintText: "Fikr qoldiring",
            controller: provider.commentTextController,
            onPressed: () async {
              if (provider.comment.isNotEmpty) {
                await provider.sendComment(widget.place, context);
              } else {
                print("boshhhhshshs");
              }
            },
          )
        ],
      ),
    );
  }

  // @override
  // void deactivate() {
  //   final provider = Provider.of<CommentVM>(context, listen: false);
  //   super.deactivate();
  // }
}
