// Bakeoff #3 - Escrita de Texto em Smartwatches
// IPM 2019-20, Semestre 2
// Entrega: exclusivamente no dia 22 de Maio, até às 23h59, via Discord

// Processing reference: https://processing.org/reference/

import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

int clicking=0;
int firstClick=0;

// Screen resolution vars;
float PPI, PPCM;
float SCALE_FACTOR;

// Finger parameters
PImage fingerOcclusion;
int FINGER_SIZE;
int FINGER_OFFSET;

// Arm/watch parameters
PImage arm;
int ARM_LENGTH;
int ARM_HEIGHT;

// teclado parameters
PImage teclado;
int teclado_length;
int teclado_height;

// Screen parameters
float SCREEN_X_LEFT, SCREEN_X_RIGHT, SCREEN_Y_UP, SCREEN_Y_DOWN, SCREEN_WIDTH, SCREEN_HEIGHT;


// Auto complete properties
String[] words;                    // contais most frequent words
int[] widx;                        // current word being suggested (word index)
String wordTyped           = "";   // new word the user is typing
int[] sugs;
int NUMSUGGESTIONS = 2;            // change this to change number of suggestions
color white = color(255, 255, 255);
color mouseOn = color(0, 255, 0);

float font15;
float font14;
float font13;
float font12;
float font11;


Button[] buttons2;
Button[] buttons;
Button[] buttons3;
int last_click = -1;
char BACKSPACE = '<';

// Study properties
String[] phrases;                   // contains all the phrases that can be tested
int NUM_REPEATS            = 2;     // the total number of phrases to be tested
int currTrialNum           = 0;     // the current trial number (indexes into phrases array above)
String currentPhrase       = "";    // the current target phrase
String currentTyped        = "";    // what the user has typed so far
char currentLetter         = 'a';
String[] typed = new String[NUM_REPEATS];

// Performance variables
float timeMouse = 0;
float startTime            = 0;     // time starts when the user clicks for the first time
float finishTime           = 0;     // records the time of when the final trial ends
float lastTime             = 0;     // the timestamp of when the last trial was completed
float lettersEnteredTotal  = 0;     // a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0;     // a running total of the number of letters expected (correct phrases)
float errorsTotal          = 0;     // a running total of the number of errors (when hitting next)

public abstract class Button {
  float x;
  float y;
  float w;
  float h;
  String text;
  int numLetters;
  int letterIdx = 0;
  int tes=0;
  
  float getTextX() {
    return x + w/2;
  }
  
  float getTextY() {
    return y + h/2;
  }
  
  boolean gotClicked() {
    return didMouseClick(x, y+1.02*PPCM, w, h);
  }
  void change(){
    tes=1;
  }
  void changeback(){
    tes=0;
  }
  boolean isClicking()
  {
     return (mouseX > x && mouseX < x + w && mouseY > y+1.02*PPCM && mouseY < y+1.02*PPCM + h);
  }
  abstract char getLetter();
  abstract char getCurrentLetter();
  
  void nextLetter() {
    letterIdx = (letterIdx + 1) % numLetters;
  }
  
  void resetLetter() {
    letterIdx = 0;
  }
  

  void display() {
    stroke(0);
    if(tes==0){
      noFill();
    }
    if(tes==1){
      fill(mouseOn);
    }
    rect(x, y, w, h);
    textAlign(CENTER);
    fill(0);
    textFont(createFont("Arial", 12));
    text(text, getTextX(), getTextY()+3);
    textFont(createFont("Arial", 16));
  }
}
public class FirstRow extends Button{
  
  FirstRow(int index, String input) {
    
    w = SCREEN_WIDTH/10;
    h = (SCREEN_HEIGHT + 0.5*PPCM)/8;
    x = ((SCREEN_X_LEFT + 0.01*PPCM)+ (index) * (SCREEN_WIDTH/10));
    y = SCREEN_Y_UP;
    text = input;
    numLetters = text.length();
  }
  
  
  @Override
  char getLetter() {
    char l = (char)(text.charAt(letterIdx) - 'A' + 'a');
    nextLetter();
    return l;
  }
  
  @Override
  char getCurrentLetter() {
    return text.charAt(letterIdx);
  }
}
public class SecondRow extends Button{
  
  SecondRow(int index, String input) {
    
    w = SCREEN_WIDTH/10;
    h = (SCREEN_HEIGHT + 0.5*PPCM)/8;
    x = SCREEN_X_LEFT+ (0.1*PPCM) + (index) * (SCREEN_WIDTH/10);
    y = SCREEN_Y_UP+0.49*PPCM ;
    text = input;
    numLetters = text.length();
  }
  
  @Override
  char getLetter() {
    char l = (char)(text.charAt(letterIdx) - 'A' + 'a');
    nextLetter();
    return l;
  }
  
  @Override
  char getCurrentLetter() {
    return text.charAt(letterIdx);
  }
}

public class ThirdRow extends Button{
  
  ThirdRow(int index, String input) {
   
    w = SCREEN_WIDTH/ 10;
    h = (SCREEN_HEIGHT + 0.5*PPCM)/8;
    x = SCREEN_X_LEFT+ (0.48*PPCM) + (index) * (SCREEN_WIDTH/ 10);
    y = SCREEN_Y_UP+ 0.98*PPCM ;
    if(index==7){
      w=SCREEN_WIDTH/7;
    }
    text = input;
    numLetters = text.length();
  }
  
  @Override
  char getLetter() {
    char l = (char)(text.charAt(letterIdx) - 'A' + 'a');
    nextLetter();
    return l;
  }
  
  @Override
  char getCurrentLetter() {
    return text.charAt(letterIdx);
  }
}

public class SpaceButton extends Button {  // button with letters
    String symbols = " ";  // space 
    SpaceButton () {
    w = SCREEN_WIDTH;
    h = (SCREEN_HEIGHT - 0.2*PPCM)/7;
    x = SCREEN_X_LEFT;
    y = SCREEN_Y_UP+ 1.5*PPCM ; //69 = 1.5 * PPCM
    text = "space";
    numLetters = text.length();
   }
  
  @Override
  char getLetter() {
    char l = (char)(' ');
    //nextLetter();
    return l;
  }
  
  @Override
  char getCurrentLetter() {
    return symbols.charAt(0);
  }
  
}

public class DeleteButton extends ThirdRow { // button with space and backspace
  String symbols = "<-";  // backspace

  DeleteButton(int index) {
    super(index, "<-");
    numLetters = symbols.length();
    text = "<";
  }
  
  @Override
  char getLetter() {
    char l = symbols.charAt(0);
    nextLetter();
    return l;
  }
  
  @Override
  char getCurrentLetter() {
    return symbols.charAt(0);
  }
  
  @Override
  void display() {
    stroke(0);
    if(tes==0){
      noFill();
    }
    if(tes==1){
      fill(mouseOn);
    }
    rect(x, y, w, h);
    textAlign(CENTER);
    fill(0);
    textFont(createFont("Arial", 19));
    text(text, getTextX(), getTextY()+6);
    textFont(createFont("Arial", 16));
  }
}

// Auto-complete auxiliar functions
void toZero() {
  System.out.println(widx.length);
  for (int i = 0; i < NUMSUGGESTIONS; i++) widx[i] = i;
}

float setWordSize(String word) {
  if (word.length() < 11) {    
    System.out.println("font15: " + font15);
    return font15; 
  }
  else if (word.length() < 14) return font13;       
  else return font11;                            
}

void printSuggestions() {
  for (int i = 0; i < NUMSUGGESTIONS; i++) {
    if(sugs[i]==1) fill(mouseOn);
    else fill(white);
    stroke(150);
    
    if (i == 0) rect(SCREEN_X_LEFT, SCREEN_Y_UP - 1*PPCM, SCREEN_WIDTH/2, 1.0*PPCM);
    else rect(SCREEN_X_LEFT + SCREEN_WIDTH/2, SCREEN_Y_UP - 1*PPCM, SCREEN_WIDTH/2, 1.0*PPCM);
  
    fill(0);
    noStroke();
    if (i == 0 && widx[0] != -1) {
      textSize(setWordSize(words[widx[0]]));
      text(words[widx[0]], SCREEN_X_LEFT, SCREEN_Y_UP - 0.5*PPCM, SCREEN_WIDTH/2, 1.0*PPCM);
    }
    else if (i == 1 && widx[1] != -1) {
      textSize(setWordSize(words[widx[1]]));
      text(words[widx[1]], SCREEN_X_LEFT + SCREEN_WIDTH/2, SCREEN_Y_UP - 0.5*PPCM, SCREEN_WIDTH/2, 1.0*PPCM);
    }
  }
  textFont(createFont("Arial", 16));
}


//Setup window and vars - runs once
void setup()
{
  //size(900, 900);
  fullScreen();
  textFont(createFont("Arial", 24));  // set the font to arial 24
  noCursor();                         // hides the cursor to emulate a watch environment
  
  // Load images
  arm = loadImage("arm_watch.png");
  fingerOcclusion = loadImage("finger.png");
  
  teclado = loadImage("teclado1.png");
  
  // Load phrases
  phrases = loadStrings("phrases.txt");                       // load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random());  // randomize the order of the phrases with no seed
  
  // Scale targets and imagens to match screen resolution
  SCALE_FACTOR = 1.0 / displayDensity();          // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");   // the text from the file is loaded into an array.
  PPI = float(ppi_string[1]);                     // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM = PPI / 2.54 * SCALE_FACTOR;               // do not change this!
  
  FINGER_SIZE = (int)(11 * PPCM);
  FINGER_OFFSET = (int)(0.8 * PPCM);
  ARM_LENGTH = (int)(19 * PPCM);
  ARM_HEIGHT = (int)(11.2 * PPCM);
  
  // Load auto complete words
  words = loadStrings("words_per_frequency.txt");
  widx = new int[NUMSUGGESTIONS];
  sugs = new int[NUMSUGGESTIONS];
  for (int j = 0; j < NUMSUGGESTIONS; j++) {
    widx[j] = -1;
    sugs[j] = 0;
  }
  
  
   // Screen properties
  SCREEN_X_LEFT = width/2 - 2.0*PPCM;
  SCREEN_X_RIGHT = width/2 + 2.0*PPCM;
  SCREEN_Y_UP = height/2 - 1.0*PPCM;
  SCREEN_Y_DOWN = height/2 + 2.0*PPCM;
  SCREEN_WIDTH = SCREEN_X_RIGHT - SCREEN_X_LEFT;
  SCREEN_HEIGHT = SCREEN_Y_DOWN - SCREEN_Y_UP;
  
  buttons = new Button[28];
  buttons2 = new Button[9];
  buttons3 = new Button[8];

  buttons[0] = new FirstRow(0, "Q");
  buttons[1] = new FirstRow(1, "W");
  buttons[2] = new FirstRow(2, "E");
  buttons[3] = new FirstRow(3, "R");
  buttons[4] = new FirstRow(4, "T");
  buttons[5] = new FirstRow(5, "Y");
  buttons[6] = new FirstRow(6, "U");
  buttons[7] = new FirstRow(7, "I");
  buttons[8] = new FirstRow(8, "O");
  buttons[9] = new FirstRow(9, "P");
  
  buttons[10] = new SecondRow(0, "A");
  buttons[11] = new SecondRow(1, "S");
  buttons[12] = new SecondRow(2, "D");
  buttons[13] = new SecondRow(3, "F");
  buttons[14] = new SecondRow(4, "G");
  buttons[15] = new SecondRow(5, "H");
  buttons[16] = new SecondRow(6, "J");
  buttons[17] = new SecondRow(7, "K");
  buttons[18] = new SecondRow(8, "L");
  
  buttons[19] = new ThirdRow(0, "Z");
  buttons[20] = new ThirdRow(1, "X");
  buttons[21] = new ThirdRow(2, "C");
  buttons[22] = new ThirdRow(3, "V");
  buttons[23] = new ThirdRow(4, "B");
  buttons[24] = new ThirdRow(5, "N");
  buttons[25] = new ThirdRow(6, "M");
  buttons[26] = new DeleteButton(7);
  buttons[27] = new SpaceButton();


  arm.resize(ARM_LENGTH , ARM_HEIGHT);
  fingerOcclusion.resize(FINGER_SIZE , FINGER_SIZE);
  
  font15 = PPCM*0.3356828;
  font14 = PPCM*0.31330398;
  font13 = PPCM*0.29092512;
  font12 = PPCM*0.26854625;
  font11 = PPCM*0.2461674;

}

void draw()
{ 
  // Check if we have reached the end of the study
  if (finishTime != 0)  return;
 
  background(255);                                                         // clear background
  
  // Draw arm and watch background
  imageMode(CENTER);
  image(arm, width/2, height/2);
  
  // Check if we just started the application
  if (startTime == 0 && !mousePressed)
  {
    fill(0);
    textAlign(CENTER);
    text("Tap to start time!", width/2, height/2);
  }
   if (startTime == 0 && mousePressed) {
     nextTrial();                    // show next sentence
     toZero();                       // reset widx
   }
  
  // Check if we are in the middle of a trial
  else if (startTime != 0)
  {
    textAlign(LEFT);
    fill(100);
    text("Phrase " + (currTrialNum + 1) + " of " + NUM_REPEATS, width/2 - 4.0*PPCM, height/2 - 8.1*PPCM);   // write the trial count
    text("Target:    " + currentPhrase, width/2 - 4.0*PPCM, height/2 - 7.1*PPCM);                           // draw the target string
    fill(0);
    text("Entered:  " + currentTyped + "|", width/2 - 4.0*PPCM, height/2 - 6.1*PPCM);                      // draw what the user has entered thus far 
    
    // Draw very basic ACCEPT button - do not change this!
    textAlign(CENTER);
    noStroke();
    fill(0, 250, 0);
    rect(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM);
    fill(0);
    text("ACCEPT >", width/2, height/2 - 4.1*PPCM);
    
    // Draw screen areas
    // simulates text box - not interactive
    //noStroke();
    //fill(125);
    //rect(width/2 - 2.0*PPCM, height/2 - 2.0*PPCM, 4.0*PPCM, 1.0*PPCM);
    //textAlign(CENTER);
    //fill(0);
    //textFont(createFont("Arial", 16));  // set the font to arial 24
    //text("NOT INTERACTIVE", width/2, height/2 - 1.3 * PPCM);             // draw current letter
    //textFont(createFont("Arial", 24));  // set the font to arial 24
    
    // THIS IS THE ONLY INTERACTIVE AREA (4cm x 4cm); do not change size
    stroke(255, 255, 255);
    noFill();
    rect(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM);
   
    //DRAW KEYBOARD 
    //imageMode(CENTER);
    //image(teclado, width/2, height/2+38, SCREEN_WIDTH , SCREEN_HEIGHT-30);
    
    
    for (int i = 0; i < 28; i++){ 
      buttons[i].display();  
      printSuggestions();
    }
  
    if(clicking==2 && mouseX>SCREEN_X_LEFT && mouseX<SCREEN_X_LEFT+SCREEN_WIDTH && mouseY>SCREEN_Y_UP && mouseY<SCREEN_Y_UP+SCREEN_HEIGHT ){
        circle(mouseX , mouseY-1.02*PPCM , 0.13*PPCM);
    }
    
    for(int i=0; i<28; i++){
      if( buttons[i].isClicking() ){
          buttons[i].change();
      }
      else
        buttons[i].changeback();
    }  
    
      if(mouseX > SCREEN_X_LEFT && mouseY - 1.02*PPCM > SCREEN_Y_UP - 1.0*PPCM && mouseX < SCREEN_X_LEFT + SCREEN_WIDTH/2 && mouseY - 1.02*PPCM  < SCREEN_Y_UP){
          sugs[0]=1;
      }
      else{
          sugs[0]=0;
      }
       if(mouseX > SCREEN_X_LEFT + SCREEN_WIDTH/2 && mouseY - 1.02*PPCM > SCREEN_Y_UP - 1.0*PPCM && mouseX < SCREEN_X_RIGHT && mouseY - 1.02*PPCM  < SCREEN_Y_UP ){
          sugs[1]=1;
      }
      else{
          sugs[1]=0;
      }
   }
        
  // Draw the user finger to illustrate the issues with occlusion (the fat finger problem)
  imageMode(CORNER);
  image(fingerOcclusion, mouseX - FINGER_OFFSET, mouseY - FINGER_OFFSET);
}



// Check if mouse click was within certain bounds
boolean didMouseClick(float x, float y, float w, float h)
{
  return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
}

void changeLastLetter(char l) {
  currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
  currentTyped += l;
}

void mousePressed(){
  
  if (didMouseClick(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM)) nextTrial();                         // Test click on 'accept' button - do not change this!
  else if(didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM))  // Test click on 'keyboard' area - do not change this condition! 
  {
    // YOUR KEYBOARD IMPLEMENTATION NEEDS TO BE IN HERE! (inside the condition)
    if(clicking!=0){
      timeMouse = millis();
    
    if (didMouseClick(SCREEN_X_LEFT, SCREEN_Y_UP, SCREEN_WIDTH, 1.0 * PPCM)) {  // complete with suggestion
      int idx;
      if (didMouseClick(SCREEN_X_LEFT, SCREEN_Y_UP, SCREEN_WIDTH/2, 1.0 * PPCM)) idx = 0;
      else idx = 1;
      currentTyped = currentTyped.substring(0, currentTyped.length() - wordTyped.length());
      currentTyped += words[widx[idx]] + " ";
      wordTyped = "";
      toZero();
    }
    else
    {    
      for (int i = 0; i < 28; i++) {
        if (buttons[i].gotClicked()) {
          if (i == 26) {  // backspace button
            if (currentTyped.length() > 0) currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
            if (wordTyped.length() > 0) wordTyped = wordTyped.substring(0, wordTyped.length() - 1);
            toZero();
          }
          else if (i == 27) {    // space button
            currentTyped += buttons[i].getLetter();
            wordTyped = "";
            toZero();
          }
          else {  
            currentTyped += buttons[i].getLetter();
            wordTyped += buttons[i].getLetter();
            for (int j = 0; j < NUMSUGGESTIONS; j++) {              
              while (widx[j] != -1 && !words[widx[j]].startsWith(wordTyped)) {
                widx[j]++;
                if (widx[j] >= words.length) widx[j] = -1;
                for (int e = 0; e < NUMSUGGESTIONS; e++)
                  if (e != j && widx[j] == widx[e] && widx[j] != -1) widx[j]++;  // if two idx point to the same word, change one of them
                if (widx[j] >= words.length) widx[j] = -1;
              }
            }
          }
        }
      }
    }
  }
    clicking=2;
  }
  else if(startTime==0 && mousePressed){
    clicking=2;
  }
  
  else System.out.println("debug: CLICK NOT ACCEPTED");
  
  if (didMouseClick(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM)) {
    toZero(); 
    wordTyped = "";
  }

}


void nextTrial()
{
  if (currTrialNum >= NUM_REPEATS) return;                                            // check to see if experiment is done
  
  // Check if we're in the middle of the tests
  else if (startTime != 0 && finishTime == 0)                                         
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + NUM_REPEATS);
    System.out.println("Target phrase: " + currentPhrase);
    System.out.println("Phrase length: " + currentPhrase.length());
    System.out.println("User typed: " + currentTyped);
    System.out.println("User typed length: " + currentTyped.length());
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim()));
    System.out.println("Time taken on this trial: " + (millis() - lastTime));
    System.out.println("Time taken since beginning: " + (millis() - startTime));
    System.out.println("==================");
    lettersExpectedTotal += currentPhrase.trim().length();
    lettersEnteredTotal += currentTyped.trim().length();
    errorsTotal += computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
    typed[currTrialNum] = currentTyped;
  }
  
  // Check to see if experiment just finished
  if (currTrialNum == NUM_REPEATS - 1)                                           
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime));
    System.out.println("Total letters entered: " + lettersEnteredTotal);
    System.out.println("Total letters expected: " + lettersExpectedTotal);
    System.out.println("Total errors entered: " + errorsTotal);

    float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f);   // FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal * .05;                                 // no penalty if errors are under 5% of chars
    float penalty = max(0, (errorsTotal - freebieErrors) / ((finishTime - startTime) / 60000f));
    float cps = (lettersEnteredTotal / (((finishTime - startTime) / 60000f) * 60));
    
    System.out.println("Raw WPM: " + wpm);
    System.out.println("Freebie errors: " + freebieErrors);
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm - penalty));                         // yes, minus, because higher WPM is better: NET WPM
    System.out.println("==================");
    
    printResults(wpm, freebieErrors, penalty, cps);
    
    currTrialNum++;                                                                   // increment by one so this mesage only appears once when all trials are done
    return;
  }

  else if (startTime == 0)                                                            // first trial starting now
  {
    System.out.println("Trials beginning! Starting timer...");
    startTime = millis();                                                             // start the timer!
  } 
  else currTrialNum++;                                                                // increment trial number

  lastTime = millis();                                                                // record the time of when this trial ended
  currentTyped = "";                                                                  // clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum];                                              // load the next phrase!
}

// Print results at the end of the study
void printResults(float wpm, float freebieErrors, float penalty, float pcm)
{
  background(0);       // clears screen
  
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen
  
  text("Finished!", width / 2, height / 2); 
  
  int h = 20;
  for(int i = 0; i < NUM_REPEATS; i++, h += 40 ) {
    text("Target phrase " + (i+1) + ": " + phrases[i], width / 2, height / 2 + h);
    text("User typed " + (i+1) + ": " + typed[i], width / 2, height / 2 + h+20);
  }
  
  text("Raw WPM: " + wpm, width / 2, height / 2 + h+20);
  text("Freebie errors: " + freebieErrors, width / 2, height / 2 + h+40);
  text("Penalty: " + penalty, width / 2, height / 2 + h+60);
  text("WPM with penalty: " + max((wpm - penalty), 0), width / 2, height / 2 + h+80);
  text("Characters per second: " + pcm, width / 2, height / 2 + 100);

  saveFrame("results-######.png");    // saves screenshot in current folder    
}

// This computes the error between two strings (i.e., original phrase and user input)
int computeLevenshteinDistance(String phrase1, String phrase2)
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++) distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++) distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
