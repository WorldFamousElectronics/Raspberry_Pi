/*
THIS PROGRAM IS WRITTEN TO TARGET RASPBERRY PI
PRESS 'S' OR 's' KEY TO SAVE A PICTURE OF THE SCREEN IN SKETCH FOLDER (.jpg)
PRESS 'R' OR 'r' KEY TO RESET THE DATA TRACES
MADE BY JOEL MURPHY APRIL 2019

THIS CODE PROVIDED AS IS, WITH NO CLAIMS OF FUNCTIONALITY OR EVEN IF IT WILL WORK
      WYSIWYG
*/

import processing.io.*;
PFont font;
SPI MCP3008;

// VARIABLES USED TO GET PULSE
long sampleCounter,lastBeatTime,jitter; // used to keep track of sample rate
int threshSetting,thresh;      // used to find the heart beat
int Signal;                    // holds the latest raw sensor data
int BPM;                       // holds the Beats Per Minute value
int IBI;                       // holds the Interbeat Interval value
int P,T,amp;                   // keeps track of the peak and trough in the pulse wave
int sampleIntervalMs;          // used to find the sample rate
boolean firstBeat,secondBeat;  // used to avoid noise on startup
boolean Pulse;                 // is true when pulse wave is above thresh
int pulseLED = 17;
// VARIABLES TO TALK TO MCP3008
byte[] outBytes = {(byte)0x01,(byte)0x80,(byte)0x00};  // tell MCP we want to read channel 0
byte[] inBytes = new byte[3]; // used to hold the incoming data from MCP
int MCP_SS = 8;  // the chip select pin number
// VARIABLES FOR VISUALIZER
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA
color eggshell = color(255, 253, 248);  // background color
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth;
int PulseWindowHeight;
int windowXmargin = 10;
int windowYmargin = 45;



void setup(){
  size(600, 600);  // Stage size
  frameRate(100);  // ask for a fast frame rate
  GPIO.pinMode(MCP_SS,GPIO.OUTPUT);
  GPIO.pinMode(pulseLED,GPIO.OUTPUT);
  //printArray(SPI.list());
  MCP3008 = new SPI(SPI.list()[0]); // use SPI_0
  MCP3008.settings(1000000, SPI.MSBFIRST, SPI.MODE3);
  font = loadFont("FreeSansBold-48.vlw");
  textFont(font,24);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);
  PulseWindowWidth = width-windowXmargin*2;
  PulseWindowHeight = height-windowYmargin*2;
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  resetDataTrace(); // set the visualizer line to 0

  background(0);
  fill(eggshell);
  drawDataWindow();     // draw the pulse window
  initPulseSensor();    // initialize the Pulse Sensor variables
  threshSetting = 550;  // adjust this as needed to avoid noise
}


void draw(){
  getPulse();  // sample the Pulse Sensor and try to find a beat
  //printRawValues();  // used for debugging
  outputLED();  // blink the LED when we find a pulse
  background(0);
  noStroke();
  drawDataWindow();    // draw the pulse window
  drawPulseWaveform(); // draw the pulse wave
// PRINT THE DATA AND VARIABLE VALUES
  fill(eggshell);      // get ready to print text
  text("Pulse Sensor Raspberry Pi",width/2,windowYmargin/2 + (textDescent()+textAscent())/2);    // tell them what you are
  text(BPM + " BPM     IBI: " + IBI + "mS      Rate: " + sampleIntervalMs + "mS",
  width/2, height-windowYmargin/2+(textDescent()+textAscent())/2); // print BPM, IBI, and sample rate

}

void drawDataWindow(){
    // DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES
    noStroke();
    fill(eggshell);  // color for the window background
    rect(width/2,height/2,PulseWindowWidth,PulseWindowHeight);
}

// DRAW THE PULSE WAVE
void drawPulseWaveform(){
  // DRAW THE PULSE WAVEFORM
  // prepare pulse data points
  int dummy = (1023 - Signal) - 512; // center the waveform around 0
  RawY[RawY.length-1] = int(map(dummy,511,-512,PulseWindowHeight+windowYmargin,windowYmargin));   // place the new raw datapoint at the end of the array
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
  }
  stroke(250,0,0);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < RawY.length-1; x++) {
    vertex(x+10, RawY[x]); //+height/2);         //draw a line connecting the data points
  }
  endShape();
}

// SET THE PULSE WAVE TO 0
void resetDataTrace(){
  for (int i=0; i<RawY.length; i++){
     RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
}

// LIGHT THE LED WHEN THE PULSE SIGNAL IS ABOVE THRESHOLD
void outputLED(){
  if(Pulse){
    GPIO.digitalWrite(pulseLED,GPIO.HIGH);
  }else{
    GPIO.digitalWrite(pulseLED,GPIO.LOW);
  }
}

// USED FOR DEBUGGING ONLY. CONSOLE PRINT TAKES TIME AND BOGS DOWN PROCESSING
void printRawValues(){
  println(sampleCounter+"\t"+Signal+"\t"+BPM+"\t"+IBI+"\t"+sampleIntervalMs);
}
