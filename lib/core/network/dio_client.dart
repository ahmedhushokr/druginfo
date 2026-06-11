// import 'package:dio/dio.dart';
// import 'package:untitled7/core/utils/pref_helper.dart';

// class DioClient {
//   final Dio dio = Dio(
//     BaseOptions(baseUrl: 'https://sonic-zdi0.onrender.com/api',),
//   ); 

//   DioClient(){
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async{
//           final String? token = await PrefHelper.getToken(); 
//           if(token != null && token.isNotEmpty) {
//             options.headers['Authorization']='Bearer $token';
//           } 
//           return handler.next(options);
//        }
//       )
//     );
//   }
//   Dio get getDio => dio;
// }