class ApiResponse<T> {
  final bool success;
  final T? data;
  final String error;

  const ApiResponse({this.success = false, this.data, this.error = ''});

  factory ApiResponse.parse(Map<String, dynamic> json, {T Function(dynamic json)? fromJsonT, bool user = false}) =>
      ApiResponse(
        error: json['error'] ?? '',
        success: json['success'] ?? false,
        data: fromJsonT == null ? json['data'] : fromJsonT(!user ? json['data'] : json),
      );

  factory ApiResponse.error({String error = ""}) => ApiResponse(success: false, data: null, error: error);
}

class ApiListResponse<T> {
  final bool success;
  final List<T> data;
  final Pagination pagination;

  const ApiListResponse({
    this.success = false,
    this.data = const [],
    this.pagination = const Pagination(),
  });

  factory ApiListResponse.parse(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    if (json['data'] == null) {
      return ApiListResponse(success: false, data: [], pagination: Pagination.fromJson(json['pagination']));
    }
    final list = json['data'] is List<dynamic> ? json['data'] : json['data']['rows'];
    return ApiListResponse(
      success: json['success'] ?? false,
      data: fromJsonT == null ? List<T>.from(list) : List<T>.from((list).map((x) => fromJsonT(x))),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  factory ApiListResponse.error() => ApiListResponse(success: false, data: [], pagination: Pagination());
}

class Pagination {
  final int currentCount;
  final int totalCount;
  final int offset;
  final int limit;
  final int totalPages;

  const Pagination({this.currentCount = 0, this.totalCount = 0, this.offset = 0, this.limit = 0, this.totalPages = 0});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentCount: json['currentCount'] ?? 0,
    totalCount: json['totalCount'] ?? 0,
    offset: json['offset'] ?? 0,
    limit: json['limit'] ?? 0,
    totalPages: json['totalPages'] ?? 0,
  );
}
