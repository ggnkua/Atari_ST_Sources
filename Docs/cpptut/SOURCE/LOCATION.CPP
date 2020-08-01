#include <iostream.h>
#include "flyaway.h"
#include "location.h"
#include "items.h"
#include "schedule.h"

extern location snack_bar;     // Special action in "move"
extern location security;      // Special action in "move"
extern items personal_items;   // Reference to players items
extern schedule flight_info;


void location::init(location *valid_north,
		    location *valid_east,
		    location *valid_south,
		    location *valid_west,
		    char *local_message,
		    char *local_look_message)
{
   north_move = valid_north;
   east_move = valid_east;
   south_move = valid_south;
   west_move = valid_west;
   message = local_message;
   look_message = local_look_message;
}


location *location::move(word direction)
{
int no_go = FALSE;

                                      // Getting out of the snack bar
   if ((this == &snack_bar) && (personal_items.item_here(money)) &&
                                    (personal_items.item_here(candy)))
      cout <<
      "You took a candy bar and didn't pay for it.  Airport security\n"
      "grabs you and after much verbal abuse agrees to let you go if\n"
      "you will either return the candy bar or pay for it.\n";

                                           // Getting through security
   else if ((this == &security) && (direction == north) &&
                                  ((personal_items.item_here(keys)) ||
                                   (personal_items.item_here(money))))
      cout <<
      "You cannot get through security because the beeper detects\n"
      "some metallic object on you.  Many people are staring at\n"
      "you and thinking that you look dangerous.\n";

                                           // A normal move somewhere
   else
   switch (direction) {
      case north : if (north_move)
                      return (north_move); // Location to north
                   else
                      no_go = TRUE;        // You can't go that way!
                   break;
      case east  : if (east_move)
                      return (east_move);  // Location to east
                   else
                      no_go = TRUE;        // You can't go that way!
                   break;
      case south : if (south_move)
                      return (south_move); // Location to south
                   else
                      no_go = TRUE;        // You can't go that way!
                   break;
      case west  : if (west_move)
                      return (west_move);  // Location to west
                   else
                      no_go = TRUE;        // You can't go that way!
                   break;
      default    : cout << "This is not a move.\n";
                   return(NULL);
   }
   if (no_go) cout << "Sorry, you cannot go that way!\n";
   return (NULL);
}


        // This adds an item to the items object in this room
void location::add_item(word item_to_add)
{
   list_of_items.add_item(item_to_add);
}


        // This drops an item from the list in this room
void location::drop_item(word item_to_drop)
{
   list_of_items.drop_item(item_to_drop);
}



         // This returns TRUE if the item is located here
char location::item_here(word item_to_check)
{
   return (list_of_items.item_here(item_to_check));
}


        // This displays the message when the room is entered
        // It also displays the flight information at a gate
void location::display_message()
{
   cout << message;
}


        // This displays the items located in this room
void location::display_list_of_items(void)
{
   cout << look_message;
   list_of_items.list_items_in_room();
   flight_info.gate_message(this);   // List the flight information
                                     //  if you are at a gate
}
