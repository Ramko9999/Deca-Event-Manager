//used to get text size
class Sizer {
  //pixel 2 width and height
  static const double pW = 411.42857142857144;
  static const double pH = 683.4285714285714;

  //grabs the text size
  static double getTextSize(double w, double h, double s) {
    return s * w / pW;
  }
}
