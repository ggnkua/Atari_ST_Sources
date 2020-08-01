                                  // Chapter 7 - Program 3
#include <iostream.h>
#include "vehicle.h"

main()
{
vehicle car, motorcycle, truck, sedan;

   car.initialize(4, 3000.0);
   motorcycle.initialize(2, 900.0);
   truck.initialize(18, 45000.0);
   sedan.initialize(4, 3000.0);
   
   cout << "The car has " << car.get_wheels() << " wheels.\n";
   cout << "The truck has a loading of " << truck.wheel_loading()
                  << " pounds per wheel.\n";
   cout << "The motorcycle weighs " << motorcycle.get_weight() 
                  << " pounds.\n";
   cout << "The sedan weighs " << sedan.get_weight() 
                  << " pounds, and has " << sedan.get_wheels() 
                  << " wheels.\n";
}




// Result of execution
//
// The car has 4 wheels.
// The truck has a loading of 2500 pounds per wheel.
// The motorcycle weighs 900 pounds.
// The sedan weighs 3000 pounds, and has 4 wheels.
