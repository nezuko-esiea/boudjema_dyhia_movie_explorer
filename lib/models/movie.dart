import 'package:json_annotation/json_annotation.dart';
part 'movie.g.dart';


@JsonSerializable()

class Movie {

  final int id;
  @JsonKey(name: 'original_language')
  final String originalLanguage;

  @JsonKey(name: 'original_title')
  final String originalTitle;

  final String overview;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'release_date')
  final String releaseDate;

  Movie(this.id, this.originalLanguage, this.originalTitle, this.overview, this.posterPath, this.releaseDate);
  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
