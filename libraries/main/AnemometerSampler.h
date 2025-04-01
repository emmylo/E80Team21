#ifndef __ANEMOMETERSAMPLER_h__
#define __ANEMOMETERSAMPLER_h__

#include <Arduino.h>
#include "DataSource.h"
#include "Pinouts.h"

/*
 * ButtonSampler implements SD logging for the onboard pushbutton 
 */


class AnemometerSampler : public DataSource
{
public:
  AnemometerSampler(void);

  void init(void);

  // Managing state
  bool anemometerState;
  void updateState(void);
  String printState(void);

  // Write out
  size_t writeDataBytes(unsigned char * buffer, size_t idx);

  int lastExecutionTime = -1;
  
};

#endif