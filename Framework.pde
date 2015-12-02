import processing.pdf.*;

//Global variables
Node A, B;
int numOfNodes;
float numOfMinutes;
Integrator[][] colorInt;

// nodes
int nodeCount; 
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

// selection
Node selection;

// record
boolean record; 

// edges
int edgeCount; 
Edge[] edges = new Edge[500];

// font
PFont font; 

void setup() {
  size(559, 559);
  font = createFont("SansSerif", 10);
  loadData(); //<>//
  //initialize itegrators
  colorInt = new Integrator[edgeCount][3];
  for (int i = 0; i < edgeCount; i++){
    colorInt[i][0] = new Integrator(hue(edges[i].col));
    colorInt[i][1] = new Integrator(saturation(edges[i].col));   
    colorInt[i][2] = new Integrator(brightness(edges[i].col)); 
  }
  
  A = null;
  B = null;
  numOfNodes = 0;
  numOfMinutes = 0.0;
  initializeActiveDataStructures();
  initializeAdjacencyMatrix();
  print("Please select a starting station.\n");
}

void loadData() {
  Table dataT = new Table("connections.csv");
  for (int i = 0; i < dataT.getRowCount(); i++){
    addEdge(dataT.getString(i, 0), dataT.getString(i, 1), dataT.getFloat(i, 3), dataT.getString(i, 2));
  }
  
}

void addEdge(String fromLabel, String toLabel, float minutes, String col) {
  // find nodes
  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);
  
  // old edge?
  for (int i = 0; i < edgeCount; i++) {
    if (edges[i].from == from && edges[i].to == to) {
      return; 
    }
  }
  
  // add edge
  Edge e = new Edge(from, to, minutes, col);
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e; 
}

Node findNode(String label) {
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label);
  }
  return n; 
}

Node addNode(String label) {
  Table nodeT = new Table("locations.csv");
  int row = nodeT.getRowIndex(label);
  
  if (row==-1){
    print("Error: Invalid node!");
    return null;
  }
  else{
    float x = nodeT.getFloat(row, 1);
    float y = nodeT.getFloat(row, 2);
    Node n = new Node(label, x, y, nodeCount);
    if (nodeCount == nodes.length) {
    nodes = (Node[]) expand(nodes);
    }
    nodeTable.put(label, n);
    nodes[nodeCount++] = n;
    return n; 
  }
}

void draw() {
  for (int i = 0; i < edgeCount; i++){
    for (int j = 0; j < 3; j++){
      colorInt[i][j].update();
    }
  }
  if (record) {
    beginRecord(PDF, "output.pdf");
  }
  background(255); 
  fill(0);
  
  //display mouseover station information
  int row = update(mouseX, mouseY);
  if (row!=-1){
    textFont(font);
    textAlign(RIGHT, TOP);
    text(getStationName(row), width, 0);
  }
  smooth();
  //display shortest-path information
  if(numOfNodes==2){
    textFont(font);
    textAlign(LEFT, TOP);
    text("From: " + A.label, 0, 0);
    text("To: " + B.label, 0, 10);
    text("Travel Time: " + numOfMinutes + " min", 0, 20);
    for (int i = 0; i < edgeCount; i++) {
      if (activeEdges[i]==false){
        colorInt[i][1].target(0);
        colorInt[i][2].target(200);
      }
    }
  }
  

    // draw the edges
    for (int i = 0; i < edgeCount; i++) {
      colorMode(HSB);
      
     edges[i].draw(color((int) colorInt[i][0].value, (int) colorInt[i][1].value, (int) colorInt[i][2].value));
    }
    
    // draw the nodes
    for (int i = 0; i < nodeCount; i++) {
     nodes[i].draw();
    }
    
    if (record) {
      endRecord();
      record = false;
    }
  
  
}

void mousePressed() {
  if (mouseButton == LEFT) {
    float closest = 5;
    for (int i = 0; i < nodeCount; i++) {
      Node n = nodes[i];
      float d = dist(mouseX, mouseY, n.x, n.y);
      if (d < closest) {
        selection = n;
        closest = d;
      }
    }
  }
  if (mouseButton == RIGHT){
    if(numOfNodes==0){ 
      print("Please select a destination station.\n");
      int row = update(mouseX, mouseY); //<>//
      if (row==-1){
        print("Invalid selection.\n");
      }
      else{
        A = findNode(getStationName(row));
        numOfNodes++;
      }
    }
    else if(numOfNodes==1){
      
      int row = update(mouseX, mouseY);
       if (row==-1){
        print("Invalid selection.\n");
      }
      else{
        B = findNode(getStationName(row));
        numOfMinutes = shortestPath(A.getIndex(), B.getIndex());
        numOfNodes++;
      }
    }
    else if(numOfNodes==2){
      
      setup();
    }
  }
}

void mouseDragged() {
  if (selection != null) {
    selection.x = mouseX;
    selection.y = mouseY;
  }
}

void mouseReleased() {
  selection = null;
}

void keyPressed() {
  if (key == 'p') {
    record = true;
  }
}

int update(int x, int y){
  Table nodeT = new Table("locations.csv");
  for(int i = 0; i<nodeT.getRowCount(); i++){
    if (mouseOver(nodeT.getInt(i, 1), nodeT.getInt(i, 2), 3)==true){
      return i;
    }
  }
  return -1;
}

boolean mouseOver(int x, int y, int err){
  float disX = x - mouseX;
  float disY = y - mouseY;
  if(sqrt(sq(disX) + sq(disY)) < err ) {
    return true;
  } else {
    return false;
  }
}

String getStationName(int row){
  Table nodeT = new Table("locations.csv");
  return nodeT.getString(row, 0);
}