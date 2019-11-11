/* ==================================================================== */
/*	Serendipity: Sound effects					*/
/* ==================================================================== */

#include	<osbind.h>
#include	"globals.h"


weep_n_wail()	{ noise(0);  }	/* The computer lost a game		*/
explosion()	{ noise(1);  }	/* The computer won a game		*/
click()		{ noise(2);  }	/* Placing a piece on the board		*/
bell()		{ noise(3);  }	/* Displaying a chivvy-type message	*/
squiggle()	{ noise(4);  }	/* A capture was made			*/
clang_1()	{ noise(6);  }	/* Clicked somewhere useless		*/
clang_2()	{ noise(8);  }	/* The game was drawn			*/
whistle()	{ noise(10); }	/* Entertainment while clearing board	*/


/* -------------------------------------------------------------------- */
/*	Drive the sound chip via the Xbios interrupt routine		*/
/* -------------------------------------------------------------------- */

noise(n)	{ Dosound((char *)&sound+sound.entry[n].offset); }

