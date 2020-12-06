import 'dart:html';
import 'package:ninja/ninja.dart';
import 'dart:typed_data';
import 'package:validators/validators.dart';

// Clipboard feature
// Article

void main() {
  String fdp = '';
  var generateButton = document.querySelector('#generateButton');
  generateButton.addEventListener('click', (e) {
    try {
      // unfocus the button
      focusField();
      String email = extractData('emailField');
      String domain = extractData('domainField');
      String masterPassword = extractData('masterPasswordField');
      String id = extractData('idField');
      if (!validate(email, domain, masterPassword, id)) {
        throw Exception('INVALID INPUT');
      }
      fdp = generateFDP(email, domain, id, masterPassword);
      setOutput(fdp);
    } catch (e) {
    }
  });
  Element copyButton = document.querySelector('.outputArea button');
  copyButton.addEventListener('click', (event) {
    _copyToClipboardHack(fdp);
    focusField();
  });
}

bool validate(String email, String domain, String masterPassword, String id) {
  String errorString = '';
  if (int.tryParse(id) == null) {
    errorString = 'ID should be a number';
  }
  if ((email + domain + id + masterPassword).contains('#')) {
    errorString = 'Hash Symbol(#) is not allowed';
  }
  if (!isEmail(email)) {
    errorString = 'Its not a valid Email';
  }
  if (!isDomain(domain)) {
    errorString = 'Its not a valid Domain';
  }
  if (email == '' || domain == '' || masterPassword == '' || id == '') {
    errorString = 'It cant be empty';
  }
  if (masterPassword.length > 32) {
    errorString = 'Master Password cant be longer than 32 characters';
  }

  if (errorString != '') {
    window.alert(errorString);
  }
  return errorString == '';
}

String generateFDP(String email, String domain, String id, String masterPass) {
  while (masterPass.length != 16 &&
      masterPass.length != 24 &&
      masterPass.length != 32) {
    masterPass += '#';
  }
  // www.twitter.com#dabotguy@gmail.com#id
  return aesEncrypt('$email#$domain#$id', masterPass);
}

String aesEncrypt(String message, String keyString) {
  final aes = AESKey(Uint8List.fromList(keyString.codeUnits));
  String encoded = aes.encryptToBase64(message);
  return encoded;
}

// DOM functions
void setOutput(text) {
  document.getElementById('output').innerText = text;
}

String extractData(id) {
  InputElementBase input = document.querySelector('#${id}');
  return input.value;
}

// Validator

bool isDomain(String input) {
  bool isDomainBool = RegExp(
          r'^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9-_]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$')
      .hasMatch(input);
  return isDomainBool;
}

// Unfocus

void focusField() {
  Element field = querySelector('input');
  field.focus();
}

// Copy

bool _copyToClipboardHack(String text) {
  final textarea = new TextAreaElement();
  document.body.append(textarea);
  textarea.style.border = '0';
  textarea.style.margin = '0';
  textarea.style.padding = '0';
  textarea.style.opacity = '0';
  textarea.style.position = 'absolute';
  textarea.readOnly = true;
  textarea.value = text;
  textarea.select();
  final result = document.execCommand('copy');
  textarea.remove();
  return result;
}