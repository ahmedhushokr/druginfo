import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/core/api/end_point.dart';
import 'package:untitled7/core/cache/cashe_helper.dart';
import 'package:untitled7/core/color/app_colors.dart';
import 'package:untitled7/core/validators/validators.dart';
import 'package:untitled7/features/home/presentation/view/screens/data_output_screen.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_elevated_button.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_text_field.dart';
import 'package:untitled7/features/home/presentation/view_model/cubit/home_cubit.dart';
import 'package:untitled7/features/home/presentation/view_model/cubit/home_state.dart';
import 'package:untitled7/features/splash/presentation/view/widget/splash_widget_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        // --- منطق البحث والنتائج (لم يتم لمسه) ---
        if (state is HomeSearchSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MedicineResultsScreen(results: state.results),
            ),
          ).then((_) => context.read<HomeCubit>().clearImageData());
        } else if (state is HomeImageUploadSuccess) {
          List<dynamic> finalResults = [];
          if (state.data is Map && state.data['matched_items'] != null) {
            finalResults = state.data['matched_items'];
          } else if (state.data is List) {
            finalResults = state.data;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MedicineResultsScreen(results: finalResults),
            ),
          ).then((_) => context.read<HomeCubit>().clearImageData());
        }
        // معالجة الأخطاء
        else if (state is HomeSearchFailure ||
            state is HomeImageUploadFailure) {
          String error = (state is HomeSearchFailure)
              ? state.error
              : (state as HomeImageUploadFailure).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // فحص حالة التحميل
        bool isLoading =
            state is HomeSearchLoading || state is HomeImageUploadLoading;

        return Stack(
          children: [
            // 1. واجهة الصفحة الرئيسية (المنطق الأصلي)
            Form(
              key: context.read<HomeCubit>().searchFormKey,
              child: Scaffold(
                backgroundColor: AppColors.primary,
                drawer: const Drawer(
                  child: Center(child: Text('Settings & Profile')),
                ),
                appBar: _buildAppBar(context),
                body: _buildBody(context, state),
              ),
            ),

            // 2. طبقة التحميل الشفافة (تظهر فوق الواجهة)
            if (isLoading)
              Container(
                // خلفية رمادية فاتحة شفافة جداً لتعطي إيحاء بالـ Glassmorphism
                color: Colors.white.withOpacity(0.85),
                width: double.infinity,
                height: double.infinity,
                child: const Center(
                  child: SplashWidgetBody(), // النص اللامع
                ),
              ),
          ],
        );
      },
    );
  }

  // --- دوال بناء الواجهة (مفصولة للتنظيم فقط) ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 200,
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 20,
          bottom: 30,
          right: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Hello, ',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
                const Spacer(),
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu, size: 30, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Find your medicine now ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: 'Search by name...',
              controller: context.read<HomeCubit>().searchController,
              validator: Validators.validatorName,
              onFieldSubmitted: (value) {
                if (context
                    .read<HomeCubit>()
                    .searchFormKey
                    .currentState!
                    .validate()) {
                  String? token = CacheHelper().getData(key: ApiKey.token);
                  context.read<HomeCubit>().searchMedicineByName(token ?? "");
                }
              },
            ),
          ],
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  '  How to scan :',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                _buildImagePreview(state),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Try to fit the following in the camera frame :\n * Medication name (required)\n * Strength\n * Form (table, capsule etc.)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildStartButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(HomeState state) {
    return Center(
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: state is HomeImagePicked
              ? Image.file(state.file, fit: BoxFit.cover)
              : Image.asset('assets/image_home.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    var cubit = context.read<HomeCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: ElevatedButtonWidget(
        onPressed: () {
          if (cubit.pickedFile == null) {
            cubit.showImageSourceDialog(context);
          } else {
            String? token = CacheHelper().getData(key: ApiKey.token);
            cubit.uploadImageOCR(token ?? "");
          }
        },
        text: cubit.pickedFile == null ? 'Pick Image' : 'Start Scan',
        borderRadius: 25,
      ),
    );
  }
}
