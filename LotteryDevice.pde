/**
 * Lottery Device. 
 * 
 * This is a Lottery Device for Seeed New Year Party
 * by Kevin Lee@2016/12/13
 */
import processing.serial.*;
 
 
Lottery luck = new Lottery(4);
//PImage img0;
//PImage img1;
//PImage img2;
//PImage img3;
//PImage img4;

// PImage img[] = {img0,img1,img2,img3,img4};
PImage[] img = new PImage[5];
boolean except = false;
Serial myPort;

void setup() {
    fullScreen(P3D,2); // Default screen 2 , render 3D 
    for (int i=0; i<5; i++) {
        String s;
        s = Integer.toString(i)+".png";
        println("the file is ",s);
        img[i] = loadImage(s);
        img[i].resize(width,height);
    }
    // img0 = loadImage("0.png");
    // img0.resize(width,height);
    try {
       printArray(Serial.list());
       myPort = new Serial(this, Serial.list()[0], 115200);     
       myPort.clear();  
    } catch(ArrayIndexOutOfBoundsException e) {
       println("except");
       except = true;
    }
    noStroke();
}

void draw() { 
  // background(img0); // change the color
  background(img[luck.getIndex()]); // change the color
  // keep draw() here to continue looping while waiting for keys
  if (except == true){
      println("something worng");
      textSize(32);
      text("Restart and check the connection.",50,1050);
      fill(255,255,255);
  } else {
      
  }
  
}

void keyPressed() {
  int keyIndex;
  if (key == 'S' || key == 's') {
      println("Start the lottery");
  } else if (key == ' ') {
      println("Recive the data");
      
  } else if (key == 'R' || key == 'r') {
      println("Reset the game");
  } else if (key >= '0' && key <= '4') {
      keyIndex = key - '0';
      background(50*keyIndex,0,67);
      luck.setIndex(keyIndex);
  }
  println("the key is",key);
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
    int inByte = myPort.read();

    if (inByte == 0xAA) { 
      myPort.clear();          // clear the serial port buffer
      println("Recive the data from serial");
    } 
}


class Lottery{
    int Lottery_index;
    Lottery (int index){
        Lottery_index = index;
        println("the number is ",index);
    };
    void setIndex(int index) {
        Lottery_index = index;
        println("Set Lottery index number to ",index);
    }
    int getIndex() {
        return Lottery_index;
    }
  
}