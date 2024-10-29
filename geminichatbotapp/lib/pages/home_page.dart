import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geminichatbotapp/controller/chat_provider.dart';
import 'package:geminichatbotapp/controller/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HelperAI',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icon(Icons.wb_sunny, key: ValueKey('light'))
                  : Icon(Icons.nightlight_round, key: ValueKey('dark')),
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: DashChat(
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.black54
                : Colors.white,
            hintText: "Enter your prompt here...",
            hintStyle: TextStyle(
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white54
                  : Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ),
          trailing: [
            IconButton(
              onPressed: () async {
                chatProvider.sendMediaMessage(context);
              },
              icon: Icon(
                Icons.image,
                color: Provider.of<ThemeProvider>(context).buttonColor,
              ),
            ),
          ],
        ),
        currentUser: chatProvider.currentUser,
        onSend: chatProvider.sendMessage,
        messages: chatProvider.messages,
        messageOptions: MessageOptions(
          currentUserContainerColor:
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.blue
                  : Colors.grey,
          currentUserTextColor: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white
              : Colors.black,
          containerColor: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.blue
              : Colors.grey,
          textColor: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white
              : Colors.black,
          messageTextBuilder: (ChatMessage message,
              ChatMessage? previousMessage, ChatMessage? nextMessage) {
            String modifiedText = message.text;
            RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
            RegExp codeRegex = RegExp(r'`([^`]+)`');
            List<TextSpan> spans = [];
            int lastMatchEnd = 0;
            for (var match in boldRegex.allMatches(modifiedText)) {
              if (match.start > lastMatchEnd) {
                spans.add(TextSpan(
                  text: modifiedText.substring(lastMatchEnd, match.start),
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
            for (var match in codeRegex.allMatches(modifiedText)) {
              if (match.start > lastMatchEnd) {
                spans.add(TextSpan(
                  text: modifiedText.substring(lastMatchEnd, match.start),
                  style: const TextStyle(color: Colors.white),
                ));
              }
              spans.add(TextSpan(
                text: match.group(1),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                ),
              ));
              lastMatchEnd = match.end;
            }
            if (lastMatchEnd < modifiedText.length) {
              spans.add(TextSpan(
                text: modifiedText.substring(lastMatchEnd),
                style: const TextStyle(color: Colors.white),
              ));
            }
            return GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: modifiedText));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Text copied to clipboard!")));
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    children: spans,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
