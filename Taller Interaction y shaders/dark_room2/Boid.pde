class Boid {
  public Frame frame;
  Vector position;
  float sc = 3; // scale factor for the render of the boid

  Boid(Vector inPos) {
    position = new Vector();
    position.set(inPos);
    frame = new Frame(scene) {
      @Override
      public void visit() {
        render();
      }
    };
    frame.setPosition(new Vector(position.x(), position.y(), position.z()));
  }  

  void move() {
    if(scene.eye().reference() == frame){
    frame.rotate(rotateyz * 20 * PI / width, rotatexz * -20 * PI / width, rotatexy * 20 * PI / width, 0.05);
    Vector delta = new Vector(0,0,0);
    delta.add(frame.xAxis().x() *10 * movex, frame.xAxis().y() *10 * movex, frame.xAxis().z() *10 * movex);
    delta.add(frame.yAxis().x() *10 * movey, frame.yAxis().y() *10 * movey, frame.yAxis().z() *10 * movey);
    delta.add(frame.zAxis().x() *10 * movez, frame.zAxis().y() *10 * movez, frame.zAxis().z() *10 * movez);
    frame.translate(delta);
    }
  }



  void render() {
    move();
    pushStyle();
    stroke(color(255, 0, 0));
    fill(color(255, 0, 0));
    beginShape(TRIANGLES);
    vertex( 0 , - sc, 0 - sc * -2);
    vertex(0.71 * sc, 0.71 * sc, 0- sc * -2);
    vertex(-0.71 * sc, 0.71 * sc, 0- sc * -2);

    vertex( 0 , - sc, 0- sc * -2);
    vertex(0.71 * sc, 0.71 * sc, 0- sc * -2);
    vertex(0 , 0, -4 * sc- sc * -2);

    vertex(0.71 * sc, 0.71 * sc, 0- sc * -2);
    vertex(0 , 0, -4 * sc- sc * -2);
    vertex(-0.71 * sc, 0.71 * sc, 0- sc * -2);
    
    vertex(0 , 0, -4 * sc- sc * -2);
    vertex( 0 , - sc, 0- sc * -2);
    vertex(-0.71 * sc, 0.71 * sc, 0- sc * -2);
    endShape();

    popStyle();
  }
}
