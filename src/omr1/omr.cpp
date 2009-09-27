#include <Magick++.h>
#include <iostream>
#include <fstream>
#include <list>
#include <string>

using namespace std;
using namespace Magick;

float dotsPerCm;
int neededWidthForMarks;
int neededHeightForMarks;
int *markSizes;

class MarkInfo {
public:
  MarkInfo(int _left, int _top, int _width, int _height) : left(_left), top(_top), width(_width), height(_height) { };
  int left, top, width, height;
};

void fillMark(Image &image,  Image& correctedImage, int i, int j, int* width, int* height) {
   if (correctedImage.pixelColor(i, j) == Color("red")) {
     *width = markSizes[i * image.size().width() + j];
     *height = markSizes[(i * image.size().width() + j) + image.size().width() * image.size().height()];
    return;
  }
  ColorGray color(image.pixelColor(i, j));
  if (color.shade() < 0.7) {
    int width2, height2, width3, height3;
    correctedImage.pixelColor(i, j, Color("red"));
    fillMark(image, correctedImage, i + 1, j, &width2, &height2);
    fillMark(image, correctedImage, i, j + 1, &width3, &height3);
    *width = max(width2 + 1, width3);
    *height = max(height2, height3 + 1);
    markSizes[i * image.size().width() + j] = *width;
    markSizes[(i * image.size().width() + j) + image.size().width() * image.size().height()] = *height;
    return;
  } else {
    *width = 0;
    *height = 0;
    return;
  }
}

float computeAverage(Image& image, int i, int j) {
  float average = 0.0;
  int nbPixels = 0;
  int size = 2. / 10. * dotsPerCm / 2.;
  // cout << size << endl;
  for (int x = i - size; x <= i + size; x++) {
    for (int y = j - size; y <= j + size; y++) {
      ++nbPixels;
      ColorGray color(image.pixelColor(x, y));
      average += color.shade();
    }
  }
  return average / nbPixels;
}

void usage() {
  cout << "Usage: omr params." << endl;
}

void searchVerticalMarks(Image& image, Image& correctedImage, list<MarkInfo*>& l, int i_min_percent, int i_max_percent, int j_min_percent, int j_max_percent) {
  int width, height;

  for (unsigned int i = image.size().width() * i_min_percent / 100; i < image.size().width() * i_max_percent / 100; ++i) {
    unsigned int j = image.size().height() * j_min_percent / 100;
    while (j < image.size().height() * j_max_percent / 100) {
      ColorGray color(image.pixelColor(i, j));
      fillMark(image, correctedImage, i, j, &width, &height);
      if ((height > neededHeightForMarks) && (width > neededWidthForMarks)) {
	cout << "    Found a mark (" << width << ", " << height << ") at (" << i << ", " << j << ")." << endl;
	l.push_back(new MarkInfo(i, j, width, height));
	i += width;
	j = image.size().height();
      }
      ++j;
    }
  }
}

void searchHorizontalMarks(Image& image, Image& correctedImage, list<MarkInfo*>& l, int i_min_percent, int i_max_percent, int j_min_percent, int j_max_percent) {
  int width, height;

  for (unsigned int j = image.size().height() * j_min_percent / 100; j < image.size().height() * j_max_percent / 100; ++j) {
    unsigned int i = image.size().width() * i_min_percent / 100;
    while (i < image.size().width() * i_max_percent / 100) {
      ColorGray color(image.pixelColor(i, j));
      fillMark(image, correctedImage, i, j, &width, &height);
      if ((height > neededWidthForMarks) && (width > neededHeightForMarks)) {
	cout << "    Found a mark (" << width << ", " << height << ") at (" << i << ", " << j << ")." << endl;
	l.push_back(new MarkInfo(i, j, width, height));
	j += height;
	i = image.size().width();
      }
      ++i;
    }
  }  
}

void writeImages(char* name, Image& image, Image& correctedImage) {
  cout << "Writing binarized image." << endl;  
  image.quality(50);
  image.write(string(name) + "_binarized.jpg");  
  cout << "Writing corrected image." << endl;
  correctedImage.quality(50);
  correctedImage.write(string(name) + "_corrected.jpg");
}

int main(int argc, char** argv) {
  
  if (argc < 17) {
    usage();
    exit(1);
  }

  unsigned int expectedVerticalMarks = atoi(argv[3]);
  unsigned int expectedHorizontalMarks = atoi(argv[4]);
  int marksWidth = atoi(argv[5]);
  int marksHeight = atoi(argv[6]);
  int marksWidthInPixels;
  int marksHeightInPixels;

  int topMarksMinPercentage = atoi(argv[7]);
  int topMarksMaxPercentage = atoi(argv[8]);
  int leftMarksMinPercentage = atoi(argv[9]);
  int leftMarksMaxPercentage = atoi(argv[10]);
  int bottomMarksMinPercentage = atoi(argv[11]);
  int bottomMarksMaxPercentage = atoi(argv[12]);
  int rightMarksMinPercentage = atoi(argv[13]);
  int rightMarksMaxPercentage = atoi(argv[14]);

  int binarizationThreshold = atoi(argv[15]);
  double answerThreshold = atof(argv[16]);

  list<MarkInfo*> topMarks, bottomMarks, leftMarks, rightMarks;

  cout << "Loading image " << argv[1] << "." << endl;
  Image image(argv[1]);

  cout << "Rotating image." << endl;

  if (image.size().width() > image.size().height()) {
    image.rotate(270);
  }
  Image correctedImage(image);

  dotsPerCm = image.size().height() / 29.7;
  cout << "dots per cm: " << dotsPerCm << endl;
  marksWidthInPixels = marksWidth * dotsPerCm / 10;
  marksHeightInPixels = marksHeight * dotsPerCm / 10;
  neededWidthForMarks = marksWidthInPixels * 0.5;
  neededHeightForMarks = marksHeightInPixels * 0.5;
  cout << "Needed width for marks: " << neededWidthForMarks << endl;
  cout << "Needed height for marks: " << neededHeightForMarks << endl;

  cout << "Preparing image." << endl;
  image.threshold(binarizationThreshold);
  
  cout << "Searching for marks." << endl;

  markSizes = (int *) malloc(image.size().width() * image.size().height() * 2 * sizeof(int));
  for (unsigned int i = 0; i < image.size().width() * image.size().height() * 2; i++) {
    markSizes[i] = -1;
  }

  cout << "  Top marks." << endl;
  searchVerticalMarks(image, correctedImage, topMarks, leftMarksMaxPercentage, rightMarksMinPercentage, topMarksMinPercentage, topMarksMaxPercentage);

  cout << "  Bottom marks." << endl;
  searchVerticalMarks(image, correctedImage, bottomMarks, leftMarksMaxPercentage,rightMarksMinPercentage, bottomMarksMinPercentage, bottomMarksMaxPercentage);

  cout << "  Left marks." << endl;
  searchHorizontalMarks(image, correctedImage, leftMarks, leftMarksMinPercentage, leftMarksMaxPercentage, topMarksMaxPercentage, bottomMarksMinPercentage);

  cout << "  Right marks." << endl;  
  searchHorizontalMarks(image, correctedImage, rightMarks, rightMarksMinPercentage, rightMarksMaxPercentage, topMarksMaxPercentage, bottomMarksMinPercentage);

  cout << "Checking numbers of marks." << endl;

  bool error = false;
  if ((topMarks.size() == expectedVerticalMarks) && (bottomMarks.size() == expectedVerticalMarks)) {
    cout << "  Vertical OK (" << topMarks.size() << ", " << bottomMarks.size() << ")."<< endl;
  }
  else {
    cout << "  Vertical not OK ("<< topMarks.size() << ", " << bottomMarks.size() << ")." << endl;
    cerr << "  Vertical not OK ("<< topMarks.size() << ", " << bottomMarks.size() << ")." << endl;
  error = true;
  }

  if ((leftMarks.size() == expectedHorizontalMarks) && (rightMarks.size()== expectedHorizontalMarks)) {
    cout << "  Horizontal OK (" << leftMarks.size() << ", " << rightMarks.size() << ")." << endl;
  }
  else {
    cout << "  Horizontal not OK ("<< leftMarks.size() << ", " << rightMarks.size() << ")." << endl;
    cerr << "  Horizontal not OK ("<< leftMarks.size() << ", " << rightMarks.size() << ")." << endl;
    error = true;
  }

  if (error) {
    cerr << "Marks were not correctly detected." << endl;
    cout << "Marks were not correctly detected." << endl;
    writeImages(argv[2], image, correctedImage);
    exit(2);
  }

  list<MarkInfo*>::iterator it;
  list<MarkInfo*>::iterator it2;
  list<MarkInfo*>::iterator it3;
  list<MarkInfo*>::iterator it4;

  cout << "Determining answers." << endl;
  ofstream outputFile((string(argv[2]) + ".omr1_data").c_str());

  int line = 1;
  float i, j;
  float average;
  correctedImage.strokeColor(Color("green"));
  correctedImage.strokeWidth(5. *  dotsPerCm / 158.);
  correctedImage.fillColor(Color(0,0,0,MaxRGB));
  int r = 5. / 10. * dotsPerCm / 2.;
  for (it = leftMarks.begin(), it2 = rightMarks.begin(); it != leftMarks.end(); ++it, ++it2) {
    cout << "Line " << line << ": ";
    for (it3 = topMarks.begin(), it4 = bottomMarks.begin(); it3 != topMarks.end(); ++it3, ++it4) {
      float a_x = (*it3)->left + (*it3)->width/2;
      float a_y = (*it3)->top;
      float b_x = (*it)->left;
      float b_y = (*it)->top + (*it)->height/2;
      float c_x = (*it4)->left + (*it4)->width/2;
      float c_y = (*it4)->top;
      float d_x = (*it2)->left;
      float d_y = (*it2)->top + (*it2)->height/2;

      if (a_x == c_x) {
	i = a_x;
	j = (b_y + d_y) / 2;
      } else {
	i = ((d_y-(((b_y-d_y)/(b_x-d_x))*d_x))-(a_y-(((c_y-a_y)/(c_x-a_x))*a_x)))/(((c_y-a_y)/(c_x-a_x))-((b_y-d_y)/(b_x-d_x)));
	j = i*((c_y-a_y)/(c_x-a_x))+(a_y-((c_y-a_y)/(c_x-a_x)*a_x));
      }
      //   cout << endl << "i=" << i << " j=" << j << endl;

      average = computeAverage(image, i, j);
      cout << average << " ";
      if (average < answerThreshold) {
	cout << "1 ";
	outputFile << "1 ";
	correctedImage.strokeColor(Color("green"));
	correctedImage.draw(DrawableArc(i - r, j - r, i + r, j + r, 0, 360));
      }
      else {
	cout << "0 ";
	outputFile << "0 ";
      }
    }
    cout << endl;
    outputFile << endl;
    ++line;
  }

  outputFile.close();

  cout << "Drawing marks lines." << endl;

  correctedImage.strokeColor(Color("blue"));
  correctedImage.strokeWidth(1);
  for (it = topMarks.begin(), it2 = bottomMarks.begin(); it != topMarks.end(); ++it, ++it2) {
    correctedImage.draw(DrawableLine((*it)->left + (*it)->width/2, (*it)->top,(*it2)->left + (*it2)->width/2, (*it2)->top + (*it2)->height));
  }

  for (it = leftMarks.begin(), it2 = rightMarks.begin(); it != leftMarks.end(); ++it, ++it2) {
    correctedImage.draw(DrawableLine((*it)->left, (*it)->top + (*it)->height/2,(*it2)->left + (*it2)->width, (*it2)->top + (*it2)->height/2));
  }

  writeImages(argv[2], image, correctedImage);
  
  if (error) {
    cerr << "There were unsure ticks for " << argv[1] << "." << endl;
    exit(3);
  } else {
    cout << "Successfully finished." << endl;
  }

  return 0;
}

