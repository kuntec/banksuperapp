/// name : ""
/// description : ""
/// version : "1.0.0"
/// author : ""
/// screens : []
/// actions : []
/// apis : [{"endpoint":"","method":"GET","headers":"","requestSchema":"","responseSchema":""}]

// class Jsonapi {
//   Jsonapi({
//     String? name,
//     String? description,
//     String? version,
//     String? author,
//     List<dynamic>? screens,
//     List<dynamic>? actions,
//     List<Apis>? apis,
//   }) {
//     _name = name;
//     _description = description;
//     _version = version;
//     _author = author;
//     _screens = screens;
//     _actions = actions;
//     _apis = apis;
//   }
//
//   Jsonapi.fromJson(dynamic json) {
//     _name = json['name'];
//     _description = json['description'];
//     _version = json['version'];
//     _author = json['author'];
//     if (json['screens'] != null) {
//       _screens = [];
//       json['screens'].forEach((v) {
//         _screens?.add(dynamic.fromJson(v));
//       });
//     }
//     if (json['actions'] != null) {
//       _actions = [];
//       json['actions'].forEach((v) {
//         _actions?.add(dynamic.fromJson(v));
//       });
//     }
//     if (json['apis'] != null) {
//       _apis = [];
//       json['apis'].forEach((v) {
//         _apis?.add(Apis.fromJson(v));
//       });
//     }
//   }
//   String? _name;
//   String? _description;
//   String? _version;
//   String? _author;
//   List<dynamic>? _screens;
//   List<dynamic>? _actions;
//   List<Apis>? _apis;
//   Jsonapi copyWith({
//     String? name,
//     String? description,
//     String? version,
//     String? author,
//     List<dynamic>? screens,
//     List<dynamic>? actions,
//     List<Apis>? apis,
//   }) =>
//       Jsonapi(
//         name: name ?? _name,
//         description: description ?? _description,
//         version: version ?? _version,
//         author: author ?? _author,
//         screens: screens ?? _screens,
//         actions: actions ?? _actions,
//         apis: apis ?? _apis,
//       );
//   String? get name => _name;
//   String? get description => _description;
//   String? get version => _version;
//   String? get author => _author;
//   List<dynamic>? get screens => _screens;
//   List<dynamic>? get actions => _actions;
//   List<Apis>? get apis => _apis;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['description'] = _description;
//     map['version'] = _version;
//     map['author'] = _author;
//     if (_screens != null) {
//       map['screens'] = _screens?.map((v) => v.toJson()).toList();
//     }
//     if (_actions != null) {
//       map['actions'] = _actions?.map((v) => v.toJson()).toList();
//     }
//     if (_apis != null) {
//       map['apis'] = _apis?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }
//
// /// endpoint : ""
// /// method : "GET"
// /// headers : ""
// /// requestSchema : ""
// /// responseSchema : ""
//
// class Apis {
//   Apis({
//     String? endpoint,
//     String? method,
//     String? headers,
//     String? requestSchema,
//     String? responseSchema,
//   }) {
//     _endpoint = endpoint;
//     _method = method;
//     _headers = headers;
//     _requestSchema = requestSchema;
//     _responseSchema = responseSchema;
//   }
//
//   Apis.fromJson(dynamic json) {
//     _endpoint = json['endpoint'];
//     _method = json['method'];
//     _headers = json['headers'];
//     _requestSchema = json['requestSchema'];
//     _responseSchema = json['responseSchema'];
//   }
//   String? _endpoint;
//   String? _method;
//   String? _headers;
//   String? _requestSchema;
//   String? _responseSchema;
//   Apis copyWith({
//     String? endpoint,
//     String? method,
//     String? headers,
//     String? requestSchema,
//     String? responseSchema,
//   }) =>
//       Apis(
//         endpoint: endpoint ?? _endpoint,
//         method: method ?? _method,
//         headers: headers ?? _headers,
//         requestSchema: requestSchema ?? _requestSchema,
//         responseSchema: responseSchema ?? _responseSchema,
//       );
//   String? get endpoint => _endpoint;
//   String? get method => _method;
//   String? get headers => _headers;
//   String? get requestSchema => _requestSchema;
//   String? get responseSchema => _responseSchema;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['endpoint'] = _endpoint;
//     map['method'] = _method;
//     map['headers'] = _headers;
//     map['requestSchema'] = _requestSchema;
//     map['responseSchema'] = _responseSchema;
//     return map;
//   }
// }
