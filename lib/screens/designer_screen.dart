import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/canvas/canvas_widget.dart';
import '../widgets/tools/tools_panel.dart';
import '../widgets/properties/properties_panel.dart';
import '../providers/canvas_provider.dart';
import '../services/export_service.dart';

/// Main designer screen that combines all components
class DesignerScreen extends ConsumerWidget {
  const DesignerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(context, ref),
      body: Row(
        children: [
          // Left tools panel
          const ToolsPanel(),
          
          // Center canvas area
          Expanded(
            child: Column(
              children: [
                // Canvas toolbar
                const CanvasToolbar(),
                
                // Canvas container
                const Expanded(
                  child: CanvasContainer(),
                ),
              ],
            ),
          ),
          
          // Right properties panel
          const PropertiesPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text(
        'ID Card Designer',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      actions: [
        // File operations
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More options',
          onSelected: (value) => _handleMenuAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new',
              child: ListTile(
                leading: Icon(Icons.add),
                title: Text('New Design'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'save',
              child: ListTile(
                leading: Icon(Icons.save),
                title: Text('Save Design'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'load',
              child: ListTile(
                leading: Icon(Icons.folder_open),
                title: Text('Load Design'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'export_png',
              child: ListTile(
                leading: Icon(Icons.image),
                title: Text('Export as PNG'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export_pdf',
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Export as PDF'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'send_to_backend',
              child: ListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text('Send to Backend'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 16),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    final canvasState = ref.read(canvasProvider);

    switch (action) {
      case 'new':
        _showNewDesignDialog(context, canvasNotifier);
        break;
      case 'save':
        _saveDesign(context, canvasNotifier);
        break;
      case 'load':
        _loadDesign(context, canvasNotifier);
        break;
      case 'export_png':
        _exportAsPNG(context, canvasState);
        break;
      case 'export_pdf':
        _exportAsPDF(context, canvasState);
        break;
      case 'send_to_backend':
        _sendToBackend(context, canvasState);
        break;
    }
  }

  void _showNewDesignDialog(BuildContext context, CanvasNotifier canvasNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Design'),
        content: const Text('Are you sure you want to create a new design? All unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              canvasNotifier.clearCanvas();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New design created')),
              );
            },
            child: const Text('Create New'),
          ),
        ],
      ),
    );
  }

  void _saveDesign(BuildContext context, CanvasNotifier canvasNotifier) {
    // In a real app, you'd show a dialog to get the filename
    // and save to local storage or cloud storage
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Design'),
        content: const Text('Design saved successfully!\n\nIn a real app, this would save your design to local storage or the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _loadDesign(BuildContext context, CanvasNotifier canvasNotifier) {
    // In a real app, you'd show a file picker or list of saved designs
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Design'),
        content: const Text('Load design feature coming soon!\n\nThis would show a list of your saved designs to choose from.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportAsPNG(BuildContext context, canvasState) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Exporting as PNG...'),
            ],
          ),
        ),
      );

      // Export using ExportService
      final exportService = ExportService();
      final success = await exportService.exportAsPNG(canvasState);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Design exported as PNG successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Export failed');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportAsPDF(BuildContext context, canvasState) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Exporting as PDF...'),
            ],
          ),
        ),
      );

      // Export using ExportService
      final exportService = ExportService();
      final success = await exportService.exportAsPDF(canvasState);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Design exported as PDF successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Export failed');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendToBackend(BuildContext context, canvasState) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Sending to backend...'),
            ],
          ),
        ),
      );

      // Send using ExportService
      final exportService = ExportService();
      final success = await exportService.sendToBackend(canvasState);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Design sent to backend successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Send to backend failed');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send to backend: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Welcome screen for new users
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.badge,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App title
            const Text(
              'ID Card Designer',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App description
            const Text(
              'Create professional ID cards with ease.\nDesign, customize, and export your cards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Quick start options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DesignerScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Start Designing'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                OutlinedButton.icon(
                  onPressed: () {
                    // Show templates dialog
                    _showTemplatesDialog(context);
                  },
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Browse Templates'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Templates'),
        content: const SizedBox(
          width: 400,
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Templates Coming Soon!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We\'re working on creating beautiful templates for you.\nFor now, start with a blank canvas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DesignerScreen()),
              );
            },
            child: const Text('Start Designing'),
          ),
        ],
      ),
    );
  }
}
