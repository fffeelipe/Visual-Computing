
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;
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

public boolean control_box= true;
boolean thirdPerson = false;

Scene scene;

int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
public Frame avatar;

Boid boid;

void setup() {
  openWirelessControl();  
  //size(1370, 700, P3D);
  size(500, 500, P3D);
  scene = new Scene(this);
  scene.setBoundingBox(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.setAnchor(scene.center());
  scene.setFieldOfView(PI / 3);
  scene.fitBall();
  
  boid = new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2));
  avatar = boid.frame;
  Toroid t1 = new Toroid(new Vector(0,0,0), new Quaternion(0,0,0,0.1), 100.0, 200.0);
  Toroid t2 = new Toroid(new Vector(0,0,0), new Quaternion(0.2,1.4,1,1), 20.0, 50.0);
  Toroid t3 = new Toroid(new Vector(300,500,300), new Quaternion(1.4,1,0,0.1), 10.0, 50.0);
  Toroid t4 = new Toroid(new Vector(600,200,400), new Quaternion(0.1,5,1,0.6), 20.0, 50.0);
  Toroid t5 = new Toroid(new Vector(450,-100,0), new Quaternion(7.5,1,0.3), 15.0, 40.0);
  Toroid t6 = new Toroid(new Vector(110,50,0), new Quaternion(0.2,1.4,1,1), 20.0, 50.0);
  Toroid t7 = new Toroid(new Vector(1300,500,300), new Quaternion(1.4,1,0,0.1), 10.0, 50.0);
  Toroid t8 = new Toroid(new Vector(1600,200,400), new Quaternion(0.1,5,1,0.6), 20.0, 50.0);
  Toroid t9 = new Toroid(new Vector(1450,-100,0), new Quaternion(7.5,1,-1,0.3), 15.0, 40.0);
  
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
  
}

void controlInteraction() {
  scene.translate(2 * movex, 2 * movey, 2 * movez);
  scene.rotate(rotateyz * 2 * PI / width, rotatexz * 2 * PI / width, rotatexy * 2 * PI / width);
}



void draw() {
  noStroke();

  sphere(100);

  getUserInput();
  background(0, 0, 0);
  directionalLight(5, 5, 5, 0, 1, -5);
  spotLight(51, 102, 126,
  avatar.worldLocation(new Vector(0,0,0)).x(), avatar.worldLocation(new Vector(0,0,0)).y() , avatar.worldLocation(new Vector(0,0,0)).z(), 
  -avatar.zAxis().x(),-avatar.zAxis().y(),-avatar.zAxis().z(),
  PI/4, 2 
  );
  walls();
  scene.traverse();
  if (control_box && !thirdPerson){
    controlInteraction();
  }
  
  
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



void mouseWheel(MouseEvent event) {
  scene.scale(event.getCount() * 20);
}

void thirdPerson() {
  scene.eye().setReference(avatar);
  scene.interpolateTo(avatar);
}

void resetEye() {
  // same as: scene.eye().setReference(null);
  scene.eye().resetReference();
  scene.lookAt(scene.center());
  scene.fitBallInterpolation();
}

void keyPressed() {
  switch (key) {
  case 't':
    scene.shiftTimers();
    break;
  case 'p':
    println("Frame rate: " + frameRate);
    break;
  case ' ':
    if(!thirdPerson)
      control_box = !control_box;
    break;
    
  case 'f':
    if (scene.eye().reference() != null){
      resetEye();
      thirdPerson = false;
    }
    else if (avatar != null){
      control_box =false;
      thirdPerson();
      thirdPerson = true;
    }
    break;
    
  }
}
