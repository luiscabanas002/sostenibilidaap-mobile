import '../core/network/api_client.dart';
import '../models/division.dart';

class DivisionService {
  Future<List<Division>> getDivisions() async {
    final response = await ApiClient.dio.get<List<dynamic>>('/Division');

    return (response.data ?? [])
        .map((item) => Division.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
