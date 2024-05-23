import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Widget/UserPost.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/globals/globals.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  var searchController = TextEditingController();
  List<QueryDocumentSnapshot<Object?>> searchResults = [];
  QuerySnapshot<Map<String, dynamic>>? snapshot;
  bool catogaryPannel = false;
  bool isSearching = false;
  String selectedValue = "";

  @override
  initState() {
    super.initState();
    setData();
  }

  @override
  void dispose() {
    categories = [];
    super.dispose();
  }

  Future<void> setData() async {
    await FirebaseFirestore.instance.collection("Category").get().then((value) {
      List<String> cat = [];
      for (var doc in value.docs) {
        var data = doc.data();
        cat.add(data['type']);
      }
      setState(() {
        categories = cat;
      });
    });
  }

  void toggle() {
    setState(() {
      catogaryPannel = !catogaryPannel;
      if (catogaryPannel == true) {
        selectedValue = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "Assets/Images/icon.png",
        ),
        title: const Text("Explore"),
        backgroundColor: Colors.grey.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            customTextfield(
                controller: searchController,
                label: "Search By Title",
                onChanged: (value) {
                  print(value);
                  searchByPartialTitle(value);
                },
                leading: const Icon(Icons.search),
                trailing: IconButton(
                    onPressed: toggle, icon: const Icon(Icons.filter_list))),
            const SizedBox(
              height: 20,
            ),
            if (catogaryPannel)
              Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < categories.length; i++)
                        RadioListTile(
                          title: Text(categories[i]),
                          value: categories[i],
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        )
                    ],
                  )),
            if (catogaryPannel && selectedValue != "")
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "$selectedValue :",
                    style: style.copyWith(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            isSearching
                ? Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Search Reasults : ",
                            style: style,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: (searchResults.isNotEmpty)
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  String id = searchResults[index].id;
                                  Map<String, dynamic> post =
                                      searchResults[index].data()
                                          as Map<String, dynamic>;
                                  return UserPost(
                                    data: post,
                                    id: id,
                                  );
                                },
                              )
                            : Text(
                                "Post Not Found",
                                style: style.copyWith(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            if (isSearching == false || selectedValue == "")
              StreamBuilder(
                  stream: (selectedValue != "")
                      ? FirebaseFirestore.instance
                          .collection("Post")
                          .where("category", isEqualTo: selectedValue)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection("Post")
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index].data();
                                String id = snapshot.data!.docs[index].id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: UserPost(
                                    data: data,
                                    id: id,
                                  ),
                                );
                              }),
                        );
                      } else {
                        return const Text("No Data");
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    } else {
                      print("Connection state is not active!");
                      return const Center(
                        child: Text(
                          "No data !!",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                  }),
          ],
        ),
      ),
    );
  }

  void searchByPartialTitle(String searchText) async {
    if (searchText == '') {
      setState(() {
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = true;
      });
    }
    String searchLowerCase = searchText.toLowerCase();

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Post').get();

    var searchResult = querySnapshot.docs.where((doc) {
      String titleLowerCase = doc['title'].toString().toLowerCase();

      return titleLowerCase.contains(searchLowerCase);
    }).toList();
    setState(() {
      searchResults = searchResult;
    });
  }
}
