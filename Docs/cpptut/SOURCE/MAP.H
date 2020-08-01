// This class handles the airport layout.  It defines which direc-
//  tion you can go from each location and performs the actions
//  requested by the player.

#ifndef MAP_H
#define MAP_H

#include "location.h"

class map {

   location *present_location;
   location *result;

public:

   void initialize(void);
   void perform_action(void);
   location *get_current_location(void) { return present_location; };

};

#endif

