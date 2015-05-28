//public class hitbox
//{
//  int size;
//  PVector boxCenter;
//  color c;
//  int pointsInBox;
//  boolean trigger;
//  int inc;
//  
//  HotSpot(int s, PVector bc, color c1)
//  {
//    size = s;
//    boxCenter = bc;
//    c = c1;
//    pointsInBox = 0;
//    trigger = false;
//    
//    inc = 0;
//  }
//  
//  void display()
//  {
//    if(!trigger && pointsInBox > 10)
//    {
//      System.out.println("TRIGGERED " + triggercount);
//      triggercount++;
//      trigger = true;
//      ap.play();
//    }
//    else if (pointsInBox < 10)
//    {
//      trigger = false;
//      ap.pause();
//    }
//    
//    pushMatrix();    
//    float boxAlpha = map(pointsInBox,0,100,0,255); 
//    if(!trigger)
//    {
//      translate(boxCenter.x,boxCenter.y,boxCenter.z);
//      stroke(c);
//      fill(100,100,100,boxAlpha);
//      box(size);
//    }
//    else
//    {          
//      translate(boxCenter.x-spook[inc%spook.length].width/2,boxCenter.y+spook[inc%spook.length].height/2,boxCenter.z);
//      rotateX(PI);
//      image(spook[inc++%spook.length],0,0);
//    }
//    popMatrix();
//    pointsInBox = 0;
//  }
//  
//  void update(PVector cP)
//  {
//    if(cP.x>boxCenter.x-size/2 && cP.x<boxCenter.x+size/2){
//      if(cP.y>boxCenter.y-size/2 && cP.y<boxCenter.y+size/2){
//        if(cP.z>boxCenter.z-size/2 && cP.z<boxCenter.z+size/2)
//        {
//          pointsInBox++;          
//        }
//      }
//    }    
//  }
//  
//  boolean play()
//  {
//    return trigger;
//  }
//}

