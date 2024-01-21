import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:gpt_chat/apis/api.dart';
import 'package:gpt_chat/apis/http_setup.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //instanse for open ai key
  final openAi = OpenAI.instance.build(
    token: Api_key,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 5),
    ),
    enableLog: true,
  );

  List<ChatMessage> messages = <ChatMessage>[];
  final ChatUser currentuser =
      ChatUser(id: '1', firstName: 'Saurab', lastName: 'gautam');
  final ChatUser gptuser =
      ChatUser(id: '2', firstName: 'gpt', lastName: 'chat');

  // ignore: non_constant_identifier_names
  Future<void> Chatresponse(ChatMessage m) async {
    setState(() {
      messages.insert(0, m);
    });

    List<Messages> messageHistory = messages.reversed.map((m) {
      if (m.user == currentuser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: messageHistory,
      maxToken: 200,
    );

    final response = await openAi.onChatCompletion(request: request);
   

    for (var element in response!.choices) {
      if (element.message != null) {
        messages.insert(
          0,
          ChatMessage(
              user: gptuser,
              createdAt: DateTime.now(),
              text: element.message!.content),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Chat'),
          centerTitle: true,
          elevation: 8.0,
        ),
        body: DashChat(
            messageOptions: const MessageOptions(
              currentUserContainerColor: Colors.blueAccent,
              showCurrentUserAvatar: true,
            ),
            currentUser: currentuser,
            onSend: (ChatMessage m) {
              Chatresponse(m);
            },
            messages: messages),
      ),
    );
  }
}
