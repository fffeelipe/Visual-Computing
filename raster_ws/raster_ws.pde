import frames.timing.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;
// Grid antialiasing
int antialiasing_div = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = false;
boolean debug = false;
boolean antialiasingEffect = false;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

float antialiasingInv = (float)1/antialiasing_div;
int antialiasingPow = antialiasing_div*antialiasing_div;

void setup() {
  //use 2^n to change the dimensions
  size(512, 512, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      scene.eye().orbit(scene.is2D() ? new Vector(0, 0, 1) :
        yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100);
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow( 2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

float orientation(Vector A, Vector B, Vector C) {
  return ((B.x() - A.x()) *  (C.y() - A.y())) - ((B.y() - A.y()) *  (C.x() - A.x()));
}

void applyAntialiasing(Vector V1, Vector V2, Vector V3, float x, float y){
  Vector avgColor = new Vector(255, 255, 255);
  Vector P = new Vector(0, 0);
  float alpha = 255;
  for (float i = 0; i < 1; i += antialiasingInv){
    for (float j = 0; j < 1; j += antialiasingInv){
      P.setX(x + i + antialiasingInv/2);
      P.setY(y + i + antialiasingInv/2);
      float W1 = orientation(V1, V2, P);
      float W2 = orientation(V2, V3, P);
      float W3 = orientation(V3, V1, P);
      float avgP = 255/((W1 + W2 + W3)*antialiasingPow);
      if (W1 >= 0 && W2 >= 0 && W3 >= 0) {
        avgColor.setX(avgColor.x() - W1*avgP);
        avgColor.setY(avgColor.y() - W2*avgP);
        avgColor.setZ(avgColor.z() - W3*avgP);
      }
      else{
        alpha -= avgP;
      }
      if(avgColor.matches(new Vector(255, 255, 255)))
        noFill();
      else
        fill(round(avgColor.x()), round(avgColor.y()), round(avgColor.z()), alpha);
    }
  }
  
}

void noAntialiasing(Vector V1, Vector V2, Vector V3, float x, float y){
  Vector avgColor = new Vector(255, 255, 255);
  Vector P = new Vector(x, y);
  float W1 = orientation(V1, V2, P);
  float W2 = orientation(V2, V3, P);
  float W3 = orientation(V3, V1, P);
  float avgP = 255/(W1 + W2 + W3);
  if (W1 >= 0 && W2 >= 0 && W3 >= 0) {
    avgColor.setX(avgColor.x() - W1*avgP);
    avgColor.setY(avgColor.y() - W2*avgP);
    avgColor.setZ(avgColor.z() - W3*avgP);
    fill(round(avgColor.x()), round(avgColor.y()), round(avgColor.z()));
  }
  else
    noFill();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  Vector V1 = frame.displacement(v1);
  Vector V2 = frame.displacement(v2);
  Vector V3 = frame.displacement(v3);
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  
  noStroke();
  Vector max = new Vector(round(max(V1.x(), V2.x(), V3.x())), round(max(V1.y(), V2.y(), V3.y())));
  Vector min = new Vector(round(min(V1.x(), V2.x(), V3.x())), round(min(V1.y(), V2.y(), V3.y())));
  
  if (orientation(V1, V2, V3)<0)
  {
    V1 = frame.displacement(v2);
    V2 = frame.displacement(v1);
  }
  if (debug) {
    pushStyle();
    stroke(255,0,255,125);
    point(round(V1.x()), round(V1.y()));
    stroke(255,0,255,125);
    stroke(255,255,0,125);
    point(round(V2.x()), round(V2.y()));
    stroke(0,255,255,125);
    point(round(V3.x()), round(V3.y()));
    popStyle();
  }
  for (float x = min.x(); x <= max.x(); x++){
    for (float y = min.y(); y <= max.y(); y++) {
      if(antialiasingEffect)
        applyAntialiasing(V1, V2, V3, x, y);
      else
        noAntialiasing(V1, V2, V3, x, y);
      rect(x, y, 1, 1);
    }
  }
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
  if (key == 'a')
    antialiasingEffect = !antialiasingEffect;
}
