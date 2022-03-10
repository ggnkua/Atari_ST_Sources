#ifndef H_SBUF
#define H_SBUF
/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*			   Screen Buffer Definitions used in BinkleyTerm				*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/


/* $Header: SBUF.H 0.1 88/04/01 03:13:12 Bob Exp $ */

/*
 * $Log:	SBUF.H $
 * Revision 0.1  88/04/01  03:13:12  Bob
 * Initial check-in
 *
 */

#define SB_OK  0
#define SB_ERR (-1)

#define SB_SIZ	SB_ROWS * SB_COLS

extern BOOLEAN sb_inited;			/* Set when sbuffer is initialised */


/* screen character/attribute buffer element definition */

#ifdef M68000

/*
 * I tried to make this machine independant, buts theres just too
 * many occurences of ((attr<<8) | ch) to convert from CELL.b to CELL.cap
 */

typedef struct
{
   unsigned char attr;							 /* attribute */
   unsigned char ch;							 /* character */
} BYTEBUF, *BYTEBUFP;

#else

typedef struct
{
   unsigned char ch;							 /* character */
   unsigned char attr;							 /* attribute */
} BYTEBUF, *BYTEBUFP;

#endif

typedef union
{
   BYTEBUF b;
   unsigned short cap;							  /* character/attribute pair */
} CELL, *CELLP;

/* screen buffer control structure */
typedef struct
{
   /* current position */
   int row, col;

   /* pointer to screen buffer array */
   CELLP bp;

   /* changed region per screen buffer row */
   int *lcol;									 /* left end of changed
												  * region */
   int *rcol;									 /* right end of changed
												  * region */

   /* buffer status */
   unsigned int flags;
} BUFFER, *BUFFERP;

/* buffer flags values */
#define SB_DELTA  0x01
#define SB_RAW	  0x02
#define SB_DIRECT 0x04
#define SB_SCROLL 0x08
#define SB_SYNC   0x10

/* coordinates of a window (rectangular region) on the screen buffer */
typedef struct
{
   /* current position */
   int row, col;

   /* window boundaries */
   int r0, c0;									 /* upper left corner */
   int r1, c1;									 /* lower right corner */

   /* scrolling region boundaries */
   int sr0, sc0;								 /* upper left corner */
   int sr1, sc1;								 /* lower right corner */

   /* window buffer flags */
   unsigned int wflags;
} REGION, *REGIONP;

/* coordinates of a window (rectangular region) on the screen buffer */
typedef struct {
   /* top left corner */
   short save_row, save_col;

   /* height and width */
   short save_ht, save_wid;

   /* Window to use */
   REGIONP region;

   /* Saved cells from the window */
   CELLP save_cells;

} SAVE, *SAVEP;

#define HIST_BBS_ROW  1
#define HIST_MAIL_ROW 1
#define HIST_ATT_ROW  2
#define HIST_CONN_ROW 3
#define HIST_FILE_ROW 4
#define HIST_LAST_ROW 5
#define HIST_COL	  13
#define HIST_COL2	  8

#define SET_EVNT_ROW  2
#define SET_PORT_ROW  3
#define SET_TIME_ROW  1
#define SET_DATE_ROW  4
#define SET_STAT_ROW  4
#define SET_TASK_ROW  5

#define SET_COL 	  10
#define SET_TIME_COL  2

/*
 * Variables
 */


#if 0
extern BUFFER Sbuf;					 /* control information */
extern CELLP Scrnbuf;				 /* screen buffer array */
#endif

/* screen buffer constants */

extern int SB_ROWS;
extern int SB_COLS;

/*
 * Windows defined in b_sbinit.c
 */

extern REGIONP wholewin;
extern REGIONP settingswin;
extern REGIONP historywin;
extern REGIONP holdwin;
extern REGIONP callwin;
extern REGIONP filewin;

/*
 * Prototypes
 */

void sb_box (REGIONP win, int type, int attr);
void sb_fill (REGIONP win, int ch, int attr);
void sb_fillc (REGIONP win, int ch);
void sb_filla (REGIONP win, int attr);
void sb_init (void);
void sb_move (REGIONP win, int r, int c);
REGIONP sb_new (int top, int left, int height, int width);
int sb_popup (int top, int left, int height, int width, int (*func)(SAVEP, int), int arg);
int sb_putc (REGIONP win, int ch);
void sb_puts (REGIONP win, unsigned char *s);
unsigned char sb_ra (REGIONP win, int r, int c);
unsigned char sb_rc (REGIONP win, int r, int c);
unsigned int sb_rca (REGIONP win, int r, int c);
int sb_input_chars (REGIONP win, int row, int col, char *str, int len, BOOLEAN upper);
#ifdef POPBUF
 char *pop_malloc (size_t s);
 void pop_free (char *s);
#else
 #define pop_malloc(s) malloc(s)
 #define pop_free(ad) free(ad);
#endif
SAVEP sb_save (int top, int left, int height, int width);
void sb_restore (SAVEP save);
void sb_scrl (REGIONP win, int n);
int sb_set_scrl (REGIONP win, int top, int left, int bottom, int right);
void sb_show (void);
void sb_clean (void);
void sb_dirty (void);
void sb_wa (REGIONP win, int attr, int n);
void sb_wc (REGIONP win, int ch, int n);
void sb_wca (REGIONP win, int ch, int attr, int n);


/*
 * These shouldn't really be here!  But the SAVEP's make it tricky
 */
 
int Overlay_Do_Get (SAVEP, int);
int Do_Get (SAVEP, int);
int Overlay_Do_Get (SAVEP, int);
int Do_Send (SAVEP, int);
int Overlay_Do_Send (SAVEP, int);
int Do_Kill (SAVEP, int);
int Overlay_Do_Kill (SAVEP, int);
int do_shell(SAVEP, int);
int Overlay_Do_Zoom (SAVEP, int);      /* ZOOMED        22.08.1990 */
int Do_Change (SAVEP p, int x);


#endif	/* H_SBUF */
