                                  // Chapter 7 - Program 4
#ifndef CAR_H
#define CAR_H

#include "vehicle.h"

class car : public vehicle {
   int passenger_load;
public:
   void initialize(int in_wheels, float in_weight, int people = 4);
   int passengers(void);
};

#endif



// Result of execution
//
// (this file cannot be executed)
