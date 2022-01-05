import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(GetMaterialApp(
    home: Home(),
    title: "Feeder",
  ));
}

class Home extends StatelessWidget {
  Controller controller = Get.put(Controller());
  addImage(RssItem item) {
    var url = null;
    var enclosureUrl = item.enclosure?.url;
    var thumbnails = item.media?.thumbnails;
    var thumbnailsUrl = null;
    if (thumbnails != null && thumbnails.length > 0) {
      var thumbnail = thumbnails.first;
      thumbnailsUrl = thumbnail.url;
    }
    url = enclosureUrl ?? thumbnailsUrl;

    if (url != null) {
      return Container(
        padding: EdgeInsets.all(5),
        child: Image.network(
          url.toString(),
          fit: BoxFit.contain,
        ),
        color: Colors.white,
      );
    } else
      return Container();
  }

  getRoundedLogo(String url) {
    if (url.isNotEmpty) {
      return CircleAvatar(
          radius: 20,
          backgroundColor: Colors.cyan[100],
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.network(
              url,
              height: 80.0,
              width: 80.0,
              fit: BoxFit.cover,
            ),
          ));
    } else {
      return CircleAvatar(
          radius: 20,
          backgroundColor: Colors.cyan[100],
          child: Text(controller.itemSite.substring(0, 1)));
    }
  }

  getFeedList(BuildContext context) {
    ListView.builder(
        itemCount: controller.sites.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(controller.sites.elementAt(index)),
          );
        });
  }

  @override
  Widget build(context) {
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
                  child: Center(
                    child: ListView.builder(
                        itemCount: controller.sites.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(controller.sites.elementAt(index)),
                            onTap: () {
                              controller.onItemTapped(index);
                              Navigator.pop(context);
                            },
                          );
                        }),
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
                          const Text('Information',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text(
                              'All contents belong to respective media.'),
                          const Text('News populated using RSS Feeds'),
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

      backgroundColor: Color(0xfff9f9f9),

      body: Container(
          child: Center(
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
                          log("length: " +
                              controller.feedlist.length.toString());
                          RssItem item = controller.feedlist[index];
                          log(item.title.toString());
                          /* if (index == 0) {
                            return Card(
                                color: Colors.white,
                                elevation: 0,
                                // shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                child: ListTile(
                                  title: Text(
                                    item.title.toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  subtitle: Text(
                                    DateFormat.yMMMd().format(DateTime.now()),
                                    textAlign: TextAlign.center,
                                  ),
                                ));
                          } else { */
                          return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 1,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black,
                                                width: 0.1)),
                                      ),
                                      // padding: EdgeInsets.all(12),
                                      child: ListTile(
                                          title: Text(
                                            controller.itemSite,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(item.pubDate == null
                                              ? "Some time ago"
                                              : timeago.format(DateTime.parse(
                                                  item.pubDate.toString()))),
                                          leading: getRoundedLogo(
                                              controller.itemLogo),
                                          trailing: IconButton(
                                              onPressed: () {
                                                Share.share(
                                                    'Did you hear about this? \n' +
                                                        item.link.toString());
                                              },
                                              icon: Icon(Icons.share))),
                                    ),
                                    addImage(item),
                                    ListTile(
                                      contentPadding: EdgeInsets.all(10),
                                      title: Text(
                                        item.title.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      subtitle: Text(
                                        item.description.toString(),
                                        maxLines: 8,
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
                                    )
                                  ])));
                        },
                      ),
                    ),
                  )))),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.refresh,
          color: Colors.black,
        ),
        onPressed: controller.fetchFact,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class Controller extends GetxController {
  var fact = ''.obs;
  var selectedIndex = 0.obs;
  var factVisible = false.obs;
  var feedlist = [].obs;
  var itemUrl;
  var itemTitle;
  var itemSite = "Mathrubhumi";
  var itemLogo;
  var urls = [
    "https://www.mathrubhumi.com/cmlink/mathrubhumi-latestnews-rssfeed-1.1184486",
    "https://www.twentyfournews.com/feed",
    "https://malayalam.oneindia.com/rss/malayalam-news-fb.xml",
    "https://malayalam.filmibeat.com/rss/filmibeat-malayalam-fb.xml",
    "https://malayalam.gizbot.com/rss/news-fb.xml",
    "https://www.cnet.com/rss/news",
    "https://itsfoss.com/feed/"
  ];
  var sites = [
    "Mathrubhumi",
    "TwentyFour News",
    "OneIndia",
    "Filmibeat",
    "Gizbot",
    "CNET",
    "Its Foss"
  ];
  @override
  void onInit() {
    super.onInit();
    fetchFact();
  }

  fetchFact() async {
    factVisible.value = false;
    var response = await http.get(Uri.parse(urls[selectedIndex.value]));
    log("Response: " + response.body);
    if (response.statusCode == 200) {
      var feed = RssFeed.parse(response.body);
      log("url: " + feed.items!.first.media!.text.toString());
      feedlist.value = feed.items!;
      itemLogo = feed.image?.url ?? "";
      /*  RssItem itemSiteTitle = new RssItem(title: itemSite);
      feedlist.insert(0, itemSiteTitle); */
    }
    factVisible.value = true;
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    itemSite = sites[index];
    log("ItemSite: " + itemSite);
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