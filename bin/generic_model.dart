import 'dart:mirrors';

class GenericModel<T> {
  final ClassMirror classMirror;

  GenericModel(Type type) : classMirror = reflectClass(type);

  T fromMap(Map<String, dynamic> map) {
    var instance = classMirror.newInstance(Symbol(''), []);
    map.forEach((key, value) {
      var fieldName = Symbol(key);
      if (classMirror.declarations.containsKey(fieldName)) {
        var field = classMirror.declarations[fieldName] as VariableMirror;
        if (!field.isFinal) {
          instance.setField(fieldName, value);
        }
      }
    });
    return instance.reflectee;
  }

  Map<String, dynamic> toMap(T instance) {
    var map = <String, dynamic>{};
    var instanceMirror = reflect(instance);
    classMirror.declarations.forEach((key, declaration) {
      if (declaration is VariableMirror && !declaration.isStatic) {
        var fieldName = MirrorSystem.getName(key);
        var fieldValue = instanceMirror.getField(key).reflectee;
        map[fieldName] = fieldValue;
      }
    });
    return map;
  }
}
