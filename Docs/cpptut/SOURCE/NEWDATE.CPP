                                     // Chapter 7 - Program 10
#include "newdate.h"

extern int days[];

         // This routine ignores leap year for simplicity, and adds
         //  the days in each month for all months less than the
         //  current month, then adds the days in the current month
         //  up to today.
int new_date::get_day_of_year(void)
{
int index = 0;

   day_of_year = 0;

   while (index < month)
      day_of_year += days[index++];

   return (day_of_year += day);
}
