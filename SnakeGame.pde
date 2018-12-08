// Declare and initialize Snake object
int girth = 25;
Snake snek;
// Declare and initialize Food object
Food morsel = new Food(girth);
int cols;
int rows;
int roundness = 7;
// Directions
int dir = 0;
int lastDir = 0;
// Frame counter
int fRate = 15;
int framer = 0;
int [][] tempShade = null;
// Score
int mScore = 0;
int mHighScore = 0;
int goalsAccomplished = 0;
// Pausing variable
boolean paused = false;

int pickBckgShade(int min, int max){
  return int(random(min, max));
}
int pickRandLoc(int dims){
  return int(random(dims)) * girth;
}
int pickRandDir(){
  int randir = int(random(4));
  switch (randir){
    case 0:
      randir = UP;
      break;
    case 1:
      randir = DOWN;
      break;
    case 2:
      randir = LEFT;
      break;
    case 3:
      randir = RIGHT;
      break;
  }
  return randir;
}
void keyPressed(){
  if (key == 27)
      exit();
  else if (key == 'p'){
    paused = !paused;
  }
  if (paused)
    noLoop();
  else if (!paused && !looping)
    loop();
}
void setup(){
  frameRate(fRate);  // limit frame rate to make movement blocky
  fullScreen();
  background(230);
  noStroke();
  dir = pickRandDir();
  cols = width / girth;
  rows = height / girth;
  tempShade = new int[rows][cols];
  snek = new Snake(pickRandLoc(cols), pickRandLoc(rows), girth);
  morsel.setLoc();
}
void draw(){
  // Cyclically reset frame counter
  if (framer > fRate)
    framer = 0;
  // Check if ESC is pressed to close program (27 is the ASCII code for ESC)
  if (keyPressed){
    if ((key == 'w' || keyCode == UP) && lastDir != DOWN){
      dir = UP;
      goalsAccomplished++;
    }
    if ((key == 'a' || keyCode == LEFT) && lastDir != RIGHT){
      dir = LEFT;
      goalsAccomplished++;
    }
    if ((key == 's' || keyCode == DOWN) && lastDir != UP){
      dir = DOWN;
      goalsAccomplished++;
    }
    if ((key == 'd' || keyCode == RIGHT) && lastDir != LEFT){
      dir = RIGHT;
      goalsAccomplished++;
    }
  }
  // Draw Background
  background(230);
  if (framer == 0 || framer == fRate / 2){
    for (int i = 0; i < cols; i++){
      for (int j = 0; j < rows; j++){
        tempShade[j][i] = pickBckgShade(235, 242);
      }
    }
  }
  for (int i = 0; i < cols; i++){
    for (int j = 0; j < rows; j++){
      fill(tempShade[j][i]);
      //fill(0);
      rect(i * girth, j * girth, girth, girth, roundness);
    }
  }
  // Draw score and high score
  textSize(32);
  fill(200, 100, 200);
  text("Score: " + mScore, 60, 60);
  fill(150, 100, 150);
  text("High Score: " + mHighScore, 60, 100);
  // Draw instructions and how to exit
  textSize(14);
  fill(100, 100, 100);
  text("Press ESCAPE to exit...", width - 200, 50);
  text("Press P to pause/unpause...", width - 200, 74);
  text("Game by Suhayl Kodiriy", width - 200, height - 50);
  if (goalsAccomplished < 15){
    textSize(18);
    //fill(100, 100, 100);
    text("Use WASD or the arrow keys to move!", width / 2 - 200, 50);
    text("Eat colored food to grow!", width / 2 - 150, 75);
  }
  // Draw objects
  snek.update();
  snek.display();
  if (snek.eat(morsel)){
    mScore++;
    morsel.setLoc();
    morsel.pickRandomColor();
    goalsAccomplished++;
  }
  morsel.display();
  // If player goes out of bounds or collides with themselves, game over / restart game
  if (snek.collide() || snek.outOfBounds()){
    if (mScore > mHighScore)
      mHighScore = mScore;
    mScore = 0;
    dir = pickRandDir();
    snek = new Snake(pickRandLoc(cols), pickRandLoc(rows), girth);
  }
  // Iterate frame counter
  framer++;
}

class Food {
  int posX;
  int posY;
  int w;
  int R, G, B;
  
  Food(int fatness){
    posX = width - girth;  // default location
    posY = height - girth; // default location
    w = fatness;
    pickRandomColor();
  }
  void pickRandomColor(){
    R = int(random(70, 230));
    G = int(random(70, 230));
    B = int(random(70, 230));
  }
  void setLoc(){
    posX = pickRandLoc(cols);
    posY = pickRandLoc(rows);
  }
  void display(){
    fill(R, G, B);
    rect(posX, posY, w, w, roundness);
  }
}

class Segment {
  int x;
  int y;
  int R, G, B;
  
  Segment(int u, int v){
    x = u;
    y = v;
    do {
      R = int(random(70, 255));
      G = int(random(70, 255));
      B = int(random(70, 255));
    }while (R == G && G == B);
  }
  Segment(int u, int v, int R, int G, int B){
    x = u;
    y = v;
    this.R = R;
    this.G = G;
    this.B = B;
  }
}

class Snake {
  int w;  // width of rectangle
  ArrayList<Segment> body = new ArrayList<Segment>(2);
  
  Snake(int X, int Y, int fatness){
    body.add(new Segment(X, Y));
    body.add(new Segment(X + w, Y));
    w = fatness;
  }
  void update(){
    // Update body segments
    // Propogate current speed to rest of body, then give head new speed
    // Also save tail's color
    int R, G, B;
    Segment tail = body.get(body.size()-1);
    R = tail.R;
    G = tail.G;
    B = tail.B;
    body.remove(body.size()-1);
    tail = null;
    
    Segment newhead = body.get(0);  // Get current position of head
    // Take care of Snake movement
    if (dir == UP){
      // prevent backwards movement when snake longer than 1 segment
      newhead = new Segment(newhead.x, newhead.y - w, R, G, B);
      lastDir = dir;
    }
    if (dir == LEFT){
      newhead = new Segment(newhead.x - w, newhead.y, R, G, B);
      lastDir = dir;
    }
    if (dir == DOWN){
      newhead = new Segment(newhead.x, newhead.y + w, R, G, B);
      lastDir = dir;
    }
    if (dir == RIGHT){
      newhead = new Segment(newhead.x + w, newhead.y, R, G, B);
      lastDir = dir;
    }
    body.add(0, newhead);
  }
  boolean eat(Food foo){
    float d = dist(body.get(0).x, body.get(0).y, foo.posX, foo.posY);  // distance between snake head and food
    int indexLast = body.size() - 1;
    if (d < 1){
      Segment s = new Segment(body.get(indexLast).x - w, body.get(indexLast).y - w, foo.R, foo.G, foo.B);
      body.add(s);
      return true;
    }
    return false;
  }
  boolean collide(){
    for (int i = 1; i < body.size(); i++){
      if (body.get(i).x == body.get(0).x && body.get(i).y == body.get(0).y){
        return true;
      }
    }
    return false;
  }
  boolean outOfBounds(){
    Segment head = body.get(0);
    if (head.x > width || head.x < 0 || head.y > height || head.y < 0){
      return true;
    }
    return false;
  }
  void display(){
    for (Segment s: body){
      fill(s.R, s.G, s.B);
      //fill(255, 255, 255);
      rect(s.x, s.y, w, w, roundness);
    }
  }
}