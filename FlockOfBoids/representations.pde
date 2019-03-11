import java.*;

boolean immediate = false, genShape = false;
HashMap<String, PShape> shape = new HashMap();

PShape grid;

class Face{
    ArrayList<Vector> vertexs;
    String s;
    
    public Face(ArrayList<Vector> vertexs){
      this.vertexs = vertexs;
    }
    public void set_vertexs(ArrayList<Vector> vertexs){
      this.vertexs = vertexs;
    }
    public ArrayList<Vector> get_vertexs(){
      return vertexs;
    }
    
    public void renderImmediate(){
      beginShape(TRIANGLES);
      for(Vector v : vertexs){
        vertex(v.x(),v.y(),v.z());
      }
      endShape();
    }
    
    public PShape get_shape(){
      if(s == null){
        s = vertexs.get(0).toString()+vertexs.get(1).toString()+vertexs.get(2).toString();
      }
      if(!shape.containsKey(s)){
        PShape shape1;
        shape1 = createShape();
        shape1.beginShape();
        for(Vector v : vertexs) shape1.vertex(v.x(),v.y(),v.z());
        shape1.endShape();
        shape.put(s,shape1);
        grid.addChild(shape1);
      }
      return shape.get(s);
    }
     
}

class FaceVertex{
  ArrayList<Vector> vertexs;
  ArrayList<Face> faces;
  public FaceVertex(float sc){
    vertexs = new ArrayList();
    faces = new ArrayList();
    int it = 0;
    for(int a = 1; a<2; a+=2)for(int b = 1; b<2; b+=2)for(int c = 1; c<2; c+=2){
    vertexs.add( new Vector(3*a * sc, 0, 0)); // pos 0
    vertexs.add( new Vector(-3*a * sc, 2*b * sc, 0)); // pos  1
    vertexs.add( new Vector(-3*a * sc, -2*b * sc, 0)); // pos 2
    faces.add(new Face( new ArrayList<Vector>() ) );
    for(int i = 0; i<3; i++) faces.get(it*4 + 0).get_vertexs().add(vertexs.get(it*4 + i));
    
    //Vector(3 * sc, 0, 0); -> pos 0
    //Vector(-3 * sc, 2 * sc, 0); -> pos 1
    vertexs.add( new Vector(-3*a * sc, 0, 2*c * sc));  // pos 3
    faces.add(new Face( new ArrayList<Vector>() ) );
    int f2[] = {0,1,3};
    for(int i = 0; i<3; i++) faces.get(it*4 + 1).get_vertexs().add(vertexs.get(it*4 + f2[i]));
    
    //Vector(3 * sc, 0, 0); -> pos 0;
    //Vector(-3 * sc, 0, 2 * sc); -> pos 3
    //Vector(-3 * sc, -2 * sc, 0); -> pos 2
    faces.add(new Face( new ArrayList<Vector>() ) );
    int f3[] = {0,2,3};
    for(int i = 0; i<3; i++) faces.get(it*4 + 2).get_vertexs().add(vertexs.get(it*4 + f3[i]));
    
    //Vector(-3 * sc, 0, 2 * sc)); pos ->3 
    //Vector(-3 * sc, 2 * sc, 0); -> pos 1
    //Vector(-3 * sc, -2 * sc, 0); -> pos 2
    faces.add(new Face( new ArrayList<Vector>() ) );
    int f4[] = {1,2,3};
    for(int i = 0; i<3; i++) faces.get(it*4 + 3).get_vertexs().add(vertexs.get(it*4 + f4[i]));
    
    it++;
    
    }
  }
  public void draw(){
    if(immediate){
      beginShape(TRIANGLES);
      for(Face f : faces) f.renderImmediate();
      endShape();
    }else{
      if(!genShape){
        grid = createShape(GROUP);
        for(Face f : faces)f.get_shape();
        genShape = true;
      }else {
        shape(grid);
    }    }
  }
}

class Edge{
  ArrayList<Vector> vertexs;
  ArrayList<Face> faces;
  ArrayList<Edge> ad_edges;
  
  public Edge(Vector a, Vector b){
    vertexs = new ArrayList();
    ad_edges = new ArrayList();
    faces  = new ArrayList();
    vertexs.add(a);
    vertexs.add(b);
  }
  public ArrayList<Vector> getVertexs(){
    return vertexs;
  }
  public ArrayList<Face> getFaces(){
    return faces;
  }
  public ArrayList<Edge> getEdges(){
    return ad_edges;
  }
}

class WingedEdge extends FaceVertex{
  ArrayList<Edge> edges;
  public WingedEdge(float sc){
    super(sc);
    edges = new ArrayList();
    for(int i = 0; i<4;i++)
      for(int j = i+1; i<4;i++)
        edges.add(new Edge(vertexs.get(i), vertexs.get(j)));
    for(Edge i : edges)
      for(Edge j : edges)
        if(i.getVertexs().get(0)== j.getVertexs().get(0) || i.getVertexs().get(1)== j.getVertexs().get(1)
              || i.getVertexs().get(1)== j.getVertexs().get(0) || i.getVertexs().get(0)== j.getVertexs().get(1)){
          i.getEdges().add(j);
          j.getEdges().add(i);
        }
    for(Edge e : edges){      
      for(Face f: faces){
        int c = 0;
        for(Vector v : f.get_vertexs()){
          if(e.getVertexs().get(0) == v || e.getVertexs().get(1) == v)c++;
        }
        if(c>1) e.getFaces().add(f);
      }
    }
  }
}
