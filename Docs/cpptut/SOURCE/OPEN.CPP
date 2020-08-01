                                     // Chapter 5 - Program 1
#include <iostream.h>

struct one_datum {
   int data_store;
};

main()
{
one_datum dog1, dog2, dog3;
int piggy;

   dog1.data_store = 12;
   dog2.data_store = 17;
   dog3.data_store = -13;
   piggy = 123;

   cout << "The value of dog1 is " << dog1.data_store << "\n";
   cout << "The value of dog2 is " << dog2.data_store << "\n";
   cout << "The value of dog3 is " << dog3.data_store << "\n";
   cout << "The value of piggy is " << piggy << "\n";
}




// Result of execution
//
// The value of dog1 is 12
// The value of dog2 is 17
// The value of dog3 is -13
// The value of piggy is 123

