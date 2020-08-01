#include <stdio.h>
#include "clock.h"



clock::clock(void)
{
   hour = 8;
   minute = 51;
}




void clock::inc_and_print_time(void)
{
   minute++;            // Add one minute to the time
   if (minute > 59) {
      minute -= 60;
      hour++;
   }

                        // Output the user prompt
   printf("\n      It is now %d:", hour);
   printf("%02dam", minute);
   printf(", what do you wish to do?     ");
}
