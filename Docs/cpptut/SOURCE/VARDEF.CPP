                                      // Chapter 1 - Program 5
#include <iostream.h>

int index;

main()
{
int stuff;
int &another_stuff = stuff; // A synonym for stuff

   stuff = index + 14;      //index was initialized to zero
   cout << "stuff has the value " << stuff << "\n";
   stuff = 17;
   cout << "another_stuff has the value " << another_stuff << "\n";

int more_stuff = 13;        //not automatically initialized

   cout << "more_stuff has the value " << more_stuff << "\n";
   
   for (int count = 3;count < 8;count++) {
      cout << "count has the value " << count << "\n";
      char count2 = count + 65;
      cout << "count2 has the value " << count2 << "\n";
   }
   
static unsigned goofy;      //automatically initialized to zero

   cout << "goofy has the value " << goofy << "\n";
}




// Result of execution
//
// stuff has the value 14
// another_stuff has the value 17
// more_stuff has the value 13
// count has the value 3
// count2 has the value D
// count has the value 4
// count2 has the value E
// count has the value 5
// count2 has the value F
// count has the value 6
// count2 has the value G
// count has the value 7
// count2 has the value H
// goofy has the value 0
