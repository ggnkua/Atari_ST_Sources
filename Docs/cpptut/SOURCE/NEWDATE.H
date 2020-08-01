                                     // Chapter 7 - Program 9
// This class inherits the date class and adds one variable and one
//  method to it.

#ifndef NEWDATE_H
#define NEWDATE_H

#include "date.h"

class new_date : public date {
protected:

   int day_of_year;             // New member variable

public:

   int get_day_of_year(void);   // New method

};

#endif
