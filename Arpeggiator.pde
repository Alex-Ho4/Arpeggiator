import SimpleOpenNI.*;
import themidibus.*; 

SimpleOpenNI kinect;
MidiBus myBus;

int basePitch = 50; //note played
int tempo = 120; //bpm
boolean tri7 = true; //true for sevenths, false for triads
int chord = 0; //note pattern (triads or sevenths)
int instrument = 0; //instrument playing
int[] data; //holds data

String[] notes;

float milliClock = 0;

int velocity = 0;

int pitch = 0;
int channel = 0;
//                Major       Minor     Augmented  Diminished
int[][] triads = {{0, 4, 3}, {0, 3, 4}, {0, 4, 4}, {0, 3, 3}};
//                 Diminished    Half-Dim     Minor        Minor-Major  Dominant     Major        Augmented     Augmented Maj
int[][] sevenths = {{0, 3, 3, 3},{0, 3, 3, 4},{0, 3, 4, 2},{0, 3, 4, 3},{0, 4, 3, 2},{0, 4, 3, 3},{0, 4, 4, 1}, {0, 4, 4, 2}};
int i = 0;

PFont f;

int[] userMap;

void setup()
{
  size(640, 480, P3D);
  background(0);
  
  data = new int[5];
  data[0] = basePitch;
  data[1] = tempo;
  data[2] = 0;
  data[3] = chord;
  data[4] = instrument;
  
  notes = genNotes();
  
  milliClock = (60000/tempo);
  
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  
  f = loadFont("Algerian-48.vlw");  
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
  
  text(notes[basePitch],0+100,0+100);
  
  //PImage depth = kinect.depthImage();  
  
  int[] users = kinect.getUsers();
  if(users.length > 0)
  {
    int userId = users[0];    
    if(kinect.isTrackingSkeleton(users[0]))
    {
      velocity = 255;     
      data = handData(users[0], instrument);
      basePitch = (int)map(data[0],0, 480, 30, 70);
      tempo = data[1];
      tri7 = (data[2] == -1) ? false : true;
      chord = data[3];
      instrument = data[4];
    }
    
    //managing sound
    if(tri7)
    {
      if(i == 0)
      {
        pitch = basePitch;
      }
      else
      {
        pitch += sevenths[constrain((int)map(chord,0,500,0,7),0,7)][i];
      }
      i = (i+1)%sevenths[0].length;
    }
    else
    {
      if(i == 0)
      {
        pitch = basePitch;
      }
      else
      {
        pitch += triads[constrain((int)map(chord,0,500,0,3),0,3)][i];
      }
      i = (i+1)%triads[0].length;
    }    
    
    
    
    
//    myBus.sendNoteOn(note); // Send a Midi noteOn
//    delay(tempo);
//    myBus.sendNoteOff(note); // Send a Midi nodeOff
    println(milliClock);
    if(millis() >= milliClock)
    {       
      milliClock += (tri7 ? (60000/(tempo*4)) : (60000/(tempo*3)));   
      thread("playSound");      
      println(milliClock);
    }
    
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
  
  dats[0] = (int)convRightHand.y; //basePitch
//  dats[1] = (int)map(convTorso.z, 700, 1700, 32, 255); //tempo
  
  dats[1] = constrain((int)map(convLeftHand.y,0, 450, 32,150),32,150);
  
//  if(convLeftHand.y <= height/2) // tri7
//    dats[2] = -1;
//  else
//    dats[2] = 0;
  dats[2] = 0;
    
  dats[3] = (int)(dist(convLeftHand.x, convLeftHand.y, convLeftHand.z, convRightHand.x, convRightHand.y, convRightHand.z)); //pattern
  dats[4] = instrument; //instrument
  
  return dats;
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

void playSound()
{
  Note note = new Note(0, pitch, velocity);
  myBus.sendNoteOn(note); // Send a Midi noteOn
  delay(tempo);
  myBus.sendNoteOff(note); // Send a Midi nodeOff
}

String[] genNotes()
{
  String[] fin = new String[108];
  for(int i = 0; i < 108; i+= 12)
  {
    fin[i+11] = "B";
    fin[i+10] = "A#";
    fin[i+9] = "A";
    fin[i+8] = "G#";
    fin[i+7] = "G";
    fin[i+6] = "F#";
    fin[i+5] = "F";
    fin[i+4] = "E";
    fin[i+3] = "D#";
    fin[i+2] = "D";
    fin[i+1] = "C#";
    fin[i] = "C";
  }
  return fin;
}
