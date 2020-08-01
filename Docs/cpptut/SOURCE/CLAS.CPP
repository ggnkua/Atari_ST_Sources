                                      // Chapter 5 - Program 2
#include <iostream.h>

class one_datum {
   int data_store;
public:
   void set(int in_value);
   int get_value(void);
};

void one_datum::set(int in_value)
{
   data_store = in_value;
}

int one_datum::get_value(void)
{
   return data_store;
}

main()
{
one_datum dog1, dog2, dog3;
int piggy;

   dog1.set(12);
   dog2.set(17);
   dog3.set(-13);
   piggy = 123;

// dog1.data_store = 115;      This is illegal in C++
// dog2.data_store = 211;      This is illegal in C++

   cout << "The value of dog1 is " << dog1.get_value() << "\n";
   cout << "The value of dog2 is " << dog2.get_value() << "\n";
   cout << "The value of dog3 is " << dog3.get_value() << "\n";
   cout << "The value of piggy is " << piggy << "\n";
}




// Result of execution
//
// The value of dog1 is 12
// The value of dog2 is 17
// The value of dog3 is -13
// The value of piggy is 123
