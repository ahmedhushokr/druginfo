//import 'package:dio/dio.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/core/api/api_consumer.dart';
import 'package:untitled7/core/api/end_point.dart';
import 'package:untitled7/core/cache/cashe_helper.dart';
import 'package:untitled7/core/error/exception.dart';
import 'package:untitled7/features/auth/presentation/view_model/cubit/auth_state.dart';
import 'package:untitled7/model/sign_in_model.dart';
import 'package:untitled7/model/sign_up_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiConsumer api;
  AuthCubit(this.api) : super(AuthInitial());

  GlobalKey<FormState> signInFormKey = GlobalKey();
  GlobalKey<FormState> signUpFormKey = GlobalKey();

  TextEditingController signInEmail = TextEditingController();
  TextEditingController signInPassword = TextEditingController();

  TextEditingController signUpName = TextEditingController();
  TextEditingController signUpEmail = TextEditingController();
  TextEditingController signUpPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  //AuthRepo authRepo = AuthRepo();
  //dddddddddddddddddd
  //shokr@gmail.com ffffffffffffff

  SignInModel? user;

  signUp() async {
    try {
      emit(SignUpLoading());

      final response = await api.post(
        EndPoint.signUp,
        isformData: true,
        data: {
          ApiKey.userName: signUpName.text.trim(),
          ApiKey.email: signUpEmail.text.trim(),
          ApiKey.password: signUpPassword.text.trim(),
          ApiKey.password2: confirmPassword.text.trim(),
        },
      );
      final signUpModel = SignUpModel.fromJson(response);

      //final decodedToken = JwtDecoder.decode(signUpModel.token);

      await CacheHelper().saveData(key: ApiKey.token, value: signUpModel.token);

      final userId = response[ApiKey.user]['id'];
      await CacheHelper().saveData(key: ApiKey.id, value: userId);

      emit(SignUpSuccess(massage: "تم إنشاء الحساب بنجاح"));

      ///emit(SignUpSuccess(massage: signUpModel.user.toString()));
    } on ServerException catch (e) {
      print(e.toString());
      emit(SignUpFailure(errorMassage: e.errorModel.errorMessage));
    }
  }

  // Future<void> login()async{
  //   try{
  //     final user = await authRepo.login(signInEmail.text.trim(),signInPassword.text.trim() );
  //     if(user !=null){emit(AuthSuccess());} else {
  //       emit(AuthFailure( errorMassage: "Invalid credentials"));
  //     }
  //   } catch (e) {
  //     emit(AuthFailure(errorMassage: e.toString()));
  //   }
  // }

  // signIn() async {
  //   try {
  //     emit(AuthLoading());
  //     final response = await api.post(
  //       //EndPoint.signIn,
  //      // data: {"email": signInEmail.text, "password": signInPassword.text},
  //     );
  //     user = SignInModel.fromJson(response);
  //     final decodedTocen = JwtDecoder.decode(user!.token);
  //     CacheHelper().saveData(key: ApiKey.token, value: user!.token);
  //     CacheHelper().saveData(key: ApiKey.id, value: decodedTocen[ApiKey.id]);
  //     emit(AuthSuccess());
  //   } on ServerException catch (e) {
  //     emit(AuthFailure(errorMassage: e.errorModel.errorMessage));
  //     print(e.toString());
  //   }
  // }
}
