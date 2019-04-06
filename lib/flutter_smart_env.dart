library flutter_smart_env;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:meta/meta.dart';

class SmartEnv {
  static final SmartEnv _singleton = new SmartEnv._internal();

  Map<String, Object> _variables = {};
  bool _isInit = false;

  _isInitWarning() {
    if (!_isInit) {
      throw Exception('SmartEnv does not initialized, run init() for fix it');
    }
  }

  // validate smart-env payload
  bool _validateSmartEnvPayload(Map<String, dynamic> data) {
    if (!data.containsKey('version')) return false;
    if (data['version'].runtimeType != String) return false;

    if (!data.containsKey('variables')) return false;

    Map<String, dynamic> vars = data['variables'];

    for (final item in vars.values) {
      if (!item.containsKey('value') || !item.containsKey('type')) return false;
      var type = item['type'] as String;
      var value = item['value'] as dynamic;
      switch (type) {
        case 'string':
          if (value == null) return false;
          if (value.runtimeType != String) return false;
          break;
        case 'number':
          if (value == null) return false;
          if (value.runtimeType != int) return false;
          break;
        case 'float':
          if (value == null) return false;
          if (value.runtimeType != double) return false;
          break;
        case 'boolean':
          if (value == null) return false;
          if (value.runtimeType != bool) return false;
          break;
      }
    }

    return true;
  }

  @visibleForTesting
  validateInitData(Map<String, dynamic> data) {
    if (_validateSmartEnvPayload(data) == true) {
      _variables = data['variables'];
      _isInit = true;
    } else {
      _isInit = false;
      _variables = {};
      throw Exception('Wrong payload, run smart-env for generate config');
    }
  }

  // init smart-env
  init({String assetName = 'assets/smart-env.vars.json'}) async {
    try {
      var jsonStr = await rootBundle.loadString(assetName);
      Map<String, dynamic> json = jsonDecode(jsonStr);
      validateInitData(json);
    } catch (e) {
      throw Exception(e);
    }
  }

  dynamic _castToType(String name, String type) {
    _isInitWarning();
    try {
      if (hasVariable(name)) {
        Map<String, dynamic> variable = _variables[name];
        switch (type) {
          case 'int':
            return variable['value'] as int;
          case 'string':
            return variable['value'] as String;
          case 'double':
            return variable['value'] as double;
          case 'bool':
            return variable['value'] as bool;
        }
      } else {
        throw Exception('$name variable doesn\'t exist');
      }
    } catch (e) {
      throw Exception('$name is not cast to $type');
    }
    return null;
  }

  // get int value
  int intVariable(String name) {
    return _castToType(name, 'int');
  }

  //get bool value
  bool boolVariable(String name) {
    return _castToType(name, 'bool');
  }

  // get string value
  String stringVariable(String name) {
    return _castToType(name, 'string');
  }

  // get double value
  double doubleVariable(String name) {
    return _castToType(name, 'double');
  }

  // has exist variable by name
  bool hasVariable(String name) {
    _isInitWarning();
    return _variables.containsKey(name);
  }

  // get raw values
  @visibleForTesting
  Map<String, Object> variables() {
    _isInitWarning();
    return _variables;
  }

  factory SmartEnv() {
    return _singleton;
  }

  SmartEnv._internal();
}
