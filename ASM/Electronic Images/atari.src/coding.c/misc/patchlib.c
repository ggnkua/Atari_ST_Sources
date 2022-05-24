/* patchlib.c  patch librarian, central module        jlc 10-87 */
/* version 1.0 */

#include <stdio.h>		/* compiler library module headers */
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "standard.h"		/* header files for patchlib.c */
#include "chain.h"
#include "writscrn.h"
#include "patchlib.h"

struct selement ajuno1[NPARAMS1] = {		/* primary menu cursor block */
    {4,  5, "DRIVE",   12, 1,  0,  0,  0 },			/* uses writscrn() conventions */
    {4,  6, "LIBRARY", 0,  2,  1,  1,  1 },
    {4,  7, "SELECT",  1,  3,  2,  2,  2 },
    {4,  8, "EDIT",    2,  4,  3,  3,  3 },
    {4,  9, "NAME",    3,  5,  4,  4,  4 },
    {4, 10, "SAVE",    4,  6,  5,  5,  5 },
    {4, 11, "UPLOAD",  5,  7,  6,  6,  6 },
    {4, 12, "DOWNLOAD",6,  8,  7,  7,  7 },
    {4, 13, "PRINT",   7,  9,  8,  8,  8 },
    {4, 14, "CLEAR",   8, 10,  9,  9,  9 },
    {4, 15, "MOVE",    9, 11, 10, 10, 10 },
    {4, 16, "IMPORT", 10, 12, 11, 11, 11 },
    {4, 18, "QUIT",   11,  0, 12, 12, 12 }};



main()
{
    int status, pick, lastpick, patchno, ans, i;

				/* pointers to screen images (see chain.h) */
    struct strchain *chain[NSCREEN];

				/* array to hold coded synth data */
    static unsigned char tonebyte[NPATCH][NCODPARAM];
    static int ajparam[NPARAM];	/* working data for one patch's parameters */
    static char ajname[11];	/* also save name of patch */
    static char prodir[50];	/* directory of program's files */
    static char patdir[50];	/* directory containing patches */
    static char libname[14];	/* current lib name, all have suffix .lby */
    static char buf[17];	/* misc. char buffer */
    static char nbuf[10];	/* buffer for ascii value of a number */
    static char nofile[] = "Need to load or download data first.";
    
/* load screens into memory */

    clearsc();
    fputs("Loading screen images....",stdout);
    
    for (i = 0; i < NSCREEN; i++){
	strcpy(buf,"ajuno");		/* screen names are ajuno1.scr, */
	nbuf[0] = '1' + i;		/* ajuno2.scr .... ajuno7.scr */
	nbuf[1] = '\0';
	strcat(buf,nbuf);
	strcat(buf,".scr");
	chain[i] = inpchain(buf,SCRNWIDE + 1);
    }
    
    for (i = 0; i < NSCREEN; i++){
	if (chain[i] == NULL){
	    fputs("Failed to load screen file ajuno",stdout);
	    itoa(i+1, buf, 10);
	    fputs(buf,stdout);
	    fputs(".scr\n",stdout);
	    fputs("Be sure you are running Patchlib from the default drive.",
		stdout);
	    exit(0);
	}
    }

    patchno = -1;				/* no data loaded yet */
    clearval(ajparam, ajname, tonebyte);	/* zero out all values */
    getcwd(prodir,50);		/* put current directory name in dir */
    strcpy(patdir,prodir);	/* start with directory set to program area */
    strcpy(libname,"NO_NAME.LBR");		/* default library name */


/* Put the primary menu on the screen, plus current settings */
/* Loop to and from dependent program segments based on selection */


    pick = 0;
    while (1){
	clearsc();
	dispchain(chain[0]);		/* display primary screen image */

	writword(BWC,patdir,58,5);	/* write patch directory on screen */
	writword(BWC,libname,58,6);		/* write library name */
	if (patchno > -1){
	    decode(patchno, ajparam, ajname, tonebyte);
	    writword(BWC,ajname,58,7);		/* write patch name */
	}
    
	while (kbhit()) getch();		 /* clear any stray keypress */
	
	lastpick = pick;
	pick = movescrn(ajuno1,pick,12); /* cursor selection of command */
	switch (pick){
	case (0):				/* drive */
	    status = pickdriv(patdir,prodir);
	    if (status != 0){	/* if user did select a drive */
		patchno = -1;
		strcpy(libname,"NO_NAME.LBR");
	    }
	    break;
	case (1):				/* library */
	    status = picklib(libname, patdir, prodir, tonebyte,
		"Type the library name (no .LBR, ret to exit) -> ");
	    if (status != -1)
		patchno = 0;
	    else{
		strcpy(libname,"NO_NAME.LBR");
		patchno = -1;
	    }
	    break;
	case (2):				/* select */
	    if (patchno < 0)
		writerr(nofile);
	    else
		patchno = selpatch(patchno,ajparam,ajname,tonebyte);
	    break;
	case (3):				/* edit */
	    if (patchno < 0)
		writerr(nofile);
	    else
		edpatch(patchno, ajparam, ajname, tonebyte, chain);
	    break;
	case (4):				/* name */
	    if (patchno < 0)
		writerr(nofile);
	    else
		namepatch(patchno, ajparam, ajname, tonebyte);
	    break;
	case (5):				/* save */
	    if (patchno < 0)
		writerr(nofile);
	    else
		savepatch(libname, patdir, prodir, tonebyte);
	    break;
	case (6):				/* upload */
	    if (patchno < 0)
		writerr(nofile);
	    else
		upload(tonebyte);
	    break;
	case (7):				/* download */
	    status = download(ajparam, ajname, tonebyte);
	    if (status != -1){
		strcpy(libname,"NO_NAME.LBR");
		patchno = 0;
	    }
	    break;
	case (8):				/* print */
	    if (patchno < 0)
		writerr(nofile);
	    else
		printpatch(libname, tonebyte);
	    break;
	case (9):				/* clear */
	    if (patchno < 0)
		writerr(nofile);
	    else{
		while (kbhit()) getch();	/* clear keyboard buffer */
		writword(BWC,"Sure you want to clear all settings on ",
		    0,SCRNTALL - 3);
		fputs(ajname,stdout);
		fputs(" (Y/N)? ",stdout);
		ans = getche();
		if (toupper(ans) == 'Y'){
		    clearval(patchno, ajparam, ajname, tonebyte);
		    writerr("All settings for selected patch are zero.");
		    break;
		}
	    }
	    break;
	case (10):				/* move */
	    if (patchno < 0)
		writerr(nofile);
	    else
		movepatch(ajparam, ajname, tonebyte);
	    break;
	case (11):				/* import */
	    if (patchno < 0)
		writerr(nofile);
	    else{
		status = import(patdir, prodir, tonebyte);
		if (status != -1){
		    patchno = status;
		}
	    }
	    break;
	case (-2):				/* esc key */
	case (12):				/* quit */
	    writword(BWC,
		"Don't forget to SAVE data.  Quit Patchlib? (Y/N) "
		    ,0,SCRNTALL - 3);
	    ans = getche();
	    if (toupper(ans) != 'Y')
		pick = 0;
	    else{
		clearsc();
		exit(0);
	    }
	    break;
	default:
	    writerr("Use arrow keys to move cursor, ret to select.");
	    pick = lastpick;
	}
    }
}

