import controlP5.*; 

int lifeSpan = 600; 
int count = 0; 
int generation = 0; 
float mutationRate = 0.01; 
float mag = 0.2; 
float red = 255;
float blue = 255; 
float green = 255; 
float alpha = 150; 
Target t = new Target(300, 50); 
Obstacle o = new Obstacle(300, 300, 400, 10); 
Rocket r; 
Population pop; 

class Obstacle {
  int x, y, w, h; 
  boolean draggable; 
  Obstacle(int x, int y, int w, int h) {
    this.x = x; 
    this.y = y;
    this.w = w; 
    this.h = h;
  }

  void display() {
    fill(255, 150); 
    rect(x, y, w, h);
  }
}

class Target {
  int x, y; 
  int radius = 50; 
  boolean draggable; 
  Target(int x, int y) {
    this.x = x; 
    this.y = y;
  }
  void display() {
    fill(255, 0, 0); 
    ellipse(x, y, radius, radius);
    fill(255); 
    ellipse(x, y, radius - 10, radius - 10);
    
    fill(255, 0, 0); 
    ellipse(x, y, radius - 20, radius - 20);
    
    fill(255); 
    ellipse(x, y, radius - 30, radius - 30);
    fill(255 , 0, 0); 
    ellipse(x, y, radius - 40, radius - 40);
  }
}

class Rocket {
  PVector location = new PVector(width/2, height);  
  PVector velocity = new PVector(); 
  PVector acceleration = new PVector();  
  int id; 
  DNA dna; 
  float fitness; 
  boolean completed = false; 
  boolean dead = false; 
  Rocket() {
    dna = new DNA();
  }
  Rocket(DNA dna) {
    this.dna = dna;
  }
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void update() {
    float distance = dist(location.x, location.y, t.x, t.y); 
    if (distance < 25) {
      completed = true; 
      location = new PVector(t.x, t.y);
    }
    if(location.x >= o.x - o.w/2 && location.x <= o.x + o.w/2 && location.y >= o.y - o.h/2 && location.y <= o.y + o.h/2){
       dead = true; 
       
       location = new PVector(location.x, location.y); 
    }
    applyForce(dna.genes[count]); 


    if (!completed && !dead) {
      velocity.add(acceleration); 
      location.add(velocity); 
      acceleration.mult(0);
    }
  }

  void calcFitness() {
    float distance = dist(location.x, location.y, t.x, t.y); 

    fitness = map(distance, 0, width, width, 0);
    if (completed) {
      fitness *= 10;
      if (count < lifeSpan * 0.8) {
        fitness *= 10;
      }
    }
    if(dead){
      
       fitness /= 100;  
    }
  }

  void show() {
    pushMatrix(); 
    noStroke(); 
    if(dead){
      red = 255; 
       green = 0; 
       blue = 0;  
    }
    else if(completed){
      red = 0; 
      blue = 0; 
      green = 255; 
    }
    else {
       red = 255; 
       green = 255; 
       blue = 255; 
    }
    fill(red, green, blue, alpha); 
    
    translate(location.x, location.y); 
    rotate(velocity.heading()); 
    rectMode(CENTER); 
    rect(0, 0, 25, 5);
    popMatrix();
  }
  String toString() {
    return "Id: " + id + " " + "Location: " + "(" + location.x + ", " + location.y +  ")";
  }
}

class Population {
  int populationSize = 25; 
  Rocket[] rockets = new Rocket[populationSize]; 
  ArrayList<Rocket> matingPool = new ArrayList<Rocket>(); 
  Population() {
    for (int i = 0; i < populationSize; i++) {
      rockets[i] = new Rocket();
      rockets[i].id = i;
    }
  }

  void run() {
    for (int i = 0; i < populationSize; i++) {
      //  println(rockets[i].toString()); 
      rockets[i].update(); 
      rockets[i].show();
    }
  }

  void evaluate() {
    float maxFitness = 0; 
    for (int i = 0; i < populationSize; i++) {
      rockets[i].calcFitness();  
      maxFitness = rockets[i].fitness > maxFitness ? rockets[i].fitness : maxFitness;
    }
    for (int i = 0; i < populationSize; i++) {
      rockets[i].fitness /= maxFitness;
    }
    matingPool = new ArrayList<Rocket>(); 
    for (int i = 0; i < populationSize; i++) {
      int n = (int)(rockets[i].fitness * 100); 
      for (int j = 0; j < n; j++) {
        matingPool.add(rockets[i]);
      }
    }
    //println(matingPool.size()); 

    //matingPool = new Rocket[];
  }
  void selection() {
    // Rocket[] newRockets = new Rocket[rockets.length]; 

    for (int i = 0; i < rockets.length; i++) {
      int parentAIndex = (int)random(matingPool.size()); 
      int parentBIndex = (int)random(matingPool.size());
      // println(parentAIndex + " " + parentBIndex); 
      DNA parentA = matingPool.get(parentAIndex).dna; 
      DNA parentB = matingPool.get(parentBIndex).dna; 

      PVector[] child = parentA.crossover(parentB);

      DNA newDNA = new DNA(child); 
      newDNA.mutation(); 
      int id = rockets[i].id; 
      rockets[i] = new Rocket(newDNA); 
      // rockets[i].dna.genes = child; 
      rockets[i].id = id; 
      //newRockets[i].id = rockets[i].id; 
      //println("New Rocket: " + newRockets[i].toString());
    }
    // rockets = newRockets;
  }
}
class DNA {
  PVector[] genes = new PVector[lifeSpan]; 
  DNA() {

    for (int i = 0; i < lifeSpan; i++) {
      genes[i] = PVector.random2D();
      genes[i].setMag(0.1);
    }
  }
  DNA(PVector[] genes) {

    this.genes = genes;
  }

  PVector[] crossover(DNA partner) {
    //DNA newdna = new DNA(); 
    PVector[] newdna = new PVector[lifeSpan]; 
    int mid = (int)(random(genes.length)); 
    // println(mid); 
    //println("=============");
    for (int i = 0; i < genes.length; i++) {
      if (i > mid) {
        // println(true); 
        newdna[i] = this.genes[i];
      } else {
        // println(false);
        newdna[i] = partner.genes[i];
      }
    }
    //println("==========="); 
    return newdna;
  }
  void mutation() {
    for (int i = 0; i < genes.length; i++) {
      if (random(1) < mutationRate) {
        genes[i] = PVector.random2D();  
        genes[i].setMag(mag);
      }
    }
  }
}



void setup() {
  size(800, 600); 
  background(0); 
  r = new Rocket(); 
  pop = new Population();
}


void draw() {
  rectMode(CENTER); 
  background(0); 
  o.display(); 
  t.display(); 
  //r.update(); 
  //r.show(); 
  pop.run();
  count++; 
  textSize(12); 
  fill(255); 
  text("Generation: " + generation, 50, 50); 
  text("Time: " + count, 50, 65); 

  if (count == lifeSpan) {
    pop.evaluate(); 
    pop.selection(); 
    count = 0;
    generation++;
  }
  if ((dist(t.x, t.y, mouseX, mouseY) <= t.radius/2) || (mouseX >= o.x - o.w/2 && mouseX <= o.x + o.w/2 && mouseY >= o.y - o.h/2 && mouseY <= o.y + o.h/2) ) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }

  if (t.draggable) {
    t.x = mouseX; 
    t.y = mouseY;
  }
  if(o.draggable){
     o.x = mouseX; 
     o.y = mouseY; 
  }
  //println(pop.rockets.length);
}

void mouseDragged() {
  if (dist(t.x, t.y, mouseX, mouseY) <= t.radius/2) {
    t.draggable = true;
  }
  if (mouseX >= o.x - o.w/2 && mouseX <= o.x + o.w/2 && mouseY >= o.y - o.h/2 && mouseY <= o.y + o.h/2) {
    
    o.draggable = true;
  }
}

void mouseReleased() {
  t.draggable = false;
  o.draggable = false; 
}