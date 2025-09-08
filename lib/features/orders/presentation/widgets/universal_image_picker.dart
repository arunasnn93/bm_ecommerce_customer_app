import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/file_data.dart';
import '../../../../core/services/universal_file_picker.dart';
import '../../../../core/services/universal_web_file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Universal image picker widget that works on all platforms
class UniversalImagePicker extends StatefulWidget {
  final FileData? selectedImage;
  final Function(FileData?) onImageSelected;
  final String? label;
  final String? hint;
  final bool enabled;
  final double? maxWidth;
  final double? maxHeight;
  final int maxFileSizeInMB;

  const UniversalImagePicker({
    super.key,
    this.selectedImage,
    required this.onImageSelected,
    this.label,
    this.hint,
    this.enabled = true,
    this.maxWidth,
    this.maxHeight,
    this.maxFileSizeInMB = 10,
  });

  @override
  State<UniversalImagePicker> createState() => _UniversalImagePickerState();
}

class _UniversalImagePickerState extends State<UniversalImagePicker> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Image picker button
        InkWell(
          onTap: widget.enabled && !_isLoading ? _pickImage : null,
          child: Container(
            width: widget.maxWidth ?? double.infinity,
            height: widget.maxHeight ?? 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: _errorMessage != null ? AppColors.error : AppColors.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: widget.enabled ? AppColors.surface : AppColors.background,
            ),
            child: _buildContent(),
          ),
        ),
        
        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        
        // Hint text
        if (widget.hint != null && _errorMessage == null) ...[
          const SizedBox(height: 8),
          Text(
            widget.hint!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.selectedImage != null) {
      return _buildImagePreview();
    }

    return _buildPlaceholder();
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        // Image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            widget.selectedImage!.bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.background,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.surface,
                size: 20,
              ),
              onPressed: widget.enabled ? _removeImage : null,
            ),
          ),
        ),
        
        // File info overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(
              '${widget.selectedImage!.name} (${widget.selectedImage!.humanReadableSize})',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.surface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: widget.enabled ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add image',
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.enabled ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Max ${widget.maxFileSizeInMB}MB',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      FileData? imageData;

      if (kIsWeb) {
        // Web: Check if mobile device for camera options
        if (_isMobileWeb()) {
          // Mobile web: Show dialog to choose camera, gallery, or files
          final source = await _showWebImageSourceDialog();
          if (source != null) {
            imageData = await _handleWebImageSource(source);
          }
        } else {
          // Desktop web: Use file picker directly
          imageData = await UniversalFilePicker.pickImage(
            maxFileSize: widget.maxFileSizeInMB * 1024 * 1024,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
          );
        }
      } else {
        // Native mobile: Show dialog to choose camera or gallery
        final source = await _showImageSourceDialog();
        if (source != null) {
          imageData = await UniversalFilePicker.pickImage(
            maxFileSize: widget.maxFileSizeInMB * 1024 * 1024,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
            source: source,
          );
        }
      }

      if (imageData != null) {
        widget.onImageSelected(imageData);
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show dialog to choose image source (camera or gallery) on mobile
  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose how you want to select an image:'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _removeImage() {
    widget.onImageSelected(null);
    setState(() {
      _errorMessage = null;
    });
  }

  String _getErrorMessage(dynamic error) {
    if (error is FilePickerException) {
      return error.message;
    }
    
    if (kIsWeb) {
      if (error.toString().contains('FileUploadInputElement')) {
        return 'File picker not supported in this browser';
      }
    }
    
    if (error.toString().contains('permission')) {
      return 'Permission denied. Please allow file access.';
    }
    
    if (error.toString().contains('size')) {
      return 'File too large. Maximum size is ${widget.maxFileSizeInMB}MB.';
    }
    
    return 'Failed to pick image. Please try again.';
  }

  /// Check if running on mobile web
  bool _isMobileWeb() {
    if (!kIsWeb) return false;
    
    // Simple mobile detection for web
    final userAgent = Uri.base.queryParameters['user_agent'] ?? '';
    return userAgent.toLowerCase().contains('mobile') ||
           MediaQuery.of(context).size.width < 768; // Tablet/mobile breakpoint
  }

  /// Show dialog for web image source selection (mobile web)
  Future<String?> _showWebImageSourceDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose how you want to select an image:'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('camera_rear'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('gallery'),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery/Files'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Handle web image source selection
  Future<FileData?> _handleWebImageSource(String source) async {
    switch (source) {
      case 'camera_rear':
        return await UniversalWebFilePicker.pickImageWithCamera(
          maxFileSize: widget.maxFileSizeInMB * 1024 * 1024,
          useFrontCamera: false,
        );
      case 'gallery':
        return await UniversalWebFilePicker.pickImage(
          maxFileSize: widget.maxFileSizeInMB * 1024 * 1024,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        );
      default:
        return null;
    }
  }
}
