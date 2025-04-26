#ifndef __MAINNAVIGATION_H__
#define __MAINNAVIGATION_H__

#define SUCCESS_RADIUS 3.0 // success radius in meters

#include <Arduino.h>
#include "MotorDriver.h"
#include "XYStateEstimator.h"
#include "Pinouts.h"
extern MotorDriver motorDriver;

class MainNavigation : public DataSource
{
public:
  MainNavigation(void);

  // defines the waypoints used for Surface Control
  void init(const int totalWayPoints_in, double * wayPoints_in, int navigateDelay_in);

  // sets the right and left motor efforts using P-Control
  void navigate(xy_state_t * state, gps_state_t * gps_state_p, int currentTime_in, int rawTeensy);

  String printString(void);

  String printWaypointUpdate(void);

  // from DataSource
  size_t writeDataBytes(unsigned char * buffer, size_t idx);

  int lastExecutionTime = -1;

  // control fields
  float yaw_des;         // desired yaw
  float yaw;             // current yaw
  float yaw_error;       // difference between current and desired yaw
  float dist;            // distance to waypoint
  float u;               // control effort
  float Kp=10.0;         // proportional control gain
  float Kr=1.0;          // right motor gain correction
  float Kl=1.0;          // left motor gain correction
  float avgPower = 20.0; // average forward thrust
  float uR;              // right motor effort
  float uL;              // left motor effort

  float Vin = 5;
  float Rf = 11000;
  float Rn1 = 6000;
  float Rg = 48000;
  float Rp1 = 50000;
  float R2 = 5000;
  float angle;
  float angledeg;
  float anglerad;
  float Vteensy; //MAKE SURE THIS IS SET CORRECTLY
  float Vdivider; //back out to get Vout from voltage divider
  float R1; // back out to get resistance 

  bool navigateState = 1; 
  bool atPoint;
  bool complete = 0;
  bool navMode = 1; // 0 for GPS, 1 for vane


  int totalWayPoints;
  double * wayPoints;

private:

  // updates the current waypoint if necessary
  void updatePoint(float x, float y);

  int getWayPoint(int dim);


  const int stateDims = 2;  // Number of dimensions in the state vector (x,y)
  int currentWayPoint = 0;
  bool gpsAcquired;
  
  int navigateDelay;
  int delayStartTime = 24000; //change for delay
  int currentTime;
  bool delayed;
};

#endif