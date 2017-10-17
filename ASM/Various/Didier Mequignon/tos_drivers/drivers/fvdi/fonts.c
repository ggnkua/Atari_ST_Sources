/*
 * fVDI font load and setup
 *
 * $Id: fonts.c,v 1.3 2005/05/06 12:29:37 johan Exp $
 *
 * Copyright 1997-2000/2003, Johan Klockars 
 * This software is licensed under the GNU General Public License.
 * Please, see LICENSE.TXT for further information.
 */

#include <mint/osbind.h>
#include "fvdi.h"
#include "relocate.h"
#include "utility.h"

extern long boot_alloc(long size);

/*
 * Unpacks 6/8 pixel wide fonts into 16 consecutive bytes
 */
long unpack_font(Fontheader *header, long format)
{
   char *buf, *tmp;
   int wrap, chars, height, width, n, m, shift;

   wrap = header->width;
   chars = header->code.high - header->code.low + 1;
   height = header->height;
   width = header->widest.cell;

   if (!(header->flags & 0x08))        /* Only allow mono-spaced for now */
      return 0;

   if (header->flags & 0x02)           /* Don't allow horizontal offset for now */
      return 0;

   if ((width != 8) && (width != 6))   /* Only allow 6 and 8 pixel wide for now */
      return 0;

   if (height > 16)                    /* 16 bytes per character for now */
      return 0;

   if (!(buf = (char *)boot_alloc((long)chars * 16)))
      return 0;
   
   header->extra.unpacked.data = buf;
   header->extra.unpacked.format = format;

   if (width == 8) {
      for(n = 0; n < chars; n++) {
         tmp = &header->data[n];
         for(m = height - 1; m >= 0; m--) {
            *buf++ = *tmp;
            tmp += wrap;
         }
         buf += 16 - height;
      }
   } else {
      shift = 24;
      for(n = 0; n < chars; n++) {
         tmp = &header->data[(((unsigned)n * 6) / 16) * 2];
         for(m = height - 1; m >= 0; m--) {
            *buf++ = ((char)(*(long *)tmp >> shift)) & 0xfc;
            tmp += wrap;
         }
         if ((shift -= 6) <= 8)
            shift += 16;
         buf += 16 - height;
      }
   }
   
   return 1;
}


/*
 * Make a new font ready for use
 */
long fixup_font(Fontheader *header, char *buffer, long flip)
{
   int top;
   int header_size;
   
   header_size = sizeof(Fontheader) - sizeof(Fontextra);

   if (flip) {
      flip_words(&header->id, (&header->size - &header->id) + 1);
      flip_words(&header->code.low, (&header->flags - &header->code.low) + 1);
      flip_longs(&header->table.horizontal,
                 ((long)&header->data - (long)&header->table.horizontal) / sizeof(long) + 1);
      flip_words(&header->width, (&header->height - &header->width) + 1);

      flip_words(buffer + (long)header->table.character - header_size,
                 header->code.high - header->code.low + 1 + 1);
      if ((header->flags & 0x02) && header->table.horizontal && (header->table.horizontal != header->table.character))
         flip_words(buffer + (long)header->table.horizontal - header_size,
                    header->code.high - header->code.low + 1);
   }

   header->data = (char *)((long)buffer - header_size + (long)header->data);
   header->table.horizontal = (short *)((long)buffer - header_size + (long)header->table.horizontal);
   header->table.character = (short *)((long)buffer - header_size + (long)header->table.character);

   top = header->distance.top;
   header->extra.distance.base    = -top;
   header->extra.distance.half    = -top + header->distance.half;
   header->extra.distance.ascent  = -top + header->distance.ascent;
   header->extra.distance.bottom  = -top - header->distance.bottom;
   header->extra.distance.descent = -top - header->distance.descent;
   header->extra.distance.top     = 0;

   header->extra.unpacked.data    = 0;    /* No smart formats yet */
   header->extra.unpacked.format  = 0;
   header->extra.width_table      = 0;    /* No smart width table yet */
   
   return 1;
}

/*
 * Insert a new font into the tree
 * Returns 1 if new ID, 0 otherwise
 */
long insert_font(Fontheader **first_font, Fontheader *new_font)
{
   Fontheader *current_font, *last_font, **previous;
   int new_id, new_size;

   /*
    * Find first font with higher or equal ID
    */

   new_id = new_font->id;
   last_font = 0;
   current_font = *first_font;
   while(current_font && (current_font->id < new_id)) {
      last_font = current_font;
      current_font = current_font->next;
   }
   
   /*
    * Get address for pointer to new font
    */

   if (last_font)
      previous = &last_font->next;
   else
      previous = first_font;

   /*
    * Insert font with new ID
    */

   if (!current_font || (current_font->id != new_id)) {
      new_font->next = *previous;
      new_font->extra.next_size = 0;
      new_font->extra.first_size = new_font;
      *previous = new_font;
      return 1;
   }

   /*
    * Find first font with larger or equal size
    */

   new_size = new_font->size;
   last_font = 0;
   while(current_font && (current_font->size < new_size)) {
      last_font = current_font;
      current_font = current_font->extra.next_size;
   }

   /*
    * Insert in the list (not first)
    */

   if (last_font) {
      new_font->extra.next_size = last_font->extra.next_size;
      new_font->next = 0;
      new_font->extra.first_size = last_font->extra.first_size;
      last_font->extra.next_size = new_font;
#if 0
      last_font->next = 0;     /* Should already be that, right? */
#endif
      return 0;
   }

   /*
    * Put font first in list
    */

   new_font->extra.next_size = *previous;
   new_font->next = (*previous)->next;
   (*previous)->next = 0;
   *previous = new_font;
   new_font->extra.first_size = new_font;

   /*
    * Update old 'first_size' pointers
    */

   current_font = new_font->extra.next_size;
   while(current_font) {
      current_font->extra.first_size = new_font;
      current_font = current_font->extra.next_size;
   }
   
   return 0;
}
