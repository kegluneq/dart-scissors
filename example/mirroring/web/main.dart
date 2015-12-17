library scissors_mirroring_example.main;

import 'messages_all.dart';
import 'package:angular2/bootstrap.dart';

import 'package:scissors_mirroring_example/foo.dart';
import 'package:intl/intl.dart';
import 'dart:html';

// TODO(ochafik): add comments
main() async {
  var languageRx = new RegExp(r'\bhl=(\w+)\b');
  Intl.defaultLocale = languageRx.firstMatch(window.location.href)?.group(1) ??
      Intl.getCurrentLocale();
  await initializeMessages(Intl.getCurrentLocale());

  document.querySelector('body').dir =
      Bidi.isRtlLanguage(Intl.getCurrentLocale())
      ? 'rtl' : 'ltr';

  document.getElementById('message').innerHtml =
      messages['SomeKey'] + '<br/>';

  bootstrap(FooComponent);
}