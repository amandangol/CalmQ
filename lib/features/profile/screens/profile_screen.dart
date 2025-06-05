import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/screens/user_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoScreen()),
              );
              // Reload profile after returning from edit screen
              context.read<UserProfileProvider>().loadUserProfile();
            },
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, profileProvider, _) {
          if (profileProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    profileProvider.error!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.loadUserProfile();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userProfile = profileProvider.userProfile;
          if (userProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Profile Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your profile to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInfoScreen(),
                        ),
                      );
                      profileProvider.loadUserProfile();
                    },
                    icon: Icon(Icons.add),
                    label: Text('Create Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => profileProvider.loadUserProfile(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(userProfile),
                  SizedBox(height: 24),
                  _buildProfileSection('Personal Information', [
                    _buildInfoRow('Name', userProfile.name),
                    _buildInfoRow('Age', userProfile.age.toString()),
                    if (userProfile.gender != null)
                      _buildInfoRow('Gender', userProfile.gender!),
                  ]),
                  SizedBox(height: 16),
                  _buildProfileSection('Wellness Goals', [
                    if (userProfile.goals.isNotEmpty)
                      ...userProfile.goals.map(
                        (goal) => _buildInfoRow('•', goal),
                      )
                    else
                      _buildInfoRow('No goals set', ''),
                  ]),
                  SizedBox(height: 16),
                  _buildProfileSection('Stress & Wellness', [
                    if (userProfile.stressFrequency != null)
                      _buildInfoRow(
                        'Stress Level',
                        userProfile.stressFrequency!,
                      ),
                    if (userProfile.healthyEating != null)
                      _buildInfoRow(
                        'Healthy Eating',
                        userProfile.healthyEating!,
                      ),
                    if (userProfile.sleepQuality != null)
                      _buildInfoRow('Sleep Quality', userProfile.sleepQuality!),
                    if (userProfile.happinessLevel != null)
                      _buildInfoRow('Happiness', userProfile.happinessLevel!),
                  ]),
                  SizedBox(height: 16),
                  _buildProfileSection('Meditation', [
                    if (userProfile.meditationExperience != null)
                      _buildInfoRow(
                        'Experience',
                        userProfile.meditationExperience!,
                      ),
                  ]),
                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Member since ${_formatDate(userProfile.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[100],
            child: Text(
              profile.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            profile.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
