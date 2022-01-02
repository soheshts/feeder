import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(GetMaterialApp(
    home: Home(),
    title: "Feeder",
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(context) {
    Controller controller = Get.put(Controller());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feeder",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          tooltip: 'Menu',
          onPressed: () {
            showModalBottomSheet<void>(
              // context and builder are
              // required properties in this widget
              context: context,
              builder: (BuildContext context) {
                // we set up a container inside which
                // we create center column and display text
                return Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Categories',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          title: Text("Mathrubhumi"),
                          onTap: () => {
                            controller.selectedIndex.value = 0,
                            Navigator.pop(context),
                            controller.fetchFact()
                          },
                        ),
                        ListTile(
                            title: Text("24News"),
                            onTap: () => {
                                  controller.selectedIndex.value = 1,
                                  Navigator.pop(context),
                                  controller.fetchFact()
                                })
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.info,
              color: Colors.black,
            ),
            tooltip: 'Info',
            onPressed: () {
              showModalBottomSheet<void>(
                // context and builder are
                // required properties in this widget
                context: context,
                builder: (BuildContext context) {
                  // we set up a container inside which
                  // we create center column and display text
                  return Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('API Used',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('http://numbersapi.com/random/trivia'),
                          const Text(
                              'https://uselessfacts.jsph.pl/random.json?language=en'),
                          const Text('Logo',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text(
                              'Made by Freepik (https://www.freepik.com)'),
                          const Text(
                              'from Flaticon (https://www.flaticon.com/)'),
                          const Text('Source',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text(
                              'Github (https://github.com/soheshts/factcat)'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
      ),
      // extendBody: true,

      backgroundColor: Colors.grey[50],

      body: Center(
          child: Obx(() => Container(
                margin: const EdgeInsets.all(20.0),
                child: Visibility(
                  visible: controller.factVisible.value,
                  replacement: CircularProgressIndicator(
                    value: null,
                  ),
                  child: ListView.builder(
                    // Let the ListView know how many items it needs to build.
                    itemCount: controller.feedlist.length,
                    // Provide a builder function. This is where the magic happens.
                    // Convert each item into a widget based on the type of item it is.
                    itemBuilder: (context, index) {
                      log("length: " + controller.feedlist.length.toString());
                      RssItem item = controller.feedlist[index];
                      log(item.title.toString());

                      return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          // elevation: 2,
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: ListTile(
                            title: Text(
                              item.title.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              item.description.toString(),
                              maxLines: 5,
                            ),
                            onTap: () async {
                              controller.itemUrl = item.link;
                              controller.itemTitle = item.title;
                              // Get.to(WebLoader());
                              await launch(
                                item.link.toString(),
                                forceWebView: true,
                                enableJavaScript: true,
                              );
                            },
                          ));
                    },
                  ),
                ),
              ))),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: controller.fetchFact,
      ),
    );
  }
}

class Controller extends GetxController {
  var fact = ''.obs;
  var selectedIndex = 0.obs;
  var factVisible = false.obs;
  var feedlist = <RssItem>[].obs;
  var itemUrl;
  var itemTitle;
  var urls = [
    "https://www.mathrubhumi.com/cmlink/mathrubhumi-latestnews-rssfeed-1.1184486",
    "https://www.twentyfournews.com/feed"
  ];
  @override
  void onInit() {
    super.onInit();
    fetchFact();
  }

  fetchFact() async {
    factVisible.value = false;
    var response = await http.get(Uri.parse(urls[selectedIndex.value]));
    log("response: " + response.body);
    if (response.statusCode == 200) {
      var feed = RssFeed.parse(response.body);
      feedlist.value = feed.items!;
      log("ItemTitle: " + feedlist.value.toString());
    }
    factVisible.value = true;
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    fetchFact();
  }
}

/* class WebLoader extends StatelessWidget {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.
  final Controller c = Get.find();
  @override
  Widget build(context) {
    // Access the updated count variable
    return Scaffold(
        appBar: AppBar(leading: BackButton(
          onPressed: () {
            Get.back();
          },
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: Text(c.itemTitle,style: TextStyle(color: Colors.black))),
        body: WebView(
          initialUrl: c.itemUrl,
        ));
  }
}
 */