//SWAPPING ANIMALS

int player_x = 50;
int player_y = 20;

final int aw = 30;
final int ah = 15;
int nextAnimal = 50;

HashMap<String, PImage> sprites = new HashMap<String, PImage>();

void loadImages() {
  java.io.File folder = new java.io.File(dataPath(""));
  String[] files = folder.list();
  for(String s : files) {
    if(s.endsWith(".jpg") || s.endsWith(".png")) {
      println("Load: " + s);
      PImage i = loadImage(s);
      sprites.put(s.substring(0, s.length() - 4), i);
    }
  }
}

ArrayList<Animal> animals = new ArrayList<Animal>();
ArrayList<Missile> missiles = new ArrayList<Missile>();

class Missile {
  int x = 50;
  int y;
  Missile(int y) {
    this.y=y;
  }

  void missileUpdate() {
    
    x += 5;
  }
  void missileDraw() {
    ellipse(this.x, this.y, 20, 20);
 }
}

class Animal {
  
  int x, y;
  int type;
  boolean spawned = true;
  int spawnDelay = 10;
  String name;
  int xspeed = 0, yspeed = 0;
  
  Animal(int x, int y) {
    this.type = (int) random(0, 10);
    this.x = x;
    this.y = y;
    do {
      this.xspeed = (int) random(-3, 3);
    } while(this.xspeed == 0);
    
    do {
      this.yspeed = (int) random(-3, 3);
    } while(this.yspeed == 0);
    
    this.spawned = true;
    this.spawnDelay = 10;
  }
  
  void update() {
    if(this.spawned) this.spawnDelay--;
    if(this.spawnDelay == 0) this.spawned = false;
    
    this.x += this.xspeed;
    this.y += this.yspeed;
  }
  
  void render() {
    fill(0, 0, 0);
    rect(this.x - aw, this.y - aw, 2 * aw, 2 * ah);
    if(this.spawned) {
      fill(255, 255, 255);
      rect(this.x - 20, this.y - 20, 40, 40);
    }
  }
}

void setup() {
  loadImages();
  size(810, 540);
  frameRate(30);
  strokeWeight(0);
  
  for(int i = 1; i < 5; i++) {
    animals.add(new Animal((int) random(0, 640), (int) random(0, 360)));
  }
}

void draw() {
  nextAnimal--;
  if(nextAnimal == 0) {
    animals.add(new Animal((int) random(0, 640), (int) random(0, 360)));
    nextAnimal = (int) random(10, 500);
  }
  
  image(sprites.get("background"), 0, 0);
  
  if(keyPressed) {
    if(key == 'z' && player_y - 5 > 20) player_y -= 5;
    if(key == 's' && player_y + 5 < 520) player_y += 5;
  }
  
  for(Animal a : animals) {
    a.update();
    //if(a.x < -aw || a.x > width + aw || a.y < ah || a.y > height + ah) animals.remove(a); 
  }
  
  for(Animal a : animals) {
    a.render();
  }
  
  fill(255, 255, 255);
  
  for(Missile m : missiles) {
    m.missileUpdate();
  }
  
  for(Missile m : missiles) {
    m.missileDraw();
  }
  
  image(sprites.get("trump0"), player_x, player_y);
}

void keyPressed() {
  if(key == ' ') missiles.add(new Missile(player_y));
}