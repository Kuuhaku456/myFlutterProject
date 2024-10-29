import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class ChatProvider with ChangeNotifier {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Custom-Gemini");
  void sendMessage(ChatMessage chatMessage) {
    messages = [chatMessage, ...messages];
    notifyListeners();
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ?? "";
          lastMessage.text += response;
          messages = [lastMessage!, ...messages];
        } else {
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ?? "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: response);
          messages = [message, ...messages];
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMediaMessage(BuildContext context) async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      String? userPrompt = await _getUserInput(context);
      if (userPrompt == null || userPrompt.isEmpty) {
        userPrompt = "Describe this picture?";
      }
      ChatMessage chatMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: userPrompt,
          medias: [
            ChatMedia(url: file.path, fileName: "", type: MediaType.image)
          ]);
      sendMessage(chatMessage);
    }
  }

  Future<String?> _getUserInput(BuildContext context) async {
    TextEditingController textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter a prompt for the image'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your prompt'
            ),
            style: TextStyle(color: Colors.black)
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () {
                Navigator.of(context).pop(textController.text);
              },
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> formatMessage(String message) {
    RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    for (var match in boldRegex.allMatches(message)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: message.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }      
      spans.add(TextSpan(
        text: match.group(1), 
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));

      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.white),
      ));
    }

    return spans;
  }
}
