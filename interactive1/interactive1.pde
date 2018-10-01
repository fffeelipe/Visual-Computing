PImage img,img2;
void setup() {
  size(475,475);
  img = loadImage("11.jpg");  // Load the image into the program
  img2 = loadImage("22.jpg");  // Load the image into the program
  
}

void mouseClicked(){
  PImage t = img;
  img = img2;
  img2 = t;
}

void draw() {
  image(img, 0, 0);
  
  
}
