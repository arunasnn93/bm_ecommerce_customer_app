import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/app_config.dart';
import '../models/store_image_model.dart';
import 'store_demo_data_source.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreImageModel>> getStoreImages();
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final ApiClient apiClient;
  final StoreDemoDataSource _demoDataSource = StoreDemoDataSource();

  StoreRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<StoreImageModel>> getStoreImages() async {
    // Use demo mode if configured
    if (AppConfig.useDemoMode) {
      return await _demoDataSource.getStoreImages();
    }
    
    try {
      print('🌐 Get Store Images API Call Details:');
      print('   Base URL: ${AppConfig.baseUrl}');
      print('   Endpoint: ${AppConstants.storeImagesEndpoint}');
      print('   Full URL: ${AppConfig.baseUrl}${AppConfig.apiVersion}${AppConstants.storeImagesEndpoint}');

      final response = await apiClient.get(AppConstants.storeImagesEndpoint);

      print('📡 API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      // Parse the response - URLs are already complete from the API
      final List<dynamic> imagesData = response.data['data'] ?? [];
      final List<StoreImageModel> storeImages = imagesData.map((json) {
        // The API already returns complete Supabase URLs, so use them directly
        print('   🔗 Using API-provided URL: ${json['url']}');
        return StoreImageModel.fromJson(json);
      }).toList();

      print('✅ API Success: Found ${storeImages.length} store images');
      print('   Image URLs: ${storeImages.map((img) => img.url).toList()}');
      return storeImages;

    } catch (e) {
      print('💥 API Error: $e');
      
      if (e is DioException) {
        print('   DioException Type: ${e.type}');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Error Message: ${e.message}');
        print('   Response Data: ${e.response?.data}');
        
        if (e.response?.statusCode == 404) {
          throw Exception('Store images not found');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Server error. Please try again.');
        } else {
          throw Exception('Network error. Please check your connection.');
        }
      }
      throw Exception('Failed to get store images: ${e.toString()}');
    }
  }
  

}
