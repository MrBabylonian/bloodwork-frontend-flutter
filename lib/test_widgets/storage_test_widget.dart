import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/models/auth_models.dart';

class StorageTestWidget extends StatefulWidget {
  const StorageTestWidget({Key? key}) : super(key: key);

  @override
  State<StorageTestWidget> createState() => _StorageTestWidgetState();
}

class _StorageTestWidgetState extends State<StorageTestWidget> {
  final StorageService _storageService = StorageService();
  String _output = 'Ready to test storage service...';

  void _addOutput(String message) {
    setState(() {
      _output += '\n$message';
    });
  }

  Future<void> _testSaveAuthData() async {
    _addOutput('\n=== Testing Save Auth Data ===');

    try {
      // Create mock user data
      final mockUser = UserModel(
        id: '123',
        username: 'test_user',
        role: 'veterinarian',
        profile: {'first_name': 'Test', 'last_name': 'User'},
      );

      await _storageService.saveAuthData(
        accessToken: 'mock_access_token_123',
        refreshToken: 'mock_refresh_token_456',
        user: mockUser,
        expiresIn: 1800, // 30 minutes
      );

      _addOutput('✅ Auth data saved successfully');
    } catch (e) {
      _addOutput('❌ Error saving auth data: $e');
    }
  }

  Future<void> _testGetTokens() async {
    _addOutput('\n=== Testing Get Tokens ===');

    try {
      final accessToken = await _storageService.getAccessToken();
      final refreshToken = await _storageService.getRefreshToken();

      _addOutput('Access Token: ${accessToken ?? 'null'}');
      _addOutput('Refresh Token: ${refreshToken ?? 'null'}');
    } catch (e) {
      _addOutput('❌ Error getting tokens: $e');
    }
  }

  Future<void> _testGetUserData() async {
    _addOutput('\n=== Testing Get User Data ===');

    try {
      final userData = await _storageService.getUserData();

      if (userData != null) {
        _addOutput('✅ User data retrieved:');
        _addOutput('  ID: ${userData.id}');
        _addOutput('  Username: ${userData.username}');
        _addOutput('  Role: ${userData.role}');
        _addOutput('  Profile: ${userData.profile}');
      } else {
        _addOutput('❌ No user data found');
      }
    } catch (e) {
      _addOutput('❌ Error getting user data: $e');
    }
  }

  Future<void> _testTokenExpiry() async {
    _addOutput('\n=== Testing Token Expiry ===');

    try {
      final isExpired = await _storageService.isTokenExpired();
      _addOutput('Is token expired: $isExpired');
    } catch (e) {
      _addOutput('❌ Error checking token expiry: $e');
    }
  }

  Future<void> _testLoginStatus() async {
    _addOutput('\n=== Testing Login Status ===');

    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      _addOutput('Is logged in: $isLoggedIn');
    } catch (e) {
      _addOutput('❌ Error checking login status: $e');
    }
  }

  Future<void> _testUpdateToken() async {
    _addOutput('\n=== Testing Update Access Token ===');

    try {
      await _storageService.updateAccessToken(
        accessToken: 'new_access_token_789',
        expiresIn: 1800,
      );

      _addOutput('✅ Access token updated');

      // Verify the update
      final newToken = await _storageService.getAccessToken();
      _addOutput('New access token: $newToken');
    } catch (e) {
      _addOutput('❌ Error updating access token: $e');
    }
  }

  Future<void> _testClearData() async {
    _addOutput('\n=== Testing Clear Auth Data ===');

    try {
      await _storageService.clearAuthData();
      _addOutput('✅ Auth data cleared');

      // Verify data is cleared
      final isLoggedIn = await _storageService.isLoggedIn();
      _addOutput('Is logged in after clear: $isLoggedIn');
    } catch (e) {
      _addOutput('❌ Error clearing auth data: $e');
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _output = 'Running all storage tests...\n';
    });

    await _testSaveAuthData();
    await _testGetTokens();
    await _testGetUserData();
    await _testTokenExpiry();
    await _testLoginStatus();
    await _testUpdateToken();
    await _testClearData();

    _addOutput('\n=== All Tests Complete ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Service Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _runAllTests,
                  child: const Text('Run All Tests'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _testSaveAuthData,
                      child: const Text('Save Data'),
                    ),
                    ElevatedButton(
                      onPressed: _testGetTokens,
                      child: const Text('Get Tokens'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _testClearData,
                      child: const Text('Clear Data'),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => setState(() => _output = 'Ready to test...'),
                      child: const Text('Clear Log'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
