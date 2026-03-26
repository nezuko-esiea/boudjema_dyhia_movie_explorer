// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
  (json['id'] as num).toInt(),
  json['original_language'] as String,
  json['original_title'] as String,
  json['overview'] as String,
  json['poster_path'] as String?,
  json['release_date'] as String,
);

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
  'id': instance.id,
  'original_language': instance.originalLanguage,
  'original_title': instance.originalTitle,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'release_date': instance.releaseDate,
};
