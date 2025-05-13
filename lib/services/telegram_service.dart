import 'package:http/http.dart' as http;
import 'dart:convert';

class TelegramService {
  static const String _botToken = '7973006298:AAEN-14X4OQy4sqEqwBO_l4xHL7xa6RDp0k';
  static const String _chatId = '5550766633';

  static Future<void> sendMessage(String message) async {
    try {
      print('=== Telegram Message Sending ===');
      print('Message content: $message');
      
      final uri = Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage');
      print('Request URL: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'HTML',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['ok'] == true) {
          print('✅ Message sent successfully!');
          print('Message ID: ${responseData['result']['message_id']}');
        } else {
          final description = responseData['description'];
          print('❌ Telegram API returned error: $description');
          // Retry with escaped message if there's a parsing error
          if (description != null && description.toString().contains('parse')) {
            await _retryWithEscapedMessage(message);
          }
        }
      } else {
        print('❌ Failed to send Telegram message. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        // Retry once on failure
        if (response.statusCode >= 500) {
          print('Retrying message send...');
          await Future.delayed(Duration(seconds: 1));
          await _retryWithEscapedMessage(message);
        }
      }
      print('=== End Telegram Message ===');
    } catch (e) {
      print('❌ Error sending Telegram message: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  static Future<void> _retryWithEscapedMessage(String message) async {
    try {
      print('Retrying with escaped message...');
      final uri = Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage');
      
      // Escape special characters
      final escapedMessage = message
          .replaceAll('_', '\\_')
          .replaceAll('*', '\\*')
          .replaceAll('[', '\\[')
          .replaceAll(']', '\\]')
          .replaceAll('(', '\\(')
          .replaceAll(')', '\\)')
          .replaceAll('~', '\\~')
          .replaceAll('`', '\\`')
          .replaceAll('>', '\\>')
          .replaceAll('#', '\\#')
          .replaceAll('+', '\\+')
          .replaceAll('-', '\\-')
          .replaceAll('=', '\\=')
          .replaceAll('|', '\\|')
          .replaceAll('{', '\\{')
          .replaceAll('}', '\\}')
          .replaceAll('.', '\\.');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'chat_id': _chatId,
          'text': escapedMessage,
          'parse_mode': 'MarkdownV2',
        },
      );

      print('Retry response status code: ${response.statusCode}');
      print('Retry response body: ${response.body}');
    } catch (e) {
      print('❌ Error in retry attempt: $e');
    }
  }

  // Test method to verify Telegram connection
  static Future<bool> testConnection() async {
    try {
      print('=== Testing Telegram Connection ===');
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/getMe');
      print('Test URL: $url');
      
      final response = await http.get(url);
      print('Test response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          print('✅ Bot is working correctly!');
          print('Bot username: ${data['result']['username']}');
          print('Bot ID: ${data['result']['id']}');
          print('Bot name: ${data['result']['first_name']}');
          
          // Send a test message
          await sendMessage('🔄 Bot connected successfully!\nTime: ${DateTime.now()}');
          return true;
        }
      }
      print('❌ Bot connection test failed');
      return false;
    } catch (e) {
      print('❌ Error testing Telegram connection: $e');
      return false;
    } finally {
      print('=== End Connection Test ===');
    }
  }
} 