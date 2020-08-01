                                  // Chapter 7 - Program 2
#include "vehicle.h"



              // initialize to any data desired
void vehicle::initialize(int in_wheels, float in_weight)
{
   wheels = in_wheels;
   weight = in_weight;
}


              // get the number of wheels of this vehicle
int vehicle::get_wheels()
{
   return wheels;
}


              // return the weight of this vehicle
float vehicle::get_weight()
{
   return weight;
}


              // return the weight on each wheel
float vehicle::wheel_loading()
{
   return weight/wheels;
}
