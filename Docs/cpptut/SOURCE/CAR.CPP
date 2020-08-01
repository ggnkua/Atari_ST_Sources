                                  // Chapter 7 - Program 5
#include "car.h"


void car::initialize(int in_wheels, float in_weight, int people)
{
   passenger_load = people;
   wheels = in_wheels;
   weight = in_weight;
}


int car::passengers(void)
{
   return passenger_load;
}




// Result of execution
//
// (this file cannot be executed)
