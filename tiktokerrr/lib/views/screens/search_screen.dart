import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktokerrr/controllers/search_controller.dart'
    as search_controller;
import 'package:tiktokerrr/models/user.dart';
import 'package:tiktokerrr/views/screens/profile_screen.dart';

class SearchScreen extends StatelessWidget {
  final search_controller.SearchController _searchController = Get.put(
    search_controller.SearchController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: TextFormField(
              decoration: InputDecoration(
                filled: false,
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              onFieldSubmitted: (value) => _searchController.searchUsers(value),
            ),
          ),
          body: _searchController.searchUser.isEmpty
              ? Center(
                  child: Text(
                    'Search for users',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchController.searchUser.length,
                  itemBuilder: (context, index) {
                    User user = _searchController.searchUser[index];

                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(uid: user.uid),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePhoto),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
