#include "Pinouts.h"

float Vin = 5;
float Rf = 11000;
float Rn1 = 6000;
float Rg = 48000;
float Rp1 = 50000;
float R2 = 5000;
float angle;

float Vteensy = VANE_PIN;

float Vdivider = -Rn1/Rf*(Vteensy - (1+Rf/Rn1)* (Rg/(Rp1+Rg)*Vin)); //back out to get Vout from voltage divider

float R1 = R2*(Vin/Vdivider - 1); // back out to get resistance 


