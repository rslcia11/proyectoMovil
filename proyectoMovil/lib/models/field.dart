import 'package:json_annotation/json_annotation.dart';

part 'field.g.dart'; // This file will be generated

@JsonSerializable()
class Field {
  final int fieldId;
  final int companyId;
  final String fieldName;
  final String fieldType;
  final String fieldSize;
  final int? fieldMaxCapacity;
  final double fieldHourPrice;
  final String fieldDescription;
  final String? fieldImg;
  final double? fieldCalification;
  final bool fieldDelete;

  Field({
    required this.fieldId,
    required this.companyId,
    required this.fieldName,
    required this.fieldType,
    required this.fieldSize,
    this.fieldMaxCapacity,
    required this.fieldHourPrice,
    required this.fieldDescription,
    this.fieldImg,
    this.fieldCalification,
    required this.fieldDelete,
  });

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);
  Map<String, dynamic> toJson() => _$FieldToJson(this);

  // Getter para obtener el icono según el tipo de cancha
  String get fieldIcon {
    switch (fieldType) {
      case 'Fútbol 5':
      case 'Fútbol 7':
      case 'Fútbol 11':
        return '⚽';
      case 'Basquet 3x3':
      case 'Basquet 5x5':
        return '🏀';
      case 'Tenis':
      case 'EcuaVoley':
        return '🏐';
      default:
        return '🏟️';
    }
  }

  // Getter para la calificación formateada
  String get formattedRating {
    if (fieldCalification == null) return 'Sin calificar';
    return fieldCalification!.toStringAsFixed(1);
  }

  // Getter para el precio formateado
  String get formattedPrice {
    return '\${fieldHourPrice.toStringAsFixed(2)}/hora';
  }
}