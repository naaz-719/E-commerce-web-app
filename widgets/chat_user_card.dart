import 'package:arts/screens/user-panel/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:arts/api/apis.dart';
import 'package:arts/helper/my_date_util.dart';
import 'package:arts/main.dart';
import 'package:arts/models/chat_user.dart';
import 'package:arts/models/message.dart';
import 'package:arts/screens/user-panel/chat_screen.dart';


class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null -> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: mq.width * .04,
        vertical: 4,
      ),
      // elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                //profile picture
                //cliprrect for circle profile
                leading: InkWell(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

                //username
                title: Text(widget.user.name),

                //last message
                subtitle: Text(
                    _message != null ? _message!.msg : widget.user.about,
                    maxLines: 1),

                //last message time
                trailing: _message == null
                    ? null //show nothing when no msg is sent
                    : _message!.read.isEmpty &&
                            _message!.formId != APIs.user.uid
                        ?
                        //show for unread msg
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.lightGreenAccent.shade400,
                                borderRadius: BorderRadius.circular(8)),
                          )
                        :
                        //msg sent time
                        Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
