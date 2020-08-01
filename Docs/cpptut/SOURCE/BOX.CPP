                                 // Chapter 5 - Program 8
#include "box.h"


box::box(void)        //Constructor implementation
{
   length = 8;
   width = 8;
}


// This method will set a box size to the two input parameters
void box::set(int new_length, int new_width)
{
   length = new_length;
   width = new_width;
}


box::~box(void)       //Destructor
{
   length = 0;
   width = 0;
}




// Result of execution
//
// This implementation file cannot be executed
