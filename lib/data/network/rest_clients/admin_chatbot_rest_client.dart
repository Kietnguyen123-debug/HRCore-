import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/chat_models.dart';

part 'admin_chatbot_rest_client.g.dart';

@RestApi()
abstract class AdminChatbotRestClient {
  factory AdminChatbotRestClient(Dio dio, {String baseUrl}) = _AdminChatbotRestClient;

  @GET('admin-chatbot/access')
  Future<void> checkAccess();

  @POST('admin-chatbot/chat')
  Future<ChatResponseDto> chat(@Body() ChatRequestDto request);
}
