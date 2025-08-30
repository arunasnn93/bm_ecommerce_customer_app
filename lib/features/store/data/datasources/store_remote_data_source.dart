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

      // Parse the response and construct full URLs
      final List<dynamic> imagesData = response.data['data'] ?? [];
      final List<StoreImageModel> storeImages = imagesData.map((json) {
        // Construct full URL for the image
        final relativeUrl = json['url'] as String;
        final fullUrl = _constructFullUrl(relativeUrl);
        
        // Create a new JSON object with the full URL
        final updatedJson = Map<String, dynamic>.from(json);
        updatedJson['url'] = fullUrl;
        
        return StoreImageModel.fromJson(updatedJson);
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
  
  /// Constructs a full URL from a relative path for database-stored images
  String _constructFullUrl(String relativeUrl) {
    // Remove leading slash if present
    final cleanRelativeUrl = relativeUrl.startsWith('/') 
        ? relativeUrl.substring(1) 
        : relativeUrl;
    
    // For database-stored images, we need to construct the URL to the image serving endpoint
    // The relativeUrl should be something like "uploads/1756581873836-59323e1d57896a77.jpg"
    // We need to extract the filename and construct the image serving URL
    
    // Extract filename from the path
    final pathParts = cleanRelativeUrl.split('/');
    final fileName = pathParts.last; // Get the filename
    
    // Construct the image serving URL
    // TODO: Update this endpoint when the backend image serving is configured
    final imageServingUrl = '${AppConfig.baseUrl}/api/images/$fileName';
    
    print('   🔗 Database Image URL: $relativeUrl → $imageServingUrl');
    print('   📁 Filename: $fileName');
    
    // For now, use demo images since the image serving endpoint is not configured
    // This ensures the virtual tour works while the backend image serving is set up
    final demoImageMap = {
      '1756581871255-9af89d8add7a5ace.jpg': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop',
      '1756581872717-fd6c66826470a301.jpg': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=600&fit=crop',
      '1756581873836-59323e1d57896a77.jpg': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop',
    };
    
    // Check if we have a demo image for this filename
    if (demoImageMap.containsKey(fileName)) {
      final demoUrl = demoImageMap[fileName]!;
      print('   🔗 Using Demo Image: $fileName → $demoUrl');
      return demoUrl;
    }
    
    // Return the database image URL (will work once endpoint is configured)
    return imageServingUrl;
  }
}
