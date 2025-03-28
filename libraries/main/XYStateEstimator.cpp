#include "XYStateEstimator.h"
#include <math.h>
#include "Printer.h"
extern Printer printer;

inline float angleDiff(float a) {
  while (a<-PI) a += 2*PI;
  while (a> PI) a -= 2*PI;
  return a;
}

XYStateEstimator::XYStateEstimator(void)
  : DataSource("x,y","float,float") // from DataSource
{}

void XYStateEstimator::init(void) {
 	state.x = 0;
  state.y = 0;
  state.yaw = 0;
}

void XYStateEstimator::updateState(imu_state_t * imu_state_p, gps_state_t * gps_state_p) {
  if (gps_state_p->num_sat >= N_SATS_THRESHOLD){
    gpsAcquired = 1;

    // Convert latitude and longitude length to m 
    float dLat = gps_state_p -> lat - orgin_lat;   //Degrees 
    float dLon = gps_state_p -> lon - orgin_lon;
    //Radians 
    float dLatRad = dLat * (PT/180);
    float dLonRad = dLon * (PT/180);
    //Equirectangular Projection 
    state.x = RADIUS_OF_EARTH_M*cos(orgin_lat * (PI/180)) * dLonRad; //East 
    state.y = RADIUS_OF_EARTH_M * dLatRad;

    // Convert IMY heading - CW from North to yaw - CCW from East 
    float headingRad = imu_state_p -> heading * (PI/180); // Convert to radians 
    float offset = PI/2; // Rotating 90 deg from north to east 
    state.yaw = angleDiff(offset - headingRad) // Flip sign for CW to CCw 
    
    

    // set the values of state.x, state.y, and state.yaw
    // It can make use of the constants RADIUS_OF_EARTH, origin_lat, origin_lon (see XYStateEstimator.h)
    // You can access the current GPS latitude and longitude readings with gps_state_p->lat and gps_state_p->lon
    // You can access the current imu heading with imu_state_p->heading
    // Also note that math.h is already included so you have access to trig functions [rad]

    ///////////////////////////////////////////////////////////////////
    // INSERT YAW, X and Y CALCULATION HERE
    //////////////////////////////////////////////////////////////////

  }
  else{
    gpsAcquired = 0;
  }
}

String XYStateEstimator::printState(void) {
  String currentState = "";
  int decimals = 2;
  if (!gpsAcquired){
    currentState += "XY_State: Waiting to acquire more satellites...";
  }
  else{
    currentState += "XY_State: x: ";
    currentState += String(state.x,decimals);
    currentState += "[m], ";
    currentState += "y: ";
    currentState += String(state.y,decimals);
    currentState += "[m], ";
    currentState += "yaw: ";
    currentState += String(state.yaw,decimals);
    currentState += "[rad]; ";
  }
  return currentState;
}

size_t XYStateEstimator::writeDataBytes(unsigned char * buffer, size_t idx) {
  float * data_slot = (float *) &buffer[idx];
  data_slot[0] = state.x;
  data_slot[1] = state.y;
  return idx + 2*sizeof(float);
}
