

void mousePressed(){
}

void mouseReleased(){
}

void keyPressed(){

 switch(key){
   case 's':    // pressing 's' or 'S' will take a jpg of the processing window
   case 'S':
     saveFrame("PulseSensor-####.jpg");    // take a shot of that!
     break;
   case 'r':
   case 'R':
     resetDataTrace();
     break;

   default:
     break;
 }
}
