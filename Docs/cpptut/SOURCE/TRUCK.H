                                  // Chapter 7 - Program 6
#ifndef TRUCK_H
#define TRUCK_H

#include "vehicle.h"

class truck : public vehicle {
   int passenger_load;
   float payload;
public:
   void init_truck(int how_many = 2, float max_load = 24000.0);
   float efficiency(void);
   int passengers(void);
};

#endif



// Result of execution
//
// (this file cannot be executed)
