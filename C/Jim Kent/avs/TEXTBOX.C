/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */

#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

/* This file does assume non-proportional text.  Here's some constants
   that tell us how to format around the font */
#define CHAR_WIDTH 8
#define CHAR_HEIGHT 8
#define LINE_HEIGHT (CHAR_HEIGHT+2)
#define BASELINE	6

/* This is the minimum border between the outside of the requestor box
   and the text inside */
#define BORDER	8

/* The width and height of the Continue "gadget" box */
#define CONT_WIDTH 80
#define CONT_HEIGHT 16

extern WORD mouse_on;

/* a structure giving us the size and position of the entire requestor */
struct rectangle box, yes_box, no_box;
static WORD omouse_on;
static WORD *ocscreen;


/* find_text_box(names) -
      Pass this an array of names terminated by a NULL, and this baby
	  will figure out how wide and how tall a requester would have to
	  be to hold it.   Since live video-holes have to be
	  on WORD boundaries, and vertically on even lines (I don't know why
	  on even lines), this does a little padding to the width and height
	  to insure this.  Then it calculates the x and y offsets to
	  center the thing.  The results of all this are in the static
	  variable "box", and also in the variable xborder, which tells
	  you where to start your text on the left side so as to be
	  centered. */
find_text_box(names)
register char *names[];	 /* NULL terminated array of strings */
{
WORD width, height;
WORD this_width;
char *name;

width = 0;
height = 0;
while ((name = *names++) != NULL) 
	{
	height += LINE_HEIGHT;
	this_width = CHAR_WIDTH*strlen(name);
	if (this_width > width)
		width = this_width;
	}
height += 2*BORDER;
width += 2*BORDER;	/* give us some room for the border etc */
box.MinX = (XMAX - width)>>1;
box.MinX = ((box.MinX+7)&0xfff8);	/* pad it to a byte boundary */
box.MinY = (YMAX - height)>>1;
box.MaxX = box.MinX+width;
box.MaxY = box.MinY+height;
}

d_top_lines_of_box(names, ypad)
char *names[];
WORD ypad;
{
WORD xoff, yoff;
WORD continu_size;
char *name;

find_text_box(names);
box.MaxY += ypad;
omouse_on = mouse_on;
ocscreen = cscreen;
cscreen = pscreen;

hide_mouse();
copy_screen(pscreen, bscreen);
/* draw the box around it all */
colblock(black, box.MinX, box.MinY, box.MaxX-1, box.MaxY-1);
draw_frame(white, box.MinX, box.MinY, box.MaxX-1, box.MaxY-1);

xoff = box.MinX + BORDER;
yoff = box.MinY + BORDER;
while ((name = *names++) != NULL) 
	{
	gtext(name, xoff, yoff, white);
	yoff += LINE_HEIGHT;
	}
return (yoff);
}


draw_white_box(b)
struct rectangle *b;
{
draw_frame(white, b->MinX, b->MinY, b->MaxX-1, b->MaxY-1);
}

/* draw_yes_no_box()
*/
draw_yes_no_box(names, yes, no)
char *names[];
char *yes;
char *no;
{
WORD yesno_size;
WORD yes_size;
WORD no_size;
WORD box_size;
WORD x;
WORD xoff, yoff;


yoff = d_top_lines_of_box(names, CONT_HEIGHT+LINE_HEIGHT);
yoff += LINE_HEIGHT/2 + BASELINE;

yesno_size = 4;
yes_size = strlen(yes);
if (yes_size > yesno_size)
	yesno_size = yes_size;
no_size = strlen(no);
if (no_size > yesno_size)
	yesno_size  = no_size;
yesno_size += 2;

box_size = (unsigned)(box.MaxX - box.MinX)/CHAR_WIDTH;
box_size -= 2*yesno_size;
xoff = box.MinX + CHAR_WIDTH*((box_size+1)/3);
xoff = (xoff+4)&0xfff8;	/* pad to a byte */
yes_box.MinX = xoff;
yes_box.MaxX = xoff + yesno_size*CHAR_WIDTH;
yes_box.MinY = yoff;
yes_box.MaxY = yoff + CONT_HEIGHT;
draw_white_box(&yes_box);
gtext(yes, 
	xoff + ((yesno_size - yes_size)>>1)*CHAR_WIDTH, 
	yoff + ((CONT_HEIGHT-CHAR_HEIGHT)>>1), 
	white);
xoff = box.MinX + CHAR_WIDTH*(yesno_size + (2*box_size)/3);
xoff = (xoff+4)&0xfff8;	/* pad to a byte */
no_box.MinX = xoff;
no_box.MaxX = xoff + yesno_size*CHAR_WIDTH;
no_box.MinY = yoff;
no_box.MaxY = yoff + CONT_HEIGHT;
draw_white_box(&no_box);
gtext(no, 
	xoff + ((yesno_size - no_size)>>1)*CHAR_WIDTH, 
	yoff + ((CONT_HEIGHT-CHAR_HEIGHT)>>1), 
	white);
show_mouse();
}


/* draw_continue_box()
	given a NULL-terminated array of names, and a prompt to put in a box
	to tell it to go away, draw a requester, and cut out a hole so the
	video goes around it */
draw_continue_box(names, continu)
char *names[];
char *continu;
{
WORD xoff, yoff;
WORD continu_size;

yoff = d_top_lines_of_box(names, CONT_HEIGHT+LINE_HEIGHT);
yoff += LINE_HEIGHT/2 + BASELINE;
xoff = box.MinX + BORDER;
xoff += (box.MaxX - box.MinX - 2*BORDER - CONT_WIDTH)>>1;
draw_frame(white, xoff, yoff, xoff+CONT_WIDTH-1, yoff+CONT_HEIGHT-1);

continu_size = strlen(continu);
yoff += ((CONT_HEIGHT-CHAR_HEIGHT)>>1);
xoff += (CONT_WIDTH-CHAR_WIDTH*continu_size)>>1;
gtext(continu, xoff, yoff, white);
show_mouse();
}


continu_line(line)
char *line;
{
char *lines[2];

lines[0] = line;
lines[1] = NULL;
continu_from(lines);
}




continu_from(lines)
char *lines[];
{
continu_from_menu(lines);
}

continu_from_menu(lines)
char *lines[];
{
draw_continue_box(lines, "Continue");
wait_click();
hide_mouse();
copy_screen(bscreen, pscreen);
cscreen = ocscreen;
if (omouse_on)
	show_mouse();
wait_penup();
}

inbox(b)
struct rectangle *b;
{
if (mouse_x >= b->MinX && mouse_x <= b->MaxX && mouse_y >= b->MinY &&
	mouse_y <= b->MaxY)
	return(1);
return(0);
}

poll_yes_no()
{
unsigned char c;

for (;;)
	{
	check_input();
	if (PJSTDN)
		{
		if (inbox(&yes_box))
			return(1);
		else if (inbox(&no_box))
			return(0);
		}
	if (RJSTDN)
		return(0);
	if (key_hit)
		{
		c = key_in;
		if (c == 'n' || c == 'N')
			return(0);
		if (c == 'y' || c == 'Y')
			return(1);
		}
	}
}

yes_no_from_menu(lines)
char *lines[];
{
WORD answer;

draw_yes_no_box(lines, "Yes", "No");
answer = poll_yes_no();
hide_mouse();
copy_screen(bscreen, pscreen);
cscreen = ocscreen;
if (omouse_on)
	show_mouse();
wait_penup();
return(answer);
}

yes_no_from(lines)
char *lines[];
{
int ret;

ret = yes_no_from_menu(lines);
return(ret);
}

yes_no_line(line)
char *line;
{
char *buf[2];

buf[0] = line;
buf[1] = NULL;
yes_no_from(buf);
}

