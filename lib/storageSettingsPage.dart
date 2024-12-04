import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageSettingsPage extends StatefulWidget {
  @override
  _StorageSettingsPageState createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends State<StorageSettingsPage> {
  late Directory _appDirectory;
  late Directory _cacheDirectory;
  double _cacheSize = 0.0;
  double _downloadsSize = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeStorageInfo();
  }

  Future<void> _initializeStorageInfo() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    _cacheDirectory = await getTemporaryDirectory();

    double cacheSize = await _calculateDirectorySize(_cacheDirectory);
    double downloadsSize = await _calculateDirectorySize(_appDirectory);

    if (mounted) {
      setState(() {
        _cacheSize = cacheSize;
        _downloadsSize = downloadsSize;
      });
    }
  }

  Future<double> _calculateDirectorySize(Directory directory) async {
    double totalSize = 0.0;
    try {
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    } catch (e) {
      debugPrint("Error calculating directory size: $e");
    }
    return totalSize / (1024 * 1024); // Convert to MB
  }

  Future<void> _clearDirectory(Directory directory) async {
    try {
      if (directory.existsSync()) {
        for (var file in directory.listSync()) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint("Error clearing directory: $e");
    }
  }

  void _clearCache() async {
    await _clearDirectory(_cacheDirectory);
    await _initializeStorageInfo(); // Refresh storage details
    _showSnackBar("Cache cleared successfully!");
  }

  void _clearAllData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Data"),
        content: const Text(
            "This will delete all app data, including saved stories and cache. Do you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearDirectory(_appDirectory);
              await _clearDirectory(_cacheDirectory);
              await _initializeStorageInfo(); // Refresh storage details
              _showSnackBar("All app data cleared!");
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Storage Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader("Storage Overview"),
            const SizedBox(height: 10),
            _buildStorageTile(
              title: "Downloaded Data",
              description: "${_downloadsSize.toStringAsFixed(2)} MB",
              icon: Icons.file_download_outlined,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 10),
            _buildStorageTile(
              title: "Cache",
              description: "${_cacheSize.toStringAsFixed(2)} MB",
              icon: Icons.cached_outlined,
              iconColor: Colors.orange,
              actionIcon: Icons.delete,
              actionColor: Colors.grey,
              onActionTap: _clearCache,
            ),
            const Divider(height: 40, thickness: 1),
            _buildSectionHeader("Manage Storage"),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text("Clear All Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStorageTile({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    IconData? actionIcon,
    Color? actionColor,
    VoidCallback? onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (actionIcon != null)
            IconButton(
              icon: Icon(actionIcon, color: actionColor),
              onPressed: onActionTap,
            ),
        ],
      ),
    );
  }
}
