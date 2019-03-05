float segments = 50.0;

float CubicHermite (float A, float B, float C, float D, float t)
{
    float a = -A/2.0f + (3.0f*B)/2.0f - (3.0f*C)/2.0f + D/2.0f;
    float b = A - (5.0f*B)/2.0f + 2.0f*C - D / 2.0f;
    float c = -A/2.0f + C/2.0f;
    float d = B;
  
    return a*t*t*t + b*t*t + c*t + d;
}



Vector CubicBezier(Vector A, Vector B, Vector C, Vector D, float t)
{
  float x[] = {A.x(), B.x(), C.x(), D.x()};
  float y[] = {A.y(), B.y(), C.x(), D.y()};
  float z[] = {A.z(), B.z(), C.x(), D.z()};
  float px=(1-t)*(1-t)*(1-t)*x[0]+3*t*(1-t)*(1-t)*x[1]+3*t*t*(1-t)*x[2]+t*t*t*x[3];
  float py=(1-t)*(1-t)*(1-t)*y[0]+3*t*(1-t)*(1-t)*y[1]+3*t*t*(1-t)*y[2]+t*t*t*y[3];
  float pz=(1-t)*(1-t)*(1-t)*z[0]+3*t*(1-t)*(1-t)*z[1]+3*t*t*(1-t)*z[2]+t*t*t*z[3];
  return new Vector(px,py,pz);
}

Vector lerp(Vector a, Vector b, float t)
{
    return new Vector(a.x() + (b.x()-a.x())*t,a.y() + (b.y()-a.y())*t,a.z() + (b.z()-a.z())*t);    
}

Vector deCasteljau(ArrayList<Vector> points, float t){
  ArrayList<Vector> to = new ArrayList();  
  for(int i = 0; i< points.size()-1; i++)
    to.add(lerp(points.get(i),points.get(i+1),t));
  if(to.size() == 1)
    return to.get(0);
  return deCasteljau(to, t);
}


void draw_Bezier3(Boid a,Boid b,Boid c,Boid d){
  beginShape();
  stroke(255,0,255);
  for(float i = 0; i<segments; i+=1.0){
    Vector v = CubicBezier(a.frame.position(),b.frame.position(),c.frame.position(),d.frame.position(),1.0/segments * i);
    vertex(v.x(),v.y(),v.z());

  }
    endShape();
}

void drawDeCastejau(ArrayList<Boid> boids){
  ArrayList<Vector> points = new ArrayList();
  for(Boid b : boids)points.add(b.frame.position());
  noFill();
  beginShape();
  stroke(124,23,200);
  for(float i = 1.0; i<=segments; i+=1.0){
    Vector v = deCasteljau(points, 1/segments * i);
    vertex(v.x(),v.y(),v.z());
  }
  endShape();
}

void draw_CubicHermite(Boid a,Boid b,Boid c,Boid d){
  float x,y,z;
  //System.out.println(a.frame.position().x());
  ArrayList<Vector> ar = new ArrayList();
  ar.add(a.frame.position());
  ar.add(b.frame.position());
  ar.add(c.frame.position());
  ar.add(d.frame.position());
  noFill();
  beginShape();
  stroke(255,0,0);
  for(int j = 0; j<4; j++){
  for(float i = 0; i<segments; i+=1.0){
    x = CubicHermite(ar.get(max(0,j-1)).x(), ar.get(j).x(),ar.get(min(3,j+1)).x(),ar.get(min(3,j+2)).x(),1.0/segments * i);
    y = CubicHermite(ar.get(max(0,j-1)).y(), ar.get(j).y(),ar.get(min(3,j+1)).y(),ar.get(min(3,j+2)).y(),1.0/segments * i);
    z = CubicHermite(ar.get(max(0,j-1)).z(), ar.get(j).z(),ar.get(min(3,j+1)).z(),ar.get(min(3,j+2)).z(),1.0/segments * i);
    vertex(x,y,z);
  }
  }
  endShape();
}
