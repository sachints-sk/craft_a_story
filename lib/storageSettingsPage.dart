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

  Widget _StorageCard(){
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downloaded Data',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Files saved for offline use',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                  "${_downloadsSize.toStringAsFixed(2)} MB",
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cache',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Temporary files and app data',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
              Text(
    "${_cacheSize.toStringAsFixed(2)} MB",
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              )
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.cleaning_services, color: Colors.black54, size: 18),
                  label: const Text(
                    'Clear Cache',
                    style: TextStyle(color: Colors.black54),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearAllData,
                  icon: const Icon(Icons.warning, color: Colors.red, size: 18,),
                  label: const Text(
                    'Clear All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  ),
                ),
              ),
            ],
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

            _buildSectionHeader("Storage Overview"),
            const SizedBox(height: 10),



            _StorageCard(),
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
