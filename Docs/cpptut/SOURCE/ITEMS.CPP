#include <iostream.h>
#include "flyaway.h"
#include "items.h"


items::items(void)
{
   keys_on_hand = FALSE;
   candy_on_hand = FALSE;
   ticket_on_hand = FALSE;
   money_on_hand = FALSE;
}


void items::add_item(word item_to_add)
{
   switch (item_to_add) {
      case keys   : keys_on_hand = TRUE;
                    break;
      case candy  : candy_on_hand = TRUE;
                    break;
      case ticket : ticket_on_hand = TRUE;
                    break;
      case money  : money_on_hand = TRUE;
                    break;
      default     : break;
   }
}


void items::drop_item(word item_to_drop)
{
   switch (item_to_drop) {
      case keys   : keys_on_hand = FALSE;
                    break;
      case candy  : candy_on_hand = FALSE;
                    break;
      case ticket : ticket_on_hand = FALSE;
                    break;
      case money  : money_on_hand = FALSE;
                    break;
      default     : break;
   }
}


int items::item_here(word item_to_check)
{
   switch (item_to_check) {
      case keys   : return keys_on_hand;
                    break;
      case candy  : return candy_on_hand;
                    break;
      case ticket : return ticket_on_hand;
                    break;
      case money  : return money_on_hand;
                    break;
      default     : return FALSE;
                    break;
   }
}


void items::list_items(void)
{
   if (keys_on_hand)
      cout << "You have the keys to your car.\n";
   if (candy_on_hand)
      cout << "You have two candy bars.\n";
   if (ticket_on_hand)
      cout << "You have a ticket for your dream vacation.\n";
   if (money_on_hand)
      cout << "You have a couple of dollars of loose change.\n";
}


void items::list_items_in_room(void)
{
   if (keys_on_hand)
      cout << "There are car keys here.\n";
   if (candy_on_hand)
      cout << "There are some candy bars here.\n";
   if (ticket_on_hand)
      cout << "There is an airplane ticket here.\n";
   if (money_on_hand)
      cout << "There is some money here.\n";
}
