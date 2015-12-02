import java.awt.Color;

class Edge {
  Node from; 
  Node to; 
  float minutes;
  color col;
  
  Edge(Node from, Node to, float minutes, String col) {
    this.from = from; 
    this.to = to; 
    this.minutes = minutes;
    this.setColor(col);
  }
  
  void setColor(String col){
    if (col.equals("red")){
      this.col = color(230, 19, 16);
    }
    else if (col.equals("green")){
      this.col = color(1, 104, 66);
    }
    else if (col.equals("blue")){
      this.col = color(0, 48, 140);
    }
    else if (col.equals("orange")){
      this.col = color(255, 131, 5);
    }
  }
  
  
  Node getFromNode() {
    return from;
  }
  
  Node getToNode() {
    return to;
  }
  
  float getMinutes() {
    return minutes;
  }
  
  
  void draw() {
    stroke(col); 
    strokeWeight(2);
    line(from.x, from.y, to.x, to.y);
    
  }
  
  void draw(color col){
    stroke(col);
    strokeWeight(2);
    line(from.x, from.y, to.x, to.y);
  }
  
}  