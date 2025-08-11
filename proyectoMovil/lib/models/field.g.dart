// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
  fieldId: (json['fieldId'] as num).toInt(),
  companyId: (json['companyId'] as num).toInt(),
  fieldName: json['fieldName'] as String,
  fieldType: json['fieldType'] as String,
  fieldSize: json['fieldSize'] as String,
  fieldMaxCapacity: (json['fieldMaxCapacity'] as num?)?.toInt(),
  fieldHourPrice: (json['fieldHourPrice'] as num).toDouble(),
  fieldDescription: json['fieldDescription'] as String,
  fieldImg: json['fieldImg'] as String?,
  fieldCalification: (json['fieldCalification'] as num?)?.toDouble(),
  fieldDelete: json['fieldDelete'] as bool,
);

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
  'fieldId': instance.fieldId,
  'companyId': instance.companyId,
  'fieldName': instance.fieldName,
  'fieldType': instance.fieldType,
  'fieldSize': instance.fieldSize,
  'fieldMaxCapacity': instance.fieldMaxCapacity,
  'fieldHourPrice': instance.fieldHourPrice,
  'fieldDescription': instance.fieldDescription,
  'fieldImg': instance.fieldImg,
  'fieldCalification': instance.fieldCalification,
  'fieldDelete': instance.fieldDelete,
};
