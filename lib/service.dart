import 'package:dio/dio.dart';
import 'package:dropdown_example/models.dart';

class Service {
  final Dio dio;
  Service(this.dio);

  Future<List<Models>> getUsers() async {
    Response response =
        await dio.get('https://jsonplaceholder.typicode.com/posts');

    List<dynamic> data = response.data;
    return data.map((json) => Models.fromJson(json)).toList();
  }
}
