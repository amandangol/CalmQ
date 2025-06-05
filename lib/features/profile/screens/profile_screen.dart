import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../auth/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController ageController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    await context.read<UserProfileProvider>().loadUserProfile();
    final profile = context.read<UserProfileProvider>().userProfile;
    if (profile != null) {
      nameController.text = profile.name;
      ageController.text = profile.age.toString();
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentProfile = context.read<UserProfileProvider>().userProfile;
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(
            name: nameController.text,
            age: int.parse(ageController.text),
          );
          await context.read<UserProfileProvider>().updateUserProfile(
            updatedProfile,
          );
          setState(() => isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        final profile = userProfileProvider.userProfile;

        if (userProfileProvider.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (profile == null) {
          return Scaffold(
            body: Center(child: Text('No profile data available')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => isEditing = true);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile),
                  SizedBox(height: 24),
                  _buildProfileSection('Personal Information', [
                    _buildEditableField(
                      'Name',
                      nameController,
                      isEditing: isEditing,
                    ),
                    SizedBox(height: 16),
                    _buildEditableField(
                      'Age',
                      ageController,
                      isEditing: isEditing,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    _buildInfoTile('Gender', profile.gender ?? 'Not specified'),
                  ]),
                  SizedBox(height: 24),
                  _buildProfileSection('Wellness Goals', [
                    _buildChipsList('Goals', profile.goals),
                  ]),
                  SizedBox(height: 24),
                  _buildProfileSection('Mental Health', [
                    _buildInfoTile(
                      'Stress Frequency',
                      profile.stressFrequency ?? 'Not specified',
                    ),
                    SizedBox(height: 16),
                    _buildInfoTile(
                      'Sleep Quality',
                      profile.sleepQuality ?? 'Not specified',
                    ),
                    SizedBox(height: 16),
                    _buildInfoTile(
                      'Happiness Level',
                      profile.happinessLevel ?? 'Not specified',
                    ),
                  ]),
                  SizedBox(height: 24),
                  _buildProfileSection('Lifestyle', [
                    _buildInfoTile(
                      'Healthy Eating',
                      profile.healthyEating ?? 'Not specified',
                    ),
                    SizedBox(height: 16),
                    _buildInfoTile(
                      'Meditation Experience',
                      profile.meditationExperience ?? 'Not specified',
                    ),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 40, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool isEditing = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? '$label cannot be empty' : null,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildChipsList(String label, List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Chip(
          label: Text(item),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        );
      }).toList(),
    );
  }
}
