import 'package:discoveruzb/view_models/comment_vm.dart';
import 'package:discoveruzb/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/comments.dart';
import '../models/places_model.dart';
import '../service/api_response.dart';
import '../view_models/home_vm.dart'; // Import HomeViewModel
import 'components/home_header.dart'; // Import CircularProfileImg

class CommentPage extends StatelessWidget {
  final Place place;
  const CommentPage({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch comments when the page is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentVM>(context, listen: false).fetchComments(place.id.toString());
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fikrlar",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Consumer<CommentVM>(builder: (context, commentVM, child) {
                if (commentVM.response.status == Status.LOADING) {
                  return const Center(child: CircularProgressIndicator());
                } else if (commentVM.response.status == Status.ERROR) {
                  return Center(
                    child: Text(
                      commentVM.response.message!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                } else if (commentVM.response.status == Status.EMPTY) {
                  return Center(
                    child: Text(
                      commentVM.response.message!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                } else if (commentVM.response.status == Status.COMPLETED) {
                  List<Comments> comments = commentVM.response.data as List<Comments>;
                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    itemCount: comments.length,
                    itemBuilder: (ctx, index) {
                      Comments comment = comments[index];
                      // Format date from timestamp
                      String formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.fromMillisecondsSinceEpoch(comment.dateTime));
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Using CircularProfileImg which is defined in home_header.dart
                          CircularProfileImg(width: 55, height: 55, imageUrl: comment.users['imgUrl'] ?? ''),
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
                                              "${comment.users['fullname']} ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: comment.comment,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall // Changed to bodySmall
                                      ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                    separatorBuilder: (ctx, index) => const Divider(
                      color: Colors.transparent,
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // Default case for initial or other states
                }
              }),
            ),
          ),
          // Comment input field
          Consumer<HomeViewModel>( // To get user data for adding comment
            builder: (context, homeVM, child) {
              return CustomTextField(
                hintText: "Fikr qoldiring",
                controller: Provider.of<CommentVM>(context, listen: false).commentTextController,
                onChanged: (text) {
                  Provider.of<CommentVM>(context, listen: false).updateCommentText(text);
                },
                onPressed: () async {
                  final commentVM = Provider.of<CommentVM>(context, listen: false);
                  if (commentVM.comment.isNotEmpty) {
                    await commentVM.addCommentToPlace(
                      place,
                      homeVM.fullName,
                      homeVM.phone,
                      homeVM.imgUrl,
                    );
                  } else {
                    // Optionally show a message to the user that comment cannot be empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharh bo\'sh bo\'lishi mumkin emas!')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
