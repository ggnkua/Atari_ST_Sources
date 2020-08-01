                                      // Chapter 1 - Program 2
#include <iostream.h>

int index = 13;

main()
{
float index = 3.1415;

   cout << "The local index value is " << index << "\n";
   cout << "The global index value is " << ::index << "\n";

   ::index = index + 7;  // 3 + 7 should result in 10

   cout << "The local index value is " << index << "\n";
   cout << "The global index value is " << ::index << "\n";

}




// Result of execution
//
// The local index value is 3.1415
// The global index value is 13
// The local index value is 3.1415
// The global index value is 10

