import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'naver_geo_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NaverGeoBloc>(
            create: (_) =>
                NaverGeoBloc(
                    clientId: "your client id",
                    clientSecret: "your client secret"))
      ],
      child: Consumer<NaverGeoBloc>(
        builder: (context, getBloc, _) {
          return MaterialApp(
            title: 'naver geo demo',
            home: MyHomePage(title: 'naver geo demo'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final latController = TextEditingController();
  final lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NaverGeoBloc geoBloc = Provider.of<NaverGeoBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            children: <Widget>[
            Text('[좌표->주소]'),
        Row(
          children: <Widget>[
            Text('latitude'),
            Expanded(
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: latController,
              ),
            )]),
            Row(
              children: <Widget>[
                Text('longitude'),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: lonController,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                    onPressed: () {
                      geoBloc.reverseGeocoder(
                          latitude: double.parse(latController.text),
                          longitude: double.parse(lonController.text));
                    },
                    child: Text('검색')),
                Text('${geoBloc.getChangedAddress()}')
              ],
            ),
            Divider(
              height: 10,
            ),
            Text('[주소검색]'),
            TextField(
              decoration: InputDecoration(hintText: '도로명 또는 상세 주소'),
              onChanged: (value) {
                geoBloc.searchAddress(keyword: value);
              },
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: geoBloc
                      .getAddressList()
                      .length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    Addresses add = geoBloc.getAddressList()[index];
                    return ListTile(title: Text('${add.roadAddress}'));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
