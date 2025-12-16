// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
      uid: json['uid'] as String?,
      placeImage: (json['placeImage'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      userImage: json['userImage'] as String?,
      placeInfo: json['placeInfo'] as String,
      placeName: json['placeName'] as String,
      address: json['address'] as String,
      id: json['id'] as String?,
      type: json['type'] as String,
      source: json['source'] as String,
      time: (json['time'] as num).toInt(),
      phoneNumber: (json['phoneNumber'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      price: json['price'] as String,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      liked:
          (json['liked'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      saved:
          (json['saved'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'placeImage': instance.placeImage,
      'userImage': instance.userImage,
      'placeInfo': instance.placeInfo,
      'placeName': instance.placeName,
      'address': instance.address,
      'id': instance.id,
      'type': instance.type,
      'source': instance.source,
      'time': instance.time,
      'phoneNumber': instance.phoneNumber,
      'price': instance.price,
      'comments': instance.comments,
      'liked': instance.liked,
      'saved': instance.saved,
      'likeCount': instance.likeCount,
      'lat': instance.lat,
      'lon': instance.lon,
    };
