                                      // Chapter 3 - Program 1
#include <iostream.h>

main()
{
int   *pt_int;
float *pt_float;
int   pig = 7, dog = 27;
float x = 1.2345, y = 32.14;
void *general;

   pt_int = &pig;
   *pt_int += dog;
   cout << "Pig now has the value of " << *pt_int << "\n";
   general = pt_int;

   pt_float = &x;
   y += 5 * (*pt_float);
   cout << "y now has the value of " << y << "\n";
   general = pt_float;

   const char *name1 = "John";    // Value cannot be changed
   char *const name2 = "John";    // Pointer cannot be changed
}




// Result of execution
//
// Pig now has the value of 34
// y now has the value of 38.3125

