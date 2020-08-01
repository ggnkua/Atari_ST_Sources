                               // Chapter 5 - Program 10

// This date class is intended to illustrate how to write a non-
//  trivial class in C++.  Even though this class is non-trivial,
//  it is still simple enough for a new C++ programmer to follow
//  all of the details.

#ifndef DATE_H
#define DATE_H

class date {
protected:
   int month;                  // 1 through 12
   int day;                    // 1 through max_days
   int year;                   // 1500 through 2200
   static char out_string[25]; // Format output area
   static char format;         // Format to use for output

         // Calculate how many days are in any given month
         // Note - This is a private method which can be called only
         //        from within the class itself
   int days_this_month(void);

public:
         // Constructor - Set the date to the current date and set
         //               the format to 1
   date(void);

         // Set the date to these input parameters
         //  if return = 0 ---> All data is valid
         //  if return = 1 ---> Something out of range
   int set_date(int in_month, int in_day, int in_year);

         // Get the month, day, or year of the stored date
   int get_month(void) { return month; };
   int get_day(void)   { return day;   };
   int get_year(void)  { return year;  };

         // Select the desired string output format for use when the
         //  get_date_string is called
   void set_date_format(int format_in) { format = format_in; };

         // Return an ASCII-Z string depending on the stored format
         //   format = 1    Aug 29, 1991
         //   format = 2    8/29/91
         //   format = 3    8/29/1991
         //   format = 4    29 Aug 1991    Military time
         //   format = ?    Anything else defaults to format 1
   char *get_date_string(void);

         // Return Jan Feb Mar Apr etc.
   char *get_month_string(void);
};

#endif
