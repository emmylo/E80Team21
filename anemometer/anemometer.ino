#include <Arduino.h>
#include <Wire.h>
//The following file defines Interrupt Service Routine (ISR)-- what happens when interrupt is triggered
//and provide list of possible interrupt routines.
#include <avr/interrupt.h>

int hallSensor = 15; //connect hall effect sensor output to pin 17 or pin corresponding to A3
int revolution = 0; //initialize revolution count

float loopDuration = 0.099;
float rps = 0;

void setup() {
  Serial.begin(9600);
  pinMode(hallSensor, INPUT_PULLUP);
  //when hallSensor pin goes from HIGH to LOW (falls), call the ISR function
  attachInterrupt(digitalPinToInterrupt(hallSensor), ISR, FALLING);
}

void loop() {

  
}

//ISR function: increments revolution count and prints to serial monitor
void ISR(){ 
  revolution += 1;
  Serial.print("Revolution count: ");
  Serial.println(revolution);

  }

