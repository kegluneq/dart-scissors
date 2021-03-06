// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
library scissors.src.css_mirroring.mirrored_entities;

import 'package:quiver/check.dart';
import 'package:csslib/visitor.dart';

import 'entity.dart';

class MirroredEntity<T extends TreeNode> {
  final MirroredEntities<T> _entities;
  final int index;
  final MirroredEntity parent;

  Entity<T> _original;
  Entity<T> flipped;

  MirroredEntity(this._entities, this.index, this.parent) {
    _original = new Entity<T>(_entities._originalSource,
        _entities._originalEntities, index, parent?._original);

    flipped = new Entity<T>(_entities._flippedSource,
        _entities._flippedEntities, index, parent?.flipped);

    checkState(_original.runtimeType == flipped.runtimeType,
        message: () => 'Mismatching entity types: '
            'original is ${_original.runtimeType}, '
            'flipped is ${flipped.runtimeType}');
  }

  bool get hasSameTextInBothVersions =>
      _original.value.span.text == flipped.value.span.text;

  bool get isDeclaration => _original.value is Declaration;
  bool get isRuleSet => _original.value is RuleSet;

  bool get isDirectionInsensitiveDirective {
    var node = _original.value;
    return node is CharsetDirective ||
        node is FontFaceDirective ||
        node is ImportDirective ||
        node is NamespaceDirective;
  }

  bool get hasNestedRuleSets {
    var node = _original.value;
    return node is MediaDirective || node is HostDirective;
  }

  MirroredEntities<dynamic> getChildren(List<dynamic> getEntityChildren(T _)) {
    return new MirroredEntities(
        _entities._originalSource,
        getEntityChildren(_original.value),
        _entities._flippedSource,
        getEntityChildren(flipped.value),
        parent: this);
  }
}

class MirroredEntities<T extends TreeNode> {
  final String _originalSource;
  final List<T> _originalEntities;

  final String _flippedSource;
  final List<T> _flippedEntities;

  final MirroredEntity parent;

  MirroredEntities(this._originalSource, this._originalEntities,
      this._flippedSource, this._flippedEntities,
      {this.parent}) {
    assert(_originalEntities.length == _flippedEntities.length);
  }

  get length => _originalEntities.length;

  void forEach(void process(MirroredEntity<T> entity)) {
    for (int i = 0; i < _originalEntities.length; i++) {
      process(new MirroredEntity<T>(this, i, parent));
    }
  }
}
