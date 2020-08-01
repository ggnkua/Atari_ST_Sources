                                     // Chapter 11 - Program 2
#include <iostream.h>
#include "person.h"

            // This method should never be called.  If it is ever
            // called, it is considered an error.
void
person::display(void)
{
   cout << "person::display - missing subclass method\n";
}
