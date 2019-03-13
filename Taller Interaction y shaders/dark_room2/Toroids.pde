class Toroid{
  public Frame frame;
  int pts = 40; 
  float angle = 0;
  float radius = 100.0;

  // lathe segments
  int segments = 60;
  float latheAngle = 0;
  float latheRadius = 200.0;

  //vertices
  PVector vertices[], vertices2[];


  Toroid(Vector inPos, Quaternion dir, float radius, float latheRadius) {
    this.radius = radius;
    this.latheRadius = latheRadius;
    frame = new Frame(scene) {
      @Override
      public void visit() {
        render();
      }
    };
    frame.setPosition(inPos);
    frame.setOrientation(dir);
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

  }

  void render() {
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


}
