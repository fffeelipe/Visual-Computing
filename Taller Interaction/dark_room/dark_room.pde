import peasy.*;
 
PVector lightDir = new PVector();
PShader defaultShader;
PGraphics shadowMap;
PGraphics canvas;
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
public boolean go_avatar = true;
Boid boid, cam1;

void setup() {
  //new PeasyCam(this, 300).rotateX(4.0);
  initShadowPass();
  initDefaultPass();
  openWirelessControl();    
  size(1370, 700, P3D);
  //size(500, 500, P3D);
  scene = new Scene(this);
  scene.setBoundingBox(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.setAnchor(scene.center());
  scene.setFieldOfView(PI / 3);
  scene.fitBall();
  
  boid = new Boid(new Vector(200, 200, 400));
  cam1 = new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2));
  avatar = boid.frame;
  Toroid t1 = new Toroid(new Vector(0,0,0), new Quaternion(0,0,0,0.1), 100.0, 200.0);
  Toroid t2 = new Toroid(new Vector(0,0,0), new Quaternion(0.2,1.4,1,1), 20.0, 50.0);
  Toroid t3 = new Toroid(new Vector(300,500,300), new Quaternion(1.4,1,0,0.1), 10.0, 50.0);
  Toroid t4 = new Toroid(new Vector(600,200,400), new Quaternion(0.1,5,1,0.6), 20.0, 50.0);
  Toroid t5 = new Toroid(new Vector(450,-100,0), new Quaternion(7.5,1,0.3), 15.0, 40.0);
  Toroid t6 = new Toroid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2), 
  new Quaternion(0,0,0,0), 20.0, 100.0);
  Toroid t7 = new Toroid(new Vector(1300,500,300), new Quaternion(1.4,1,0,0.1), 10.0, 50.0);
  Toroid t8 = new Toroid(new Vector(1600,200,400), new Quaternion(0.1,5,1,0.6), 20.0, 50.0);
  Toroid t9 = new Toroid(new Vector(1450,-100,0), new Quaternion(7.5,1,-1,0.3), 15.0, 40.0);
  //scene.eye().setReference(cam1.frame);
  //scene.interpolateTo(cam1.frame);
  //shadowMap.beginDraw(); shadowMap.perspective(60 * DEG_TO_RAD, 1, 10, 1000); shadowMap.endDraw();
  //shadowMap.beginDraw(); shadowMap.ortho(-200, 200, -200, 200, 10, 400); shadowMap.endDraw();
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



void draw() {
    getUserInput();
  float lightAngle = frameCount * 0.002;
    lightDir.set(avatar.position().x(),avatar.position().y(),avatar.position().z());
    println("x: " + avatar.position().x());
    println("y: " + avatar.position().y());
    println("z: " + avatar.position().z());
    
    // Render shadow pass
    shadowMap.beginDraw();
    shadowMap.camera(lightDir.x, lightDir.y, lightDir.z, 0, 0, 0, 0, 1, 0);
    shadowMap.background(0xffffffff); // Will set the depth to 1.0 (maximum depth)
    canvas = shadowMap;
    scene.traverse();
    shadowMap.endDraw();
    shadowMap.updatePixels();
 
    // Update the shadow transformation matrix and send it, the light
    // direction normal and the shadow map to the default shader.
    updateDefaultShader();
 
    // Render default pass
    background(0xff222222);
    canvas = g;
    scene.traverse();
 
    // Render light source
    pushMatrix();
    //fill(0,255,0);
    translate(150, 150, 150);
    box(50);
    popMatrix();
    //spotLight(51, 102, 126,avatar.worldLocation(new Vector(0,0,0)).x(), avatar.worldLocation(new Vector(0,0,0)).y() , avatar.worldLocation(new Vector(0,0,0)).z(), -avatar.zAxis().x(),-avatar.zAxis().y(),-avatar.zAxis().z(), PI/4, 2 );
  
  
  
  
  
}


void thirdPerson() {
  scene.eye().setReference(avatar);
  scene.interpolateTo(avatar);
}

void resetEye() {
  // same as: scene.eye().setReference(null);
  scene.eye().setReference(cam1.frame);
  scene.interpolateTo(cam1.frame);
  scene.lookAt(scene.center());
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
    if (scene.eye().reference() == avatar){
      resetEye();
      thirdPerson = false;
    }
    else{
      control_box =false;
      thirdPerson();
      thirdPerson = true;
    }
    break;
    
  }
}
public void initShadowPass() {
    shadowMap = createGraphics(2048, 2048, P3D);
    String[] vertSource = {
        "uniform mat4 transform;",
 
        "attribute vec4 vertex;",
 
        "void main() {",
            "gl_Position = transform * vertex;",
        "}"
    };
    String[] fragSource = {
 
        // In the default shader we won't be able to access the shadowMap's depth anymore,
        // just the color, so this function will pack the 16bit depth float into the first
        // two 8bit channels of the rgba vector.
        "vec4 packDepth(float depth) {",
            "float depthFrac = fract(depth * 255.0);",
            "return vec4(depth - depthFrac / 255.0, depthFrac, 1.0, 1.0);",
        "}",
 
        "void main(void) {",
            "gl_FragColor = packDepth(gl_FragCoord.z);",
        "}"
    };
    shadowMap.noSmooth(); // Antialiasing on the shadowMap leads to weird artifacts
    //shadowMap.loadPixels(); // Will interfere with noSmooth() (probably a bug in Processing)
    shadowMap.beginDraw();
    shadowMap.noStroke();
    shadowMap.shader(new PShader(this, vertSource, fragSource));
    shadowMap.ortho(-200, 200, -200, 200, 10, 400); // Setup orthogonal view matrix for the directional light
    shadowMap.endDraw();
}
 
public void initDefaultPass() {
    String[] vertSource = {
        "uniform mat4 transform;",
        "uniform mat4 modelview;",
        "uniform mat3 normalMatrix;",
        "uniform mat4 shadowTransform;",
        "uniform vec3 lightDirection;",
 
        "attribute vec4 vertex;",
        "attribute vec4 color;",
        "attribute vec3 normal;",
 
        "varying vec4 vertColor;",
        "varying vec4 shadowCoord;",
        "varying float lightIntensity;",
 
        "void main() {",
            "vertColor = color;",
            "vec4 vertPosition = modelview * vertex;", // Get vertex position in model view space
            "vec3 vertNormal = normalize(normalMatrix * normal);", // Get normal direction in model view space
            "shadowCoord = shadowTransform * (vertPosition + vec4(vertNormal, 0.0));", // Normal bias removes the shadow acne
            "lightIntensity = 0.5 + dot(-lightDirection, vertNormal) * 0.5;",
            "gl_Position = transform * vertex;",
        "}"
    };
    String[] fragSource = {
        "#version 120",
 
        // Used a bigger poisson disk kernel than in the tutorial to get smoother results
        "const vec2 poissonDisk[9] = vec2[] (",
            "vec2(0.95581, -0.18159), vec2(0.50147, -0.35807), vec2(0.69607, 0.35559),",
            "vec2(-0.0036825, -0.59150), vec2(0.15930, 0.089750), vec2(-0.65031, 0.058189),",
            "vec2(0.11915, 0.78449), vec2(-0.34296, 0.51575), vec2(-0.60380, -0.41527)",
        ");",
 
        // Unpack the 16bit depth float from the first two 8bit channels of the rgba vector
        "float unpackDepth(vec4 color) {",
            "return color.r + color.g / 255.0;",
        "}",
 
        "uniform sampler2D shadowMap;",
 
        "varying vec4 vertColor;",
        "varying vec4 shadowCoord;",
        "varying float lightIntensity;",
 
        "void main(void) {",
 
            // Project shadow coords, needed for a perspective light matrix (spotlight)
            "vec3 shadowCoordProj = shadowCoord.xyz / shadowCoord.w;",
 
            // Only render shadow if fragment is facing the light
            "if(lightIntensity > 0.5) {",
                "float visibility = 9.0;",
 
                // I used step() instead of branching, should be much faster this way
                "for(int n = 0; n < 9; ++n)",
                    "visibility += step(shadowCoordProj.z, unpackDepth(texture2D(shadowMap, shadowCoordProj.xy + poissonDisk[n] / 512.0)));",
 
                "gl_FragColor = vec4(vertColor.rgb * min(visibility * 0.05556, lightIntensity), vertColor.a);",
            "} else",
                "gl_FragColor = vec4(vertColor.rgb * lightIntensity, vertColor.a);",
 
        "}"
    };
    shader(defaultShader = new PShader(this, vertSource, fragSource));
    noStroke();
    perspective(60 * DEG_TO_RAD, (float)width / height, 10, 1000);
}
 
void updateDefaultShader() {
 
    // Bias matrix to move homogeneous shadowCoords into the UV texture space
    PMatrix3D shadowTransform = new PMatrix3D(
        0.5, 0.0, 0.0, 0.5, 
        0.0, 0.5, 0.0, 0.5, 
        0.0, 0.0, 0.5, 0.5, 
        0.0, 0.0, 0.0, 1.0
    );
 
    // Apply project modelview matrix from the shadow pass (light direction)
    shadowTransform.apply(((PGraphicsOpenGL)shadowMap).projmodelview);
 
    // Apply the inverted modelview matrix from the default pass to get the original vertex
    // positions inside the shader. This is needed because Processing is pre-multiplying
    // the vertices by the modelview matrix (for better performance).
    PMatrix3D modelviewInv = ((PGraphicsOpenGL)g).modelviewInv;
    shadowTransform.apply(modelviewInv);
 
    // Convert column-minor PMatrix to column-major GLMatrix and send it to the shader.
    // PShader.set(String, PMatrix3D) doesn't convert the matrix for some reason.
    defaultShader.set("shadowTransform", new PMatrix3D(
        shadowTransform.m00, shadowTransform.m10, shadowTransform.m20, shadowTransform.m30, 
        shadowTransform.m01, shadowTransform.m11, shadowTransform.m21, shadowTransform.m31, 
        shadowTransform.m02, shadowTransform.m12, shadowTransform.m22, shadowTransform.m32, 
        shadowTransform.m03, shadowTransform.m13, shadowTransform.m23, shadowTransform.m33
    ));
 
    // Calculate light direction normal, which is the transpose of the inverse of the
    // modelview matrix and send it to the default shader.
    float lightNormalX = lightDir.x * modelviewInv.m00 + lightDir.y * modelviewInv.m10 + lightDir.z * modelviewInv.m20;
    float lightNormalY = lightDir.x * modelviewInv.m01 + lightDir.y * modelviewInv.m11 + lightDir.z * modelviewInv.m21;
    float lightNormalZ = lightDir.x * modelviewInv.m02 + lightDir.y * modelviewInv.m12 + lightDir.z * modelviewInv.m22;
    float normalLength = sqrt(lightNormalX * lightNormalX + lightNormalY * lightNormalY + lightNormalZ * lightNormalZ);
    defaultShader.set("lightDirection", lightNormalX / -normalLength, lightNormalY / -normalLength, lightNormalZ / -normalLength);
 
    // Send the shadowmap to the default shader
    defaultShader.set("shadowMap", shadowMap);
 
}
