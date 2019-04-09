



import processing.io.*;
PFont font;
SPI MCP3008;

// VARIABLES USED TO GET PULSE
long sampleCounter,lastBeatTime,jitter;
int threshSetting,thresh,Signal,P,T,BPM,IBI,amp,sampleIntervalMs;
boolean firstBeat,secondBeat,QS,Pulse;
int[] rate = new int[10];
int pulseLED = 17;
// MCP3008
byte[] outBytes = {(byte)0x01,(byte)0x80,(byte)0x00};
byte[] inBytes = new byte[3];
int MCP_SS = 8;
// VARIABLES FOR VISUALIZER

int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA
int[] ratePlot;      // USED TO POSITION BPM DATA WAVEFORM
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth;
int PulseWindowHeight;
int windowXmargin = 10;
int windowYmargin = 45;
boolean beat;



void setup(){
  size(600, 600);  // Stage size
  frameRate(100);
  GPIO.pinMode(MCP_SS,GPIO.OUTPUT);
  GPIO.pinMode(pulseLED,GPIO.OUTPUT);
  //printArray(SPI.list());
  MCP3008 = new SPI(SPI.list()[0]);
  MCP3008.settings(1000000, SPI.MSBFIRST, SPI.MODE3);
  font = loadFont("FreeSansBold-48.vlw");
  textFont(font,24);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);
  PulseWindowWidth = width-windowXmargin*2;
  PulseWindowHeight = height-windowYmargin*2;
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array

 // set the visualizer lines to 0
  resetDataTrace();

 background(0);
 // DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES
  drawDataWindow();
  //drawHeart();

  fill(eggshell);

  initPulseSensor();

}


void draw(){
  getPulse();
  //printRawValues();
  outputLED();
  background(0);
  noStroke();
  drawDataWindow();
  drawPulseWaveform();
// PRINT THE DATA AND VARIABLE VALUES
  fill(eggshell);                                       // get ready to print text
  text("Pulse Sensor Raspberry Pi",width/2,windowYmargin/2 + (textDescent()+textAscent())/2);    // tell them what you are
  text(BPM + " BPM     IBI: " + IBI + "mS      Rate: " + sampleIntervalMs + "mS",
  width/2, height-windowYmargin/2+(textDescent()+textAscent())/2); // print BPM and IBI

}

void drawDataWindow(){
    // DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES
    noStroke();
    fill(eggshell);  // color for the window background
    rect(width/2,height/2,PulseWindowWidth,PulseWindowHeight);
}

void drawPulseWaveform(){
  // DRAW THE PULSE WAVEFORM
  // prepare pulse data points
  int dummy = (1023 - Signal) - 512;
  RawY[RawY.length-1] = int(map(dummy,511,-512,PulseWindowHeight+windowYmargin,windowYmargin));   // place the new raw datapoint at the end of the array
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
  }
  stroke(250,0,0);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < RawY.length-1; x++) {
    vertex(x+10, RawY[x]); //+height/2);              //draw a line connecting the data points
  }
  endShape();
}

void resetDataTrace(){
  for (int i=0; i<RawY.length; i++){
     RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
}

void outputLED(){
  if(Pulse){
    GPIO.digitalWrite(pulseLED,GPIO.HIGH);
  }else{
    GPIO.digitalWrite(pulseLED,GPIO.LOW);
  }
}

void printRawValues(){
  println(sampleCounter+"\t"+Signal+"\t"+BPM+"\t"+IBI+"\t"+sampleIntervalMs);
}
