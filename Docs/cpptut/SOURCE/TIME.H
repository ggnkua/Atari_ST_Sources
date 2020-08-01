                                // Chapter 6 - Program 10

// This is probably the minimum usable time class, but is intended as
//  an illustration of a class rather than to build an all inclusive
//  class for future use.  Each student can develop his own to suit
//  his own taste.

#ifndef TIME_H
#define TIME_H

class time_of_day {
protected:
   int hour;                   // 0 through 23
   int minute;                 // 0 through 59
   int second;                 // 0 through 59
   static char format;         // Format to use for output
   static char out_string[25]; // Format output area

public:
         // Constructor - Set time to current time and format to 1
   time_of_day(void);
   time_of_day(int H) {hour = H; minute = 0; second = 0; };
   time_of_day(int H, int M) {hour = H; minute = M; second = 0; };
   time_of_day(int H, int M, int S) {hour = H;
                                           minute = M; second = S; };

         // Set the time to these input values
         //  return = 0 ---> data is valid
         //  return = 1 ---> something is out of range
   int set_time(void);
   int set_time(int hour_in);
   int set_time(int hour_in, int minute_in);
   int set_time(int hour_in, int minute_in, int second_in);

         // Select string output format
   void set_time_format(int format_in) { format = format_in; };

         // Return an ASCII-Z string depending on the stored format
         //   format = 1    13:23:12
         //   format = 2    13:23
         //   format = 3     1:23 PM
   char *get_time_string(void);

};

#endif
