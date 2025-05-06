/*****************************************************************************/
/*      File    : LINES.C			Copyright (c) 1992           */
/*                                                                           */
/*	Author	: Kenneth W. Hartlen					     */
/*	Address	: Box 37, Site 6, RR#3					     */
/*		  Armdale, Nova Scotia					     */
/*		  B3L 4J3 Canada					     */
/*									     */
/*      Purpose : Simple program that uses graphics commands and can be	     */
/*		  be compiled in Lattice, Sozobon and Turbo C.		     */
/*									     */
/*		  The program draws a Qix like object on the screen that     */
/*		  moves around and rebounds off the sides of the screen.     */
/*                                                                           */
/*****************************************************************************/
/*	Compiling with Lattice C:					     */
/*		lc.ttp -fm lines.c					     */
/*		clink.ttp c.o+lines.o					     */
/*			LIB graphics.lib+lcm.lib+lcg.lib+lc.lib		     */
/*			TO lines.prg					     */
/*                                                                           */
/*	Compiling with Sozobon C v2.0:					     */
/*		cc -c lines.c						     */
/*		cc -o lines.prg -r lines.o graphics.a aesfast.a vdifast.a    */
/*                                                                           */
/*	Compiling with Heat & Serve Sozobon C v1.33i:			     */
/*		cc -c lines.c						     */
/*		cc -o lines.prg lines.o graphics.a libm.a aesfast.a \	     */
/*				vdifast.a				     */
/*                                                                           */
/*	Compiling with Turbo C:						     */
/*		Use Turbo C's IDE					     */
/*                                                                           */
/*****************************************************************************/

#ifdef SOZOBON				/* Causes some graphics functions to */
#define __MAIN_SRC__			/* to be included with user's source */
#endif

#include <stdio.h>			/* common header files */
#include <graphics.h>

#ifndef SOZOBON				/* Ignore header files not available */
#include <stdlib.h>			/* to Sozobon users		     */
#include <dos.h>
#endif

#ifdef __TURBOC__			/* include appropriate header file   */
#include <conio.h>			/* for kbhit() function		     */
#else
#include <osbind.h>
#endif

/*****************************************************************************/
/*  Main program loop                                                        */
/*****************************************************************************/

#define	MAXLINES	100		/* maximum # of lines to display */
#define MAXINC		20		/* maximum distance between lines */

void main()
{
int     graphdriver = DETECT, graphmode;

int	maxX,				/* save getmaxx() result */
	maxY,				/* save getmaxy() result */
	numLines,			/* # of lines to display */
	stepInc;			/* distance between the lines */
	
int	i,				/* array indices used to treat      */
	j,				/* arrays as a circular list to     */
	k;				/* eliminate copying array contents */
	
int	x1[MAXLINES+1],y1[MAXLINES+1],	/* xy coords for end #1 */
	x2[MAXLINES+1],y2[MAXLINES+1];	/* xy coords for end #2 */
	
int	stepx1,				/* how much to move x1 */
	stepx2,				/* how much to move x2 */
	stepy1,				/* how much to move y1 */
	stepy2;				/* how much to move y2 */

#ifdef __TURBOC__
struct time now;
#endif

    #ifdef __TURBOC__			/* get system time for use as the */
    gettime(&now);			/* random number generator seed   */
    srand(now.ti_sec);
    #else
    srand(Tgettime());
    #endif

    /* initialize graphics */    
    initgraph(&graphdriver,&graphmode,"");
    
    maxX = getmaxx();			/* save values to eliminate     */
    maxY = getmaxy();			/* function call in the do loop */
        
    setwritemode(XOR_PUT);
    setcolor(WHITE);
    
    settextjustify(CENTER_TEXT,TOP_TEXT);
    outtextxy(maxX/2,maxY/3,"LINES DEMO");
    outtextxy(maxX/2,maxY/3+textheight("H")*2,"by Kenneth W. Hartlen");
    outtextxy(maxX/2,maxY/3+textheight("H")*4,"Copyright (c) 1992");
    outtextxy(maxX/2,maxY/3+textheight("H")*7,"press a key to end");
    rectangle(0,0,maxX,maxY);
        
    /* initialize variables */
    numLines = (rand() % MAXLINES) + 1;	/* how many lines? */
    stepInc = (rand() % MAXINC) + 1;	/* how far apart? */
    
    stepx1=((rand()%stepInc) + 1) * (rand()%2 ? 1 : -1);
    stepy1=((rand()%stepInc) + 1) * (rand()%2 ? 1 : -1);
    stepx2=((rand()%stepInc) + 1) * (rand()%2 ? 1 : -1);
    stepy2=((rand()%stepInc) + 1) * (rand()%2 ? 1 : -1);

    for(k=1;k<=numLines;k++) {
	x1[k]= y1[k]= x2[k] = y2[k] = 0;
    }
    
    i=1 ; j=0 ; k=2;

    /* determine end points for first line */    
    x1[j]=rand()%maxX ; y1[j]=rand()%maxY;
    x2[j]=rand()%maxX ; y2[j]=rand()%maxY;

    do {
        /* move the line and save the coords */
	if ((x1[j]+stepx1<0) || (x1[j]+stepx1>maxX)) stepx1=-stepx1;
	x1[i]=x1[j]+stepx1;
	if ((y1[j]+stepy1<0) || (y1[j]+stepy1>maxY)) stepy1=-stepy1;
	y1[i]=y1[j]+stepy1;
	if ((x2[j]+stepx2<0) || (x2[j]+stepx2>maxX)) stepx2=-stepx2;
	x2[i]=x2[j]+stepx2;
	if ((y2[j]+stepy2<0) || (y2[j]+stepy2>maxY)) stepy2=-stepy2;
	y2[i]=y2[j]+stepy2;
	
	/* draw the new line in a visible colour */
	line(x1[i],y1[i],x2[i],y2[i]);

	/* update array indices */
	if (i+1>numLines) i=1; else i++;
	if (j+1>numLines) j=1; else j++;
	if (k+1>numLines) k=1; else k++;
	
	/* erase the k th line */
	line(x1[k],y1[k],x2[k],y2[k]);
	
    } while (!kbhit());			/* while key not pressed */

    closegraph();			/* close graphics */
    return;
        
} /* main */



