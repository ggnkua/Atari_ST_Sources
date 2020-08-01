                                // Chapter 6 - Program 12

#include <iostream.h>
#include "date.h"
#include "time.h"

void main(void)
{
date today;
time_of_day now, lunch(12, 15);

   cout << "This program executed on " << today.get_date_string() <<
           " at " << now.get_time_string() << "\n";

   cout << "We are planning lunch at " << lunch.get_time_string() <<
           " tomorrow.\n";

   lunch.set_time(13);
   cout << "We decided to move lunch to "<< lunch.get_time_string()
        << " due to a late meeting.\n";
}


// Result of execution

// This program executed on Jan 20, 1991 at 10:34:16
// We are planning lunch at 12:15:00 tomorrow.
// We decided to move lunch to 13:00:00 due to a late meeting.
