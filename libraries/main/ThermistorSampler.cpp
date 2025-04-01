#include "ThermistorSampler.h"
#include "Printer.h"

extern Printer printer;

ThermistorSampler::ThermistorSampler(void) 
  : DataSource("Thermistor","double") // from DataSource is thermistor the right name? double?
{}


void ThermistorSampler::init(void)
{
  pinMode(USER_BUTTON,INPUT_PULLUP); //WHAT PIN MODE???
  // when the button is not pressed the voltage
  // at USER_BUTTON will be high
}


void ThermistorSampler::updateState(void)
// This function is called in the main loop of Default_Robot.ino
{
  // when the voltage at USER_BUTTON is low, the button 
  // has been pressed, thus buttonState is set to high
  thermistorState = !analogRead(USER_BUTTON); //changed from digital to analog?
}


String ThermistorSampler::printState(void)
// This function returns a string that the Printer class 
// can print to the serial monitor if desired
{
  return "Thermistor Temperature: " + String(thermistorState);
}

size_t ThermistorSampler::writeDataBytes(unsigned char * buffer, size_t idx)
// This function writes data to the micro SD card
{
  double * data_slot = (double *) &buffer[idx];
  data_slot[0] = thermistorState;
  return idx + sizeof(double); //double or bool?
}
