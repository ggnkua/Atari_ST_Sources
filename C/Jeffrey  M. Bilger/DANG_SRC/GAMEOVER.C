
#include <globals.h>

/************/
 game_over()
  {
   char reboot;

   clear_it();
   v_gtext(handle,20,50,"Press any key to Reboot");

   reboot = Bconin(2);
   exit(0);
  }
/************/
