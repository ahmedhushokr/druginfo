// import 'package:dio/dio.dart';
// import 'package:untitled7/core/network/api_exceptions.dart';
// import 'package:untitled7/core/network/dio_client.dart';

// class ApiServic {
//   final DioClient _dioClient =DioClient();

//   Future<dynamic> get(String endPoint)async{
//     try{
//       final response =await  _dioClient.dio.get(endPoint);
//       return response.data;
//     }on DioException catch(e){
//       return ApiExceptions.handleError(e);
//     }
//   }
 
//   Future<dynamic> post(String endPoint,Map<String,dynamic> body)async{
//     try{
//       final response =await  _dioClient.dio.post(endPoint,data: body);
//       return response.data;
//     }on DioException catch(e){
//       return ApiExceptions.handleError(e);
//     }
//   }
//   Future<dynamic> patch(String endPoint,Map<String,dynamic> body)async{
//     try{
//       final response =await  _dioClient.dio.patch(endPoint,data: body);
//       return response.data;
//     }on DioException catch(e){
//       return ApiExceptions.handleError(e);
//     }
//   }
//   Future<dynamic> delete(String endPoint,Map<String,dynamic> body)async{
//     try{
//       final response =await  _dioClient.dio.delete(endPoint,data: body);
//       return response.data;
//     }on DioException catch(e){
//       return ApiExceptions.handleError(e);
//     }
//   }
// }