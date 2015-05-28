import SimpleOpenNI.*;
import themidibus.*;
import processing.opengl.*;
import SimpleOpenNI.*;

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

hitbox triToggle;
hitbox insUp;
hitbox insDown;

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
  
  f = loadFont("AgencyFB-Bold-48.vlw");  
  
  triToggle = new hitbox(100, new PVector(width/2, 0+50, 800), color(0,255,0), "Sevenths");
  insUp = new hitbox(100, new PVector(width-50, 0+50, 800), color(255,0,0), "Instrument\nUp");
  insDown = new hitbox(100, new PVector(width-50, 0+150, 800), color(0,0,255), "Instrument\nDown");
  
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
  
  PVector[] depthPoints = kinect.depthMapRealWorld();
  
  for(int i =0;i<depthPoints.length;i+=33)
  {
    PVector currPoint = depthPoints[i];
    triToggle.update(currPoint);
    insUp.update(currPoint);
    insDown.update(currPoint);         
  }
  
  if(tri7)
    triToggle.setText("Sevenths");
  else
    triToggle.setText("Triads");
  
  if(triToggle.display())
    tri7 = !tri7;
  insUp.display();
  insDown.display();  
  
  //PImage depth = kinect.depthImage();  
  
  int[] users = kinect.getUsers();
  if(users.length > 0)
  {
    int userId = users[0];    
    if(kinect.isTrackingSkeleton(users[0]))
    {
      velocity = 255;     
      data = handData(users[0], instrument);
      basePitch = (int)map(data[0],0, 480, 36, 59);
      tempo = data[1];
      tri7 = (data[2] == -1) ? false : true;
      chord = data[3];
      instrument = data[4];
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
    
//    Note note = new Note(0, pitch, velocity);
//    myBus.sendNoteOn(note); // Send a Midi noteOn
//    delay(tempo);
//    myBus.sendNoteOff(note); // Send a Midi nodeOff
    
    textFont(f,48);
    fill(255);
    if(tri7)
      text(genChord(tri7) + " Seventh on " + notes[basePitch],10,50);
    else
      text(notes[basePitch] + " " + genChord(tri7),10,50);
    text("BPM: " + tempo ,10,100);
    text(instrument,10,150);
    
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
  PVector convRightHand = new PVector();
  PVector convTorso = new PVector();
//  while(confidenceL < .5 && confidenceR < .5)
//  {     
//    confidenceL = kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
//    confidenceR = kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
//    confidenceTorso = kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torso);
//  }
  kinect.convertRealWorldToProjective(leftHand, convLeftHand);   
  kinect.convertRealWorldToProjective(rightHand, convRightHand);    
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
  
  Note note = new Note(0, pitch, velocity);
  myBus.sendNoteOn(note); // Send a Midi noteOn
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

String genChord(boolean tri7)
{
  String[] seventh = {"Diminished","Half-Dim","Minor","Minor-Major","Dominant","Major","Augmented","Augmented Maj"};
  String[] triad = {"Major","Minor","Augmented","Diminished"};
  if(tri7)
  {
    return seventh[constrain((int)map(chord,0,500,0,7),0,7)];
  }
  return triad[constrain((int)map(chord,0,500,0,3),0,3)];
}
