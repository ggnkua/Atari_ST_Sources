/*
 * stvfosil.c
 *
 * ST implementation of the Video Fossil functions
 *
 * (C) Copyright 1990,1991,1992 STeVeN W Green, All rights reserved
 *     With Modifications from Roland Bohn (UseColor)
 *
 * To be used with BinkleyTerm.  Free Software Foundation licence
 * agreements apply.
 *
 * BinkleyTerm only uses:
 *   VioWrtTTY
 *   VioWrtCellStr
 *
 * So I'm only going to implement those two!
 *
 * Refer to FSC-0021 for more details
 */

#include <stdio.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <osbind.h>
#endif
#include <ctype.h>
#include <stdlib.h>

#include "bink.h"
#include "com_st.h"
#include "vfossil.h"
#include "keybd.h"

#ifdef __TOS__
#define ld_col_bg v_col_bg
#define ld_col_fg v_col_fg
#define ld_cel_mx v_cel_mx
#define ld_cel_my v_cel_my
#define ld_vplanes v_planes
#else
LA_DATA *linea_data;
LA_EXT *linea_ext;
#endif

static UBYTE old_conterm;
#define CONTERM (*(UBYTE *)0x484)

static short old_back, old_fore;

static short oldcol0;

BOOLEAN nolinea = FALSE;		/* Set this to use VT52 codes */
#ifdef BIOSDISPLAY
BOOLEAN BIOSdisplay = FALSE;	/* Use BIOS for screen output */
#endif
BOOLEAN UseColors = FALSE;		/* Use fast monochrome output by default */


/*
 * Function for fiddling with system CONTERM variable
 * so as to allow the shift bits through with Bconin()
 */
 
static void set_conterm(void)
{
	old_conterm = CONTERM;
	CONTERM |= 8;
}

static void reset_conterm(void)
{
	CONTERM = old_conterm;
}

/*
 * Restore character colours before exitting, clearing screen, etc
 */

static void default_colors(void)
{
	if(nolinea)
		cprintf("\033b?\033c0");			/* Back=0, fore=15 */
	else
	{
		linea_ext->ld_col_fg = old_fore;		/* Restore colors */
		linea_ext->ld_col_bg = old_back;
	}
}

/*
 * Initialise video Fossil routines
 */

void vfossil_init(void)
{
	if(vfossil_installed)
		return;


	oldcol0 = Setcolor(0,-1)&0xfff;		/* Get color 0 for screen blanking */

#ifdef __TOS__
	linea_init();
#else
	linea_data = linea0();
	linea_ext = ((LA_EXT *)linea_data-1);
#endif

#if 0
	if(!nolinea)
	{
#endif
		/* Filling these in may make it work on big monitors, etc */

		/*
		** Check if ROWS, COLS are defined then take size from this
		** variables
		*/
		
		if (getenv("BCOLS"))
			SB_COLS = atoi(getenv("BCOLS"));
		else
			SB_COLS = linea_ext->ld_cel_mx + 1;	/* Number of text columns */
			
		if (getenv("BROWS"))
			SB_ROWS = atoi(getenv("BROWS"));
		else
			SB_ROWS = linea_ext->ld_cel_my;		/* Number of text rows */
			
		/*
		if(SB_COLS < 80)
			SB_COLS = 80;
		if(SB_ROWS < 23)
			SB_ROWS = 23;
		*/
#if 1
	if(!nolinea)
	{
#endif
		old_fore = linea_ext->ld_col_fg;		/* Get old colors */
		old_back = linea_ext->ld_col_bg;
	}

	cprintf("\033f");		/* Enable cursor */
    vfossil_installed = 1;
    Supexec((long(*)(void))set_conterm);

	/* Clear the Keyboard buffer */
	
	while(Cconis())
		Crawcin();

}

void vfossil_close(void)
{
	if(!vfossil_installed)
		return;

	default_colors();
	Setcolor(0, oldcol0);

	Supexec((long(*)(void))reset_conterm);
	cprintf("\033f");		/* Enable cursor */
	vfossil_installed = 0;
	
	/* Clear the Keyboard buffer */
	
	while(Cconis())
		Crawcin();

}

/* 
 * Enable or disable cursor
 */

void vfossil_cursor (int st)
{
	cputc('\033');
	cputc( st ? 'e' : 'f' );
}

/*
 * ST specific key input, to return similar sort of codes to the PC
 *
 * i.e. if it is an ascii character then that is in low 8 bits
 * otherwise a keyscan is in bits 8..15
 */

int getkey(void)
{
	union {
		long longkey;
		struct {
		        UBYTE shift;
		        UBYTE scan;
		        UBYTE fill;
		        UBYTE ascii;
		} kb;
	} key;

#if 0
	key.longkey = Bconin(2);
#else
	key.longkey = Crawcin();		/* See comment in com_st.h */
#endif	

	/* Alt-Function keys */
	
	if( (key.kb.shift & 8) && (key.kb.scan >= 0x3b) && (key.kb.scan <= 0x44) )
		return (int)(key.kb.scan + 45) << 8;

	/* Page Down = Shift Down arrow */
	
	if( (key.kb.shift & 3) && (key.kb.scan == 0x50) )
		return 0x5100;
	
	/* Page up = Shift Up arrow */
	
	if( (key.kb.shift & 3) && (key.kb.scan == 0x48) )
		return 0x4900;

	/*
	 * Process Alt/Ctrl-Keys... try to be keyboard independant by looking up the
	 * ascii value.
	 *
	 * Alt-Keys are only looked up if they don't have an ascii value, because
	 * on German keyboards some normal characters are accessed with Alt.
	 */

	if(!key.kb.ascii && (key.kb.shift & 8))
	{
		struct s_keytab {
			char *unshift;
			char *shift;
			char *capslock;
		} *bioskeys = (struct s_keytab *)Keytbl((char *)-1, (char *)-1, (char *)-1);

		if(key.kb.shift & 3)	/* Shift key */
			key.kb.ascii = bioskeys->shift[key.kb.scan];
		else
			key.kb.ascii = bioskeys->unshift[key.kb.scan];

		if(key.kb.ascii)
			return (int)key.kb.ascii + ALT_OFFSET;
	}

	/* Control keys... add an offset to distinguish <Return> from Ctrl-M */


	if(key.kb.ascii && (key.kb.shift & 4))		/* Control Key? */
		return key.kb.ascii + CTRL_OFFSET;


	/*
	 * Otherwise its just a plain ordinary key
	 */

	if(key.kb.ascii)
		return (int)key.kb.ascii;
	else
		return (int)key.kb.scan << 8;
}

#if 0	/* This is Stevens Routine */

/*
 * Write a Cell string
 *
 * Note that the string is in Character/Attribute pairs
 *
 * Map the Attribute to Atari colours.  Of course this isnt going to
 * work very well in mono is it!
 */

void VioWrtCellStr(BYTEBUFP s, size_t len, int row, int column, int vhandle)
{
	char oldback = -1;
	char oldfore = -1;

#if 0
	if(nolinea)
		oldback = oldfore = (char) -1;
#endif

	/* Move cursor to col,row */
	
	cprintf("\033Y%c%c", (char)row+' ', (char)column+' ');

	/* Print message */

	len >>= 1;		/* length is actually byte length */
	
	while(len--)
	{
		char fore = (s->attr & 15);
		char back = (s->attr >> 4) & 7;

		/*
		 * Send back/foreground colours... maybe ought to check for
		 * monitors and things tomake sure background and foreground
		 * are different.  Or maybe even ignore it completely!
		 */



		if(nolinea)
		{
			if(fore != oldfore)
				cprintf("\033b%c", (oldfore = fore) + '0');
			if(back != oldback)
				cprintf("\033c%c", (oldback = back) + '0');
		}
		else
		{
			/* Set the colours quickly with linea variables */
			/* Its possible that linea_data->text[fg|bg] should be used */

			linea_ext->ld_col_fg = fore;
			linea_ext->ld_col_bg = back;
		}

		if(BIOSdisplay)
		{
			if(s->ch)
				Bconout(5,s->ch);		/* Raw output */
			else
				Bconout(5,' ');
		}
		else	/* GEMdos */
		{
			if(s->ch)
				Cconout(iscntrl(s->ch) ? ' ' : s->ch);
			else
				Cconout(' ');
		}			
		s++;
	}
}

#else	/* And here are my changes [Roland Bohn] */

/*
 * Write a Cell string
 *
 * Note that the string is in Character/Attribute pairs
 *
 * Map the Attribute to Atari colours.  Of course this isnt going to
 * work very well in mono is it!
 */

void VioWrtCellStr(BYTEBUFP s, size_t len, int row, int column, int vhandle)
{
	char c;
	char oldback = -1;
	char oldfore = -1;
	char tmpstr[256];
	char *ptr;
	
#if 0
	if(nolinea)
		oldback = oldfore = (char) -1;
#endif
	
	/* Move cursor to col,row */
	
	if ( vhandle )
	{
	}

	Cconout(27);
	Cconout('Y');
	Cconout(row + ' ');
	Cconout(column + ' ');
	
	/* Print message */
	
	len >>= 1;		/* length is actually byte length */
	
	*tmpstr = '\0';	/* Init the temporary string */
	ptr = tmpstr;
	
	while(len--)
	{
		if (UseColors)		/* To write things faster, no colors */
		{
			char fore = (s->attr & 15);
			char back = (s->attr >> 4) & 7;
			
			/* If color has changed then print the string at the old color */
			
			if(ptr > tmpstr && (fore != oldfore || back != oldback))
			{
				*ptr = '\0';
				Cconws(tmpstr);
				*tmpstr = '\0';
				ptr = tmpstr;
			}
			
			/*
			 * Send back/foreground colours... maybe ought to check for
			 * monitors and things to make sure background and foreground
			 * are different.  Or maybe even ignore it completely!
			 */
			
			if(nolinea)
			{
				if(fore != oldfore)
				{
					Cconout(27);		/* Cconout is faster than cprintf */
					Cconout('b');
					Cconout(fore + '0');
				}
				if(back != oldback)
				{
					Cconout(27);
					Cconout('c');
					Cconout(back + '0');
				}
			}
			else
			{
				/* Set the colours quickly with linea variables */
				/* Its possible that linea_data->text[fg|bg] should be used */
				
				linea_ext->ld_col_fg = fore;
				linea_ext->ld_col_bg = back;
			}
			
			oldfore = fore;
			oldback = back;
		}
		
		c = s->ch;
		if(c && !iscntrl(c))
			*ptr++ = c;
		else
			*ptr++ = ' ';
		
		s++;			/* Next Character */
	}
	*ptr = '\0';		/* Make shure the String is null terminated */
	
	Cconws(tmpstr);		/* Print the String on the Screen */
}
#endif

void blank_screen(void)
{
	Setcolor(0,0);					/* Color 0 = Black */
	cprintf("\033c0\033E");			/* Clear screen to color 0 */
}

void unblank_screen( void )
{
	Setcolor(0,oldcol0);
}


void screen_clear( void )
{
	default_colors();
	cprintf("\033E");
}

void clear_eol( void )
{
	default_colors();
	cprintf("\033K");		/* Clear to end of line */
}
