/*****************************************************************************
 *									     *
 *			       Spectral  Sorcery			     *
 *				A Strategy Game				     *
 *				    for the				     *
 *			      Atari ST  Computers			     *
 *									     *
 *				Compiled using				     *
 *				Mark William's C			     *
 *				  Version 3.0				     *
 *                                                                           *
 *                            Copyright (c)  1988                            *
 *                              by Jeff Makaiwi                              *
 *									     *
 *****************************************************************************/

/*******************************
 *   External File Inclusion   *
 *******************************/

#include "readable.h"	/* My C Macros for Readability */
#include "sorcery.h"	/* Spectral Sorcery Standard Constants */
#include <osbind.h>	/* Include low-level OS-calls */
#include <linea.h>	/* need a few linea calls to shut off mouse */



/************************************/
/*   Animation Variables and Data   */
/************************************/

#include "xdatared.c"
#include "xmaskred.c"
#include "xdatavio.c"
#include "xmaskvio.c"
#include "xdatapad.c"


/* Pointers to the animation image data blocks */
short *wizImages[2][16] = {{rwFront, rwBack, rwNod1, rwNod2, rwNod3, rwNod4,
			  rwSpl1, rwSpl2, rwSpl3, rwSpl4, rwSpl5, rwSpl6,
			  rwTrn1, rwTrn2, rwTrn3, rwTrn4},
			 {vwFront, vwBack, vwNod1, vwNod2, vwNod3, vwNod4,
			  vwSpl1, vwSpl2, vwSpl3, vwSpl4, vwSpl5, vwSpl6,
			  vwTrn1, vwTrn2, vwTrn3, vwTrn4}};

short *wizMasks[2][16] = {{rmFront, rmBack, rmNod1, rmNod2, rmNod3, rmNod4,
			 rmSpl1, rmSpl2, rmSpl3, rmSpl4, rmSpl5, rmSpl6,
			 rmTrn1, rmTrn2, rmTrn3, rmTrn4},
			{vmFront, vmBack, vmNod1, vmNod2, vmNod3, vmNod4,
			 vmSpl1, vmSpl2, vmSpl3, vmSpl4, vmSpl5, vmSpl6,
			 vmTrn1, vmTrn2, vmTrn3, vmTrn4}};

short *telePads[5]	= {tpad1, tpad2, tpad3, tpad4, tpad5};


/* Buffers to hold the platfrom image data */
short padImages[5][PADSIZE], edgeImages[3][EDGESIZE];

/* Pad and Edge Image Pixel Value Templates and 1-plane Patterns */

/* 4-plane Pixel value templates for Platfrom colors RED to VIOLET */
short padTemplate[5][4] = {{0xffff,0x0000,0x0000,0x0000},
			 {0x0000,0xffff,0x0000,0x0000},
			 {0xffff,0xffff,0x0000,0x0000},
			 {0x0000,0x0000,0xffff,0x0000},
			 {0xffff,0x0000,0xffff,0x0000}};

/* 4-plane Pixel value templates for Edge colors (GRAY, IR, UV) */
short edgeTemplate[3][4] = {{0x0000,0xffff,0xffff,0x0000},
			  {0xffff,0xffff,0xffff,0x0000},
			  {0x0000,0x0000,0x0000,0xffff}};

/* 1-plane bitmap Pattern for Platform Pads */
short padPattern[] = {0x0000,0x01f0,0x0000,0x0000,
		    0x0000,0x0ffe,0x0000,0x0000,
		    0x0000,0x7fff,0xc000,0x0000,
		    0x0003,0xffff,0xf800,0x0000,
		    0x001f,0xffff,0xff00,0x0000,
		    0x00ff,0xffff,0xffe0,0x0000,
		    0x07ff,0xffff,0xfffc,0x0000,
		    0x3fff,0xffff,0xffff,0x8000,
		    0xffff,0xffff,0xffff,0xe000,
		    0x3fff,0xffff,0xffff,0x8000,
		    0x07ff,0xffff,0xfffc,0x0000,
		    0x00ff,0xffff,0xffe0,0x0000,
		    0x001f,0xffff,0xff00,0x0000,
		    0x0003,0xffff,0xf800,0x0000,
		    0x0000,0x7fff,0xc000,0x0000,
		    0x0000,0x0ffe,0x0000,0x0000,
		    0x0000,0x01f0,0x0000,0x0000};

/* 1-plane bitmap Pattern for Platform edges */
short edgePattern[] = {0xc000,0x0000,0x0000,0x6000,
		     0xf800,0x0000,0x0003,0xe000,
		     0x3f00,0x0000,0x001f,0x8000,
		     0x07e0,0x0000,0x00fc,0x0000,
		     0x00fc,0x0000,0x07e0,0x0000,
		     0x001f,0x8000,0x3f00,0x0000,
		     0x0003,0xf001,0xf800,0x0000,
		     0x0000,0x7e0f,0xc000,0x0000,
		     0x0000,0x0ffe,0x0000,0x0000,
		     0x0000,0x01f0,0x0000,0x0000};


/****************************************************************
 *   Sound Chip Musical Note Data, (coarse,fine) tuning bytes   *
 ****************************************************************/
/* These are to be loaded into reg 1 and 0 of the sound chip (respectively) */
/* Index as notes[octave][note][coarse/fine] */

char notes[8][12][2] = { 
     /* Octave 0 */
	0x0d,0x9d, 0x0c,0x9c, 0x0b,0xe7, 0x0b,0x3c,
	0x0a,0x9b, 0x0a,0x02, 0x09,0x73, 0x08,0xeb,
	0x08,0x6b, 0x07,0xf2, 0x07,0x80, 0x07,0x14,
     /* Octave 1 */
	0x06,0xae, 0x06,0x4e, 0x05,0xf4, 0x05,0x9e,
	0x05,0x4d, 0x05,0x01, 0x04,0xb9, 0x04,0x75,
	0x04,0x35, 0x03,0xf9, 0x03,0xc0, 0x03,0x8a,
     /* Octave 2 */			
	0x03,0x57, 0x03,0x27, 0x02,0xf2, 0x02,0xcf,
	0x02,0xa7, 0x02,0x81, 0x02,0x5d, 0x02,0x3b,
	0x02,0x1b, 0x01,0xfc, 0x01,0xe0, 0x01,0xc5,
     /* Octave 3 */	
	0x01,0xac, 0x01,0x94, 0x01,0x7d, 0x01,0x68,
	0x01,0x53, 0x01,0x40, 0x01,0x2e, 0x01,0x1d,
	0x01,0x0d, 0x00,0xfe, 0x00,0xf0, 0x00,0xe2,
     /* Octave 4 */	
	0x00,0xd6, 0x00,0xca, 0x00,0xbe, 0x00,0xb4,
	0x00,0xaa, 0x00,0xa0, 0x00,0x97, 0x00,0x8f,
	0x00,0x87, 0x00,0x81, 0x00,0x7f, 0x00,0x71,
     /* Octave 5 */	
	0x00,0x6b, 0x00,0x65, 0x00,0x5f, 0x00,0x5a,
	0x00,0x55, 0x00,0x50, 0x00,0x4c, 0x00,0x47,
	0x00,0x43, 0x00,0x40, 0x00,0x3c, 0x00,0x39,
     /* Octave 6 */	
	0x00,0x35, 0x00,0x32, 0x00,0x30, 0x00,0x2d,
	0x00,0x2a, 0x00,0x28, 0x00,0x26, 0x00,0x24,
	0x00,0x22, 0x00,0x20, 0x00,0x1e, 0x00,0x1c,
     /* Octave 7 */	
	0x00,0x1b, 0x00,0x19, 0x00,0x18, 0x00,0x16,
	0x00,0x15, 0x00,0x14, 0x00,0x13, 0x00,0x12,
	0x00,0x11, 0x00,0x10, 0x00,0x0f, 0x00,0x0e};

/***********************
 *   Message Strings   *
 ***********************/

/* Names of the players */
char *playerName[] = {"Red Sorcerer", "Violet Wizard"};

/* Names of the legal actions, for the menu */
char *actions[] = {"PASS","MOVE","CAST","STOMP","HELP ME","RESIGN"};

/* Names of the legal SPELLS */
char *spells[8] = {"NO SPELL", "CONVERT", "TELEPORT", "BLITZ",
		   "TRANSMUTE", "LOCK", "UNLOCK", "RELEASE LOCKS"};

/* Names of the Colors of the pads */
char *colorName[] = {"Red","Yellow","Green","Blue","Violet"};


/*****************************
 *   Global Game Variables   *
 *****************************/

/* Player information, power, location, etc. */
PLINFO player[2];


/* The RGB values of my color palette, use with XBIOS Setcolor or Setpalette */
short colorSet[16] = {0x000,0x700,0x770,0x040,0x037,0x405,0x555,0x745,
		      0x507,0x303,0x404,0x310,0x420,0x654,0x333,0x777};

/* Game option constants */
short gameCtrl[3];	/* Which Stick for which Player */

/* Screen pointers */
long mainScreen, screenBuff;

short oldColors[16];	/* place to save old palette */
short playerOrder[2];	/* order of play, set as a game option */

/* Game board arrays, treated as a 5x5 array (a union). */
/* Low byte = color, Hi byte = lock status */
BDTYPE board, workBoard;

/* The extra screen buffers */
long scrbuff1[SCRSIZE], background[8000];



/************************************
 *   External Function References   *
 ************************************/
/* from CONTROL.C */
extern void Game_Loop();

/* from SETUP.C */
extern void Create_Platforms();

/* from DRAWING.S */
extern void Clear_Block();



/************************************
 *   The CODE Section Starts Here   *
 ************************************/

/************************************************************************
 * This routine finds good addresses for the screenbuffer in an array.  *
 * It also clears the three screen areas.  Two display, one background. *
 ************************************************************************/
static void SetupScreens()
begin
    screenBuff = ((long)scrbuff1 + 255L) & 0x00ffff00L;
    mainScreen = (long)Logbase();

    Clear_Block(background, 4000);
    Clear_Block(screenBuff, 4000);
    Clear_Block(mainScreen, 4000);
end /* of Setup Screen Buffers PROC */


/****************************************************************************
 * This, of course, is where it all starts.  It sets the screen resolution  *
 * to the proper value or wails on the user for having a monochrome system. *
 * Believe me, it would be very difficult to play this in mono.             *
 ****************************************************************************/
main()
begin
    long _stksize = 0x1000L;
    register short i;
    static short oldRes;

    lineaa();	/* Hide Mouse */
    if ( (oldRes = Getrez()) != 2) begin

	Setscreen(-1L, -1L, 0);
	for (i = 0; i < 16; i++) begin
	    oldColors[i] = Setcolor(i, colorSet[i]);
	end /* of set color palette */

 	Create_Platforms();
	SetupScreens();

	Game_Loop();

	Setscreen(mainScreen, mainScreen, oldRes);
	Setpalette(oldColors);

    end else begin
	Cconws("SPECTRAL SORCERY only runs in COLOR...\n\r");
	Bconin(2);
    end /* of resolution check */
    linea9();	/* Show mouse */
end /* of main */
