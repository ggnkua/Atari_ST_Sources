                                      // Chapter 4 - Program 1
#include <iostream.h>

void do_stuff(int wings, float feet, char eyes);

main()
{
int arm = 2;
float foot = 1000.0;
char lookers = 2;

   do_stuff(3, 12.0, 4);
   do_stuff(arm, foot, lookers);
}

void do_stuff(int wings, float feet, char eyes)
{
   cout << "There are " << wings << " wings." << "\n";
   cout << "There are " << feet << " feet." << "\n";
   cout << "There are " << (int)eyes << " eyes." << "\n\n";
}




// Result of execution
//
// There are 3 wings.
// There are 12 feet.
// There are 4 eyes.
//
// There are 2 wings.
// There are 1000 feet.
// There are 2 eyes.
