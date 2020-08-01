                                  // Chapter 7 - Program 8
#include <iostream.h>
#include "vehicle.h"
#include "car.h"
#include "truck.h"


main()
{
vehicle unicycle;

   unicycle.initialize(1, 12.5);
   cout << "The unicycle has " << 
                                unicycle.get_wheels() << " wheel.\n";
   cout << "The unicycle's wheel loading is " << 
         unicycle.wheel_loading() << " pounds on the single tire.\n";
   cout << "The unicycle weighs " << 
                             unicycle.get_weight() << " pounds.\n\n";

car sedan;

   sedan.initialize(4, 3500.0, 5);
   cout << "The sedan carries " << sedan.passengers() << 
                                                    " passengers.\n";
   cout << "The sedan weighs " << sedan.get_weight() << " pounds.\n";
   cout << "The sedan's wheel loading is " << 
                    sedan.wheel_loading() << " pounds per tire.\n\n";

truck semi;

   semi.initialize(18, 12500.0);
   semi.init_truck(1, 33675.0);
   cout << "The semi weighs " << semi.get_weight() << " pounds.\n";
   cout << "The semi's efficiency is " << 
                          100.0 * semi.efficiency() << " percent.\n";
}




// Result of execution
//
// The unicycle has 1 wheel.
// The unicycle's wheel loading is 12.5 pounds on the single tire.
// The unicycle weighs 12.5 pounds.
//
// The sedan carries 5 passengers.
// The sedan weighs 3500 pounds.
// The sedan's wheel loading is 875 pounds per tire.
//
// The semi weighs 12500 pounds.
// The semi's efficiency is 72.929072 percent.
