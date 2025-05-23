import 'package:flutter/material.dart';
import 'package:pet_track/components/app_bar.dart';
import 'package:pet_track/components/map.dart';
import 'package:pet_track/components/nav_bar.dart';
import 'package:pet_track/screens/calendar_screen.dart';
import 'package:pet_track/screens/pet_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:pet_track/screens/profile_screen.dart';
import 'dart:convert';

import 'package:pet_track/services/user_service.dart';

const runUrl = 'get-pets-958615888221.europe-southwest1.run.app';

Future<http.Response?> callCloudFunction({
  required String functionName,
  required String? firebaseIdToken,
  Map<String, dynamic>? data,
  String method = 'GET',
}) async {
  final uri = Uri.https(
    runUrl,
    '/$functionName',
    method == 'GET' ? data?.map((k, v) => MapEntry(k, v.toString())) : null,
  );

  if (method == 'GET') {
    return await http.get(uri);
  } else {
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data ?? {}),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;

  final _pages = const [
    PetListScreen(),
    CalendarScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarWidget(height: screenHeight * 0.1),
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: NavBar(
          currentIndex: _index,
          onTap: (i) async {
            if (i == 0) {
              //   final response = await callCloudFunction(
              //     functionName: 'get-pets',
              //     firebaseIdToken: null,
              //   );
              //   if (response != null && response.statusCode == 200) {
              //     print('Mascotes: ${response.body}');
              //   } else {
              //     print(
              //       'Error carregant mascotes: ${response?.statusCode} ${response?.body}',
              //     );
              //   }
              // }
              print(userData);
            }
            setState(() => _index = i);
          },
        ),
      ),
    );
  }
}
