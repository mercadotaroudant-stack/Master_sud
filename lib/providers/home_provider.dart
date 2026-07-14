import 'package:flutter/material.dart';

import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/showroom_model.dart';
import '../models/video_model.dart';
import '../repositories/banner_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/showroom_repository.dart';
import '../repositories/video_repository.dart';

enum HomeLoadState { initial, loading, loaded, error }

/// يدير حالة بيانات الصفحة الرئيسية بالكامل: البانرات، الفئات، المنتجات
/// الشائعة، الـ Showrooms، وفيديوهات التكوين — كلها من Firebase، مع دعم
/// Pull-To-Refresh و Skeleton Loading وError Handling موحّد.
class HomeProvider extends ChangeNotifier {
  final BannerRepository _bannerRepository;
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;
  final ShowroomRepository _showroomRepository;
  final VideoRepository _videoRepository;

  HomeProvider({
    BannerRepository? bannerRepository,
    CategoryRepository? categoryRepository,
    ProductRepository? productRepository,
    ShowroomRepository? showroomRepository,
    VideoRepository? videoRepository,
  })  : _bannerRepository = bannerRepository ?? FirebaseBannerRepository(),
        _categoryRepository = categoryRepository ?? FirebaseCategoryRepository(),
        _productRepository = productRepository ?? FirebaseProductRepository(),
        _showroomRepository = showroomRepository ?? FirebaseShowroomRepository(),
        _videoRepository = videoRepository ?? FirebaseVideoRepository();

  HomeLoadState state = HomeLoadState.initial;
  List<BannerModel> banners = [];
  List<CategoryModel> categories = [];
  List<ProductModel> popularProducts = [];
  List<ShowroomModel> showrooms = [];
  List<VideoModel> trainingVideos = [];
  String? errorMessage;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      state = HomeLoadState.loading;
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        _bannerRepository.getActiveBanners(),
        _categoryRepository.getCategories(),
        _productRepository.getPopularProducts(),
        _showroomRepository.getShowrooms(),
        _videoRepository.getTrainingVideos(),
      ]);
      banners = results[0] as List<BannerModel>;
      categories = results[1] as List<CategoryModel>;
      popularProducts = results[2] as List<ProductModel>;
      showrooms = results[3] as List<ShowroomModel>;
      trainingVideos = results[4] as List<VideoModel>;
      state = HomeLoadState.loaded;
    } catch (e) {
      errorMessage = e.toString();
      state = HomeLoadState.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load(silent: true);
}
