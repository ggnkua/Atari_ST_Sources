          // This is the game clock.  It increments once for every
          //  move, the increment being accomplished in the method
          //  named inc_and_print_time.

#ifndef CLOCK_H
#define CLOCK_H

class clock {
   int hour;
   int minute;
public:
   clock(void);
   int present_hour(void)    {return hour;}
   int present_minute(void)  {return minute;}
   void inc_and_print_time(void);
};

#endif

