naver geocoding api와 reverse geocoding api를 조금 사용하기 쉽게 bloc로 만들어 두었습니다.

bloc 생성자에 naver cloud platform에서 발급 받으신 client ID, client Secret을 넣으시고

reverseGeocoder(latitude, longitude)를 호출하면 getChangedAddress()로 변환 된 주소를 얻을 수 있고

searchAddress(keyword)를 호출하면 getAddressList()로 검색 된 주소들이 list로 전달 됩니다.

Provider를 활용하여 bloc는 ChangeNotifier를 사용하였기 때문에

UI page에서는 ChangeNotifierProvider로 등록하시면 사용 가능합니다.

제가 프로젝트 중에 필요해서 임시로 만든 bloc이기 떄문에 원하시는 형태로 바꿔서 사용하시면 됩니다.

자세한건 main.dart 파일 참조


