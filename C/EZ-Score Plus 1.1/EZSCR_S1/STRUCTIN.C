/* EZ-Score Plus
 * structure initialization file
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   10 January 1988
 * Last modified: 06 March 1988
 */

overlay "ezpdat"

#include <gem.h>

#include "structs.h"
#include "extern.h"
#include "ezp.h"

int  braceh[] = { 168, 198, 243, 288, 333, 378, 423,
                   468, 516, 558, 603, 648, 693, 738 };

init_symb_structs()
{
   int   i;

   staff.bt_width = 2;
   staff.height = (ONESPACE << 2) + 1;
   staff.image = (short*)staffi;
   brackt.bt_width = brackm.bt_width = brackb.bt_width = 2;
   brackt.height = brackb.height = 9;
   brackm.height = 1;
   brackt.image = (short*)brackit;
   brackm.image = (short*)brackim;
   brackb.image = (short*)brackib;
   for (i = 0; i < 14; i++) {
      bracei[i].bt_width = (i < 4)? 2: 4;
      bracei[i].height = braceh[i];
   }
   bracei[0].image = (short*)brace056i;
   bracei[1].image = (short*)brace066i;
   bracei[2].image = (short*)brace081i;
   bracei[3].image = (short*)brace096i;
   bracei[4].image = (short*)brace111i;
   bracei[5].image = (short*)brace126i;
   bracei[6].image = (short*)brace141i;
   bracei[7].image = (short*)brace156i;
   bracei[8].image = (short*)brace171i;
   bracei[9].image = (short*)brace186i;
   bracei[10].image = (short*)brace201i;
   bracei[11].image = (short*)brace216i;
   bracei[12].image = (short*)brace231i;
   bracei[13].image = (short*)brace246i;
}

/* EOF */
