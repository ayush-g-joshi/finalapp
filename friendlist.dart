import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatRoom.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key? key}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              "email",
              isNotEqualTo: _auth.currentUser?.email,
            )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Container(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Row(
                          children: [
                            const SizedBox(
                              width: 15,
                              height: 20,
                            ),
                            document['image'] == null ||
                                    document['image'].isEmpty
                                ? Center(
                                    child: ClipOval(
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        child: const FittedBox(
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: ClipOval(
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        child: FittedBox(
                                          child: Image.network(
                                              '${document['image']}'),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                    child: Text(document['name'].toString())),
                                Center(
                                    child: Text(
                                  document['email'].toString(),
                                )),
                              ],
                            )
                          ],
                        ),
                        onTap: () {
                          userMap = {
                            "image": document["image"],
                            "uid": document["uid"],
                            "name": document["name"],
                            "email": document["email"],
                            "status": document["status"],
                          };

                          String roomId = chatRoomId(
                              _auth.currentUser!.displayName!,
                              userMap!['name']);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: roomId,
                                userMap: userMap!,
                              ),
                            ),
                          );
                        },
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.black38,
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
