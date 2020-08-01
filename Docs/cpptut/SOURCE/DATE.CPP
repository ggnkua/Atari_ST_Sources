                               // Chapter 5 - Program 11

// This file contains the implementation for the date class.

#include <stdio.h>       // Prototype for sprintf
#include <time.h>        // Prototypes for the current date
#include "date.h"

char date::format;         // This defines the static data member
char date::out_string[25]; // This defines the static string

         // Constructor - Set date to current date, and
         //               set format to the default of 1
date::date(void)
{
time_t time_date;
struct tm *current_date;

   time_date = time(NULL);                // DOS system call
   current_date = localtime(&time_date);  // DOS system call
   month = current_date->tm_mon + 1;
   day = current_date->tm_mday;
   year = current_date->tm_year + 1900;
   format = 1;
}


         // Set the date to these input parameters
         //  if return = 0 ---> All data is valid
         //  if return = 1 ---> Something out of range
int date::set_date(int in_month, int in_day, int in_year)
{
int temp = 0;
int max_days;
                      // The limits on the year are purely arbitrary
   if (in_year < 1500) {           // Check that the year is between
      year = 1500;                 //  1500 and 2200
      temp = 1;
   } else {
      if (in_year > 2200) {
         year = 2200;
         temp = 1;
      } else
         year = in_year;
   }

   if(in_month < 1) {              // Check that the month is between
      month = temp = 1;            //  1 and 12
   } else {
      if (in_month > 12) {
         month = 12;
         temp = 1;
      } else
         month = in_month;
   }

   max_days = days_this_month();
   if (in_day < 1) {               // Check that the day is between
      day = temp = 1;              //  1 and max_days
   } else {
      if (in_day > max_days) {
         day = max_days;
         temp = 1;
      } else
         day = in_day;
   }

   return temp;
}



static char *month_string[13] = {" ", "Jan", "Feb", "Mar", "Apr",
                                      "May", "Jun", "Jul", "Aug",
                                      "Sep", "Oct", "Nov", "Dec"};

         // Return Jan Feb Mar Apr etc.
char *date::get_month_string(void)
{
   return month_string[month];
}



         // Return an ASCII-Z string depending on the stored format
         //   format = 1    Aug 29, 1991
         //   format = 2    8/29/91
         //   format = 3    8/29/1991
         //   format = 4    29 Aug 1991    Military time
         //   format = ?    Anything else defaults to format 1
char *date::get_date_string(void)
{
   switch (format) {
                       // This printout assumes that the year will be
                       //  between 1900 and 1999
      case 2  : sprintf(out_string, "%02d/%02d/%02d",
                                            month, day, year - 1900);
                break;

      case 3  : sprintf(out_string, "%02d/%02d/%04d",
                                                   month, day, year);
                break;

      case 4  : sprintf(out_string, "%d %s %04d",
                                     day, month_string[month], year);
                break;

      case 1  : // Fall through to the default case
      default : sprintf(out_string, "%s %d, %04d",
                                     month_string[month], day, year);
                break;
   }
   return out_string;
}



int days[13] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

         // Since this is declared in the private part of the class
         //  header is is only available for use within the class.
         //  It is hidden from use outside of the class.
int date::days_this_month(void)
{
   if (month != 2)
      return days[month];

   if (year % 4)       // Not leap year
      return 28;
   if (year % 100)     // It is leap year
      return 29;
   if (year % 400)     // Not leap year
      return 28;
   return 29;          // It is leap year
}
