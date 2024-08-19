import 'dart:convert';

import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/flutter_flow_swipeable_stack.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:diary_cli/components/main_card.dart';
import 'package:diary_cli/entity/Item.dart';
import 'package:diary_cli/userpage/flutter_flow_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:carousel_slider/carousel_slider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageModel _model;
  late Future<List<Item>> futureItems;
  int itemNum = 0;
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    futureItems = fetchAllItems(1, 10);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<List<Item>> fetchAllItems(int current, int pageSize) async {
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/item/$current/$pageSize');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  Future<void> addToCart(String itemId, String userId, double price) async {
    print('itemId: $itemId, userId: $userId, price: $price');
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/shoppingCart/addToShoppingCart');
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              width: MediaQuery.of(context).size.width,
              height: 250.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30.0),
                ),
              ),
              child: CarouselSlider(
                items: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://ice.frostsky.com/2024/08/19/d73c2bc3a4232e9b466d028b8d0af6d2.jpeg',
                      width: 300.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://ice.frostsky.com/2024/08/19/fdc048bb8bbbd4dd6efc4b413d66769b.jpeg',
                      width: 300.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://ice.frostsky.com/2024/08/19/b999032f05583a1d595a4441e1e45f32.jpeg',
                      width: 300.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://ice.frostsky.com/2024/08/19/f82bff9bcb5e1f74294f29bf5aa7ef7d.jpeg',
                      width: 300.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                carouselController: _model.carouselController ??=
                    CarouselController(),
                options: CarouselOptions(
                  initialPage: 3,
                  viewportFraction: 0.5,
                  disableCenter: false,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.25,
                  enableInfiniteScroll: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayInterval: Duration(milliseconds: (800 + 4000)),
                  autoPlayCurve: Curves.linear,
                  pauseAutoPlayInFiniteScroll: true,
                  onPageChanged: (index, _) =>
                      _model.carouselCurrentIndex = index,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          FutureBuilder(
            future: futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('查询失败: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: const Center(child: Text('没有数据')),
                );
              } else {
                final items = snapshot.data!;
                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0), // 添加左右间距
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 每行两个元素
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75, // 调整子项的宽高比
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // final item = items[index];
                        return MainCard(
                          itemId: items[index].itemId,
                          itemName: items[index].itemName,
                          onPressed: () {
                            addToCart(
                                items[index].itemId,
                                SharedPre.getUserId().toString(),
                                items[index].price);
                          },
                          price: items[index].price,
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
