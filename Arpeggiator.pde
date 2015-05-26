import SimpleOpenNI.*;
import themidibus.*; 

SimpleOpenNI kinect;
MidiBus myBus;

int pitch = 25; //note played
int tempo = 120; //bpm
int varience = 0; //Sharp, flat, neutral
int chord = 0; //note pattern
int instrument = 0; //instrument playing
int[] data;

PFont f;

int[] userMap;

void setup()
{
  size(640, 480, P3D);
  background(0);
  
  data = new int[5];
  data[0] = pitch;
  data[1] = tempo;
  data[2] = varience;
  data[3] = chord;
  data[4] = instrument;
  
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  
  f = loadFont("RosewoodStd-Regular-48.vlw");  
  textFont(f,48);
  textAlign(CENTER);
  
  myBus = new MidiBus(this, -1, "Microsoft GS Wavetable Synth");
  
  
}

void draw()
{  
  background(0);
  kinect.update();
  
  if(kinect.getNumberOfUsers() > 0)
  {
    userMap = kinect.userMap();
    loadPixels();
    for(int i = 0; i < userMap.length; i+=9)
    {
      if(userMap[i] != 0)
      {
        pixels[i] = color(100,255,150);
      }
    }
    updatePixels();
  }
  
  PImage depth = kinect.depthImage();  
  
  int[] users = kinect.getUsers();
  if(users.length > 0)
  {
    int userId = users[0];    
    
    if(kinect.isTrackingSkeleton(users[0]))
    {     
      data = handData(users[0], instrument);
      pitch = data[0];
      tempo = data[1];
      varience = data[2];
      chord = data[3];
      instrument = data[4];
    }
    
    //managing sound
    Note note = new Note(0, pitch, 255);
    
    myBus.sendNoteOn(note); // Send a Midi noteOn
    myBus.sendNoteOff(note); // Send a Midi nodeOff
    
    for(int j : data)
    {
      print(j + " ");
    }
    println();
  }
}

void onNewUser(SimpleOpenNI ourContect, int userId)
{
  kinect.startTrackingSkeleton(userId);
}

int[] handData(int userId, int instrument)
{
  int[] dats = new int[5];
  
  PVector leftHand = new PVector();
  PVector rightHand = new PVector();
  PVector torso = new PVector();
       
  float confidenceL = kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
  float confidenceR = kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
  float confidenceTorso = kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torso);
       
  PVector convLeftHand = new PVector();
  kinect.convertRealWorldToProjective(leftHand, convLeftHand);
       
  PVector convRightHand = new PVector();
  kinect.convertRealWorldToProjective(rightHand, convRightHand);
  
  PVector convTorso = new PVector();
  kinect.convertRealWorldToProjective(torso, convTorso);
  
  // make test line
  fill(255,0,0);
  ellipse(convLeftHand.x, convLeftHand.y, 50, 50);
  fill(0,0,255);
  ellipse(convRightHand.x, convRightHand.y, 50, 50);
  stroke(0,255,0);
  strokeWeight(5);
  line(convLeftHand.x, convLeftHand.y, convRightHand.x, convRightHand.y);
  
  dats[0] = (int)convRightHand.y;
  dats[1] = (int)map(convTorso.z, 700, 1700, 32, 255);
  
  if(convLeftHand.y < height/2 - 100)
    dats[2] = 1;
  else if(convLeftHand.y > height/2 + 100)
    dats[2] = -1;
  else
    dats[2] = 0;
    
  dats[3] = (int)(dist(convLeftHand.x, convLeftHand.y, convLeftHand.z, convRightHand.x, convRightHand.y, convRightHand.z));
  dats[4] = instrument;
  
  return dats;
}

void delay(int time)
{
  int current = millis();
  while (millis () < current+time) Thread.yield();
}
