import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_smart_env/flutter_smart_env.dart';

void main() {
  test('instance must be singleton', () {
    var ins1 = SmartEnv();
    var ins2 = SmartEnv();
    expect(identical(ins1, ins2), isTrue);
  });

  test('init check warning', () {
    const name = 'VAR_NAME';
    expect(() => SmartEnv().hasVariable(name), throwsException);
    expect(() => SmartEnv().boolVariable(name), throwsException);
    expect(() => SmartEnv().doubleVariable(name), throwsException);
    expect(() => SmartEnv().intVariable(name), throwsException);
    expect(() => SmartEnv().stringVariable(name), throwsException);
    expect(() => SmartEnv().variables(), throwsException);
    expect(() => SmartEnv().init(), throwsException);
    expect(() => SmartEnv().init(assetName: 'wrong_asset'), throwsException);
  });

  group('use cases', () {
    const intVal = 1;
    const doubleVal = 1.6;
    const strVal = 'FooBar';
    const boolVal = true;

    const intName = 'INT_VAR';
    const floatName = 'FLOAT_VAR';
    const strName = 'STR_VAR';
    const boolName = 'BOOL_VAR';

    test('case when payload is success', () {
      const notExistVarName = 'NOT_EXIST_VAR_NAME';
      const successPayload = {
        'version': '1.0',
        'variables': {
          intName: {'value': intVal, 'type': 'number'},
          floatName: {'value': doubleVal, 'type': 'float'},
          strName: {'value': strVal, 'type': 'string'},
          boolName: {'value': boolVal, 'type': 'boolean'},
        }
      };

      SmartEnv().validateInitData(successPayload);
      expect(SmartEnv().intVariable(intName), intVal);
      expect(SmartEnv().doubleVariable(floatName), doubleVal);
      expect(SmartEnv().stringVariable(strName), strVal);
      expect(SmartEnv().boolVariable(boolName), boolVal);

      expect(SmartEnv().variables(), successPayload['variables']);

      expect(() => SmartEnv().intVariable(notExistVarName), throwsException);
      expect(() => SmartEnv().doubleVariable(notExistVarName), throwsException);
      expect(() => SmartEnv().stringVariable(notExistVarName), throwsException);
      expect(() => SmartEnv().boolVariable(notExistVarName), throwsException);
    });

    test('case when payload is fail', () {
      Map<String, dynamic> payload = {};

      // missing version and variables
      expect(() => SmartEnv().validateInitData(payload), throwsException);
      payload['version'] = null;

      // version is null
      expect(() => SmartEnv().validateInitData(payload), throwsException);

      // version not string
      payload['version'] = 1.0;
      expect(() => SmartEnv().validateInitData(payload), throwsException);

      // missing variables
      payload['version'] = '1.0';
      expect(() => SmartEnv().validateInitData(payload), throwsException);

      payload['variables'] = {};
      Map<String, dynamic> variable = {};

      // variable is null
      payload['variables'] = {intName: variable};
      expect(() => SmartEnv().validateInitData(payload), throwsException);

      // variable type is null, valid value
      variable[intName] = {'value': 1};
      payload['variables'] = {intName: variable};
      expect(() => SmartEnv().validateInitData(payload), throwsException);

      // variable value is null, valid type
      variable[intName] = {'type': 'number'};
      payload['variables'] = {intName: variable};
      expect(() => SmartEnv().validateInitData(payload), throwsException);
    });
  });
}
