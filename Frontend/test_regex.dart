// ignore_for_file: avoid_print
void main() {
  final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  print('Testing valid...');
  print(r.hasMatch('kristin.watson@example.com'));
  
  print('Testing missing dot...');
  print(r.hasMatch('kristin.watson@example'));

  print('Testing long with bad end...');
  print(r.hasMatch('test@example.com.com.com.com.com.com.com.c'));

  print('Testing missing tld...');
  print(r.hasMatch('test@example.'));

  print('Testing very long invalid...');
  // This causes catastrophic backtracking if the regex is vulnerable
  print(r.hasMatch('test@test.test.test.test.test.test.test.test.test.test'));

  print('Done');
}
