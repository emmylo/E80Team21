
/*SPI*/

#include "Metro.h"     //Include Metro library
#include "MLX90316.h"  // Include MLX90316 library
int pin_SS = 10; 
int pinSCLK = 13; 
int pinMOSI = 11; 
int ii;
int angle;
String direction;
Metro mlxMetro = Metro(5);
MLX90316 mlx_1  = MLX90316();

void setup() { 
Serial.begin(9600);
//Initializes the SPI bus by setting SCK, MOSI, and SS to outputs, pulling SCK and MOSI low, and SS high.
  mlx_1.attach(pin_SS,pinSCLK, pinMOSI );
Serial.println(" MLX90316 Rotary Position Sensor");
}


void loop() {
  
  if (mlxMetro.check() == 1) {
    ii = mlx_1.readAngle();
    angle = ii/10; //readAngle gives 10 * degrees, thus 3600 = is 360.0º
    /* if ii = -1 then no SPI signal
     * if ii = -2 then signal too strong
     * if ii = -3 then signal too weak
     * "angle" will read 0 if signal is lost
    */  
    
    if ((angle >= 0 && angle <= 225) | (angle > 3375 && angle <= 3600)){
        direction = "North";
      } else if (angle > 225 && angle <= 675){
        direction = "North East";
      } else if (angle > 675 && angle <= 1125){
        direction = "East";
      } else if (angle > 1125 && angle <= 1575){
        direction = "South East";
      } else if (angle > 1575 && angle <= 2025){
        direction = "South";
      } else if (angle > 2025 && angle <= 2475){
        direction = "South West";
      } else if (angle > 2475 && angle <= 2925){
        direction = "West"; 
      } else if (angle > 2925 && angle <= 3375){
        direction = "North West";
      } else if (angle == -3){
         direction = "weak signal";
      } else if (angle == -2){
        direction = "too strong signal";
      } else if (angle == -1){
        direction = "no signal";
      } else{
        direction = "?";
      }
    Serial.print(angle); 
    Serial.print("   direction   ");
    Serial.println(direction);
  }
  delay(300);                        
}

