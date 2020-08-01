                                  // Chapter 7 - Program 1
// vehicle header file

#ifndef VEHICLE_H
#define VEHICLE_H

class vehicle {
protected:
   int wheels;
   float weight;
public:
   void initialize(int in_wheels, float in_weight);
   int get_wheels(void);
   float get_weight(void);
   float wheel_loading(void);
};

#endif
