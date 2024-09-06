import 'dart:convert';

import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:diary_cli/components/main_card.dart';
import 'package:diary_cli/components/sort_card.dart';
import 'package:diary_cli/entity/Item.dart';
import 'package:diary_cli/host.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserSort extends StatefulWidget {
  @override
  _UserSortState createState() => _UserSortState();
}

class _UserSortState extends State<UserSort> {
  int selectedIndex = 0;
  String _host = Host.host;
  late Future<List<Item>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = fetchItemsBySort(selectedIndex + 1);
  }

  final List<NavigationRailDestination> navRailDestinations = destinations
      .map(
        (destination) => NavigationRailDestination(
          icon: Tooltip(
            message: destination.label,
            child: destination.icon,
          ),
          selectedIcon: Tooltip(
            message: destination.label,
            child: destination.selectedIcon,
          ),
          label: Text(destination.label),
        ),
      )
      .toList();

  Widget _buildLeftNavigation(int index) {
    return NavigationRail(
      onDestinationSelected: _onDestinationSelected,
      destinations: navRailDestinations,
      selectedIndex: index,
    );
  }

  void _onDestinationSelected(int value) {
    setState(() {
      selectedIndex = value;
      futureItems = fetchItemsBySort(selectedIndex + 1);
    });
  }

  Future<void> addToCart(String itemId, String userId, double price) async {
    print('itemId: $itemId, userId: $userId, price: $price');
    final url = Uri.parse(
        'http://$_host:4001/diary-server/shoppingCart/addToShoppingCart');
    final headers = {
      'Content-Type': 'application/json',
      'token': SharedPre.getToken().toString()
    };
    final body = json.encode({
      'itemId': itemId,
      'userId': userId,
      'price': price,
    });
    final response = await http.post(url, headers: headers, body: body);
    final responseBody = jsonDecode(response.body);
    print(responseBody);
    String text = responseBody['message'];
    if (responseBody['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加成功')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    }
  }

  Future<List<Item>> fetchItemsBySort(int sortId) async {
    final url = Uri.parse(
        'http://$_host:4001/diary-server/sort/selectItemBySortId/$sortId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'token': SharedPre.getToken().toString()
    });
    final responseBody = jsonDecode(response.body);
    print(response.body);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data'];
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: 85,
          child: IntrinsicHeight(
            child: _buildLeftNavigation(selectedIndex),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 85,
          decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground),
          child: FutureBuilder(
            future: futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('查询失败: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return SortCard(
                      itemId: snapshot.data![index].itemId,
                      itemName: snapshot.data![index].itemName,
                      onPressed: () {
                        addToCart(
                            snapshot.data![index].itemId,
                            SharedPre.getUserId().toString(),
                            snapshot.data![index].price);
                      },
                      price: snapshot.data![index].price,
                    );
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }
}

const List<NavigationDestination> destinations = [
  NavigationDestination(icon: Text('狗'), label: "狗", selectedIcon: Text('狗')),
  NavigationDestination(
    icon: Text('猫'),
    label: "猫",
    selectedIcon: Text('猫'),
  ),
  NavigationDestination(
    icon: Text('猪'),
    label: "猪",
    selectedIcon: Text('猪'),
  ),
  NavigationDestination(
    icon: Text('鸡'),
    label: "鸡",
    selectedIcon: Text('鸡'),
  ),
  NavigationDestination(
    icon: Text('鸟'),
    label: "鸟",
    selectedIcon: Text('鸟'),
  ),
];
