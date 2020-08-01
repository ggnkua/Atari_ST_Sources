          // This stores the items located in each room and also in
          //  the players posession.  It consists of four boolean
          //  variables and methods to use them.

#ifndef ITEMS_H
#define ITEMS_H

#include "words.h"

class items {

   int keys_on_hand;      // TRUE if keys are here, otherwise FALSE
   int candy_on_hand;
   int ticket_on_hand;
   int money_on_hand;

public:

   items(void);            // Constructor, set all to FALSE
   void add_item(word item_to_add);      // Add one item to list
   void drop_item(word item_to_drop);    // Drop one item from list
   int item_here(word item_to_check);    // Returns TRUE or FALSE
   void list_items(void);                // List personal items
   void list_items_in_room(void);        // List location items

};

#endif

