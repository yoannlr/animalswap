import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;

int player_x = 50;
int player_y = 220;
int nextAnimal = 50;
int points = 0;

int state = -1;
boolean showTutorial = true;
boolean soundsEnabled = false;

HashMap<String, PImage> sprites = new HashMap<String, PImage>();

//charge toutes les images du dossier data dans une arraylist avec leur nom sans extension comme identifier
void loadImages() {
  java.io.File folder = new java.io.File(dataPath(""));
  String[] files = folder.list();
  for(String s : files) {
    if(s.endsWith(".jpg") || s.endsWith(".png")) {
      println("Load: " + s + " as " + s.substring(0, s.length() - 4));
      PImage i = loadImage(s);
      sprites.put(s.substring(0, s.length() - 4), i);
    }
  }
}


HashMap<String, AudioSample> sounds = new HashMap<String, AudioSample>();

//charge tous les sons du dossier data en tant qu'audioSample de minim
void loadSounds() {
  java.io.File folder = new java.io.File(dataPath(""));
  String[] files = folder.list();
  for(String s : files) {
    if(s.endsWith(".wav")) {
      println("Load: " + s + " as " + s.substring(0, s.length() - 4));
      AudioSample a = minim.loadSample(s);
      sounds.put(s.substring(0, s.length() - 4), a);
    }
  }
}

ArrayList<Animal> animals = new ArrayList<Animal>();
ArrayList<Missile> missiles = new ArrayList<Missile>();

Animal touched1;
Animal touched2;

class Missile {
  int x = 120 ;
  int y;
  int w = 20;
  int h = 10;
  Missile(int y) {
    this.y=y;
    if(soundsEnabled) sounds.get("missile").trigger();
  }

  void missileUpdate() {
    x += 5;
    for(Animal a : animals) {
      if(this.x + this.w > a.x && this.x < a.x + a.w && this.y + this.h > a.y && this.y < a.y + a.h) {
        if(touched1 == null) {
          touched1 = a;
          a.xspeed = 0;
          a.yspeed = 0;
          this.y = -30;
        } else if(touched1 != a && touched2 == null) {
          touched2 = a;
          a.xspeed = 0;
          a.yspeed = 0;
          this.y = -30;
        }
        
        if(touched1 != null && touched2 != null) {
          if(touched1.body != touched1.head || touched2.body != touched2.head) points += 20;      //si l'animal a deja ete swap, 2 fois plus de points !
          else if(touched1.body == touched1.head && touched2.body == touched2.head && touched1.body == touched2.body) points -= 15;    //malus si on swap 2 animaux identiques
          else points += 10;
          
          int tmpbody = touched1.body;
          touched1.body = touched2.body;
          touched2.body = tmpbody;
          
          touched1.setNewSpeed();
          touched2.setNewSpeed();
          
          touched1 = null;
          touched2 = null;
        }
      }
    }
  }
  void missileDraw() {
    rect(this.x, this.y, this.w, this.h);
 }
}

class Animal {
  int x, y, w = 60, h = 30;              //x y longueur et largeur de l'animal
  int head = 0, body = 0;                //type d'animal pour sa tete et pour son corps
  boolean newAnimal = true;              //l'animal vient d'apparaitre
  int animationDelay = 10;               //delai pour l'animation d'apparition
  int xspeed = 0, yspeed = 0;            //vitesse de deplacement
  
  Animal(int x, int y) {
    this.head = (int) random(0, 8);
    this.body = this.head;
    this.x = x;
    this.y = y;
    
    //applique une vitesse aleatoire differente de 0 a l'animal
    setNewSpeed();
    
    if(soundsEnabled) sounds.get("animal" + this.body);
  }
  
  void update() {
    if(this.newAnimal) this.animationDelay--;
    if(this.animationDelay == 0) this.newAnimal = false;
    
    this.x += this.xspeed;
    this.y += this.yspeed;
  }
  
  void render() {
    fill(0, 0, 0);
    image(sprites.get("head" + this.head), this.x, this.y);
    image(sprites.get("body" + this.body), this.x + 30, this.y);
    if(this.newAnimal) {
      image(sprites.get("spawn_particle"), this.x, this.y);
    }
  }
  
  void setNewSpeed() {
    do {
      this.xspeed = (int) random(-2, 2);
    } while(this.xspeed == 0);
    
    do {
      this.yspeed = (int) random(-2, 2);
    } while(this.yspeed == 0);
  }
}

void setup() {
  minim = new Minim(this);
  loadImages();
  loadSounds();
  size(810, 540);
  frameRate(30);
  strokeWeight(0);
  
  for(int i = 1; i < 5; i++) {
    animals.add(new Animal((int) random(0, 640), (int) random(0, 360)));
  }
  
  state = 0;
  image(sprites.get("menu"), 0, 0);
}

void draw() {
  if(state == 1) {
    nextAnimal--;
    if(nextAnimal == 0) {
      animals.add(new Animal((int) random(200, 810), (int) random(0, 540)));
      nextAnimal = (int) random(10, 200);
    }
    
    image(sprites.get("background"), 0, 0);
    
    if(keyPressed) {
      if(key == 'z' && player_y - 5 > 20) player_y -= 5;
      if(key == 's' && player_y + 5 < 380) player_y += 5;
    }
    
    ArrayList<Animal> deadAnimals = new ArrayList<Animal>();
    for(Animal a : animals) {
      a.update();
      if(a.x < 0 || a.x > width || a.y < 0 || a.y > height) {
        deadAnimals.add(a);
        if(touched1 == a) touched1 = null;
        if(touched2 == a) touched2 = null;
      }
    }
    animals.removeAll(deadAnimals);
    
    for(Animal a : animals) {
      a.render();
    }
    
    fill(255, 255, 255);
    
    ArrayList<Missile> lostMissiles = new ArrayList<Missile>();
    for(Missile m : missiles) {
      m.missileUpdate();
      if(m.x > width) lostMissiles.add(m);
    }
    missiles.removeAll(lostMissiles);
    
    for(Missile m : missiles) {
      m.missileDraw();
    }
    
    image(sprites.get("forest"), 0, 0);
    
    image(sprites.get("trump0"), player_x, player_y);
    
    if(showTutorial) image(sprites.get("tutorial"), 0, 0);
    
    text("SCORE: " + points, 370, 20);
  }
}

void mouseClicked() {
  if(mouseX > 340 && mouseY > 230 && mouseX < 730 && mouseY < 380 && state == 0) state = 1;
}

void keyPressed() {
  if(state == 1 && showTutorial) showTutorial = false;
  if(key == ' ' && state == 1) missiles.add(new Missile(player_y + 65));
}