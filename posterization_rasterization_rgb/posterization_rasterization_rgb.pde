import processing.core.PApplet;
import processing.core.PImage;
import processing.svg.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

ArrayList<Integer> palette;
PImage img;
PImage posterizedImg; // Store the posterized image globally
int numRows = 40;
int numCols = 40;
int gapX = 1;
int gapY = 1;
boolean exportingSVG = false; // Flag to control SVG export


void setup() {
  size(600, 600);
  rectMode(CENTER);

  palette = new ArrayList<Integer>();

  // Load an image (replace with your path)
  img = loadImage("f21288cf-418e-4cca-a0dd-f751528de59e.png");
  if (img == null) {
    println("Error: Could not load image.");
    exit();
  }
  img.resize(width, height); // Resize image to fit window

  // Example color palette (you can change this)
  palette.add(color(255, 0, 0));     // Red
  palette.add(color(0, 255, 0));     // Green
  palette.add(color(0, 0, 255));     // Blue
  palette.add(color(255, 255, 0));  // Yellow
  palette.add(color(0, 255, 255));  // Cyan
  palette.add(color(255, 0, 255));  // Magenta
  palette.add(color(255, 255, 255));  // White
  palette.add(color(0, 0, 0));      // Black

  // Posterize the image only once in setup
  posterizedImg = posterizeImage(img, palette);
}


void draw() {
  background(220);

    if(exportingSVG){
        beginRecord(SVG, "output.svg"); // Start recording to SVG
    }
  drawGrid();
      if (exportingSVG) {
      endRecord(); // Stop recording
      exportingSVG = false; // Reset the flag
      println("SVG exported");
    }
}

void keyPressed(){
    if(key == 's' || key == 'S'){
        exportingSVG = true;
    }
}

void drawGrid() {
  rectMode(CENTER);
  float rectWidth = (float)(width - (numCols-1)*gapX) / numCols;
  float rectHeight = (float)(height - (numRows-1)*gapY) / numRows;

  for (int row = 0; row < numRows; row++) {
    for (int col = 0; col < numCols; col++) {
      float x = col * (rectWidth + gapX);
      float y = row * (rectHeight + gapY);

      int sampledColor = samplePosterizedImage(x, y, rectWidth, rectHeight);
      stroke(sampledColor);
      int step = 2;
      float rectW = rectWidth;
      float rectH = rectHeight;

      while (rectW > 0 && rectH > 0) {
        rect(x+rectW/2, y+rectH/2, rectW, rectH);
        rectW = rectW - step;
        rectH = rectH - step;
      }
    }
  }
}

int samplePosterizedImage(float x, float y, float rectWidth, float rectHeight) {
  HashMap<Integer, Integer> colorCounts = new HashMap<>();
  int samplePointsPerRow = 3;

  float sampleStepX = rectWidth / (samplePointsPerRow + 1);
  float sampleStepY = rectHeight / (samplePointsPerRow + 1);

  for (int i = 1; i <= samplePointsPerRow; i++) {
    for (int j = 1; j <= samplePointsPerRow; j++) {
      int sampleX = (int) (x + sampleStepX * i);
      int sampleY = (int) (y + sampleStepY * j);

      if (sampleX >= 0 && sampleX < posterizedImg.width && sampleY >= 0 && sampleY < posterizedImg.height) {
        int sampledColor = posterizedImg.get(sampleX, sampleY);
        colorCounts.put(sampledColor, colorCounts.getOrDefault(sampledColor, 0) + 1);
      }
    }
  }

  int mostFrequentColor = 0;
  int maxCount = 0;

  for (Map.Entry<Integer, Integer> entry : colorCounts.entrySet()) {
    if (entry.getValue() > maxCount) {
      maxCount = entry.getValue();
      mostFrequentColor = entry.getKey();
    }
  }
  return mostFrequentColor;
}


PImage posterizeImage(PImage source, ArrayList<Integer> palette) {
  PImage result = source.copy();
  result.loadPixels();

  for (int i = 0; i < result.pixels.length; i++) {
    int sourceColor = result.pixels[i];
    int closestPaletteColor = findClosestColor(sourceColor, palette);
    result.pixels[i] = closestPaletteColor;
  }

  result.updatePixels();
  return result;
}

int findClosestColor(int sourceColor, ArrayList<Integer> palette) {
  float closestDistance = Float.MAX_VALUE;
  int closestColor = 0;

  for (int paletteColor : palette) {
    float distance = colorDistance(sourceColor, paletteColor);
    if (distance < closestDistance) {
      closestDistance = distance;
      closestColor = paletteColor;
    }
  }

  return closestColor;
}


float colorDistance(int color1, int color2) {
  float r1 = red(color1);
  float g1 = green(color1);
  float b1 = blue(color1);

  float r2 = red(color2);
  float g2 = green(color2);
  float b2 = blue(color2);

  // Euclidean Distance in RGB space
  float distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));
  return distance;
}
