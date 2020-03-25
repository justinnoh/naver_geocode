import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const GEO_URL = 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode';
const REVERSE_GEO_URL = 'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';

class NaverGeoBloc with ChangeNotifier
{
  List<Addresses> _addressList; //검색하면 결과를 받는 array
  Map<String, String> header; //http 헤더
  String _chagnedAddress; // 좌표로 검색하여 얻은 주소

  //생성자에 헤더 및 list 초기화
  NaverGeoBloc({String clientId, String clientSecret}){
    header = {
      'X-NCP-APIGW-API-KEY-ID' : clientId,
      'X-NCP-APIGW-API-KEY' : clientSecret
    };
    _addressList = [];
    _chagnedAddress = "";
    notifyListeners();
  }
  //주소 검색해서 얻은 결과들 list
  List<Addresses> getAddressList() => _addressList;

  ///좌표->주소
  String getChangedAddress() => _chagnedAddress;

  ///주소 검색
  void searchAddress({String keyword}) async {
    if(keyword==null || keyword.length == 0) return;
    var response = await http.get(Uri.encodeFull(GEO_URL+"?query=${keyword}")
        , headers: header);
    if(response.statusCode == 200){
      dynamic jsonObj = json.decode(response.body);
      String status = jsonObj['status'];

      Meta meta = jsonObj['meta'] != null ? new Meta.fromJson(jsonObj['meta']) : null;
      if (jsonObj['addresses'] != null) {
        _addressList = new List<Addresses>();
        jsonObj['addresses'].forEach((dynamic v) {
          _addressList.add(new Addresses.fromJson(v));
        });
      }
      String errorMessage = jsonObj['errorMessage'];
      if(status != "OK"){
        print("error Message=${errorMessage}");
      }else{
        print("${_addressList.length} address found!");
      }

    }else{
      print(response.body);
    }
    //변경 된 사항 알리기
    notifyListeners();
  }
  //좌표로 주소 얻기
  void reverseGeocoder({double latitude, double longitude }) async{
    List<Results> resultList;
    if(latitude == 0 || longitude == 0) return;
    print("${latitude},${longitude}");
    var response = await http.get(Uri.encodeFull(REVERSE_GEO_URL+"?coords=${longitude},${latitude}&output=json&orders=roadaddr")
        , headers: header);
    if(response.statusCode == 200){
      dynamic jsonObj = json.decode(response.body);
      Status status =
      jsonObj['status'] != null ? new Status.fromJson(jsonObj['status']) : null;
      if (jsonObj['results'] != null) {
        resultList = new List<Results>();
        jsonObj['results'].forEach((dynamic v) {
          resultList.add(new Results.fromJson(v));
        });
        if(resultList.length>0){
          _chagnedAddress = "";
          Region tempRegion = resultList[0].region;
          if(tempRegion!=null){
            Area1 a1 = tempRegion.area1;
            if(a1!=null){
              _chagnedAddress+= "${a1.name} ";
            }
            Area0 a2 = tempRegion.area2;
            if(a2!=null){
              _chagnedAddress+= "${a2.name} ";
            }
            Area0 a3 = tempRegion.area3;
            if(a3!=null){
              _chagnedAddress+= "${a3.name} ";
            }
            Area0 a4 = tempRegion.area4;
            if(a4!=null){
              _chagnedAddress+= "${a4.name} ";
            }
          }
          Land tempLand = resultList[0].land;
          if(tempLand!=null){
            _chagnedAddress+= "${tempLand.name} ";
            if(tempLand.number1!=null){
              _chagnedAddress+= "${tempLand.number1} ";
            }
          }

          if(_chagnedAddress.length>1){
            _chagnedAddress = _chagnedAddress.substring(0, _chagnedAddress.length -1);
          }
          print(_chagnedAddress);

        }
      }else{
        print(status.toString());
      }

    }else{
      print(response.body);
    }

    notifyListeners();
  }

}


//여기서부터는 json paring을 위한 DATA class
class Meta {
  int totalCount;
  int page;
  int count;

  Meta({this.totalCount, this.page, this.count});

  Meta.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    page = json['page'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    data['page'] = this.page;
    data['count'] = this.count;
    return data;
  }
}

class Addresses {
  String roadAddress;
  String jibunAddress;
  String englishAddress;
  List<AddressElements> addressElements;
  String x;
  String y;
  double distance;

  Addresses(
      {this.roadAddress,
        this.jibunAddress,
        this.englishAddress,
        this.addressElements,
        this.x,
        this.y,
        this.distance});

  Addresses.fromJson(Map<String, dynamic> json) {
    roadAddress = json['roadAddress'];
    jibunAddress = json['jibunAddress'];
    englishAddress = json['englishAddress'];
    if (json['addressElements'] != null) {
      addressElements = new List<AddressElements>();
      json['addressElements'].forEach((dynamic v) {
        addressElements.add(new AddressElements.fromJson(v));
      });
    }
    x = json['x'];
    y = json['y'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roadAddress'] = this.roadAddress;
    data['jibunAddress'] = this.jibunAddress;
    data['englishAddress'] = this.englishAddress;
    if (this.addressElements != null) {
      data['addressElements'] =
          this.addressElements.map((v) => v.toJson()).toList();
    }
    data['x'] = this.x;
    data['y'] = this.y;
    data['distance'] = this.distance;
    return data;
  }
}

class AddressElements {
  List<String> types;
  String longName;
  String shortName;
  String code;

  AddressElements({this.types, this.longName, this.shortName, this.code});

  AddressElements.fromJson(Map<String, dynamic> json) {
    types = json['types'].cast<String>();
    longName = json['longName'];
    shortName = json['shortName'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['types'] = this.types;
    data['longName'] = this.longName;
    data['shortName'] = this.shortName;
    data['code'] = this.code;
    return data;
  }
}


class Status {
  int code;
  String name;
  String message;

  Status({this.code, this.name, this.message});

  Status.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['message'] = this.message;
    return data;
  }
}

class Results {
  String name;
  Code code;
  Region region;
  Land land;

  Results({this.name, this.code, this.region, this.land});

  Results.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'] != null ? new Code.fromJson(json['code']) : null;
    region =
    json['region'] != null ? new Region.fromJson(json['region']) : null;
    land = json['land'] != null ? new Land.fromJson(json['land']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.code != null) {
      data['code'] = this.code.toJson();
    }
    if (this.region != null) {
      data['region'] = this.region.toJson();
    }
    if (this.land != null) {
      data['land'] = this.land.toJson();
    }
    return data;
  }
}

class Code {
  String id;
  String type;
  String mappingId;

  Code({this.id, this.type, this.mappingId});

  Code.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    mappingId = json['mappingId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['mappingId'] = this.mappingId;
    return data;
  }
}

class Region {
  Area0 area0;
  Area1 area1;
  Area0 area2;
  Area0 area3;
  Area0 area4;

  Region({this.area0, this.area1, this.area2, this.area3, this.area4});

  Region.fromJson(Map<String, dynamic> json) {
    area0 = json['area0'] != null ? new Area0.fromJson(json['area0']) : null;
    area1 = json['area1'] != null ? new Area1.fromJson(json['area1']) : null;
    area2 = json['area2'] != null ? new Area0.fromJson(json['area2']) : null;
    area3 = json['area3'] != null ? new Area0.fromJson(json['area3']) : null;
    area4 = json['area4'] != null ? new Area0.fromJson(json['area4']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.area0 != null) {
      data['area0'] = this.area0.toJson();
    }
    if (this.area1 != null) {
      data['area1'] = this.area1.toJson();
    }
    if (this.area2 != null) {
      data['area2'] = this.area2.toJson();
    }
    if (this.area3 != null) {
      data['area3'] = this.area3.toJson();
    }
    if (this.area4 != null) {
      data['area4'] = this.area4.toJson();
    }
    return data;
  }
}

class Area0 {
  String name;
  Coords coords;

  Area0({this.name, this.coords});

  Area0.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    coords =
    json['coords'] != null ? new Coords.fromJson(json['coords']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.coords != null) {
      data['coords'] = this.coords.toJson();
    }
    return data;
  }
}

class Coords {
  Center center;

  Coords({this.center});

  Coords.fromJson(Map<String, dynamic> json) {
    center =
    json['center'] != null ? new Center.fromJson(json['center']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.center != null) {
      data['center'] = this.center.toJson();
    }
    return data;
  }
}

class Center {
  String crs;
  double x;
  double y;

  Center({this.crs, this.x, this.y});

  Center.fromJson(Map<String, dynamic> json) {
    crs = json['crs'];
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['crs'] = this.crs;
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}

class Area1 {
  String name;
  Coords coords;
  String alias;

  Area1({this.name, this.coords, this.alias});

  Area1.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    coords =
    json['coords'] != null ? new Coords.fromJson(json['coords']) : null;
    alias = json['alias'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.coords != null) {
      data['coords'] = this.coords.toJson();
    }
    data['alias'] = this.alias;
    return data;
  }
}


class Land {
  String type;
  String number1;
  String number2;
  Addition0 addition0;
  Addition0 addition1;
  Addition0 addition2;
  Addition0 addition3;
  Addition0 addition4;
  String name;
  Coords coords;

  Land(
      {this.type,
        this.number1,
        this.number2,
        this.addition0,
        this.addition1,
        this.addition2,
        this.addition3,
        this.addition4,
        this.name,
        this.coords});

  Land.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    number1 = json['number1'];
    number2 = json['number2'];
    addition0 = json['addition0'] != null
        ? new Addition0.fromJson(json['addition0'])
        : null;
    addition1 = json['addition1'] != null
        ? new Addition0.fromJson(json['addition1'])
        : null;
    addition2 = json['addition2'] != null
        ? new Addition0.fromJson(json['addition2'])
        : null;
    addition3 = json['addition3'] != null
        ? new Addition0.fromJson(json['addition3'])
        : null;
    addition4 = json['addition4'] != null
        ? new Addition0.fromJson(json['addition4'])
        : null;
    name = json['name'];
    coords =
    json['coords'] != null ? new Coords.fromJson(json['coords']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['number1'] = this.number1;
    data['number2'] = this.number2;
    if (this.addition0 != null) {
      data['addition0'] = this.addition0.toJson();
    }
    if (this.addition1 != null) {
      data['addition1'] = this.addition1.toJson();
    }
    if (this.addition2 != null) {
      data['addition2'] = this.addition2.toJson();
    }
    if (this.addition3 != null) {
      data['addition3'] = this.addition3.toJson();
    }
    if (this.addition4 != null) {
      data['addition4'] = this.addition4.toJson();
    }
    data['name'] = this.name;
    if (this.coords != null) {
      data['coords'] = this.coords.toJson();
    }
    return data;
  }
}

class Addition0 {
  String type;
  String value;

  Addition0({this.type, this.value});

  Addition0.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}