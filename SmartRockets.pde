class Target{
   int x, y; 
  Target(int x, int y){
   this.x = x; 
   this.y = y; 
 }
 void display(){
    fill(198, 196, 196); 
    ellipse(x, y, 50, 50);  
 }
  
}

class Rocket{
   PVector location, velocity, acceleration; 
   
   
}
Target t = new Target(300, 50); 
void setup(){
   size(600, 600); 
   background(0); 
}


void draw(){
  
  background(0); 
  t.display(); 
  
}