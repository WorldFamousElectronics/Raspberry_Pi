
// Initialize (seed) the pulse detector
void initPulseSensor(){
  BPM = 0;
  IBI = 600;                  // 600ms per beat = 100 Beats Per Minute (BPM)
  Pulse = false;
  sampleCounter = 0;
  lastBeatTime = 0;
  P = 512;                    // peak at 1/2 the input range of 0..1023
  T = 512;                    // trough at 1/2 the input range.
  thresh = 550;               // threshold a little above the trough
  amp = 100;                  // beat amplitude 1/10 of input range.
  firstBeat = true;           // looking for the first beat
  secondBeat = false;         // not yet looking for the second beat in a row
}

void getPulse(){
  inBytes = MCP3008.transfer(outBytes);
  Signal = char(inBytes[1]) << 8;
  Signal |= char(inBytes[2]);
  sampleIntervalMs =int((1/frameRate)*1000.0);  //
  sampleCounter += sampleIntervalMs;            // keep track of the time in mS with this variable
  int N = int(sampleCounter - lastBeatTime);    // monitor the time since the last beat to avoid noise

  // Fade the Fading LED

  //  find the peak and trough of the pulse wave
  if (Signal < thresh && N > (IBI / 5) * 3) { // avoid dichrotic noise by waiting 3/5 of last IBI
    if (Signal < T) {                         // T is the trough
      T = Signal;                             // keep track of lowest point in pulse wave
    }
  }

  if (Signal > thresh && Signal > P) {       // thresh condition helps avoid noise
    P = Signal;                              // P is the peak
  }                                          // keep track of highest point in pulse wave

  //  NOW IT'S TIME TO LOOK FOR THE HEART BEAT
  // signal surges up in value every time there is a pulse
  if (N > 250) {                             // avoid high frequency noise
    if ( (Signal > thresh) && (Pulse == false) && (N > (IBI / 5) * 3) ) {
      Pulse = true;                          // set the Pulse flag when we think there is a pulse
      IBI = int(sampleCounter - lastBeatTime);    // measure time between beats in mS
      lastBeatTime = sampleCounter;          // keep track of time for next pulse

      if (secondBeat) {                      // if this is the second beat, if secondBeat == TRUE
        secondBeat = false;                  // clear secondBeat flag
      }

      if (firstBeat) {                       // if it's the first time we found a beat, if firstBeat == TRUE
        firstBeat = false;                   // clear firstBeat flag
        secondBeat = true;                   // set the second beat flag
        // IBI value is unreliable so discard it
        return;
      }



      BPM = 60000 / IBI;                      // how many beats can fit into a minute? that's BPM!
    }
  }

  if (Signal < thresh && Pulse == true) {  // when the values are going down, the beat is over
    Pulse = false;                         // reset the Pulse flag so we can do it again
    amp = P - T;                           // get amplitude of the pulse wave
    thresh = amp / 2 + T;                  // set thresh at 50% of the amplitude
    P = thresh;                            // reset these for next time
    T = thresh;
  }

  if (N > 2500) {                          // if 2.5 seconds go by without a beat
    thresh = threshSetting;                // set thresh default
    P = 512;                               // set P default
    T = 512;                               // set T default
    lastBeatTime = sampleCounter;          // bring the lastBeatTime up to date
    firstBeat = true;                      // set these to avoid noise
    secondBeat = false;                    // when we get the heartbeat back
    BPM = 0;
    IBI = 600;                  // 600ms per beat = 100 Beats Per Minute (BPM)
    Pulse = false;
    amp = 0;

  }
}
