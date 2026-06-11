import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled7/features/home/presentation/view_model/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  GlobalKey<FormState> searchFormKey = GlobalKey();
  TextEditingController searchController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  final Dio _dio = Dio();

  Future<void> searchMedicineByName(String token) async {
    if (searchController.text.isEmpty) return;
    try {
      emit(HomeSearchLoading());

      final response = await _dio.get(
        'http://46.101.108.29:8000/api/medicines/',
        queryParameters: {'search': searchController.text.trim()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // التعامل الصحيح مع البيانات
      List<dynamic> results = [];

      if (response.data is List) {
        // إذا كانت البيانات قائمة مباشرة
        results = response.data as List<dynamic>;
      } else if (response.data is Map) {
        // إذا كانت البيانات Map، تحقق من وجود key معين
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        results = data['results'] ?? data['data'] ?? [];
      }

      if (results.isEmpty) {
        emit(HomeSearchFailure("عذراً، لم يتم العثور على دواء بهذا الاسم"));
      } else {
        emit(HomeSearchSuccess(results));
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ??
          e.message ??
          "حدث خطأ في الاتصال بالسيرفر";
      emit(HomeSearchFailure(errorMessage.toString()));
    } catch (e) {
      emit(HomeSearchFailure("حدث خطأ غير متوقع: ${e.toString()}"));
    }
  }

  Future<void> uploadImageOCR(String token) async {
    if (pickedFile == null) return;

    try {
      emit(HomeImageUploadLoading());

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          pickedFile!.path,
          filename: pickedFile!.name,
        ),
      });

      final response = await _dio.post(
        'http://46.101.108.29:8000/api/uploads/ocr-search/',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      emit(HomeImageUploadSuccess(response.data));
    } on DioException catch (e) {
      debugPrint("OCR Error: ${e.response?.data}");
      emit(
        HomeImageUploadFailure(
          e.response?.data['detail'] ?? "فشل في تحليل الصورة",
        ),
      );
    } catch (e) {
      emit(HomeImageUploadFailure("حدث خطأ غير متوقع"));
    }
  }

  Future<void> pickerImage(ImageSource source) async {
    try {
      pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        emit(HomeImagePicked(File(pickedFile!.path)));
      }
    } catch (e) {
      emit(HomeInitial());
    }
  }

  void clearImageData() {
    pickedFile = null;
    searchController.clear();
    emit(HomeInitial());
  }

  void showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source", textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickerImage(ImageSource.camera);
            },
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickerImage(ImageSource.gallery);
            },
            child: const Text("Gallery"),
          ),
        ],
      ),
    );
  }
}

// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:untitled7/features/home/presentation/view_model/cubit/home_state.dart';

// class HomeCubit extends Cubit<HomeState> {
//   HomeCubit() : super(HomeInitial());

//   final ImagePicker _picker = ImagePicker();
//   XFile? pickedFile;

//   Future<void> uploadImage(File imageFile, String token) async {
//     final dio = Dio();
//      final formData = FormData.fromMap({
//       'image': await MultipartFile.fromFile(
//         imageFile.,
//         filename: imageFile.path.split('/').last,
//       ),
//     });

//     final response = await dio.post(
//       'http://46.101.108.29:8000/api/uploads/ocr-search/',
//       data: formData,
//       options: Options(
//         headers: {
//           'Authorization':
//               'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc4Mzc4MDExLCJpYXQiOjE3NzgzNzQ0MTEsImp0aSI6IjU3NGQyOTczNjA4MzRhOTk5ZGNhZWE3MDY5ZjNmYTliIiwidXNlcl9pZCI6IjE3In0.Iy2GrVGAVcWgUYUeP-Buva9aE8n_37fQI4Oy0zzKL28',
//         },
//       ),
//     );

//     print(response.data);
//   }

//   Future<void> pickerImage(ImageSource source) async {
//     try {
//       pickedFile = await _picker.pickImage(source: source);

//       if (pickedFile != null) {
//         emit(HomeImagePicked(File(pickedFile!.path)));
//       }
//     } catch (e) {
//       emit(HomeInitial());
//     }
//   }

//   void showImageSourceDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             "Select Image Source",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 pickerImage(ImageSource.camera);
//               },
//               child: Text("Camera"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 pickerImage(ImageSource.gallery);
//               },
//               child: Text("Gallery"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   sendPictureMedicion() {}
// }
