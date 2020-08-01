                                     // Chapter 9 - Program 5
#include <iostream.h>
#include "datetime.h"

datetime now, birthday(10, 18, 1938,  1, 30, 17);
datetime       special( 2, 19, 1950, 13, 30,  0);

void main(void)
{

   cout << "Now = " << now.get_date_string() << " "
                    << now.get_time_string() << " and is day "
                    << now.get_day_of_year() << "\n";

   cout << "Birthday = " << birthday.get_date_string() << " "
                    << birthday.get_time_string() << " and is day "
                    << birthday.get_day_of_year() << "\n";

   cout << "Special = " << special.get_date_string() << " "
                    << special.get_time_string() << " and is day "
                    << special.get_day_of_year() << "\n";

}



// Result of execution

// Now = Jan 20, 1992 21:12:56 and is day 20
// Birthday = Oct 18, 1938  1:30:17 and is day 291
// Special = Feb 19, 1950 13:30:00 and is day 50