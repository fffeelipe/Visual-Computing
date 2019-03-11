/**
 * Flock of Boids
 * by Jean Pierre Charalambos.
 *
 * This example displays the famous artificial life program "Boids", developed by
 * Craig Reynolds in 1986 [1] and then adapted to Processing by Matt Wetmore in
 * 2010 (https://www.openprocessing.org/sketch/6910#), in 'third person' eye mode.
 * The Boid under the mouse will be colored blue. If you click on a boid it will
 * be selected as the scene avatar for the eye to follow it.
 *
 * 1. Reynolds, C. W. Flocks, Herds and Schools: A Distributed Behavioral Model. 87.
 * http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
 * 2. Check also this nice presentation about the paper:
 * https://pdfs.semanticscholar.org/73b1/5c60672971c44ef6304a39af19dc963cd0af.pdf
 * 3. Google for more...
 *
 * Press ' ' to switch between the different eye modes.
 * Press 'a' to toggle (start/stop) animation.
 * Press 'p' to print the current frame rate.
 * Press 'm' to change the boid visual mode.
 * Press 'v' to toggle boids' wall skipping.
 * Press 's' to call scene.fitBallInterpolation().
 */

import frames.primitives.*;
import frames.core.*;
import frames.processing.*;
import java.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

public ControlIO control;
public ControlDevice device;

public float movex; 
public float movez;
public float rotatexz;
public float rotateyz;
public float movey;
public float rotatexy;
  



Scene scene;
//flock bounding box
int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
boolean avoidWalls = true;
int fcount, lastm;
float frate;
int fint = 3;
public int initBoidNum = 1; // amount of boids to start the program with
ArrayList<Boid> flock;
ArrayList<Boid> randomFlock;
public Frame avatar;
boolean animate = true;
public boolean control_box= false;
int c1[] = new int[4];
void setup() {
  //control stuff
  openWirelessControl();
  //end control stuff
  
  size(1000, 800, P3D);
  scene = new Scene(this);
  scene.setBoundingBox(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.setAnchor(scene.center());
  scene.setFieldOfView(PI / 3);
  scene.fitBall();
  // create and fill the list of boids
  flock = new ArrayList();
  for (int i = 0; i < initBoidNum; i++)
    flock.add(new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2)));
  for(int i = 0; i<4; i++){
    c1[i] = (int)(Math.random()*(initBoidNum-1));
  }
  randomFlock = new ArrayList();
  for(int i = 0; i<8; i++){
    randomFlock.add(flock.get((int)(Math.random()*(initBoidNum-1))));
  }
  avatar = flock.get(0).frame;
}

void openWirelessControl() {
  control = ControlIO.getInstance(this);
  device = control.getMatchedDevice("control");
  if (device == null) {
    println("No suitable device configured");
    System.exit(0); // End the program NOW!
  }
}

public void getUserInput() {
  movex = device.getSlider("movex").getValue();
  movez = device.getSlider("movez").getValue();
  rotatexz = device.getSlider("rotatexz").getValue();
  rotateyz = device.getSlider("rotateyz").getValue(); // Rotations
  rotatexy = device.getButton("rotatexyn").pressed()? -1:0;
  movey = device.getSlider("moveyn").getValue() == -1? 0:1;
  movey += device.getButton("moveyp").pressed()?-1:0; // Buttons
  rotatexy += device.getButton("rotatexyp").pressed()?1:0;
  
  println("movex" + movex);
  println("movey" + movey);
  println("movez" + movez);
  println("rotatexy" + rotatexy);
  println("rotateyz" + rotateyz);
  println("rotatexz" + rotatexz);
  

}

void controlInteraction() {
  scene.translate(10 * movex, 10 * movey, 10 * movez);
  scene.rotate(rotateyz * 20 * PI / width, rotatexz * 20 * PI / width, rotatexy * 20 * PI / width);
}

void draw() {
  background(10, 50, 25);
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  getUserInput();
  walls();
  scene.traverse();
  // uncomment to asynchronously update boid avatar. See mouseClicked()
  // updateAvatar(scene.trackedFrame("mouseClicked"));
  
  //drawDeCastejau(randomFlock);
  //draw_CubicHermite(flock.get(c1[0]),flock.get(c1[1]),flock.get(c1[2]),flock.get(c1[3]));
  //draw_Bezier3(flock.get(c1[0]+1),flock.get(c1[1]+1),flock.get(c1[2]+1),flock.get(c1[3]+1));
  
  if (control_box){
    controlInteraction();
  }
  
  /*
  fcount += 1;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m;
    println("fps: " + frate);
  }
  fill(0);
  text("fps: " + frate, 10, 20);
  */
}

void walls() {
  pushStyle();
  noFill();
  stroke(255, 255, 0);

  line(0, 0, 0, 0, flockHeight, 0);
  line(0, 0, flockDepth, 0, flockHeight, flockDepth);
  line(0, 0, 0, flockWidth, 0, 0);
  line(0, 0, flockDepth, flockWidth, 0, flockDepth);

  line(flockWidth, 0, 0, flockWidth, flockHeight, 0);
  line(flockWidth, 0, flockDepth, flockWidth, flockHeight, flockDepth);
  line(0, flockHeight, 0, flockWidth, flockHeight, 0);
  line(0, flockHeight, flockDepth, flockWidth, flockHeight, flockDepth);

  line(0, 0, 0, 0, 0, flockDepth);
  line(0, flockHeight, 0, 0, flockHeight, flockDepth);
  line(flockWidth, 0, 0, flockWidth, 0, flockDepth);
  line(flockWidth, flockHeight, 0, flockWidth, flockHeight, flockDepth);
  popStyle();
}



// Sets current avatar as the eye reference and interpolate the eye to it
void thirdPerson() {
  scene.eye().setReference(avatar);
  scene.interpolateTo(avatar);
}

// Resets the eye
void resetEye() {
  // same as: scene.eye().setReference(null);
  scene.eye().resetReference();
  scene.lookAt(scene.center());
  scene.fitBallInterpolation();
}

// picks up a boid avatar, may be null
void mouseClicked() {
  // two options to update the boid avatar:
  // 1. Synchronously
  //updateAvatar(scene.track("mouseClicked", mouseX, mouseY));
  control_box = !control_box;
  // which is the same as these two lines:
  // scene.track("mouseClicked", mouseX, mouseY);
  // updateAvatar(scene.trackedFrame("mouseClicked"));
  // 2. Asynchronously
  // which requires updateAvatar(scene.trackedFrame("mouseClicked")) to be called within draw()
  // scene.cast("mouseClicked", mouseX, mouseY);
}

// 'first-person' interaction
void mouseDragged() {
  if (scene.eye().reference() == null)
    if (mouseButton == LEFT)
      // same as: scene.spin(scene.eye());
      scene.spin();
    else if (mouseButton == RIGHT)
      // same as: scene.translate(scene.eye());
      scene.translate();
    else
      // same as: scene.zoom(mouseX - pmouseX, scene.eye());
      scene.zoom(mouseX - pmouseX);
}

// highlighting and 'third-person' interaction
void mouseMoved(MouseEvent event) {
  // 1. highlighting
  scene.cast("mouseMoved", mouseX, mouseY);
  // 2. third-person interaction
  if (scene.eye().reference() != null)
    // press shift to move the mouse without looking around
    if (!event.isShiftDown())
      scene.lookAround();
}

void mouseWheel(MouseEvent event) {
  // same as: scene.scale(event.getCount() * 20, scene.eye());
  scene.scale(event.getCount() * 20);
}  

void keyPressed() {
  switch (key) {
  case 'a':
    animate = !animate;
    break;
  case 's':
    if (scene.eye().reference() == null)
      scene.fitBallInterpolation();
    break;
  case 't':
    scene.shiftTimers();
    break;
  case 'p':
    println("Frame rate: " + frameRate);
    break;
  case 'v':
    avoidWalls = !avoidWalls;
    break;
  case ' ':
    if (scene.eye().reference() != null)
      resetEye();
    else if (avatar != null)
      thirdPerson();
    break;
  }
}
