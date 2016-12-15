/**
 * Lottery Device. 
 * 
 * This is a Lottery Device for Seeed New Year Party
 * by Kevin Lee@2016/12/13
 */
import processing.serial.*;
JSONObject json;
Lottery luck = new Lottery(4);

PImage[] img = new PImage[5];
boolean except = false;                  // Judge if there is a except

Serial myPort;
int progress = 0;                        // Define the progress bar value
static int knocktimes = 30;              // Define how many times click the drum will open the lottery
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
    background(img[luck.getIndex()]);
    if (except == true){
        println("something worng");
        textSize(32);
        text("Restart and check the connection.",50,1050);
        fill(255,255,255);
    } else {
        luck.start(progress);
  }
    
}

void keyPressed() {
  int keyIndex;
  if (luck.GameStart == false && (key == 'S' || key == 's')) {  // Start the game 
      luck.GameStart = true;
      textSize(68);
      text("Game Start",width/2-300,height/2-100);
      fill(255,255,255);
      println("Start the lottery");
      
  } else if (key == ' ') {
      println("Recive the data");
      if(luck.GameStart == true) {
          progress++;
      } else {
          progress = 0;
      }
      
  } else if (key == 'R' || key == 'r') {    // Reset the game
      luck.reset();
      println("Reset the game");
  } else if (luck.GameStart == false && (key >= '0' && key <= '4')) {    // Select the prize
      keyIndex = key - '0';
 
      luck.setIndex(keyIndex);
      //background(img[luck.getIndex()]);
  }
  println("the key is",key);
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
    int inByte = myPort.read();

    if (inByte == 0xAA) { 
      myPort.clear();          // clear the serial port buffer
      println("Recive the data from serial");
      
      if(luck.GameStart == true) {
          progress++;
      } else {
          progress = 0;
      }
      
    } 
}



class Lottery{
    int Lottery_index;
    boolean[] Result = new boolean[5];
    boolean GameStart = false;               // The flag indicates the Game status
    int[][] lucknum4 = new int[6][8];
    int[]   Coor_4rd = {540,340,110,60};     // Define the 4rd prize layout x,y xgap,ygap
    private int now_progress = 0;
    private int last_progress = 0;
    Lottery (int index){
        Lottery_index = index;
        println("the Lottery index number is ",index);
    };
    void setIndex(int index) {
        Lottery_index = index;
        println("Set Lottery index number to ",index);
    }
    int getIndex() {
        return Lottery_index;
    }
    void reset() {
        switch(Lottery_index) {
        case 0:
            println("Reset 0");
            break;
        case 1:
            println("Reset 1");
            break;
        case 2:
            println("Reset 2");
            break;
        case 3:
            println("Reset 3");
            break;
        case 4:
            println("Reset 4");
            break; 
        default:
            break;
            }       
    }
    void start(int progress) {
        
        color c1 = color(0,255,progress*8); // define the progress bar
        color c2 = color(255,255,255);
        fill(c2);                           // Fill the background color of prograss bar
        rect(width/3-100, height/4*3, 800, 55, 7);
        noFill();
        if (progress>=knocktimes) {
            GameStart = false;
            println("The Game is over");
            Result[Lottery_index] = true;
        } 
            println("The progress is ",progress);
            switch(Lottery_index) {
            case 0:                                  // Create 1 results
                println("Start 0");
                break;
            case 1:                                  // Create 1 results
                println("Start 1");
                break;
            case 2:                                  // Create 2 results
                println("Start 2");
                break;
            case 3:                                  // Create 8 results
                println("Start 3");
                break;
            case 4:                                  // Create 138 results
                Create4rdPrize(knock(progress));
                if(GameStart){
                    println("Start 4");
                } else {
                    
                }
                if(Result[Lottery_index]) {
                    c1 = color(0,255,240);
                    fill(c1);
                    rect(width/3-100, height/4*3, 800, 55, 7); 
                } else {
                    fill(c1);
                    rect(width/3-100, height/4*3, progress*(800/30), 55, 7); 
                }
                noFill();
                break;  
            default:
                break;
            }             
    }
    void Create4rdPrize(boolean flag) {
        println("the flag is ",int(flag));
        String s;
        if(GameStart){
            for(int i=0; i<6; i++) {
                for (int j=0; j<8; j++) {
                    lucknum4[i][j] = int(random(1,1000));
                    s = Integer.toString(lucknum4[i][j]);
                    if(i == 5 && (j==0 || j==7)) {
                        lucknum4[i][j] = 0;
                        s = "";
                    }
                    textSize(32);
                    text(s,Coor_4rd[0]+Coor_4rd[2]*j+10*int(flag),Coor_4rd[1]+Coor_4rd[3]*i-35*int(flag));
                    // text(s,width/3+100*j,height/3);
                    fill(255,255,255);
                }
            }      
        } else {
            for(int i=0; i<6; i++) {
                for (int j=0; j<8; j++) {
                    s = Integer.toString(lucknum4[i][j]);
                    if(i == 5 && (j==0 || j==7)) {
                        lucknum4[i][j] = 0;
                        s = "";
                    }
                    textSize(32);
                    text(s,Coor_4rd[0]+Coor_4rd[2]*j,Coor_4rd[1]+Coor_4rd[3]*i);
                    // text(s,width/3+100*j,height/3);
                    fill(255,255,255);
                }
            } 
        }


    }
    boolean knock(int progress) {

        now_progress = progress;
        if (now_progress != last_progress) {
           last_progress = now_progress;
           return true;
        } else{
           return false;
        }
    }
}