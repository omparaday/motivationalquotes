// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DailyData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyData _$DailyDataFromJson(Map<String, dynamic> json) => DailyData(
      json['quote'] as String,
      json['about'] as String,
      json['goodness'] as int,
    );

Map<String, dynamic> _$DailyDataToJson(DailyData instance) => <String, dynamic>{
      'quote': instance.quoteKey,
      'about': instance.about,
      'goodness': instance.goodness,
    };
