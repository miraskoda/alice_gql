// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_transform_link/gql_transform_link.dart';

import 'http_link.dart';

class HttpAuthLink extends Link {
  HttpAuthLink({
    required this.getToken,
    required this.graphQLEndpoint,
  });

  final String graphQLEndpoint;
  final Future<String?> Function() getToken;
  late Link _link;
  late String? _token;

  Future<void> updateToken() async => _token = await getToken();

  Request transformRequest(Request request) {
    if (kDebugMode) {
      print('TRANSFORM Request with token: Bearer $_token');
    }
    return request.updateContextEntry<HttpLinkHeaders>(
      (headers) => HttpLinkHeaders(
        headers: <String, String>{
          ...headers?.headers ?? <String, String>{},
          'Authorization': _token != null ? 'Bearer $_token' : '',
        },
      ),
    );
  }

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    await updateToken();
    _link = Link.from([
      TransformLink(
        requestTransformer: transformRequest,
        responseTransformer: (resp) {
          return resp;
        },
      ),
    ]);
    yield* _link.concat(HttpLink(graphQLEndpoint)).request(request, forward);
  }
}
