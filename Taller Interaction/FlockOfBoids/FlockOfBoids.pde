
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

//testing
int pts = 40; 
float angle = 0;
float radius = 100.0;

// lathe segments
int segments = 60;
float latheAngle = 0;
float latheRadius = 200.0;

//vertices
PVector vertices[], vertices2[];
//end testing


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
  scene.translate(10 * movex, 10 * movey, 10 * movez);
  scene.rotate(rotateyz * 20 * PI / width, rotatexz * 20 * PI / width, rotatexy * 20 * PI / width);
}



void draw() {
  noStroke();

  sphere(100);

  getUserInput();
  spotLight(51, 102, 126, 80, 20, 40, -1, 0, 0, PI/2, 2);

  background(0, 0, 0);
  directionalLight(255, 255, 255, 0, 1, -5);
  spotLight(51, 102, 126,
  avatar.worldLocation(new Vector(0,0,0)).x(), avatar.worldLocation(new Vector(0,0,0)).y() , avatar.worldLocation(new Vector(0,0,0)).z(), 
  -avatar.zAxis().x(),-avatar.zAxis().y(),-avatar.zAxis().z(),
  PI/4, 2 
  );
  println("x: " + avatar.zAxis().x());
  println("y: " + avatar.zAxis().y());
  println("z: " + -avatar.zAxis().z());
  walls();
  scene.traverse();
  if (control_box && !thirdPerson){
    controlInteraction();
  }
  
  
  //testing
  // initialize point arrays
  vertices = new PVector[pts+1];
  vertices2 = new PVector[pts+1];

  // fill arrays
  for(int i=0; i<=pts; i++){
    vertices[i] = new PVector();
    vertices2[i] = new PVector();
    vertices[i].x = latheRadius + sin(radians(angle))*radius;
    vertices[i].z = cos(radians(angle))*radius;
    angle+=360.0/pts;
  }

  // draw toroid
  latheAngle = 0;
  for(int i=0; i<=segments; i++){
    beginShape(QUAD_STRIP);
    for(int j=0; j<=pts; j++){
      if (i>0){
        vertex(vertices2[j].x, vertices2[j].y, vertices2[j].z);
      }
      vertices2[j].x = cos(radians(latheAngle))*vertices[j].x;
      vertices2[j].y = sin(radians(latheAngle))*vertices[j].x;
      vertices2[j].z = vertices[j].z;
      // optional helix offset
      vertex(vertices2[j].x, vertices2[j].y, vertices2[j].z);
    }
    // create extra rotation for helix
    latheAngle+=360.0/segments;
    
    endShape();
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
