import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../../home/screens/home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? gender;
  List<String> goals = [];
  List<String> causes = [];
  String? stressFrequency;
  String? healthyEating;
  String? meditationExperience;
  String? sleepQuality;
  String? happinessLevel;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> stressFrequencyOptions = [
    'Almost daily',
    'A few times a week',
    'A few times a month',
    'Rarely',
    'Never',
  ];
  final List<String> healthyEatingOptions = [
    'Always',
    'Most of the time',
    'Sometimes',
    'Rarely',
    'Never',
  ];
  final List<String> meditationExperienceOptions = ['Yes', 'No'];
  final List<String> sleepQualityOptions = [
    'Very good',
    'Good',
    'Average',
    'Poor',
    'Very poor',
  ];
  final List<String> happinessLevelOptions = [
    'Very happy',
    'Happy',
    'Neutral',
    'Unhappy',
    'Very unhappy',
  ];
  final List<String> goalsOptions = [
    'Manage anxiety',
    'Reduce stress',
    'Improve mood',
    'Improve sleep',
    'Enhance relationships',
  ];
  final List<String> causesOptions = [
    'Work/school',
    'Relationships',
    'Finances',
    'Health',
    'Other',
  ];

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<UserProfileProvider>().saveUserProfile(
          name: nameController.text,
          age: int.parse(ageController.text),
          gender: gender,
          goals: goals,
          causes: causes,
          stressFrequency: stressFrequency,
          healthyEating: healthyEating,
          meditationExperience: meditationExperience,
          sleepQuality: sleepQuality,
          happinessLevel: happinessLevel,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        String errorMessage = 'Error saving profile';
        if (e.toString().contains('unable to start connection')) {
          errorMessage =
              'Unable to connect to the server. Please check your internet connection and try again.';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please try logging in again.';
        } else if (e.toString().contains('not-authenticated')) {
          errorMessage =
              'You are not authenticated. Please try logging in again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tell us about yourself',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: userProfileProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('What should we call you?', nameController),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      'What is your gender?',
                      genderOptions,
                      (value) => setState(() => gender = value),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'How old are you?',
                      ageController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildMultiSelectField(
                      'What are your main goals?',
                      goalsOptions,
                      goals,
                    ),
                    const SizedBox(height: 20),
                    _buildMultiSelectField(
                      'What causes your mental health issues?',
                      causesOptions,
                      causes,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      'How often do you feel stressed?',
                      stressFrequencyOptions,
                      (value) => setState(() => stressFrequency = value),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      'Do you eat healthy?',
                      healthyEatingOptions,
                      (value) => setState(() => healthyEating = value),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      'Have you tried meditation before?',
                      meditationExperienceOptions,
                      (value) => setState(() => meditationExperience = value),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      'How would you rate your sleep quality?',
                      sleepQualityOptions,
                      (value) => setState(() => sleepQuality = value),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      'How happy are you?',
                      happinessLevelOptions,
                      (value) => setState(() => happinessLevel = value),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: userProfileProvider.isLoading
                              ? null
                              : _saveData,
                          child: userProfileProvider.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9EB567),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                              vertical: 12.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          (value == null || value.isEmpty) ? '$label cannot be empty' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: options
          .map(
            (String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          (value == null || value.isEmpty) ? '$label cannot be empty' : null,
    );
  }

  Widget _buildMultiSelectField(
    String label,
    List<String> options,
    List<String> selectedValues,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: options.map((String option) {
            return FilterChip(
              label: Text(option),
              selected: selectedValues.contains(option),
              onSelected: (bool selected) {
                setState(() {
                  selected
                      ? selectedValues.add(option)
                      : selectedValues.remove(option);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
