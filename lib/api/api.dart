const apiBaseUrl = "http://91.99.143.187:1386";
const url = apiBaseUrl;

Uri buildApiUri(String endpoint, {Map<String, dynamic>? queryParameters}) {
  return Uri.parse('$apiBaseUrl$endpoint').replace(
    queryParameters: queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    ),
  );
}
