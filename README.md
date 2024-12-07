# alice_graphql with graphql support

[![pub package](https://img.shields.io/pub/v/alice_graphql.svg)](https://pub.dartlang.org/packages/alice_graphql)
[![pub package](https://img.shields.io/badge/github-alice_graphql-blue?style=flat)](https://github.com/miraskoda/alice_gql)
[![pub package](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice_graphql)

alice_graphql is a fork of the original Alice package, now enhanced with support for GraphQL. <b>All you need to connect with gql client like Ferry is within example folder.</b> Connection is realized throught gql LINK chaining.

 Alice It catches and stores http requests and responses, which can be viewed via simple UI. It is inspired from [Chuck](https://github.com/jgilfelt/chuck) and [Chucker](https://github.com/ChuckerTeam/chucker).

Based on Alice 0.4.1

**Supported Dart http client plugins and graphql:**

- Dio
- gql_exec
- gql
- Ferry
- HttpClient from dart:io package
- Http from http/http package
- Chopper
- Generic HTTP client

**Features:**  
✔️ Detailed logs for each HTTP calls (HTTP Request, HTTP Response)  
✔️ Inspector UI for viewing HTTP calls  
✔️ Save HTTP calls to file  
✔️ Statistics  
✔️ Notification on HTTP call  
✔️ Support for top used HTTP clients in Dart  
✔️ Error handling  
✔️ Shake to open inspector  
✔️ HTTP calls search
✔️ Flutter/Android logs

## Install

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice_graphql: ^0.4.1
```

2. Install it

```bash
$ flutter packages get
```

3. Import it

```dart
import 'package:alice_graphql_graphql/alice_graphql.dart';
```

## Usage
### alice_graphql configuration
1. Create alice_graphql instance:

```dart
alice_graphql alice_graphql = alice_graphql();
```

2. Add navigator key to your application:

```dart
MaterialApp( navigatorKey: alice_graphql.getNavigatorKey(), home: ...)
```

You need to add this navigator key in order to show inspector UI.
You can use also your navigator key in alice_graphql:

```dart
alice_graphql alice_graphql = alice_graphql(showNotification: true, navigatorKey: yourNavigatorKeyHere);
```

If you need to pass navigatorKey lazily, you can use:
```dart
alice_graphql.setNavigatorKey(yourNavigatorKeyHere);
```
This is minimal configuration required to run alice_graphql. Can set optional settings in alice_graphql constructor, which are presented below. If you don't want to change anything, you can move to Http clients configuration.

### Additional settings

You can set `showNotification` in alice_graphql constructor to show notification. Clicking on this notification will open inspector.
```dart
alice_graphql alice_graphql = alice_graphql(..., showNotification: true);
```

You can set `showInspectorOnShake` in alice_graphql constructor to open inspector by shaking your device (default disabled):

```dart
alice_graphql alice_graphql = alice_graphql(..., showInspectorOnShake: true);
```

If you want to pass another notification icon, you can use `notificationIcon` parameter. Default value is @mipmap/ic_launcher.
```dart
alice_graphql alice_graphql = alice_graphql(..., notificationIcon: "myNotificationIconResourceName");
```

If you want to limit max numbers of HTTP calls saved in memory, you may use `maxCallsCount` parameter.

```dart
alice_graphql alice_graphql = alice_graphql(..., maxCallsCount: 1000));
```

If you want to change the Directionality of alice_graphql, you can use the `directionality` parameter. If the parameter is set to null, the Directionality of the app will be used.
```dart
alice_graphql alice_graphql = alice_graphql(..., directionality: TextDirection.ltr);
```

If you want to hide share button, you can use `showShareButton` parameter.
```dart
alice_graphql alice_graphql = alice_graphql(..., showShareButton: false);
```

### HTTP Client configuration
If you're using Dio, you just need to add interceptor.

```dart
Dio dio = Dio();
dio.interceptors.add(alice_graphql.getDioInterceptor());
```


If you're using HttpClient from dart:io package:

```dart
httpClient
	.getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
	.then((request) async {
		alice_graphql.onHttpClientRequest(request);
		var httpResponse = await request.close();
		var responseBody = await httpResponse.transform(utf8.decoder).join();
		alice_graphql.onHttpClientResponse(httpResponse, request, body: responseBody);
 });
```

If you're using http from http/http package:

```dart
http.get('https://jsonplaceholder.typicode.com/posts').then((response) {
    alice_graphql.onHttpResponse(response);
});
```

If you're using Chopper. you need to add interceptor:

```dart
chopper = ChopperClient(
    interceptors: [alice_graphql.getChopperInterceptor()],
);
```

Attention! alice_graphql will add special "alice_graphql_token" header to the request in order to calculate correct id for the http call. 

If you have other HTTP client you can use generic http call interface:
```dart
alice_graphqlHttpCall alice_graphqlHttpCall = alice_graphqlHttpCall(id);
alice_graphql.addHttpCall(alice_graphqlHttpCall);
```

## Show inspector manually

You may need that if you won't use shake or notification:

```dart
alice_graphql.showInspector();
```

## Saving calls

alice_graphql supports saving logs to your mobile device storage. In order to make save feature works, you need to add in your Android application manifest:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Flutter logs

If you want to log Flutter logs in alice_graphql, you may use these methods:

```dart
alice_graphql.addLog(log);

alice_graphql.addLogs(logList);
```


## Inspector state

Check current inspector state (opened/closed) with:

```dart
alice_graphql.isInspectorOpened();
```


## Extensions
You can use extensions to shorten your http and http client code. This is optional, but may improve your codebase.
Example:
1. Import:
```dart
import 'package:alice_graphql_graphql/core/alice_graphql_http_client_extensions.dart';
import 'package:alice_graphql_graphql/core/alice_graphql_http_extensions.dart';
```

2. Use extensions:
```dart
http
    .post('https://jsonplaceholder.typicode.com/posts', body: body)
    .interceptWithalice_graphql(alice_graphql, body: body);
```

```dart
httpClient
    .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
    .interceptWithalice_graphql(alice_graphql, body: body, headers: Map());
```


## Example
See complete example here: https://github.com/jhomlala/alice_graphql/blob/master/example/lib/main.dart
To run project, you need to call this command in your terminal:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
You need to run this command to build Chopper generated classes. You should run this command only once,
you don't need to run this command each time before running project (unless you modify something in Chopper endpoints).
