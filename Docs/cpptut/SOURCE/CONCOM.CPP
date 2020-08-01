                                        // Chapter 1 - Program 1

#include <iostream.h>       /* This is the stream definition file */

void print_it(const int data_value);

main()
{
const int START = 3;        // The value of START cannot be changed
const int STOP = 9;         // The value of STOP cannot be changed
volatile int CENTER = 6;    /* The value of CENTER may be changed
                                 by something external to this
                                 program.                          */
int index;                  /* A normal C variable                 */

   for (index = START ; index < STOP ; index++)
      print_it(index);
}     /* End of program */


void print_it(const int data_value)
{
   cout << "The value of the index is  " << data_value << "\n";
}




// Result of execution
//
// The value of the index is  3
// The value of the index is  4
// The value of the index is  5
// The value of the index is  6
// The value of the index is  7
// The value of the index is  8

