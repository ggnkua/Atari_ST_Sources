

#include "datatypes.h"


#ifndef __display
#define __display


/* Width and Height of the window */
#define XW	(160)
//640
#define YW	(100)
//400

extern u32 rgbBuffer[YW+100][XW];


#define XW_D 640
#define YW_D 400

extern u32 rgbBuffer_display[YW_D+100][XW_D];


extern u8  chunkyBuffer[YW][XW];

extern u32 colortable[256];


void clear_rgbBuffer(u32 color);

int chunky_to_rgb();
void colorclip(int *color);


#endif

