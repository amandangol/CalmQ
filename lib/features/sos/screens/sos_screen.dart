import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'National Crisis Hotline',
      'number': '988',
      'description': '24/7 Crisis Support',
    },
    {
      'name': 'Emergency Services',
      'number': '911',
      'description': 'For immediate emergency assistance',
    },
    {
      'name': 'Crisis Text Line',
      'number': '741741',
      'description': 'Text HOME to connect with a counselor',
    },
  ];

  final List<Map<String, dynamic>> _resources = [
    {
      'title': 'Grounding Techniques',
      'description': '5-4-3-2-1 Sensory Exercise',
      'steps': [
        'Name 5 things you can see',
        'Name 4 things you can touch',
        'Name 3 things you can hear',
        'Name 2 things you can smell',
        'Name 1 thing you can taste',
      ],
    },
    {
      'title': 'Quick Breathing Exercise',
      'description': 'Box Breathing Technique',
      'steps': [
        'Breathe in for 4 counts',
        'Hold for 4 counts',
        'Breathe out for 4 counts',
        'Hold for 4 counts',
        'Repeat 4 times',
      ],
    },
  ];

  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await launchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Support'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Emergency Contacts
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 16),
                ..._emergencyContacts.map(
                  (contact) => Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        contact['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      subtitle: Text(contact['description']),
                      trailing: ElevatedButton(
                        onPressed: () => _makePhoneCall(contact['number']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Call'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Crisis Resources
                Text(
                  'Crisis Resources',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 16),
                ..._resources.map(
                  (resource) => Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            resource['description'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          ...resource['steps'].map(
                            (step) => Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                  Expanded(child: Text(step)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
