// This is the definition of the 19 different locations it is
//  possible to enter.  This class contains an embedded object of
//  class "items" to store the elements in each location.  The
//  message is output automatically when the location is entered,
//  and the look_message is output when the player gives the look
//  command.


#ifndef LOCATION_H
#define LOCATION_H

#include "items.h"    // This gets the definition of the item list

class location {

   location *north_move;      // Where we go to, north of here
   location *east_move;       // Where we go to, east of here
   location *south_move;      // Where we go to, south of here
   location *west_move;       // Where we go to, west of here
   char *message;             // Message output when we enter here
   char *look_message;        // The message output for a "look"
   items list_of_items;       // The list of items in this location

public:

   void init(location *valid_north,  // These four directions are
	     location *valid_east,   //   initialized when init
	     location *valid_south,  //   is called.
	     location *valid_west,
	     char *local_message,
	     char *local_look_message);
   location *move(word direction);   // Move to another location
   void add_item(word item_to_add);  // This puts an item here
   void drop_item(word item_to_drop);// Item picked up by player
   char item_here(word item_to_check);// Is this item here?
   void display_message(void);       // This displays the message
   void display_list_of_items(void); // Display items found here
                                     //  and a few room details.
};

#endif
