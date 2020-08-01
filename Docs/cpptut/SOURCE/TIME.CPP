                                // Chapter 6 - Program 11

#include <stdio.h>         // For the sprintf function
#include <time.h>          // For the time & localtime functions
#include "time.h"          // For the class header


char time_of_day::format;  // This defines the static data member
char time_of_day::out_string[25];  // This defines the string


         // Constructor - Set time to current time
         //               and format to 1
time_of_day::time_of_day(void)
{
time_t time_date;
struct tm *current_time;

   time_date = time(NULL);
   current_time = localtime(&time_date);
   hour     = current_time->tm_hour;
   minute   = current_time->tm_min;
   second   = current_time->tm_sec;

   format   = 1;
}


         // Set the time to these input values
         //  return = 0 ---> data is valid
         //  return = 1 ---> something out of range
int time_of_day::set_time(void)         {return set_time(0, 0, 0); };
int time_of_day::set_time(int H)        {return set_time(H, 0, 0); };
int time_of_day::set_time(int H, int M) {return set_time(H, M, 0); };
int time_of_day::set_time(int hour_in, int minute_in, int second_in)
{
int error = 0;

   if (hour_in < 0) {
      hour_in = 0;
      error = 1;
   } else if (hour_in > 59) {
      hour_in = 59;
      error = 1;
   }
   hour = hour_in;

   if (minute_in < 0) {
      minute_in = 0;
      error = 1;
   } else if (minute_in > 59) {
      minute_in = 59;
      error = 1;
   }
   minute = minute_in;

   if (second_in < 0) {
      second_in = 0;
      error = 1;
   } else if (second_in > 59) {
      second_in = 59;
      error = 1;
   }
   second = second_in;

   return error;
}



         // Return an ASCII-Z string depending on the stored format
         //   format = 1    13:23:12
         //   format = 2    13:23
         //   format = 3     1:23 PM
char *time_of_day::get_time_string(void)
{
   switch (format) {
      case 2  : sprintf(out_string, "%2d:%02d", hour, minute);
                break;

      case 3  : if (hour == 0)
                   sprintf(out_string, "12:%02d AM", minute);
                else if (hour < 12)
                   sprintf(out_string, "%2d:%02d AM", hour, minute);
                else if (hour == 12)
                   sprintf(out_string, "12:%02d PM", minute);
                else
                   sprintf(out_string, "%2d:%02d PM",
                                                 hour - 12, minute);
                break;

      case 1  : // Fall through to default so the default is also 1
      default : sprintf(out_string, "%2d:%02d:%02d",
                                               hour, minute, second);
                break;
   }

   return out_string;
}
