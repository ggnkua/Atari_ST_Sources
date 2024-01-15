/*****************************************************************************
Author     : Peter Persson (based on svga_disp.c & amiga_disp.c)
Description: Atari Falcon specific falcon stuff
Version    : 0.0.1 (2006-01-07)
******************************************************************************/

#include "config.h"
#include "version.h"

/* Standard Includes */
#include <stdio.h>
#include <stdlib.h>
#include <mint/falcon.h>

/* My headers */
#include "types.h"
#include "vmachine.h"
#include "address.h"
#include "files.h"
#include "colours.h"
#include "keyboard.h"
#include "limiter.h"
#include "options.h"
#include "c2p.h"

struct AlColor
{
	char reserved,red, green, blue;
};

#define NUMCOLORS 128
struct AlColor colors[NUMCOLORS];
struct AlColor oldcol[NUMCOLORS];

/* Various variables and short functions */

/* Start of image data */
BYTE *vscreen;

/* The width and height of the image, including any magnification */
int vwidth, vheight, theight;

/* The frame rate counter. Used by the -rr switch */
int tv_counter = 0;
int tv_depth = 8;

/* Optionally set by the X debugger. */
int redraw_flag = 1;

int tv_bytes_pp=1;

static int bytesize;

/* Videl stuff */
#define VIDEL_MODE 0x100|0x10|0x03 /* 320 x 240 x 8bpp */
unsigned int old_modecode;
unsigned short* new_screen_ptr;
unsigned short* old_screen_ptr;


/* Inline helper to place the tv image */
static inline void put_image (void)
{
	c2p(new_screen_ptr,vscreen);
}

/* Create the color map of Atari colors */
static void
create_cmap (void)
{
  int i;

  /* Initialise parts of the colors array */
  for (i = 0; i < NUMCOLORS; i++)
    {
      /* Use the color values from the color table */
      colors[i].red = (colortable[i * 2] & 0xff0000) >> 16;
      colors[i].green = (colortable[i * 2] & 0x00ff00) >> 8;
      colors[i].blue = (colortable[i * 2] & 0x0000ff);
    }
}

/* Create the main window */
/* argc: argument count */
/* argv: argument text */
static void
create_window (int argc, char **argv)
{
	/* Calculate the video width and height */
	vwidth = 320;
	theight = 200;
	vheight = 200;
	
	/* Turn on the keyboard. Must be done after toplevel is created */
	init_keyboard ();

	/* Save the current color map */
	VgetRGB (0, NUMCOLORS, &oldcol);

	/* Create the color map */
	create_cmap ();

	/* Use the color map */
	VsetRGB (0, NUMCOLORS, &colors);
}


/* Turns on the television. */
/* argc: argument count */
/* argv: argument text */
/* returns: 1 for success, 0 for failure */
int tv_on (int argc, char **argv)
{
	/* Reserve physical screen memory */
	old_screen_ptr = (void*) Physbase();
	new_screen_ptr = (unsigned short*) Mxalloc( VgetSize( VIDEL_MODE ), 0);

	bytesize = tv_height * 320;
	if (bytesize > 64000) bytesize = 64000;

	/* Create the windows */
	create_window (argc, argv);

	if (Verbose)
		printf ("OK\n  Allocating screen buffer...");

	vscreen = (BYTE*) Malloc( bytesize );

	if (!vscreen)
	{
		if (Verbose) printf ("Memory Allocation FAILED\n");
		return (0);
	}
	
	if (!new_screen_ptr)
	{
		if (Verbose) printf ("Failed to allocate video memory (ST-RAM)\n");
		return (0);
	}

	/* Set screen mode and address */

	old_modecode = Vsetmode( VIDEL_MODE );
	Setscreen( new_screen_ptr, new_screen_ptr, -1 );

	if (Verbose) printf ("OK\n");

	return (1);
}


/* Turn off the tv */
void tv_off (void)
{	
	int i;
	if (Verbose)
		printf ("Switching off...\n");

	/* Restore the color map */
	VsetRGB (0, NUMCOLORS, &oldcol);

	/* Restore screenmode */
	Vsetmode( old_modecode );
	Setscreen( old_screen_ptr, old_screen_ptr, -1 );

	/* Release memory */
	Mfree( new_screen_ptr );
	Mfree( vscreen );
}

/* Translates a 2600 color value into an X11 pixel value */
/* b: byte containing 2600 colour value */
/* returns: X11 pixel value */
unsigned int 
tv_color (BYTE b)
{
  return ((b>>1)<<8)+(b>>1);
}


/* Displays the tv screen */
void tv_display (void)
{
	static int frameskip = 0
	;
	/* Only display if the frame is a valid one. */
	if (frameskip--)
	{
		if (Verbose) printf ("displaying...\n");
		put_image ();
		
	} else
		frameskip =  base_opts.rr;
		
	tv_counter++;
}

/* The Event code. */
void tv_event (void)
{
	read_keyboard();
}

/* Single pixel plotting function. Used for debugging,  */
/* not in production code  */
/* x: horizontal position */
/* y: vertical position */
/* value: pixel value */
void
tv_putpixel (int x, int y, BYTE value)
{
  BYTE *p;

  switch (base_opts.magstep)
    {
    case 1:
      x = x << 1;
      p = vscreen + x + y * vwidth;
      *(p) = value;
      *(p + 1) = value;
    } 
}
