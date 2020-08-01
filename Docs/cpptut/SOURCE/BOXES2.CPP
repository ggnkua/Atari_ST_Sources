                                 // Chapter 5 - Program 9
#include <iostream.h>
#include "box.h"

main()
{
box small, medium, large;          //Three boxes to work with

   small.set(5, 7);
                          // Note that the medium box uses the values
                          // supplied by the constructor
   large.set(15, 20);
   
   cout << "The small box area is " << small.get_area() << "\n";
   cout << "The medium box area is " << medium.get_area() << "\n";
   cout << "The large box area is " << large.get_area() << "\n";
   
}




// Result of execution
//
// The small box area is 35
// The medium box area is 64
// The large box area is 300
