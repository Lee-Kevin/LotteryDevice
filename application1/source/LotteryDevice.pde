import processing.serial.*;
Lottery test;

/**
 * @Components layout
 */  
 
int[] coor_longitude = {150, 28};
int[] coor_latitude = {150, 48};
int[] coor_satellite = {280, 300};
int[] coor_pic = {610, 25, 600, 240};
int[] coor_compass = {500, 180};
int[] coor_dashBoard = {600, 240};
int[] coor_thermometer = {800, 250};
int[] coor_humidity = {900, 250};
int[] coor_button = {600, 470};

/**
 * @Button layout
 */
 
int g_ibutton_width =  80;
int g_ibutton_height = 50;
int g_ibutton_gap = g_ibutton_width + 25;
int g_itext_gap = g_ibutton_height + 15;
int[] g_ibutton1 = {coor_button[0], coor_button[1]};
int[] g_ibutton2 = {coor_button[0] + 1 * g_ibutton_gap, coor_button[1]};
int[] g_ibutton3 = {coor_button[0] + 2 * g_ibutton_gap, coor_button[1]};
int[] g_ibutton4 = {coor_button[0] + 3 * g_ibutton_gap, coor_button[1]};

PShape satellite;
PShape thermometer;
PShape humidity;
PImage compass;
PImage compass_arrow;

Serial myPort;
OutputStream output;

int is_first_change_to_system_state_1   = 0;    //something special should be done at first when system_state is changed to 1
int number_got_of_img_now               = -1;

String inString = "0";          //this is a temp vary to store the date from the Serial.
int pic_length;                 //how many bytes the img include

int system_state = 0;//this vary indicate which state is the program running now.

PImage img;
PImage bg;

void setup() {
  //size(1920, 1080, P3D);
  fullScreen(P3D,2);
  noStroke();
  printArray(Serial.list());
  //LOOK HERE!!  0 is the number of Serial module on my PC, you NEED change it to a correct number, most time is 0 or 1 in PC.
  myPort = new Serial( this, Serial.list()[0], 115200);     
  myPort.clear();
  println("Processing init finished");
  satellite = loadShape("rocket.obj");
  img = loadImage("pic.jpg");
  thermometer = loadShape("thermometer.svg");
  humidity = loadShape("thermometer.svg");
  bg = loadImage("metel.png");
  compass = loadImage("my_compass.png");
  compass_arrow = loadImage("my_compass_arrow.png");
}
float rotate_x = 0.0;
float rotate_y = 0.0;
float rotate_z = 0.0;
float compass_value = 0;
void draw() {
  background(238,65,67);
  stroke(255);
  fill(0);
  
  //draw 
  gps_coordinate(12.234234234, 43.23232);
  
  draw_picture();
  draw_compass(TWO_PI*random(1.0));
  draw_temp_and_humi(100.00, 90.32);
  draw_satellitePosture(rotate_x, rotate_y, rotate_z);
  
  rotate_y += 0.02;
  rotate_x += 0.05;
  rotate_z += 0.02;
  compass_value += HALF_PI*0.01;
  
  if (system_state == 1) {
    while ( myPort.available () > 0 ) {
      if (is_first_change_to_system_state_1 == 0) {       // Arduino will send the length of img at first, get it
        delay(500);
        inString = myPort.readStringUntil('\n');
        inString =  trim(inString);
        pic_length = int(inString);
        println("pic_length: "+pic_length);
        if (pic_length == 0) {
          system_state = 0;
          break;
        }
        is_first_change_to_system_state_1 = 1;
      } else {
        int[] dataBuffer = new int[128];
        int sum = 0;
        boolean numberEnoughFlag = true;

        for (int i = 0; i < 127; ++i) {
          if (numberEnoughFlag) {

            if (Get_Valid_Serial_Number() == false) {           //if get enough data from serial
              numberEnoughFlag = false;
            }
            if (numberEnoughFlag) {
              dataBuffer[i] = myPort.read();                  //get the data bytes from serial
              sum += dataBuffer[i];
              sum = sum % 0xFF;
            }
          }
        }
        if (numberEnoughFlag) {

          if (Get_Valid_Serial_Number() == false) {
            numberEnoughFlag = false;
          }
          dataBuffer[127] = myPort.read();    //get the check byte
        }

        while ((sum != dataBuffer[127]) || (!numberEnoughFlag)) {   //if check byte is incorrect or not enough bytes received, get bytes again
          myPort.write('0');                              //send '0' to tell the arduino something is wrong during communication

          sum = 0;
          numberEnoughFlag = true;

          int falseNumber = 0;
          for (int i = 0; i < 127; ++i) {
            if (numberEnoughFlag) {

              if (Get_Valid_Serial_Number() == false) {
                numberEnoughFlag = false;
              }

              if (numberEnoughFlag) {
                dataBuffer[i] = myPort.read();
                sum += dataBuffer[i];
                sum = sum % 0xFF;
                falseNumber = i;
              }
            }
          }

          if (numberEnoughFlag) {

            if (Get_Valid_Serial_Number() == false) {
              numberEnoughFlag = false;
            }
            dataBuffer[127] = myPort.read();
          }
        }

        number_got_of_img_now += 127;
        print('.');

        if (number_got_of_img_now <= pic_length) {      //havn't got all the data
          for (int i = 0; i < 127; ++i) {
            try {
              output.write(dataBuffer[i]);
            }
            catch (IOException e) {
              e.printStackTrace();
            }
          }

          myPort.write('1');
        } else {                                         //finished the communicating,
          for (int i = 0; i < (127 + pic_length - number_got_of_img_now); ++i) {
            try {
              output.write(dataBuffer[i]);
            }
            catch (IOException e) {
              e.printStackTrace();
            }
          }

          try {
            output.flush(); // Writes the remaining data to the file
            output.close(); // Finishes the file
          }

          catch (IOException e) {
            e.printStackTrace();
          }

          img = loadImage("pic.jpg");             //show the image
          image(img, 0, 0);
          system_state = 0;
          myPort.write('1');

          break;
        }
      }
    }
  } else {
    while (myPort.available() > 0) {    //system_state = 0, just print the data from serial
      print(myPort.readChar());
    }
  }
}

/**
 * [Get_Valid_Serial_Number description] return false if there is still nothing from Serial after 100ms. or return true. in case of some bytes lost while communication,
 *                                       but the program is waiting all the time.
 */
boolean Get_Valid_Serial_Number() {
  int waitingCount = 0;
  while (myPort.available() <= 0) {
    delay(1);
    if (waitingCount++ > 100) {
      return false;
    }
  }
  return true;
}

void mouseReleased() {
  if (mouseIn(g_ibutton1[0], g_ibutton1[1], g_ibutton1[0] + g_ibutton_width, g_ibutton1[1] + g_ibutton_height)) {
    output = createOutput("pic.jpg");
    myPort.write('2');
    is_first_change_to_system_state_1 = 0;
    number_got_of_img_now = 0;

    system_state = 1;

    delay(5000);
    while (myPort.available() > 0 ) {
      print(myPort.readChar());
    }
    myPort.write('2');
    println("taking a photo");
  }
  if (mouseIn(g_ibutton2[0], g_ibutton2[1], g_ibutton2[0] + g_ibutton_width, g_ibutton2[1] + g_ibutton_height)) {
    myPort.write('2');
    delay(5000);
    while (myPort.available() > 0 ) {
      print(myPort.readChar());
    }

    myPort.write('3');
    println("taking up servo");
  }
  if (mouseIn(g_ibutton3[0], g_ibutton3[1], g_ibutton3[0] + g_ibutton_width, g_ibutton3[1] + g_ibutton_height)) {
    myPort.write('2');
    delay(5000);
    while (myPort.available() > 0 ) {
      print(myPort.readChar());
    }

    myPort.write('4');
    println("taking down servo");
  }
  //Reset
  if (mouseIn(g_ibutton4[0], g_ibutton4[1], g_ibutton4[0] + g_ibutton_width, g_ibutton4[1] + g_ibutton_height)) {
    myPort.write('3');
    system_state = 0;
  }
}



boolean mouseIn(int x1, int y1, int x2, int y2) {
  if ( (mouseX > x1) && (mouseX < x2) && (mouseY > y1) && (mouseY < y2)) {
    return true;
  } else {
    return false;
  }
}

void keyPressed() {
    
  println(key);
}


void draw_satellitePosture(float rotate_x, float rotate_y, float rotate_z) {
  pushMatrix();
  translate(coor_satellite[0], coor_satellite[1]);
  rotateX(rotate_x);
  rotateY(rotate_y);
  rotateZ(rotate_z);
  scale(0.7);
  shape(satellite);
  popMatrix();
}

void draw_compass(float degree) {
  pushMatrix();
  translate(coor_compass[0], coor_compass[1]);
  image(compass, 0, 0, 400, 300);
  popMatrix();
  pushMatrix();
  translate(coor_compass[0] + compass.width/4, coor_compass[1] + compass.height/4);
  rotateZ(degree);
  translate(-compass.width/4, -compass.height/4);
  image(compass_arrow, 0, 0, 400, 300);
  popMatrix();
}

void draw_picture() {
  image(img, coor_pic[0], coor_pic[1]);
}

void draw_temp_and_humi(float temp, float humi) {
  String str_temp = String.format("%.2f", temp) + "C";
  String str_humi = String.format("%.2f", humi) + "%";
  fill(204, 0, 0);
  noStroke();
  textSize(20);
  text(str_temp, coor_thermometer[0], coor_thermometer[1] + 180);
  text(str_humi, coor_humidity[0], coor_humidity[1] + 180);
  shape(thermometer, coor_thermometer[0], coor_thermometer[1], 30, 150);
  shape(humidity, coor_humidity[0], coor_humidity[1], 30, 150);
  rect(coor_thermometer[0] + 10, coor_thermometer[1] + 132 - temp, 5, temp);
  rect(coor_humidity[0] + 10, coor_humidity[1] + 132 - humi, 5, humi);
  
}

void gps_coordinate(float longitude, float latitude) {
  String str_longitude = "longitude:" + String.format("%f",longitude);;
  String str_latitude = "latitude:" + String.format("%f",latitude);
  textSize(20);
  fill(255, 0, 0);
  text(str_longitude, coor_longitude[0], coor_longitude[1]);
  text(str_latitude, coor_latitude[0], coor_latitude[1]);
}
// END FILE