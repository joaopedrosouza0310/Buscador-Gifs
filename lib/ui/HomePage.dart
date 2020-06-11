import 'dart:convert';
import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search;
  int offset = 0;

  Future<Map> getGifs() async {
    http.Response response;
    if (search == null) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key= APIKEYHERE &limit=20&rating=G");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=0RmgU3N2Pl3ryScbNPtj3Lw1vOxegOVk&q=$search&limit=19&offset=$offset&rating=G&lang=en");
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offset = 0;
                });
              },
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return tabelaGifs(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int getCount(List data) {
    if (search == "" || search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget tabelaGifs(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
                onLongPress: () {
                  Share.share(snapshot.data["data"][index]["images"]
                      ["fixed_height"]["url"]);
                },
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data["data"][index])));
                },
                child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    height: 300,
                    fit: BoxFit.cover,
                    image: snapshot.data["data"][index]["images"]
                        ["fixed_height"]["url"]));
          } else {
            return Container(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    offset += 19;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}
