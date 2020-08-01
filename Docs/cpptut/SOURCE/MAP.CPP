#include <iostream.h>
#include "conio.h"
#include "map.h"
#include "message.txt"
#include "words.h"
#include "items.h"
#include "schedule.h"

location your_car;
location pass_drop_off;
location lobby;
location baggage_claim;
location dark_room;
location ticket_counter;
location tunnel;
location rest_room;
location snack_bar;
location security;
location waiting_area;
location gate1;
location gate2;
location gate3;
location gate4;
location plane1;
location plane2;
location plane3;
location plane4;

extern schedule flight_info;
extern items personal_items;
extern words input_words;


void map::initialize(void)
{
   cout << startup_message;

   present_location = &your_car;

   your_car.init(&pass_drop_off, // North from here
              NULL,              // East from here
              NULL,              // South from here
              NULL,              // West from here
              your_car_message,  // message when entering here
              y_c_look_message); // message for look command

   pass_drop_off.init(&lobby,
              NULL,
              NULL,    // You cannot go back to the car, it leaves
              NULL,
              pass_drop_off_message,
              p_d_o_look_message);

   lobby.init(&ticket_counter,
              NULL,
              &pass_drop_off,
              &baggage_claim,
              lobby_message,
              l_look_message);

   baggage_claim.init(NULL,
              &lobby,
              NULL,
              &dark_room,
              baggage_claim_message,
              b_c_look_message);

   dark_room.init(NULL,
              NULL,
              NULL,
              NULL,
              dark_room_message,
              d_r_look_message);

   ticket_counter.init(&tunnel,
              NULL,
              &lobby,
              NULL,
              ticket_counter_message,
              t_c_look_message);

   tunnel.init(&security,
              &snack_bar,
              &ticket_counter,
              &rest_room,
              tunnel_message,
              t_look_message);

   rest_room.init(NULL,
              &tunnel,
              NULL,
              NULL,
              rest_room_message,
              r_r_look_message);

   snack_bar.init(NULL,
              NULL,
              NULL,
              &tunnel,
              snack_bar_message,
              s_b_look_message);

   security.init(&waiting_area,
              NULL,
              &tunnel,
              NULL,
              security_message,
              s_look_message);

   waiting_area.init(NULL,
              &gate3,
              &security,
              &gate2,
              waiting_area_message,
              w_a_look_message);

   gate1.init(&plane1,
              &gate2,
              NULL,
              NULL,
              gate1_message,
              g1_look_message);

   plane1.init(NULL,
              NULL,
              NULL,
              NULL,
              plane_message,
              plane_look_message);

   gate2.init(&plane2,
              &waiting_area,
              NULL,
              &gate1,
              gate2_message,
              g2_look_message);

   plane2.init(NULL,
              NULL,
              NULL,
              NULL,
              plane_message,
              plane_look_message);

   gate3.init(&plane3,
              &gate4,
              NULL,
              &waiting_area,
              gate3_message,
              g3_look_message);

   plane3.init(NULL,
              NULL,
              NULL,
              NULL,
              plane_message,
              plane_look_message);

   gate4.init(&plane4,
              NULL,
              NULL,
              &gate3,
              gate4_message,
              g4_look_message);

   plane4.init(NULL,
              NULL,
              NULL,
              NULL,
              plane_message,
              plane_look_message);

   personal_items.add_item(keys);     // Player gets keys
   personal_items.add_item(money);    // Player gets money

   your_car.add_item(ticket);         // Ticket is in car
   snack_bar.add_item(candy);         // Candy is in snack bar
}




void map::perform_action(void)
{
   if (input_words.is_a_direction()) {      // Move to a new location
      result = present_location->move(input_words.get_verb());
      if (result) {                  // If Non-NULL
         present_location = result;  // Valid move found
         present_location->display_message();
      }

                                 // Force end of game if in dark room
      if (present_location == &dark_room) {
         input_words.stop_game();  // Set the verb to "quit"
         cout << "Hit any key to end the game.";
         getch();
      }
   }
                                                         // Inventory
   else if (input_words.get_verb() == inventory)
      personal_items.list_items();

                                                              // Look
   else if (input_words.get_verb() == look)
      present_location->display_list_of_items();

                                                         // Drop item
   else if (input_words.get_verb() == drop) {
      if (personal_items.item_here(input_words.get_noun())) {
         personal_items.drop_item(input_words.get_noun());
         present_location->add_item(input_words.get_noun());
         cout << " Dropped.\n";
      } else {
         cout << "You can't drop what you don't have.\n";
      }
   }

                                                          // Get item
   else if (input_words.get_verb() == get) {
      if (present_location->item_here(input_words.get_noun())) {
         present_location->drop_item(input_words.get_noun());
         personal_items.add_item(input_words.get_noun());
         cout << " Picked up.\n";
      } else {
         cout << "It isn't here so you can't pick it up.\n";
      }
   }

                                                         // Buy candy
   else if ((input_words.get_verb() == buy) &&
                  (input_words.get_noun() == candy) &&
                           (present_location == &snack_bar)) {
      if ((personal_items.item_here(money)) &&
                           (present_location->item_here(candy))) {
         personal_items.drop_item(money);
         personal_items.add_item(candy);
         present_location->drop_item(candy);
         present_location->add_item(money);
         cout << " You now have candy.\n";
      } else
         cout << "Surely you are not serious about that!\n";
   }

                                                       // Read ticket
   else if ((input_words.get_verb() == read) &&
                             (input_words.get_noun() == ticket))
      if (personal_items.item_here(ticket))
         flight_info.list_actual_destination();
      else
         cout << "You don't have a ticket to read.\n";

                                                      // Read monitor
   else if ((input_words.get_verb() == read) &&
                     (input_words.get_noun() == monitor) &&
                            (present_location == &ticket_counter))
      flight_info.list_flights(present_location);

                                                      // Read monitor
   else if ((input_words.get_verb() == read) &&
                   (input_words.get_noun() == monitor) &&
                              (present_location == &waiting_area))
      flight_info.list_flights(present_location);

                                                        // Read paper
   else if ((input_words.get_verb() == read) &&
                   (input_words.get_noun() == paper) &&
                                     (present_location == &lobby))
      cout << paper_message;
                                                              // Help
   else if (input_words.get_verb() == help)
      cout << help_message;
                                                              // Quit
   else if (input_words.get_verb() == quit)      // Ignore to prevent
      ;                                          //  message output

   else
      cout << "I don't understand what you want.\n";

}
