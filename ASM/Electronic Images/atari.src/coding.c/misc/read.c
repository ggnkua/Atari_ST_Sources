/* record.c   simple routine to record one track and play it back */


/* for Turbo C insert line "#define TURBOC 1" */

#include <stdio.h>	/* compiler library headers */
#include <conio.h>
#include <string.h>

#if TURBOC
    #include <alloc.h>
#else
    #include <malloc.h>
#endif

#include "chain.h"
#include "writscrn.h"
#include "standard.h"
#include "mpu401.h"

#define NPARAMS1	7

struct selement record1[NPARAMS1] = {
    {4, 8,  "BPM",       NPARAMS1-1,1, 0, 0, 0},
    {4, 9,  "TIME",      0,         2, 1, 1, 1},
    {4, 10, "MET ON/OFF",1,         3, 2, 2, 2},
    {4, 11, "RECORD",    2,         4, 3, 3, 3},
    {4, 12, "PLAY",      3,         5, 4, 4, 4},
    {4, 13, "CLEAR",     4,         6, 5, 5, 5},
    {4, 15, "QUIT",      5,         0, 6, 6, 6},
};

struct event {
    struct event far *next;
    char nbytes;
    char b[4]; 
};

struct event far *eventalloc();
struct event far *store();
struct event far *record();
struct event far *play();

    
main()
{
    struct strchain *schain;
    struct event far *startevent[8];	/* first node for eight tracks */
    struct event far *lastevent[8];	/* current node for eight tracks */

    char buf[20];
    int i, ans, pick, lastpick, curtrack, hasdata, meton;
    int *metrate, *meter;

    metrate = (int *)malloc(sizeof(int));
    meter = (int *)malloc(sizeof(int));
    
    curtrack = 0;			/* this program only uses track 1 */
    hasdata = 0;
    meton = 0;
    *metrate = 120;			/* MPU-401 default settings */
    *meter = 4;				/* 120 bpm, 4/4 time */
    
    clearsc();
    putcmd(RESET);			/* clear MPU-401 */

    puts("Loading screen image.");
    schain = inpchain("record.scr",81);

    sendcmd(BEND_ON);			/* allow pitch bend data to pass */
    sendcmd(SET_TEMPO);			/* set tempo to default value */
    putdata(*metrate/2);
    sendcmd(METRO_MEAS); 		/* set meter to default value */
    putdata(*meter);			

    pick = 0;
    while (1){
	clearsc();
	dispchain(schain);
	itoa(*metrate,buf,10);
	writword(BWC,buf,67,8);		/* put bpmin on screen */
	strcpy(buf," ");
	itoa(*meter,buf,10);		
	writword(BWC,buf,67,9);		/* put meter on screen */
	if (meton)
	    writword(BWC,"ON",67,10);	/* put metronome status on screen */
	else
	    writword(BWC,"OFF",67,10);
	
	while (kbhit()) getch();		/* clear stray keypress */
	
	lastpick = pick;
	pick = movescrn(record1,pick,NPARAMS1 - 1);
	
	switch (pick){
	case (0):		/* BPM */
	    ans = getint(SCRNTALL-2,"Enter metronome rate in beeps/min ->",
		metrate,8,200);
	    if (ans == 1){
		sendcmd(SET_TEMPO);
		putdata(*metrate/2);
	    }
	    break;
	case (1):		/* TIME */
	    ans = getint(SCRNTALL-2,"Enter beats per measure ->",
		meter,1,20);
	    if (ans == 1){
		sendcmd(METRO_MEAS);
		putdata(*meter);
	    }
	    break;
	case (2):		/* MET ON/OFF */
	    if (meton){
		sendcmd(MET_OFF);
		meton = 0;
	    }
	    else{
		sendcmd(MET_ON_WOUT);
		meton = 1;
	    }
	    break;
	case (3):		/* RECORD */
	    writword(BWC,"Hit space bar to stop recording.",0,SCRNTALL-2);
	    startevent[curtrack] = record(curtrack);
	    hasdata = 1;
	    clearline(SCRNTALL-2);
	    break;
	case (4):		/* PLAY */
	    if (!hasdata){
		writerr("No data in memory to play.");
	    }
	    else{				/* always start at begining */
		for (i = 0; i < 8; i++){		
		    lastevent[i] = startevent[i];
		}
		writword(BWC,"Hit space bar to stop play.",0,SCRNTALL-2);
		sendcmd(ACT_TRACK);
		putdata(1);			/* activate track one only */
		play(lastevent);
		clearline(SCRNTALL-2);
	    }
	    break;
	case (5):		/* CLEAR */
	    clear(startevent[curtrack]);
	    hasdata = 0;
	    writerr("The track has been erased.  ");
	    break;
	case (-2):		/* ESC key */
	case (NPARAMS1-1):	/* QUIT */
	    clearsc();
	    exit();
	    break;
	default:
	    writerr("Use arrow keys to move cursor, ret to select.");
	    pick = lastpick;
	}
    }
}




#define BUFSIZE		100
int cmdbuf[BUFSIZE];		/* global buffer for pending MPU commands */
int cmdbufp = 0;		/* next free position in cmdbuf */

getnext()	/* get a possibly pushed back command from MPU or cmdbuf */
{
    return((cmdbufp > 0) ? cmdbuf[--cmdbufp] : getdata());
}


ungetnext(n)	/* push a command back on input */
int n;
{
    if (cmdbufp > BUFSIZE)
	printf("\nungetnext ran out of buffer space.");
    else
	cmdbuf[cmdbufp++] = n;
}


get401()		/* get next byte from mpu401 (or pending buffer) */		
{			/* try forever, stop on keypress */
    int i;
    
    while (1){
	i = getnext();
	if (kbhit()) return(-1);
	if (i != -1) return(i);
    }
}



sendcmd(n)	/* send a command, check for ACK, if not save MPU data */
int n;		/* until it stops sending */
{
    int ans;

    ans = putcmd(n);
    if (ans == ACK)
	return;
    else if (ans != -1){
	ungetnext(ans);		/* put pending data on stack */
	while (1){		/* check for more incoming data */
	    ans = getdata();
	    if (ans == ACK || ans == -1)
		return;
	    else
		ungetnext(ans);
	}
    }
}


struct event far *record()	/* record a track, stop on any keypress */
{
    int first, second, third, fourth, mstatus;
    struct event far *firstnode;
    struct event far *nextnode;

    mstatus = 0;
    firstnode = eventalloc();	/* start memory allocation with first node */
    nextnode = firstnode;
    while (kbhit()) getch();	/* clear any stray keypress */
    sendcmd(START_REC);

    while (1){
	first = get401();
	if (first == -1){		/* a keypress */
	    while (kbhit()) getch();
	    sendcmd(STOP_REC);
	    first = get401();
	}
	if (first <= 0xEF){		/* timing byte */
	    second = get401();
	    if (second <= 0x7F){		/* MIDI data, running status assumed */
		third = get401();
		nextnode = store(nextnode,4,first,mstatus,second,third);
	    }
	    else if (second <= 0xBF){	/* MIDI message, note on/off */	
		mstatus = second;	/* after touch or control change */
		third = get401();
		fourth = get401();
		nextnode = store(nextnode,4,first,second,third,fourth);
	    }
	    else if (second <= 0xDF){	/* prog change or chan after touch */
		mstatus = second;
		third = get401();
		nextnode = store(nextnode,3,first,second,third,0);
	    }
	    else if (second <= 0xEF){	/* pitch wheel */
		mstatus = second;
		third = get401();
		fourth = get401();
		nextnode = store(nextnode,4,first,second,third,fourth);	    
	    }
	    else if (second == 0xF9){	/* measure end */
		nextnode = store(nextnode,2,first,second,0,0);
	    }
	    else if (second == 0xFC){	/* data end for track */
		nextnode = store(nextnode,2,first,second,0,0);
		return(firstnode);	/* only one track recording, so done */
	    }
	    else{
		printf("\nUnrecognized data %x %x",first,second);
	    }
	}
	else if (first <= 0xF7)		/* track data requests */
	    printf("\nTrack data was requested (%x)",first);
	else if (first == 0xF8)		/* time out */
	    nextnode = store(nextnode,1,first,0,0,0);
	else if (first == 0xF9)		/* conductor request */
	    printf("\nGot a conductor data request.");
	else if (first == 0xFC)		/* all end */
	    return(firstnode);
	else if (first == 0xFD)		/* mpu send clock signal */
	    printf("\nGot a clock out signal (%x)",first);
	else if (first == 0xFE){		/* ignore acknoledge */
	}
	else{
	    writerr("Record stopped.");
	    return(firstnode);
	}
	
	if (nextnode == NULL){
	    writerr("Could not allocate more memory (full?), record stopped.");
	    sendcmd(STOP_REC);
	    get401();
	    return(firstnode);
	}
    }
}



struct event far *eventalloc()		/* returns pointer to memory area */
{					/* sized for one event. */
#if TURBOC
    return((struct event far *)farmalloc(sizeof(struct event)));
#else
    return((struct event far *)_fmalloc(sizeof(struct event)));
#endif
}

    
    
struct event far *store(node,nbytes,b1,b2,b3,b4)
int nbytes;
struct event far *node;		/* store an event, return pointer to next */
int b1,b2,b3,b4;
{
    node->next = eventalloc();
    (node->next)->next = NULL;	/* null pointer in next node to mark end */
    node->nbytes = nbytes;
    node->b[0] = b1;
    node->b[1] = b2;
    node->b[2] = b3;
    node->b[3] = b4;
    return(node->next);
}


	
struct event far *play(events)		/* play tracks */	
struct event far *events[];	
{
    int i, cmd, trk, firstcmd;
    firstcmd = 1;

    while (kbhit()) getch();		/* clear any stray keypress */

    sendcmd(CLEAR_PCOUNT);		/* clear play counters */
    sendcmd(START_PLAY);
		
    while (1){
	cmd = get401();			/* get next mpu-401 request */
	if (cmd == -1)
	    break;			/* quit on keypress */
	if (cmd >= REQ_T1 && cmd <= REQ_T8){		/* track req */
	    firstcmd = 0;
	    trk = cmd - REQ_T1;				/* track number */
	    for (i = 0; i < events[trk]->nbytes; i++){
		putdata(events[trk]->b[i]);		/* send data bytes */
	    }
	    if (events[trk]->next == NULL)
		break;
	    else
		events[trk] = events[trk]->next;	/* move track counter */	
	     						/* forward one event */
	}
	else if (cmd == ALL_END){
	    if (firstcmd)		/* don't quit if received at start */
		firstcmd = 0;
	    else
		break;
	}
    }
    sendcmd(STOP_PLAY);
    sendcmd(CLEAR_PMAP);
    return(events[trk]);
}



clear(event)			/* clear a track from memory */
struct event far *event;
{
    struct event far *nextevent;
    
    do{
	nextevent = event->next;
#if TURBOC
	farfree(event);
#else
	_ffree(event);
#endif
	event = nextevent;
    }while (event != NULL);
}

