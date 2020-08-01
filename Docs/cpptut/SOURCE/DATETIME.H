                                     // Chapter 9 - Program 4
#ifndef DATETIME_H
#define DATETIME_H

#include "newdate.h"
#include "time.h"

class datetime : public new_date, public time_of_day {

public:

   datetime(void) { ; };        // Default to todays date and time
   datetime(int M, int D, int Y, int H, int Mn, int S) :
                    new_date(),              // Member initializer
                    time_of_day(H, Mn, S)    // Member initializer
                    { set_date(M, D, Y); };  // Constructor body

};

#endif
