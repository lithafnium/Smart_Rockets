int lifeSpan = 600; 
int count = 0; 
Target t = new Target(300, 50); 

class Target {
  int x, y; 
  Target(int x, int y) {
    this.x = x; 
    this.y = y;
  }
  void display() {
    fill(198, 196, 196); 
    ellipse(x, y, 50, 50);
  }
}

class Rocket {
  PVector location, velocity, acceleration; 
  DNA dna = new DNA(); 
  float fitness; 
  Rocket() {
    location = new PVector(width/2, height); 
    velocity = new PVector(); 
    acceleration = new PVector();
  }
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void update() {
    applyForce(dna.genes[count]); 
    velocity.add(acceleration); 
    location.add(velocity); 
    acceleration.mult(0);
  }
  
  void calcFitness(){
      float distance = dist(location.x, location.y, t.x, t.y); 
      
      fitness = map(distance, 0, width, width, 0); 
  }

  void show() {
    pushMatrix(); 
    noStroke(); 
    fill(255, 150); 
    translate(location.x, location.y); 
    rotate(velocity.heading()); 
    rectMode(CENTER); 
    rect(0, 0, 25, 5);
    popMatrix();
  }
}

class Population {
  int populationSize = 25; 
  Rocket[] rockets = new Rocket[populationSize]; 
  ArrayList<Rocket> matingPool = new ArrayList<Rocket>(); 
  Population() {
    for (int i = 0; i < populationSize; i++) {
      rockets[i] = new Rocket();
    }
  }

  void run() {
    for (int i = 0; i < populationSize; i++) {
      rockets[i].update(); 
      rockets[i].show();
    }
  }
  
  void evaluate(){
    float maxFitness = 0; 
     for(int i = 0; i < populationSize; i++){
        rockets[i].calcFitness();  
        maxFitness = rockets[i].fitness > maxFitness ? rockets[i].fitness : maxFitness;
       
     }
     for(int i = 0; i < populationSize; i++){
        rockets[i].fitness /= maxFitness;  
     }
     matingPool = new ArrayList<Rocket>(); 
     for(int i = 0; i < populationSize; i++){
         int n = (int)rockets[i].fitness * 100; 
         for(int i = 0; i < n; i++){
            matingPool.add(rockets[i]);  
         }
      }
     
     //matingPool = new Rocket[]; 
  }
  void selection(){
     int parentAIndex = random(0, matingPool.size()); 
     Rocket parentA = random(matingPool);  
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
  
}


Rocket r; 
Population pop; 
void setup() {
  size(600, 600); 
  background(0); 
  r = new Rocket(); 
  pop = new Population();
}


void draw() {
  
  background(0); 
  t.display(); 
  //r.update(); 
  //r.show(); 
  pop.run();
  count++; 
  if(count == lifeSpan){
     pop = new Population(); 
     count = 0; 
  }
}