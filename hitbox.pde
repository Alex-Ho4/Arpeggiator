public class hitbox
{
  int size;
  PVector boxCenter;
  color c;
  int pointsInBox;
  boolean trigger;
  String text;
  
  hitbox(int s, PVector bc, color c1, String t)
  {
    size = s;
    boxCenter = bc;
    c = c1;
    pointsInBox = 0;
    trigger = false;
    text = t;
  }
  
  boolean display()
  {
    if(!trigger && pointsInBox > 5)
    {
      trigger = true;
    }
    else if (pointsInBox < 5)
    {
      trigger = false;
    }    
    
    pushMatrix();    
    translate(boxCenter.x,boxCenter.y,boxCenter.z);
    stroke(c);
    fill(100,100,100, pointsInBox);
    box(size);
    PFont f = loadFont("AgencyFB-Bold-48.vlw");
    textFont(f,18);
    text(text,boxCenter.x, boxCenter.y, boxCenter.z);
    popMatrix();
    pointsInBox = 0;

    if(trigger)
      return true;
    return false;
  }
  
  void update(PVector cP)
  {
    if(cP.x>boxCenter.x-size/2 && cP.x<boxCenter.x+size/2){
      if(cP.y>boxCenter.y-size/2 && cP.y<boxCenter.y+size/2){
        if(cP.z>boxCenter.z-size/2 && cP.z<boxCenter.z+size/2)
        {
          pointsInBox++;          
        }
      }
    }    
  }
  
  void setText(String t)
  {
    text = t;
  }
}

