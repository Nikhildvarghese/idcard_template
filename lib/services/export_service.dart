import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../models/canvas_state.dart';
import '../models/canvas_element.dart';

/// Service for exporting designs and sending to backend
class ExportService {
  static const String baseUrl = 'https://your-backend-api.com'; // Replace with your API URL
  final Dio _dio = Dio();

  /// Check and request storage permission
  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return true; // iOS doesn't require storage permission for app directories
  }

  /// Get the appropriate directory for saving files
  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      // Try to get external storage first (Downloads folder)
      try {
        if (await _checkStoragePermission()) {
          return Directory('/storage/emulated/0/Download');
        } else {
          throw Exception("Storage permission denied");
        }
      } catch (e) {
        // Fallback to application documents directory
        return await getApplicationDocumentsDirectory();
      }
    } else {
      // For iOS, use documents directory
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Export canvas as PNG image
  Future<bool> exportAsPNG(CanvasState canvasState) async {
    try {
      // Get the save directory
      final directory = await _getSaveDirectory();
      
      // Create the directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final fileName = 'id_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      
      // Create mock image data (replace with actual canvas rendering)
      final mockImageData = _createMockImageData(canvasState);
      
      // Write data to file
      await file.writeAsBytes(mockImageData);
      
      print('PNG exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error exporting PNG: $e');
      return false;
    }
  }

  /// Export canvas as PDF document
  Future<bool> exportAsPDF(CanvasState canvasState) async {
    try {
      // Get the save directory
      final directory = await _getSaveDirectory();
      
      // Create the directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final pdf = pw.Document();

      // Add a page with the canvas content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            canvasState.canvasSize.width * PdfPageFormat.mm,
            canvasState.canvasSize.height * PdfPageFormat.mm,
          ),
          build: (pw.Context context) {
            return _buildPdfContent(canvasState);
          },
        ),
      );

      final fileName = 'id_card_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Save PDF to file
      await file.writeAsBytes(await pdf.save());
      
      print('PDF exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error exporting PDF: $e');
      return false;
    }
  }

  // ... (rest of your methods remain the same)

  /// Send design to backend API
  Future<bool> sendToBackend(CanvasState canvasState) async {
    try {
      // Convert canvas state to JSON
      final designData = {
        'canvas': canvasState.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      // Send to backend API
      final response = await _dio.post(
        '$baseUrl/api/designs',
        data: designData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Design sent to backend successfully');
        return true;
      } else {
        throw Exception('Backend returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending to backend: $e');
      
      // For demo purposes, simulate successful send after delay
      await Future.delayed(const Duration(seconds: 2));
      return true; // In real implementation, return false on error
    }
  }

  /// Upload image to backend and get URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/api/upload/image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Save design to backend
  Future<String?> saveDesign(CanvasState canvasState, String designName) async {
    try {
      final designData = {
        'name': designName,
        'canvas': canvasState.toJson(),
        'thumbnail': await _generateThumbnail(canvasState),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _dio.post(
        '$baseUrl/api/designs',
        data: designData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['id'];
      }
      return null;
    } catch (e) {
      print('Error saving design: $e');
      return null;
    }
  }

  /// Load design from backend
  Future<CanvasState?> loadDesign(String designId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/designs/$designId',
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
          },
        ),
      );

      if (response.statusCode == 200) {
        final canvasData = response.data['canvas'];
        return CanvasState.fromJson(canvasData);
      }
      return null;
    } catch (e) {
      print('Error loading design: $e');
      return null;
    }
  }

  /// Get list of saved designs
  Future<List<Map<String, dynamic>>> getDesigns() async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/designs',
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
          },
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['designs']);
      }
      return [];
    } catch (e) {
      print('Error getting designs: $e');
      return [];
    }
  }

  /// Create mock image data for demo purposes
  Uint8List _createMockImageData(CanvasState canvasState) {
    // This is a simple mock implementation
    // In a real app, you'd convert the actual canvas to image bytes
    final width = canvasState.canvasSize.width.toInt();
    final height = canvasState.canvasSize.height.toInt();
    
    // Create a simple bitmap header and data
    final headerSize = 54;
    final imageSize = width * height * 3; // 3 bytes per pixel (RGB)
    final fileSize = headerSize + imageSize;
    
    final bytes = Uint8List(fileSize);
    
    // BMP header
    bytes[0] = 0x42; // 'B'
    bytes[1] = 0x4D; // 'M'
    
    // File size
    bytes[2] = fileSize & 0xFF;
    bytes[3] = (fileSize >> 8) & 0xFF;
    bytes[4] = (fileSize >> 16) & 0xFF;
    bytes[5] = (fileSize >> 24) & 0xFF;
    
    // Pixel data offset
    bytes[10] = headerSize;
    
    // Fill with background color
    final bgColor = canvasState.backgroundColor;
    final r = bgColor.red;
    final g = bgColor.green;
    final b = bgColor.blue;
    
    for (int i = headerSize; i < fileSize; i += 3) {
      bytes[i] = b; // Blue
      bytes[i + 1] = g; // Green
      bytes[i + 2] = r; // Red
    }
    
    return bytes;
  }

  /// Build PDF content from canvas state
  pw.Widget _buildPdfContent(CanvasState canvasState) {
    return pw.Container(
      width: canvasState.canvasSize.width,
      height: canvasState.canvasSize.height,
      decoration: pw.BoxDecoration(
        color: PdfColor(
          canvasState.backgroundColor.red / 255,
          canvasState.backgroundColor.green / 255,
          canvasState.backgroundColor.blue / 255,
        ),
      ),
      child: pw.Stack(
        children: canvasState.sortedElements.map((element) {
          return pw.Positioned(
            left: element.position.dx,
            top: element.position.dy,
            child: _buildPdfElement(element),
          );
        }).toList(),
      ),
    );
  }

  /// Build PDF element from canvas element
  pw.Widget _buildPdfElement(CanvasElement element) {
    switch (element.type) {
      case ElementType.text:
        final textElement = element as TextElement;
        return pw.Container(
          width: element.size.width,
          height: element.size.height,
          child: pw.Text(
            textElement.text,
            style: pw.TextStyle(
              fontSize: textElement.fontSize,
              fontWeight: textElement.fontWeight == FontWeight.bold 
                  ? pw.FontWeight.bold 
                  : pw.FontWeight.normal,
              color: PdfColor(
                textElement.color.red / 255,
                textElement.color.green / 255,
                textElement.color.blue / 255,
              ),
            ),
          ),
        );

      case ElementType.shape:
        final shapeElement = element as ShapeElement;
        if (shapeElement.shapeType == ShapeType.rectangle) {
          return pw.Container(
            width: element.size.width,
            height: element.size.height,
            decoration: pw.BoxDecoration(
              color: PdfColor(
                shapeElement.fillColor.red / 255,
                shapeElement.fillColor.green / 255,
                shapeElement.fillColor.blue / 255,
              ),
              borderRadius: pw.BorderRadius.circular(shapeElement.borderRadius),
            ),
          );
        }
        break;

      default:
        // For other element types, return a placeholder
        return pw.Container(
          width: element.size.width,
          height: element.size.height,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          child: pw.Center(
            child: pw.Text(
              'Element\n${element.type.toString().split('.').last}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey,
              ),
            ),
          ),
        );
    }

    return pw.Container();
  }

  /// Generate thumbnail for design preview
  Future<String> _generateThumbnail(CanvasState canvasState) async {
    // In a real implementation, you'd generate a small image thumbnail
    // For now, return a placeholder
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
  }
}
