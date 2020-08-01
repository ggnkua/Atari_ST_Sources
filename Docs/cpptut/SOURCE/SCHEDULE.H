// This takes care of all gate assignments and flight scheduling.
// The players flight is shuffled (changed) each move until he reads 
// his ticket.  If he gets to the proper gate prior to reading the
// monitor in the waiting area, (reading the monitor at the ticket
// counter doesn't matter), the gates are rescheduled.
//
// The method named check_flight does all of the required checking
// to see that everything was done properly prior to getting on
// the plane.  It only does checking if the player is on one of the
// planes.

#ifndef SCHEDULE_H
#define SCHEDULE_H

#include "location.h"

class schedule {

   location *gate[4];        // Gate names
   int flight_number[4];     // There are four flights [0] to [3]
   char *destination[4];
   int depart_hour[4];
   int depart_minute[4];
   int flights_frozen;       // Frozen after monitor is read in the
                             //  waiting area
   int gates_frozen;         // Frozen after ticket is read
   int my_gate;

public:

   schedule(void);
   void shuffle_flights(void);
   void shuffle_gates(void);
   void list_flights(location *current_location);
   void gate_message(location *current_location);
   void list_actual_destination(void);
   void list_time(int index);
   void check_flight(void);

};

#endif

