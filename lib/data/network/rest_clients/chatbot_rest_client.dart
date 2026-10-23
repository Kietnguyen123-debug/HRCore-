import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/chat_models.dart';

part 'chatbot_rest_client.g.dart';

@RestApi()
abstract class ChatbotRestClient {
  factory ChatbotRestClient(Dio dio, {String baseUrl}) = _ChatbotRestClient;

  @POST('Chatbot/chat')
  Future<ChatResponseDto> chat(@Body() ChatRequestDto request);
}
