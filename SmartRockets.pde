int lifeSpan = 400; 
int count = 0; 
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


Target t = new Target(300, 50); 
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
  if(count == 400){
     pop = new Population(); 
     count = 0; 
  }
}