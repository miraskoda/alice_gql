// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../../base/constants.dart';
import '../../flows/auth/domain/storage/token_storage.dart';
import '../../flows/auth/model/jwt_token.dart';
import 'graphql_service.dart';
import 'http_auth_link.dart';

Future<GraphQlService> initGraphQLModule() async {
  await Hive.initFlutter();

  final Box<dynamic> box = await Hive.openBox('graphql');

  final HiveStore store = HiveStore(box);

  final Cache cache = Cache(store: store);

  final authLink = HttpAuthLink(
    getToken: () async {
      final TokenStorage tokenStorage = GetIt.I<TokenStorage>();
      String? accessToken = await tokenStorage.getAccessToken().onError((_, __) => null);

      if (JwtBearerToken.isExpired(accessToken)) {
        final refreshToken = await tokenStorage.getRefreshToken();
        try {
          final response = await http.post(
            Uri.parse(
              kDebugMode ? graphQlDebugUrl : graphQlReleaseUrl,
            ),
            body: jsonEncode({'query': 'mutation { refreshLogin { accessToken } }'}),
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $refreshToken',
              HttpHeaders.contentTypeHeader: 'application/json',
            },
          );
          if (response.statusCode == 200) {
            final bodyMap = jsonDecode(response.body) as Map<String, Object?>;
            final data = bodyMap['data'];
            if (bodyMap['errors'] == null && data is Map<String, Object?>) {
              final refreshLoginEntity = data['refreshLogin']! as Map<String, Object?>;
              accessToken = refreshLoginEntity['accessToken']! as String;
              await tokenStorage.save(
                accessToken: accessToken,
                refreshToken: refreshToken!,
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Refresh login error');
          }
        }
      }
      return accessToken;
    },
    graphQLEndpoint: kDebugMode ? graphQlDebugUrl : graphQlReleaseUrl,
  );

  final GraphQlService client = GraphQlService(
    cache: cache,
    link: Link.from(<Link>[
      authLink,
      // link,
    ]),
  );
  return client;
}
