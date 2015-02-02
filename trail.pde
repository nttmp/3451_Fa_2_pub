class TRAIL {
  ArrayList<Coord> trail = new ArrayList<Coord>();
  int trailSize = 30;
  int prev;
  float incFactor = 1;  //Controls the factor of increase when drawing ellipses
  float eSize = 5;  //Starting size of the ellipse
  float mouseChangeX = 0;
  float mouseChangeY = 0;
  float accelw = 5;
  float accelh = 5;
  float accelStop = 150;
  
  void drag(float a, float b) { //"Where each point moves halfway to the previous one"
      if (trail.size() == trailSize)
         trail.remove(0);
      trail.add(new Coord(a, b));
      
      for(int i = 1; i <trailSize; i++)
      {
       if(i < trailSize -1)
       {
         trail.set(i-1,new Coord( (trail.get(i).xPosition + trail.get(i+1).xPosition)/2 , (trail.get(i).yPosition + trail.get(i+1).yPosition)/2 ));
       }
       else
       {
         trail.set(i-1,new Coord( (trail.get(i).xPosition + a)/2 , (trail.get(i).yPosition + b)/2 ));
       }
      }
  }
  
  void push(float a, float b) { //"A simple fifo"
      if (trail.size() == trailSize)
         trail.remove(0);
      trail.add(new Coord(a, b));
  }

  void show() { //"The display of the whole trail"
    float circleSize = eSize; //Optimize this
    float g = 255;
    float b = 255;
    float mouseDeltaX = mouseX - pmouseX;
    float mouseDeltaY = mouseY - pmouseY;
          
    //Technique 3
    if(superduper)
    {
      stroke(blue);
      fill(blue);
      if ( mouseDeltaX > mouseChangeX)
        accelw += abs(mouseDeltaX);
        else accelw -= abs(incFactor*5);
      if ( mouseDeltaY > mouseChangeY)
        accelh += abs(mouseDeltaY);
        else accelh -= abs(incFactor*5);
        if (accelw >= accelStop) accelw = accelStop;
        if (accelh >= accelStop) accelh = accelStop;
        if (accelw <= 0) accelw = 0;
        if (accelh <= 0) accelh = 0;
        alpha(int(20.0 * (mouseDeltaX+mouseDeltaY)));
      ellipse(width/2,height/2, accelw, accelh); 
      mouseChangeX = mouseDeltaX;
      mouseChangeY = mouseDeltaY;
      fill(white); 
  }  // Continues below
        
    for(int i = 0; i < trail.size(); i++){
      stroke(black);
      strokeWeight(4);
      //Technique 3
      if (superduper) {
        noStroke();
        fill(255, g, b);
        g -= 9;
        b -= 9;
      } // End of Technique 3
      ellipse(trail.get(i).xPosition, trail.get(i).yPosition, circleSize, circleSize);//ellipse(x-coord, y-coord, w, h)
      if (i != trail.size() - 1) { //Optimize this
        stroke(white);
        strokeWeight(1);
        circleSize += incFactor;
        ellipse(trail.get(i).xPosition, trail.get(i).yPosition, circleSize, circleSize);//ellipse(x-coord, y-coord, w, h)
      }
    }
  }//end of show()
  
  //***************
  //***Project 2***
  //***************
  
  void predict() {
    float circleSize = eSize+10;
    float v1;
    float v2;
    Coord initPoint;
    if (trail.size() == trailSize) {  //ensure that we have 30 points in the trail
       Coord avgA = avgPoint(0,9);  //Avg point for 1st third (Note: originally (0,9)
       Coord avgB = avgPoint(10,19); //Avg point for 2nd third
       Coord avgC = avgPoint(20,29); //Avg point for 3rd third (Note: originally (20,29)
       fill(green);
       noStroke();
       ellipse(avgA.xPosition, avgA.yPosition, circleSize, circleSize);  //Drawing the 
       ellipse(avgB.xPosition, avgB.yPosition, circleSize, circleSize);  //average points
       ellipse(avgC.xPosition, avgC.yPosition, circleSize, circleSize);  //on screen.
       
       //float velocity = velocity(avgA, avgC);  //Deprecated
       float velocityX = velocityX(avgA, avgC);
       float velocityY = velocityY(avgA, avgC);
       //float acceleration = acceleration(avgA, avgB, avgC);  //Deprecated
       float accelerationX = accelerationX(avgA, avgB, avgC);
       float accelerationY = accelerationY(avgA, avgB, avgC);
       //TO DO: change where the prediction occurs
       initPoint = avgB;
       for (float t = 0; t < 3; t += 0.1) {
            v1 = initPoint.xPosition + (t * velocityX) + ((1.0/2.0) * (t*t) * (accelerationX));
            v2 = initPoint.yPosition + (t * velocityY) + ((1.0/2.0) * (t*t) * (accelerationY));
         ellipse(v1, v2, circleSize, circleSize);
       }//End of for 
    }//End of if
  }//End of predict
  
  Coord avgPoint(int a, int b) {  //Used on an existing trail, finds the average point between given indices
    float v1 = 0.0;
    float v2 = 0.0;
    float divBy= 0.0;
    for (int i = a; i <= b; i++) {
      v1 +=  trail.get(i).xPosition;
      v2 += trail.get(i).yPosition;
      divBy += 1.0;
    }
    v1 /= divBy;
    v2 /= divBy;
    Coord temp = new Coord(v1, v2);
    return temp;
  }
  
  float magnitude(float a, float b) {  //Calculate magnitude of a vector given its components.
    return sqrt((a*a) + (b*b));
  }
  
  float acceleration(Coord a, Coord b, Coord c) {  //Acceleration btw 3 points, formula: A-2B+C
    float v1 = a.xPosition - (2.0*(b.xPosition)) + c.xPosition;
    float v2 = a.yPosition - (2.0*(b.yPosition)) + c.yPosition;
    return magnitude(v1, v2);
  }
  
  float accelerationX(Coord a, Coord b, Coord c) {
    return a.xPosition - (2.0*(b.xPosition)) + c.xPosition;
  }
  
  float accelerationY(Coord a, Coord b, Coord c) {
    return a.yPosition - (2.0*(b.yPosition)) + c.yPosition;
  }
  
  float velocity(Coord a, Coord c) {  //Velocity given 2 points, formula: (AB+BC)/2 -> (C-A)/2. This is G.
    float v1 = c.xPosition - a.xPosition;
    float v2 = c.yPosition - a.yPosition;
    return magnitude(v1, v2)/2.0;
  }
  
  float velocityX(Coord a, Coord c) {
    float v1 = c.xPosition - a.xPosition;
    return v1/2.0;
  }
  
  float velocityY(Coord a, Coord c) {
    float v2 = c.yPosition - a.yPosition;
    return v2/2.0; 
  }

}//end of TRAIL

class Coord {  //A class for treating mouse position as a single object
  float xPosition;
  float yPosition;
  
  Coord(float a, float b) {
    xPosition = a;
    yPosition = b;
  }
  
}
