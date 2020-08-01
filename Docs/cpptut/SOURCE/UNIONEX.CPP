                                     // Chapter 2 - Program 4
#include <iostream.h>

struct aircraft {
   int wingspan;
   int passengers;
   union {
      float fuel_load;     // for fighters
      float bomb_load;     // for bombers
      int pallets;         // for transports
   };
} fighter, bomber, transport;

main()
{
   fighter.wingspan = 40;
   fighter.passengers = 1;
   fighter.fuel_load = 12000.0;
   
   bomber.wingspan = 90;
   bomber.passengers = 12;
   bomber.bomb_load = 14000.0;
   
   transport.wingspan = 106;
   transport.passengers = 4;
   transport.pallets = 42;
   
   transport.fuel_load = 18000.0;
   fighter.pallets = 4;
   
   cout << "The fighter carries " 
                              << fighter.pallets << " pallets.\n";
   cout << "The bomber bomb load is " << bomber.bomb_load << "\n";
   
}




// Result of execution
//
// The fighter carries 4 pallets.
// The bomber bomb load is 14000
