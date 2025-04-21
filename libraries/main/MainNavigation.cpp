#include "MainNavigation.h"
#include "Printer.h"
#include "Pinouts.h"

extern Printer printer;

inline float angleDiff(float a) {
  while (a<-PI) a += 2*PI;
  while (a> PI) a -= 2*PI;
  return a;
}

MainNavigation::MainNavigation(void) 
: DataSource("u,uL,uR,yaw,yaw_des","float,float,float,float,float"){}


void MainNavigation::init(const int totalWayPoints_in, double * wayPoints_in, int navigateDelay_in) {
  totalWayPoints = totalWayPoints_in;
  // create wayPoints array on the Heap so that it isn't erased once the main Arduino loop starts
  wayPoints = new double[2*totalWayPoints]; // Create a 1-d array to hold the waypoints in the format x0,y0,x1,y1,...
  for (int i=0; i<totalWayPoints; i++) { 
    wayPoints[i] = wayPoints_in[i];
  }
  navigateDelay = navigateDelay_in;
  if (totalWayPoints == 0) atPoint = 1; // not doing surface control
  else atPoint = 0; // doing surface control
}

int MainNavigation::getWayPoint(int dim) {
  return wayPoints[currentWayPoint*stateDims+dim];
}

void MainNavigation::navigate(xy_state_t * state, gps_state_t * gps_state_p, int currentTime_in) {

if (navMode == 0){
  currentTime = currentTime_in;

  if (gps_state_p->num_sat >= N_SATS_THRESHOLD) {
    gpsAcquired = 1;

    updatePoint(state->x, state->y);
    if (currentWayPoint == totalWayPoints) return; // stops motors at final surface point
    
    if (atPoint || delayed) {
      uL = 0; 
      uR = 0;
      return; // stops motors at surface waypoint
    }

    // set up variables
    int x_des = getWayPoint(0);
    int y_des = getWayPoint(1);

    // Set the values of yaw_des, yaw, yaw_error, control effort (u), uL, and uR appropriately for P control
    // You can use trig functions (atan2 might be useful)
    // You can access the x and y coordinates calculated in XYStateEstimator.cpp using state->x and state->y respectively
    // You can access the yaw calculated in XYStateEstimator.cpp using state->yaw

    ///////////////////////////////////////////////////////////
    // INSERT P CONTROL CODE HERE
    yaw = state->yaw;
    float x = state->x;
    float y = state->y;
    yaw_des = atan2(y_des - y, x_des - x);
    yaw_error = angleDiff(yaw_des - yaw);
    u = Kp*yaw_error;
    uR = avgPower + u;
    uL = avgPower - u;
    ///////////////////////////////////////////////////////////
    
    
  }
  else {
    gpsAcquired = 0;
  }
}
else{
  currentTime = currentTime_in;
  
  TeensyToVoltage();
  Vdivider = -Rn1/Rf*(Vteensy - (1+Rf/Rn1)* (Rg/(Rp1+Rg)*Vin)); //back out to get Vout from voltage divider
  R1 = R2*(Vin/Vdivider - 1); // back out to get resistance 

    while (R1 >= 6000 || R1 <= 4000) {
        if (R1 > 6000) {
            R1 -= 1000;  // Decrease R1 by 1000 if it's greater than 6000
        } else {
            R1 += 1000;  // Increase R1 by 1000 if it's less than 4000
        }
    }

    if(R1>=5000){
        R1 -= 5000;
        angle = R1/1000;

    }
    else{
        R1 -= 4000;
        angle = R1/1000;
    }
    
    angledeg = 360 - angle*360; // degrees

    anglerad = angledeg*3.1415/180; //radians

    yaw = state->yaw;
    yaw_des = anglerad;
    yaw_error = angleDiff(yaw_des - yaw);
    u = Kp*yaw_error;
    uR = avgPower + u;
    uL = avgPower - u;

    /* heading version 
    float heading = state->heading;
    float heading_des = angledeg;
    float heading_error = heading_des - heading;
    float u = Kp*heading_error;
    float uR = avgPower + u;
    float uL = avgPower - u;
    */


}

}

String MainNavigation::printString(void) {
  String printString = "";

  if(navMode == 0){
  if (!navigateState) {
    printString += "MainNavigation: Not in navigate state";
  }
  else if (!gpsAcquired) {
    printString += "MainNavigation: Waiting to acquire more satellites...";
  }
  else {
    printString += "GPSControl: ";
    printString += "Yaw_Des: ";
    printString += String(yaw_des*180.0/PI);
    printString += "[deg], ";
    printString += "Yaw: ";
    printString += String(yaw*180.0/PI);
    printString += "[deg], ";
    printString += "u: ";
    printString += String(u);
    printString += ", u_L: ";
    printString += String(uL);
    printString += ", u_R: ";
    printString += String(uR);
  } 
  return printString;
}

else{
    printString += "WindControl: ";
    printString += "Yaw_Des: ";
    printString += String(yaw_des*180.0/PI);
    printString += "[deg], ";
    printString += "Yaw: ";
    printString += String(yaw*180.0/PI);
    printString += "[deg], ";
    printString += "u: ";
    printString += String(u);
    printString += ", u_L: ";
    printString += String(uL);
    printString += ", u_R: ";
    printString += String(uR);

    return printString;

}
}

String MainNavigation::printWaypointUpdate(void) {
  String wayPointUpdate = "";
  if (!navigateState) {
    wayPointUpdate += "MainNavigation: Not in navigate state";
  }
  else if (!gpsAcquired) {
    wayPointUpdate += "MainNavigation: Waiting to acquire more satellites...";
  }
  else if (delayed) {
    wayPointUpdate += "MainNavivation: Waiting for delay";
    wayPointUpdate += String(currentWayPoint);
  }
  else {
    wayPointUpdate += "MainNavigation: ";
    wayPointUpdate += "Current Waypoint: ";
    wayPointUpdate += String(currentWayPoint);
    wayPointUpdate += "; Distance from Waypoint: ";
    wayPointUpdate += String(dist);
    wayPointUpdate += "[m]";
  }
  return wayPointUpdate;
}

void MainNavigation::updatePoint(float x, float y) {
  if (currentWayPoint == totalWayPoints) return; // don't check if finished

  float x_des = getWayPoint(0);
  float y_des = getWayPoint(1);
  dist = sqrt(pow(x-x_des,2) + pow(y-y_des,2));

  if ((dist < SUCCESS_RADIUS && currentWayPoint < totalWayPoints) || delayed) {
    String changingWPMessage = "";
    int cwpmTime = 20;

    // navigateDelay
    if (delayStartTime == 0) delayStartTime = currentTime;
    if (currentTime < delayStartTime + navigateDelay) {
      delayed = 1;
      changingWPMessage = "Got to surface waypoint " + String(currentWayPoint)
        + ", waiting until delay is over";
    }
    else {
      delayed = 0;
      delayStartTime = 0;
      changingWPMessage = "Got to surface waypoint " + String(currentWayPoint)
        + ", now directing to next point";
      atPoint = 1;
      currentWayPoint++;
    }
    if (currentWayPoint == totalWayPoints) {
      changingWPMessage = "Completed the surface path.";
      uR=0;
      uL=0;
      complete = 1;
      cwpmTime = 10;
    }
    printer.printMessage(changingWPMessage,cwpmTime);
  }
}

size_t MainNavigation::writeDataBytes(unsigned char * buffer, size_t idx) {
  float * data_slot = (float *) &buffer[idx];
  data_slot[0] = u;
  data_slot[1] = uL;
  data_slot[2] = uR;
  data_slot[3] = yaw;
  data_slot[4] = yaw_des;
  return idx + 5*sizeof(float);
}