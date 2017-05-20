int lifeSpan = 600; 
int count = 0; 
int generation = 0; 
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
  PVector location = new PVector(width/2, height);  
  PVector velocity = new PVector(); 
  PVector acceleration = new PVector();  
  int id; 
  DNA dna; 
  float fitness; 
  boolean completed; 
  Rocket() {
    dna = new DNA(); 
  }
  Rocket(DNA dna){
     this.dna = dna;  
  }
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void update() {
    float distance = dist(location.x, location.y, t.x, t.y); 
    if(distance < 25){
      completed = true; 
      location = new PVector(t.x, t.y); 
    }
    applyForce(dna.genes[count]); 
    if(!completed){
      velocity.add(acceleration); 
      location.add(velocity); 
      acceleration.mult(0);
    }
  }

  void calcFitness() {
    float distance = dist(location.x, location.y, t.x, t.y); 

    fitness = map(distance, 0, width, width, 0);
    if(completed){
       fitness *= 10;
       if(count < lifeSpan * 0.8){
          fitness *= 10;  
       }
    }
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
  String toString(){
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
  void mutation(){
     for(int i = 0; i < genes.length; i++){
        if(random(1) < 0.01){
           genes[i] = PVector.random2D();  
           genes[i].setMag(0.1);  
        }
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
  //println(pop.rockets.length); 
}