import 'dart:collection';
import 'dart:io';

//we can use static values in a class to hold and which do not need the context for instance, like File pointers
class Global {
  static File userDataFile;
  static LinkedList contextStack;
  static String program = "random";
}
