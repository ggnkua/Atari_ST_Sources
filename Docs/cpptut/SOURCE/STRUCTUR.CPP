                                 // Chapter 2 - Program 2
#include <iostream.h>

struct animal {
   int weight;
   int feet;
};

main()
{
animal dog1, dog2, chicken;
animal cat1;
struct animal cat2;

   dog1.weight = 15;
   dog2.weight = 37;
   chicken.weight = 3;

   dog1.feet = 4;
   dog2.feet = 4;
   chicken.feet = 2;

   cout << "The weight of dog1 is " << dog1.weight << "\n";
   cout << "The weight of dog2 is " << dog2.weight << "\n";
   cout << "The weight of chicken is " << chicken.weight << "\n";
}




// Result of execution
//
// The weight of dog1 is 15
// The weight of dog2 is 37
// The weight of chicken is 3

