import 'dart:convert';

import 'package:gql_exec/src/request.dart' as ferry_request;
import 'package:http/http.dart' as http;

import '../model/alice_http_call.dart';
import '../model/alice_http_request.dart';
import '../model/alice_http_response.dart';
import 'alice_core.dart';

class AliceGqlAdapter {
  /// Creates alice http adapter
  AliceGqlAdapter(this.aliceCore);

  /// AliceCore instance
  final AliceCore aliceCore;

  /// Handles http response. It creates both request and response from http call
  void onResponse(
    ferry_request.Request request,
    http.Response response,
  ) {
    if (request.variables.isEmpty) {
      return;
    }

    final httpResponse = AliceHttpResponse()
      ..status = response.statusCode
      ..body = response.body
      ..size = utf8.encode(response.body).length
      ..time = DateTime.now()
      ..headers = response.headers;

    aliceCore.addResponse(httpResponse, request.hashCode);
  }

  void onRequest(
    ferry_request.Request request,
  ) {
    if (request.variables.isEmpty) {
      return;
    }
    final operationName = request.operation.operationName;

    final call = AliceHttpCall(request.hashCode)
      ..loading = true
      ..client = 'Ferry GraphQl'
      ..method =
          'gql ${(operationName?.toLowerCase().contains('set') ?? false) ? 'mutation' : 'query'} ->'
      ..endpoint = operationName ?? 'unknown'
      ..server = 'http://35.205.118.31/graphql/';

    final httpRequest = AliceHttpRequest()
      ..size = utf8.encode(request.toString()).length
      ..body = request.variables
      // TO-DO header implementation
      ..headers = <String, dynamic>{}
      ..contentType = 'graphql'
      ..time = DateTime.now()
      ..queryParameters = request.variables;

    call
      ..request = httpRequest
      ..response = AliceHttpResponse()
      ..loading = true;
    aliceCore.addCall(call);
  }
}
