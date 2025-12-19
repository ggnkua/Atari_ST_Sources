/*****************************************************************************
*
*                                   dumproto.h
*
*   from DKBTrace (c) 1990  David Buck
*
*  This file contains routines to choose colour palettes for dump2iff
*
* This software is freely distributable. The source and/or object code may be
* copied or uploaded to communications services so long as this notice remains
* at the top of each file.  If any changes are made to the program, you must
* clearly indicate in the documentation and in the programs startup message
* who it was who made the changes. The documentation should also describe what
* those changes were. This software may not be included in whole or in
* part into any commercial package without the express written consent of the
* author.  It may, however, be included in other public domain or freely
* distributed software so long as the proper credit for the software is given.
*
* This software is provided as is without any guarantees or warranty. Although
* the author has attempted to find and correct any bugs in the software, he
* is not responsible for any damage caused by the use of the software.  The
* author is under no obligation to provide service, corrections, or upgrades
* to this package.
*
* Despite all the legal stuff above, if you do find bugs, I would like to hear
* about them.  Also, if you have any comments or questions, you may contact me
* at the following address:
*
*     David Buck
*     22C Sonnet Cres.
*     Nepean Ontario
*     Canada, K2H 8W7
*
*  I can also be reached on the following bulleton boards:
*
*     OMX              (613) 731-3419
*     Mystic           (613) 596-4249  or  (613) 596-4772
*
*  Fidonet:   1:163/109.9
*  Internet:  dbuck@ccs.carleton.ca
*  You Can Call Me Ray: (708) 358-5611
*
*
*****************************************************************************/

#include <stdio.h>
#include <exec/types.h>
#include "showprioq.h"
#include "dump2iff.h"
#include "dumproto.h"

ULONG last_red = 0, last_green = 0, last_blue = 0;
int Close_Threshold;

#define absdif(x,y) ((x>y) ? (x-y):(y-x))
#define Make_Colour(x, y, z) ((x & 0xF) << 8) + ((y & 0xF) << 4) + (z & 0xF)

#define extract_red(x) ((x & 0xF00) >> 8)
#define extract_green(x) ((x & 0x0F0) >> 4)
#define extract_blue(x) (x & 0x00F)

struct prioq_struct *Colour_q;
struct prioq_struct *pq_new();


extern UWORD ColourTbl[16];

void reset_colours ()
  {
  last_red = last_green = last_blue = 0;
  }

int closeness(x, y)
  int x, y;
  {
  int red, blue, green;

  red = absdif(extract_red(x), extract_red(y));
  blue = absdif (extract_blue(x), extract_blue(y));
  green = absdif(extract_green(x), extract_green(y));
  return (red+blue+green);
  }

void start_recording_colours ()
  {
  Colour_q = pq_new (256, 4096);
  if (Colour_q == NULL)
    exit (0);

  reset_colours();
  }

void record_colours (new_red, new_green, new_blue)
  int new_red, new_green, new_blue;
  {
  LONG delta_red, delta_green, delta_blue, match_quality;

  delta_red = absdif (new_red, last_red);
  delta_green = absdif (new_green, last_green);
  delta_blue = absdif (new_blue, last_blue);

  if (delta_red > delta_green)
    if (delta_red > delta_blue) {
      last_red = new_red;
      match_quality = delta_green + delta_blue;
      }
    else {
      last_blue = new_blue;
      match_quality = delta_green + delta_red;
      }
  else
    if (delta_green > delta_blue)
      {
      last_green = new_green;
      match_quality = delta_red + delta_blue;
      }
    else {
      last_blue = new_blue;
      match_quality = delta_green + delta_red;
      }

    if (match_quality != 0)
      pq_add (Colour_q, match_quality,
              Make_Colour (new_red, new_green, new_blue));
  }      

void choose_palette()
  {
  int i, j, colour, min_distance, temp_distance;
  struct prioq_struct *post_pq;

  post_pq = pq_new (32, 4096);

  ColourTbl[0] = Make_Colour (0, 0, 0);
  for (i=1 ; i < 16 ;) {
    if (pq_get_highest_index (Colour_q) > pq_get_highest_index (post_pq))
      {
      colour = pq_get_highest_value (Colour_q);
      pq_delete_highest (Colour_q);

      min_distance = 255;
      for (j = 0 ; j < i ; j++)
       if ((temp_distance = closeness (ColourTbl[j], colour)) < min_distance)
         min_distance = temp_distance;

      if (min_distance < 5)
        pq_add (post_pq, min_distance, colour);
      else
       ColourTbl[i++] = colour;
      }
    else
      {
      ColourTbl[i++] = pq_get_highest_value (post_pq);
      pq_delete_highest (post_pq);
      }
    }
  pq_free (Colour_q);
  pq_free (post_pq);
  }

int best_colour (new_red, new_blue, new_green)
  int new_red, new_blue, new_green;
  {
  int i, match_quality, best_match, colour,
      delta_red, delta_green, delta_blue, temp_match_quality;

  delta_red = absdif (new_red, last_red);
  delta_green = absdif (new_green, last_green);
  delta_blue = absdif (new_blue, last_blue);

  if (delta_red > delta_green)
    if (delta_red > delta_blue) {
      last_red = new_red;
      colour = 0x20 + new_red;
      match_quality = delta_green + delta_blue;
      }
    else {
      last_blue = new_blue;
      colour = 0x10 + new_blue;
      match_quality = delta_green + delta_red;
      }
  else
    if (delta_green > delta_blue)
      {
      last_green = new_green;
      colour = 0x30 + new_green;
      match_quality = delta_red + delta_blue;
      }
    else {
      last_blue = new_blue;
      colour = 0x10 + new_blue;
      match_quality = delta_green + delta_red;
      }

  if (match_quality != 0)
    for (i = 0 ; i < 16 ; i++)
      if ((temp_match_quality =
           closeness (ColourTbl[i],
            Make_Colour (new_red, new_green, new_blue)))
          < match_quality) {
        match_quality = temp_match_quality;
        colour = i;
        last_red = extract_red (ColourTbl[i]);
        last_green = extract_green (ColourTbl[i]);
        last_blue = extract_blue (ColourTbl[i]);
        }
  return (colour);
  }
