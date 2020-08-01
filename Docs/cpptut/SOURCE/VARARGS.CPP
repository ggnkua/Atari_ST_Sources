                                       // Chapter 4 - Program 5
#include <iostream.h>
#include <stdarg.h>

            // Declare a function with one required parameter
void display_var(int number, ...);

main()
{
int index = 5;
int one = 1, two = 2;

   display_var(one, index);
   display_var(3, index, index + two, index + one);
   display_var(two, 7, 3);
}


void display_var(int number, ...)
{
va_list param_pt;

   va_start(param_pt,number);               // Call the setup macro

   cout << "The parameters are ";
   for (int index = 0 ; index < number ; index++) 
      cout << va_arg(param_pt,int) << " ";  // Extract a parameter
   cout << "\n";
   va_end(param_pt);                        // Closing macro
}




// Result of Execution
//
// The parameters are 5
// The parameters are 5 7 6
// The parameters are 7 3
