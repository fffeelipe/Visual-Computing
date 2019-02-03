PImage img;
void setup() {
  size(730,469);
  img = loadImage("curve_squares.jpg");  // Load the image into the program
  
}

int i = 26;



void draw() {
  //mouseClicked();
  image(img, 0, 0);
  
  if(mousePressed){
    for(int j = 1; j<20; j++)
      line(0, i * j, 730, i * j);
      strokeWeight(3);
      stroke(255,0,0);
  }
  
  
  
}
