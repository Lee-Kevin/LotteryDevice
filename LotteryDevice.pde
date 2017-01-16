/**
 * Lottery Device. 
 * 
 * This is a Lottery Device for Seeed New Year Party
 * by Kevin Lee@2016/12/13
 */
import java.io.*;
import processing.serial.*;

Lottery luck = new Lottery(4);

PImage[] img = new PImage[5];

boolean except = false;                  // Judge if there is a except
boolean ready =  false;                  // Judge if there is a except

Serial myPort;
int progress = 0;                        // Define the progress bar value
int MAX_NUMBER = 239;

//------------------------

void setup() {
    fullScreen(P3D,2); // Default screen 2 , render 3D 
    // Generate_Number generate_num = new Generate_Number();
    

    for (int i=0; i<5; i++) {
        String s;
        s = Integer.toString(i)+".jpg";
        println("the file is ",s);
        img[i] = loadImage(s);
        img[i].resize(width,height);
    }
    try {
       printArray(Serial.list());
       myPort = new Serial(this, Serial.list()[0], 115200);     
       myPort.clear();
    } catch(ArrayIndexOutOfBoundsException e) {
       println("except");
       except = true;
    }
    luck.max_number = MAX_NUMBER;
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
        if(!luck.GameStart) {
            progress = 0;
            ready = false;
        }
        luck.start(progress);  // Always run this function
  }
  
/*******************************************/    
    // ProgrcessBar bar = new ProgrcessBar();
    // bar.setProgressbar(50,i);
    
    // if(i++ >=50) {
        // i=0;
    // }
    // delay(50);    


/*******************************************/    
    
}

void keyPressed() {
  int keyIndex;
  PImage img;
  if (ready == false && luck.GameStart == false && (key == 'S' || key == 's')) {  // Start the game 
      ready = true;
// This is the start flag      
      img = loadImage("ready.png");
      image(img,600,700,img.width*2/3,img.height*2/3);
      
      // textSize(68);
      // text("开始抽奖了",width/2-300,height/2-100);
      // fill(255,255,255);
      noLoop();
      println("Start the lottery");
      
  } else if (key == ' ') {
      println("Recive the data");
      if(ready) {
          loop();
          progress++;
          luck.GameStart = true;
      }
      
  } else if (key == 'R' || key == 'r') {    // Reset the game
      luck.reset();
      luck.GameStart = false;
      println("Reset the game");
  } else if (luck.GameStart == false && (key >= '0' && key <= '4')) {    // Select the prize
      keyIndex = key - '0';
 
      luck.setIndex(keyIndex);
  } else {
       println("the key is",key);
  }
  println("the key is",key);
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
    int inByte = myPort.read();

    if (inByte == 0xAA) { 
      myPort.clear();          // clear the serial port buffer
      println("Recive the data from serial");
      if(ready) {
          loop();
          progress++;
          luck.GameStart = true;
      }
    } 
}

class ProgrcessBar {
    int width_bar = 45;
    int length_bar = 800;
    // int coor_x = width/3-100;
    // int coor_y = height/4*3;  
    
    int coor_x = 540;
    int coor_y = 810;
    
    color from = color (232, 255, 62);
    color to = color (255, 62, 143);
    // color from = color (00, 177, 213);
    // color to = color (56, 255, 0);
    ProgrcessBar() {
        
    }
// rect(width/3-100, height/4*3, 800, 45, 7);
    void setProgressbar(int knocktimes,int progress) {
        for (int i=0;i<progress;i++) {
            color interA=lerpColor(from, to, (float(i)/progress));
            fill(interA);
            if(i==0 || i== knocktimes-1) {
                rect(i*(length_bar/knocktimes)+coor_x,coor_y, length_bar/knocktimes-1, width_bar,7);
            } else {
                rect(i*(length_bar/knocktimes)+coor_x,coor_y, length_bar/knocktimes-1, width_bar);
            }
            noFill();
            
        }    
    }
}


class Lottery{
    
    final int temp_max = 170;  // Not include the unlucky list 156
    private int[] temp_list = new int[temp_max];   // Store the temp lottery number.    
    
    JSONObject json;
    int Lottery_index;                        // indicate the lottery index
    boolean[] Result = new boolean[5];
    boolean GameStart = false;                // The flag indicates the Game status
    boolean SaveStatus = false;               // The flag indicates if save the result
    int[][] lucknum4 = new int[6][8];         // This is the array to save the lottery 4
    int[]   lucknum3 = new int[8];            // This is the array to save the lottery 3
    int[]   lucknum2 = new int[2];            // This is the array to save the lottery 2
    int     lucknum1 = 0;                     // This is the variable to save the lottery 1
    int     lucknum0 = 0;                     // This is the variable to save the lottery 0
    
    int[]   Coor_4rd = {540,360,110,60};      // Define the 4rd prize layout x,y xgap,ygap
    int[]   Coor_3rd = {540,410,250,200};     // Define the 3rd prize layout x,y xgap,ygap
    int[]   Coor_2rd = {640,530,510,0};       // Define the 2rd prize layout x,y xgap,ygap
    int[]   Coor_1rd = {880,530};             // Define the 1rd prize layout x,y xgap,ygap
    int     max_number;                       // The max_number in this lottery  
    
    int     guest_startnum = 300;
    int     guest_stopnum  = 340;
    
    
    PImage img;
    
    ProgrcessBar bar = new ProgrcessBar();
    

    private int knocktimes = 30;              // Define how many times click the drum will open the lottery
    String[] Lottery_Name = {"lottery0","lottery1","lottery2","lottery3","lottery4","unlucky"}; 
    String[] lottery4_status = {"null","first","second","finished"};
    
    private int lottery4_index = 0;
    private int now_progress = 0;
    private int last_progress = 0;
    private int view_result = 0;
    
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
            println("Reset Lottery:",Lottery_index);
            
            json = loadJSONObject("data.json");
            JSONArray lottery_name = json.getJSONArray(Lottery_Name[Lottery_index]);
            JSONObject lottery_data = lottery_name.getJSONObject(0);  
            
            if(Lottery_index == 4){
                if(--lottery4_index <= 0) {
                    lottery4_index = 0;
                    
                }
                Result[Lottery_index] = false;
                lottery_data.setString("label",lottery4_status[lottery4_index]);
                saveJSONObject(json,"data/data.json");
                
            } else {
                Result[Lottery_index] = false;
                lottery_data.setString("label","null");
                saveJSONObject(json,"data/data.json");
            }
    }
    
    void start(int progress) {
        
        img = loadImage("finished.png");
        
    
        color c1 = color(0,255,progress*8); // define the progress bar
        color c2 = color(255,255,255);
        fill(c2);                           // Fill the background color of prograss bar
        rect(width/3-100, height/4*3, 800, 45, 7);
        noFill();
        
        json = loadJSONObject("data.json");
        JSONArray lottery = json.getJSONArray(Lottery_Name[Lottery_index]);
        JSONObject lottery_data = lottery.getJSONObject(0);
        String label = lottery_data.getString("label");
        
        println("The label is :",label);
        
        println("The progress is ",progress);
        fill_list(); 
            switch(Lottery_index) {
            case 0:                                  // Create 1 results
                knocktimes = 100;
                if (label.compareTo("finished") == 0) {
                    GameStart = false;
                    
                    bar.setProgressbar(knocktimes,knocktimes);
                    image(img,500,900,img.width*2/3,img.height*2/3);
                    
                }
                if (progress >= knocktimes) {
                    GameStart = false;
                    Result[Lottery_index] = true;
                    lottery_data.setString("label","finished");
                    saveJSONObject(json,"data/data.json");  
                }  
                
                bar.setProgressbar(knocktimes,progress);
                
                Create0rdPrize(knock(progress));
                saveResult(json);
                break;
            case 1:                                  // Create 1 results
                knocktimes = 100;
                
                if (label.compareTo("finished") == 0) {
                    GameStart = false;
                    bar.setProgressbar(knocktimes,knocktimes);
                    image(img,500,900,img.width*2/3,img.height*2/3);
                }
                if (progress >= knocktimes) {
                    GameStart = false;
                    Result[Lottery_index] = true;
                    lottery_data.setString("label","finished");
                    saveJSONObject(json,"data/data.json");  
                }
                bar.setProgressbar(knocktimes,progress);
                
                Create1rdPrize(knock(progress));
                saveResult(json);
                println("Start 2");
                break;
            case 2:                                  // Create 2 results
                knocktimes = 100;
                if (label.compareTo("finished") == 0) {
                    GameStart = false;
                    bar.setProgressbar(knocktimes,knocktimes);
                    image(img,500,900,img.width*2/3,img.height*2/3);
                }
                if (progress >= knocktimes) {
                    GameStart = false;
                    Result[Lottery_index] = true;
                    lottery_data.setString("label","finished");
                    saveJSONObject(json,"data/data.json");  
                } 
                
                bar.setProgressbar(knocktimes,progress);
                
                Create2rdPrize(knock(progress),progress);
                saveResult(json);  
                println("Start 2");
                break;
            case 3:                                  // Create 8 results
                knocktimes = 100;
                if (label.compareTo("finished") == 0) {
                    GameStart = false;
                    
                    bar.setProgressbar(knocktimes,knocktimes);
                    image(img,500,900,img.width*2/3,img.height*2/3);
                }
                if (progress >= knocktimes) {
                    GameStart = false;
                    Result[Lottery_index] = true;
                    lottery_data.setString("label","finished");
                    saveJSONObject(json,"data/data.json");  
                }
                
                bar.setProgressbar(knocktimes,progress);
                
                Create3rdPrize(knock(progress),progress);
                saveResult(json);
                break;
            /** Here is the code about how to create lottery 4  **/
            case 4:                                  // Create 138 results
                knocktimes = 50;
                if (label.compareTo("null") == 0) {
                    lottery4_index = 0;
                } else if ( label.compareTo("first") == 0){
                    image(img,500,900,img.width*2/3,img.height*2/3);
                    lottery4_index = 1;
                    if(Result[Lottery_index]) {
                        bar.setProgressbar(knocktimes,knocktimes);
                    }
                } else if ( label.compareTo("second") == 0){
                    
                    image(img,500,900,img.width*2/3,img.height*2/3);
                    image(img,700,900,img.width*2/3,img.height*2/3);
                    
                    lottery4_index = 2;
                    if(Result[Lottery_index]) {
                        bar.setProgressbar(knocktimes,knocktimes);
                    }                    
                } else if ( label.compareTo("finished") == 0){
                    lottery4_index = 3;
                    
                    image(img,500,900,img.width*2/3,img.height*2/3);
                    image(img,700,900,img.width*2/3,img.height*2/3);
                    image(img,900,900,img.width*2/3,img.height*2/3);
                    
                    bar.setProgressbar(knocktimes,knocktimes);
                    GameStart = false;
                }
                if (progress>=knocktimes) {
                    
                    if(++lottery4_index >= 4) {
                        lottery4_index = 3;
                    }
                    lottery_data.setString("label",lottery4_status[lottery4_index]);
                    
                    saveJSONObject(json,"data/data.json");  
                    GameStart = false;
                    Result[Lottery_index] = true;
                    println("Finish the Game number",lottery4_index);
                    println("The Game is over");
                }
                
                bar.setProgressbar(knocktimes,progress);
                
                Create4rdPrize(knock(progress));
                println("the Game number",lottery4_index);
                saveResult(json);
                
                break;  
            default:
                break;
            }
        
    }

    void Create0rdPrize(boolean flag) {
        String s="0";
        if(GameStart) {   //产生不重复的数字
            int[] test_result = randomCommon(1,max_number,1);
            lucknum0 = test_result[0];
            s = Integer.toString(lucknum0);
            fill(255,255,255); 
            textSize(100);
            text(s,Coor_1rd[0]+10*int(flag),Coor_1rd[1]-35*int(flag));
                    // text(s,width/3+100*j,height/3);
            noFill();
            // fill(255,255,255);  
            Result[Lottery_index] = false;
            SaveStatus = false;
        } else {
            s = Integer.toString(lucknum0);
            fill(255,255,255); 
            textSize(100);
            text(s,Coor_1rd[0]+10*int(flag),Coor_1rd[1]-35*int(flag));
            noFill();
        }
    }
    
    void Create1rdPrize(boolean flag) {
        String s="0";
        if(GameStart) {   //产生不重复的数字
            int[] test_result = randomCommon(1,max_number,1);
            lucknum1 = test_result[0];
            s = Integer.toString(lucknum1);
            
            fill(255,255,255);  
            textSize(100);
            text(s,Coor_1rd[0]+10*int(flag),Coor_1rd[1]-35*int(flag));
                    // text(s,width/3+100*j,height/3);
            noFill();
            Result[Lottery_index] = false;
            SaveStatus = false;
        } else {
            s = Integer.toString(lucknum1);
            fill(255,255,255);  
            textSize(100);
            text(s,Coor_1rd[0]+10*int(flag),Coor_1rd[1]-35*int(flag));
            noFill();
        }
    }
    
    void Create2rdPrize(boolean flag,int progress) {
        String s="0";
        if(GameStart) {   //产生不重复的数字
            int index = 0;
            int[] test_result = randomCommon(1,max_number,2);
            if(progress >= knocktimes/2) {
                for(int i=0; i<2; i++) {
                    if(i == 0) {
                        s = Integer.toString(lucknum2[i]);;
                    } else {
                        s = Integer.toString(test_result[i]);
                    }
                    fill(255,255,255);  
                    textSize(90);
                    text(s,Coor_2rd[0]+Coor_2rd[2]*i+10*int(flag),Coor_2rd[1]-35*int(flag));
                        // text(s,width/3+100*j,height/3);
                    noFill();                    
                }
            } else {
                for(int i=0; i<2; i++) {
                    lucknum2[i] = test_result[i];
                }
                for(int i=0; i<2; i++) {
                    if(i == 1) {
                        s = "0";
                    } else {
                        s = Integer.toString(lucknum2[i]);
                    }
                    fill(255,255,255);  
                    textSize(90);
                    text(s,Coor_2rd[0]+Coor_2rd[2]*i+10*int(flag),Coor_2rd[1]-35*int(flag));
                        // text(s,width/3+100*j,height/3);
                    noFill();                    
                }
            
            }
            Result[Lottery_index] = false;
            SaveStatus = false;
        } else {
            for(int i=0; i<2; i++) {
                s = Integer.toString(lucknum2[i]);
                fill(255,255,255);
                textSize(84);
                text(s,Coor_2rd[0]+Coor_2rd[2]*i+10*int(flag),Coor_2rd[1]-35*int(flag));
                        // text(s,width/3+100*j,height/3);
                noFill();                        
            }
        }
    }    
        
    
    void Create3rdPrize(boolean flag,int progress) {
        String s="0";
        if(GameStart) {   //产生不重复的数字
            int index = 0;
            int[] test_result = randomCommon(1,max_number,8);
            if(progress >= knocktimes/2) {
                for(int i=0; i<2; i++) {
                    for(int j=0; j<4; j++) {
                        if(i==1) {
                            s = Integer.toString(test_result[4+j]);
                        } else {
                            s = Integer.toString(lucknum3[4*i+j]);
                        }
                        fill(255,255,255); 
                        textSize(68);
                        text(s,Coor_3rd[0]+Coor_3rd[2]*j+10*int(flag),Coor_3rd[1]+Coor_3rd[3]*i-35*int(flag));
                            // text(s,width/3+100*j,height/3);
                        noFill(); 
                    }
                }
            } else {
                for(int i=0; i<8; i++) {
                    lucknum3[i] = test_result[i];
                }
                for(int i=0; i<2; i++) {
                    for(int j=0; j<4; j++) {
                        if(i==1) {
                            s = "0";
                        } else{
                            s = Integer.toString(lucknum3[4*i+j]);
                        }
                        fill(255,255,255);
                        textSize(68);
                        text(s,Coor_3rd[0]+Coor_3rd[2]*j+10*int(flag),Coor_3rd[1]+Coor_3rd[3]*i-35*int(flag));
                            // text(s,width/3+100*j,height/3);
                        noFill(); 
                    }
                }                
            }
            Result[Lottery_index] = false;
            SaveStatus = false;
        } else {
            for(int i=0; i<2; i++) {
                for(int j=0; j<4; j++) {
                    s = Integer.toString(lucknum3[4*i+j]);
                    fill(255,255,255); 
                    textSize(68);
                    text(s,Coor_3rd[0]+Coor_3rd[2]*j+10*int(flag),Coor_3rd[1]+Coor_3rd[3]*i-35*int(flag));
                        // text(s,width/3+100*j,height/3);
                    noFill(); 
                }
            }

        }
    }    
    
    
    void Create4rdPrize(boolean flag) {
        String s="0";
        if(GameStart) {   //产生不重复的数字
            int index = 0;
            int[] test_result = randomCommon(1,max_number,48);
            int[] guest_result = randomCommon(guest_startnum,guest_stopnum,2);
            for(int i=0; i<6; i++) {
              for(int j=0; j<8; j++){

                if (i==5 && (j==0 || j==7)) {
                    lucknum4[i][j] = 0;
                    s = "";
                } else {
                    index++;
                    lucknum4[i][j] = test_result[index];
                    s = Integer.toString(lucknum4[i][j]);
                }
                if(i == 3 && (j==0 || j==6)) {
                    lucknum4[i][j] = guest_result[j/6];
                }
                fill(255,255,255); 
                textSize(32);
                text(s,Coor_4rd[0]+Coor_4rd[2]*j+10*int(flag),Coor_4rd[1]+Coor_4rd[3]*i-35*int(flag));
                    // text(s,width/3+100*j,height/3);
                noFill(); 
              }
            }
            Result[Lottery_index] = false;
            SaveStatus = false;
        } else {
            for(int i=0; i<6; i++) {
                for (int j=0; j<8; j++) {

                    s = Integer.toString(lucknum4[i][j]);
                    if(i == 5 && (j==0 || j==7)) {
                        lucknum4[i][j] = -1;
                        s = "";
                    }
                    fill(255,255,255);
                    textSize(32);
                    text(s,Coor_4rd[0]+Coor_4rd[2]*j,Coor_4rd[1]+Coor_4rd[3]*i);
                    // text(s,width/3+100*j,height/3);
                    noFill();
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
    
    // Save the result
    void saveResult(JSONObject json) {
        String s;
        JSONArray lottery = json.getJSONArray(Lottery_Name[Lottery_index]);
        JSONObject lottery_data = lottery.getJSONObject(0);
        String label = lottery_data.getString("label");
        JSONObject lottery_result = lottery_data.getJSONObject("result");
        
        switch(Lottery_index) {
        case 0:
            if(Result[Lottery_index] && SaveStatus == false) { // Finish the lottery
                SaveStatus = true;
                s = Integer.toString(1);
                lottery_result.setInt(s,lucknum0);
                saveJSONObject(json,"data/data.json");   
                println("Finish the 4-1 prize and save the result");     
            }
            break;
        case 1:
            if(Result[Lottery_index] && SaveStatus == false) { // Finish the lottery
                SaveStatus = true;
                s = Integer.toString(1);
                lottery_result.setInt(s,lucknum1);
                saveJSONObject(json,"data/data.json");   
                println("Finish the 4-1 prize and save the result");     
            }  
            break;
        case 2:
            if(Result[Lottery_index] && SaveStatus == false) { // Finish the lottery
                SaveStatus = true;
                for(int i=0; i<2; i++) {
                    s = Integer.toString(1+i);
                    lottery_result.setInt(s,lucknum2[i]);
                }
                saveJSONObject(json,"data/data.json");   
                println("Finish the 4-1 prize and save the result");     
            }         
            break;
        case 3:
            if(Result[Lottery_index] && SaveStatus == false) { // Finish the lottery
                SaveStatus = true;
                for(int i=0; i<8; i++) {
                    s = Integer.toString(1+i);
                    lottery_result.setInt(s,lucknum3[i]);
                }
                saveJSONObject(json,"data/data.json");   
                println("Finish the 4-1 prize and save the result");     
            } 
            break;
        case 4:
            if(Result[Lottery_index] && SaveStatus == false) { // Finish the lottery
                SaveStatus = true;
                for(int i=0; i<6; i++) {
                    for (int j=0; j<8; j++) {
                        s = Integer.toString(48*(lottery4_index-1)+8*i+(j+1));
                        lottery_result.setInt(s,lucknum4[i][j]);
                    }
                }
                saveJSONObject(json,"data/data.json");   
                println("Finish the 4-1 prize and save the result");    
                
            } 
            // if(label.compareTo("first") == 0 && !GameStart) {  // Have finished the 4rd-first time lottery
                // for(int i=0; i<6; i++) {
                    // for (int j=0; j<8; j++) {
                        // s = Integer.toString(8*i+(j+1));
                        // lottery_result.setInt(s,lucknum4[i][j]);
                    // }
                // }
                // saveJSONObject(json,"data/data.json");   
                // println("Finish the 4-1 prize and save the result");
            // } 
            break;
        default:
            break;
            
        }
    }
    
    /** 
     * 随机指定范围内N个不重复的数 
     * 最简单最基本的方法 
     * @param min 指定范围最小值 
     * @param max 指定范围最大值 
     * @param n 随机数个数 
     */  
    public int[] randomCommon(int min, int max, int n){
            
        if (n > (max - min + 1) || max < min) {  
               return null;  
           }  
        int[] result = new int[n];  
        int count = 0;  
        while(count < n) {  
            int num = (int) (Math.random() * (max - min)) + min;  
            boolean flag = true;  
            for (int j = 0; j < n; j++) {  
                if(num == result[j]){  
                    flag = false;  
                    break;  
                }  
            }
            if(findlist(num)) {
                flag = false;
            }
            if(flag){  
                result[count] = num;  
                // println("The luck number is ",result[count]);
                count++;  
                
            }  
        }  
        return result;  
    }  
    // To Judge if the number is already in the list.
    void fill_list() {
        int index = 5;
        int list_index = 0;
        String s;
        for (int i= index; i>=Lottery_index; i--) {
            JSONArray lottery = json.getJSONArray(Lottery_Name[i]);
            JSONObject lottery_data = lottery.getJSONObject(0);
            JSONObject lottery_result = lottery_data.getJSONObject("result"); 
            for(int j=1; j<150; j++) {
                try {
                    s = Integer.toString(j);
                    int x = lottery_result.getInt(s);
                    temp_list[list_index++] = x;
                } catch (Exception e) {
                    println("Still cann't find the number, break the loop");
                    break;
                }           
            }
        }
    }
    
    boolean findlist(int ran) {
        boolean find = false;
        for(int i=0; i<temp_max; i++) {
            if(ran == temp_list[i]) {
                // println("The Same number is ",ran);
                return true;
            }
            if(temp_list[i] == 0) {
                return false;
            }
        }
        return false;
    }
}