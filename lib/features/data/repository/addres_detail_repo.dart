import 'package:dio/dio.dart';
import '../models/address_detail_model.dart';
import '../models/app_lat_long.dart';

class AddressDetailRepository{
  @override
  Future<AddressDetailModel?> getAddressDetail(AppLatLong latLong) async{
    String mapApiKey = "7e254a83-f152-4733-9da2-b81d9510c175";

    try{
      Map<String,String> queryParams = {
        'apikey': mapApiKey,
        'geocode': '${latLong.long},${latLong.lat}',
        'lang': 'uz',
        'format': 'json',
        'results': '1',
      };
      Dio yandexDio = Dio();
      var response = await yandexDio.get(
        "https://geocode-maps.yandex.ru/1.x/",
        queryParameters: queryParams,
      );


      return AddressDetailModel.fromJson(response.data);
    }catch(e){
      print("Error $e");
    }
    return null;
  }
}