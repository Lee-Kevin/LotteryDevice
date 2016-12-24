/*****************************************************************************/
// Lottery Device Arduino Side 
// By Jianli
//
/*******************************************************************************/
#include <Adafruit_NeoPixel.h>
#include <Wire.h>
#include "MMA7660.h"

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

#define PIN 6

#define SOUNDPIN A0

#define NUMPIXELS 52

#define BRIGHTNESS 50


  
//Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, PIN, NEO_GRBW + NEO_KHZ800);
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

int8_t x;
int8_t y;
int8_t z;
uint8_t bright = 0;
int8_t last_z;
MMA7660 accelemeter;
int8_t result_z[5];

uint16_t knock = 0;


int sensorValue = 0;
void setup()
{
	accelemeter.init();  
	Serial.begin(115200);
    pixels.setBrightness(BRIGHTNESS);
    pixels.begin();
    
    sbi(ADCSRA,ADPS2) ;
    cbi(ADCSRA,ADPS1) ;
    cbi(ADCSRA,ADPS0) ;
    
    //strip.show(); // Initialize all pixels to 'off'
    for(uint16_t i=0; i<pixels.numPixels(); i++) {
        pixels.setPixelColor(i,pixels.Color(100,100,0));
        delay(10);
    }
    pixels.show();
    delay(1000);
    for(uint16_t i=0; i<pixels.numPixels(); i++) {
        pixels.setPixelColor(i,pixels.Color(0,0,0));
        delay(1);
    }
    pixels.show();
    delay(100);
    

}
void loop()
{
    uint8_t r;
    uint8_t g;
    uint8_t b;
    int8_t min = 127;
    int8_t max = -127;
    int16_t sum = 0;
    
    for (uint8_t i=0; i<5; i++) {
        accelemeter.getXYZ(&x,&y,&z);
        delay(6);
        result_z[i] = z;
        if(result_z[i] < min) {
            min = result_z[i];
        }
        if(result_z[i] > max) {
            max = result_z[i];
        }
        sum += result_z[i];
    }
    z = (sum - (max + min))/3;
    
    
    
    
    for(uint16_t i=0; i<pixels.numPixels(); i++) {
            if(abs(7*(z+20))>255) {
                r = 255;
            } else {
                r = abs(7*(z+20));
            }
            pixels.setPixelColor(i,pixels.Color(255,0,r));
    }
    sensorValue = analogRead(SOUNDPIN);
	if(abs(z+20)>20 && sensorValue > 800) {
        4*abs(z+20)>=100 ? bright=100 : bright=4*abs(z+20);
        pixels.setBrightness(bright);
        pixels.show();
        knock++;
        Serial.print("sensorValue is:");
        Serial.println(sensorValue);     
        Serial.print("Knock time is:");
        Serial.println(knock);
        delay(150);
        Serial.println("------------------------------");
   } else {
       bright<=2 ? bright = 0 : bright -= 2;
       if(bright <=0) {
           bright = 0;
       }
       pixels.setBrightness(bright);
       pixels.show();
   }
   // Serial.print("z -last_z ");
   // Serial.println(z+20);
   last_z = z;

   // Serial.print("z = ");
   // Serial.println(z);
//

	
}


