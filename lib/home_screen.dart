import 'package:chat_app/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottom_chat_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user!.displayName!,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'SignOut',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              AuthProvider().signOut();
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Chats(),
            const BottomChatBar(),
          ],
        ),
      ),
    );
  }
}

class Chats extends StatelessWidget {
  Chats({Key? key}) : super(key: key);
  final user = FirebaseAuth.instance.currentUser;
  final Stream<QuerySnapshot> _chatsStream = FirebaseFirestore.instance
      .collection('chats')
      .orderBy('createdAt', descending: false)
      .limit(15)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('$snapshot.error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Flexible(
          child: GestureDetector(
            onTap: () {},
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

                if (user?.uid == data['owner']) {
                  return SentMesaage(data: data);
                } else {
                  return RecievedMesaage(data: data);
                }
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class SentMesaage extends StatelessWidget {
  const SentMesaage({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(),
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
            decoration: const BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    data['text'],
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10.0),
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(
                    data['imageUrl'],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RecievedMesaage extends StatelessWidget {
  const RecievedMesaage({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(),
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    data['text'],
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10.0),
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(
                    data['imageUrl'],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
