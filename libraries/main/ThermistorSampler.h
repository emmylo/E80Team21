#ifndef __THERMISTORSAMPLER_h__
#define __THERMISTORSAMPLER_h__

#include <Arduino.h>
#include "DataSource.h"
#include "Pinouts.h"

/*
 * ButtonSampler implements SD logging for the onboard pushbutton 
 */


class ThermistorSampler : public DataSource
{
public:
  ThermistorSampler(void);

  void init(void);

  // Managing state
  bool thermistorState;
  void updateState(void);
  String printState(void);

  // Write out
  size_t writeDataBytes(unsigned char * buffer, size_t idx);

  int lastExecutionTime = -1;
  
};

#endif