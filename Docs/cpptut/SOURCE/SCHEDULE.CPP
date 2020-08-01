#include <iostream.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include "flyaway.h"
#include "schedule.h"
#include "items.h"
#include "map.h"
#include "location.h"
#include "clock.h"

extern location rest_room;
extern location waiting_area;
extern location gate1;
extern location gate2;
extern location gate3;
extern location gate4;
extern location plane1;
extern location plane2;
extern location plane3;
extern location plane4;

extern items personal_items;
extern clock time_of_day;
extern words input_words;
extern map airport;

int visited_rest_room = FALSE;   // TRUE if the rest room was visited
                                 //  as checked in shuffle_gates

schedule::schedule(void)
{
   flight_number[0] = 222;
   flight_number[1] = 17;
   flight_number[2] = 141;
   flight_number[3] = 79;
   destination[0] = new char[7];
      strcpy(destination[0], "HAWAII");
   destination[1] = new char[7];
      strcpy(destination[1], "PARIS ");
   destination[2] = new char[7];
      strcpy(destination[2], "ROME  ");
   destination[3] = new char[7];
      strcpy(destination[3], "TAHITI");
   depart_hour[0] = 9;
   depart_hour[1] = 9;
   depart_hour[2] = 9;
   depart_hour[3] = 9;
   depart_minute[0] = 19;
   depart_minute[1] = 17;
   depart_minute[2] = 16;
   depart_minute[3] = 18;
   gate[0] = &gate1;
   gate[1] = &gate2;
   gate[2] = &gate3;
   gate[3] = &gate4;
   flights_frozen = FALSE;
   gates_frozen = FALSE;
   my_gate = 0;
}


void schedule::shuffle_flights(void)
{
   if (!flights_frozen)             // Until flights are frozen,
      my_gate = (my_gate + 1) % 4;  //  select the next flight
                                    //  at the next gate.
}


void schedule::shuffle_gates(void)
{
int temp;
char *temp_point;

   if (airport.get_current_location() == &rest_room)
      visited_rest_room = TRUE;

   if ((airport.get_current_location() ==
                                 gate[my_gate]) && (!gates_frozen)) {

      temp             = flight_number[0];
      flight_number[0] = flight_number[1];
      flight_number[1] = flight_number[2];
      flight_number[2] = flight_number[3];
      flight_number[3] = temp;

      temp_point     = destination[0];
      destination[0] = destination[1];
      destination[1] = destination[2];
      destination[2] = destination[3];
      destination[3] = temp_point;

      temp           = depart_hour[0];
      depart_hour[0] = depart_hour[1];
      depart_hour[1] = depart_hour[2];
      depart_hour[2] = depart_hour[3];
      depart_hour[3] = temp;

      temp             = depart_minute[0];
      depart_minute[0] = depart_minute[1];
      depart_minute[1] = depart_minute[2];
      depart_minute[2] = depart_minute[3];
      depart_minute[3] = temp;

      my_gate = (my_gate + 3) % 4;  // Subtract one from my_gate

      cout <<
         "A message is heard on the airport paging system, \"All"
         " gates\nhave been rescheduled due to bad weather.  No "
         "flights have\nbeen cancelled at this time.\"\n";

   }
}


                                // This freezes the gate assignments
void schedule::list_flights(location *current_location)
{
   if (current_location == &waiting_area)
      gates_frozen = TRUE;

   for (int index = 0 ; index < 4 ; index++) {
      printf("Gate %d - Flight %3d - %s - ",
              (index + 1),
              flight_number[index],
              destination[index]);
      list_time(index);
   }
}


void schedule::gate_message(location *current_location)
{
int index;

              // Find gate we are at and print message
   for (index = 0;index < 4;index++)
      if (current_location == gate[index]) goto gate_is_found;

   return;    // If not a gate

   gate_is_found:
   printf("Flight %3d - %s - ",     // If a gate is found
           flight_number[index],
           destination[index]);
   list_time(index);
}


                                   // This freezes the players flight
void schedule::list_actual_destination(void)
{
      flights_frozen = TRUE;

      printf("Flight %3d - %s - ",
           flight_number[my_gate],
           destination[my_gate]);
      list_time(my_gate);
}


void schedule::list_time(int index)
{
   if (depart_minute[index] < 10)
      printf("%d:0%d\n",depart_hour[index], depart_minute[index]);
   else
      printf("%d:%d\n",depart_hour[index], depart_minute[index]);
}


void schedule::check_flight(void)
{

   if ((airport.get_current_location() == &plane1) ||
         (airport.get_current_location() == &plane2) ||
           (airport.get_current_location() == &plane3) ||
             (airport.get_current_location() == &plane4)) {

                                            // You must have a ticket
      if (!personal_items.item_here(ticket))
         cout <<
         "Unfortunately, you don't have a ticket, you are arrested\n"
         "as a stowaway and drug off the plane screaming.  No vaca-\n"
         "tion for you.\n";

                                            // On plane 1 from gate 1
      else if ((airport.get_current_location() == &plane1) &&
                                                      (my_gate != 0))
         cout <<
         "Unfortunately, you are at gate 1 and this flight is going\n"
         " to " << destination[0] << ".  Better luck next time.\n";

                                            // On plane 2 from gate 2
      else if ((airport.get_current_location() == &plane2) &&
                                                      (my_gate != 1))
         cout <<
         "Unfortunately, you are at gate 2 and this flight is going\n"
         " to " << destination[1] << ".  Better luck next time.\n";

                                            // On plane 3 from gate 3
      else if ((airport.get_current_location() == &plane3) &&
                                                      (my_gate != 2))
         cout <<
         "Unfortunately, you are at gate 3 and this flight is going\n"
         " to " << destination[2] << ".  Better luck next time.\n";

                                            // On plane 4 from gate 4
      else if ((airport.get_current_location() == &plane4) &&
                                                      (my_gate != 3))
         cout <<
         "Unfortunately, you are at gate 4 and this flight is going\n"
         " to " << destination[3] << ".  Better luck next time.\n";

                                               // You must be on time
      else if ((time_of_day.present_hour() > depart_hour[my_gate]) ||
               (time_of_day.present_minute() > depart_minute[my_gate]))
         cout <<
         "Unfortunately, you are too late for your flight and are\n"
         "aboard a cargo plane to Greasy Creek, Missouri.  Better\n"
         "luck next time.\n";

                                               // You must have candy
      else if (!personal_items.item_here(candy))
         cout <<
         "Unfortunately, you failed to bring any food along and you\n"
         "died of malnutrition half way to your destination.\n";

                                      // You must visit the rest room
      else if (!visited_rest_room)
         cout <<
         "Unfortunately, you forgot to take care of your bladder\n"
         "problem back at the airport.  The restrooms on this plane\n"
         "are out-of-order.  You suffer a ruptured bladder and die\n"
         "enroute to your destination.\n";

                             // A successful trip through the airport
      else
         cout <<
         "Congratulations, you are comfortably enroute to your well\n"
         "deserved vacation.  You can study the source code to this\n"
         "program on the plane.  If you do not have the source code,\n"
         "you can read the paper in the lobby for the address where\n"
         "you can write for more information.\n";

      cout  << "\nHit any key to end the game.\n";
      getch();                  // Wait for keyhit
      input_words.stop_game();  // End the game
   }
}
