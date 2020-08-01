                                      // Chapter 4 - Program 2
#include <iostream.h>

void do_stuff(int, float, char);

main()
{
int arm = 2;
float foot = 1000.0;
char lookers = 65;

   do_stuff(3, 12.0, 67);
   do_stuff(arm, foot, lookers);
}

void do_stuff(int wings,    // Number of wings
              float feet,   // Number of feet
              char eyes)    // Number of eyes
{
   cout << "There are " << wings << " wings." << "\n";
   cout << "There are " << feet << " feet." << "\n";
   cout << "There are " << eyes << " eyes." << "\n\n";
}




// Result of execution
//
// There are 3 wings.
// There are 12 feet.
// There are C eyes.
//
// There are 2 wings.
// There are 1000 feet.
// There are A eyes.
