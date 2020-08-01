                                  // Chapter 7 - Program 7
#include "truck.h"

void truck::init_truck(int how_many, float max_load)
{
   passenger_load = how_many;
   payload = max_load;
}


float truck::efficiency(void)
{
   return payload / (payload + weight);
}


int truck::passengers(void)
{
   return passenger_load;
}




// Result of execution
//
// (this file cannot be executed)
