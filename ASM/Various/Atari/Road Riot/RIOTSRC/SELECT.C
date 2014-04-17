/*======================================================================*/
/*		TITLE:			SELECT				*/
/*		Function:		Selection screen and & related routines	*/
/*									*/
/*		First Edit:		04/12/91			*/
/*		Project #:						*/
/*		Programmer:		Dennis Harper			*/
/*					    Dave Akers				*/
/*									*/
/*		COPYRIGHT 1990/91 ATARI GAMES CORP.			*/
/*	  UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,		*/
/*	  PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR		*/
/*	THE ASSOCIATED AUDIOVISUAL WORK	IS STRICTLY PROHIBITED.		*/
/*	       		ALL RIGHTS RESERVED.				*/
/*									*/
/*----------------------------------------------------------------------*/

#ifdef ARIUM

#include	"prog/inc/rrdef.h"
#include	"prog/inc/comminc.h"
#include	"prog/inc/mobinc.h"
#include	"prog/inc/hrdwmap.h"
#include	"prog/inc/buttons.h"
#include	"prog/inc/message.h"
#include	"prog/inc/gcode.h"
#include	"prog/inc/plrcase.h"
#include	"prog/inc/audio.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"

#else

#include	"inc:rrdef.h"
#include	"inc:comminc.h"
#include	"inc:mobinc.h"
#include	"inc:hrdwmap.h"
#include	"inc:buttons.h"
#include	"inc:message.h"
#include	"inc:gcode.h"
#include	"inc:plrcase.h"
#include	"inc:audio.h"
#include	"inc:eeprom.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"

#endif

#define SMINTIME (2 * 32 )
#define SMAXTIME (11 * 32 )
#define MAXSEL  10
#define DIALX  15
#define DIALY  13

extern  BYTE    active[];		/* active systems */
extern  ulong	bckdsp;			/* Background routine dispatches */
extern  MOBLK   boxblk;
extern  BYTE	game;			/* TRUE if playing game		*/
extern  WORD	gcount;
extern  WORD	gstate;
extern  WORD    mcpno;			/* number of controlling player */
extern  WORD	nstate;
extern  MDTYPE  obj[];			/* objects */
extern  WORD    plyrno;			/* number for this player */
extern  MDTYPE	*pp;
extern  BYTE    ramp;
extern  PFI		setup;
extern  BYTE    solo;
extern  BYTE    wincnt;		/* number of consecutive wins */
extern  WORD	world;
extern  short   SEL000[];
extern  short   *dial_tbl[];
extern  short   *trophy_tbl[];
extern  WORD    hostpal[];
extern  BYTE    selector;
extern  BYTE    comp;
extern  BYTE    oselect();
extern  CTLPKT  *ptable[];

MT2 psmsg2	= { 14, 27, "SELECT  COURSE", 0 };
MT  psmsg1	= { 20, 26,      "TO", 2, &psmsg2 };
MT  psmsg	= { 15, 25, "PRESS START", 2, &psmsg1 };

MT2 psbmsg1	= { 20, 26, "BY", 0 };
MT  psbmsg	= { 15, 25, "PLEASE STAND", 2, &psbmsg1 };

#if 0
MT2 selmsg5	= { 34,  4, "TO DATE", 0 };
MT  selmsg4	= { 34,  2, "WINNINGS", 2, &selmsg5 };
MT  selmsg3	= { 12, 12, "WITH STEERING WHEEL", 2, &selmsg4 };
#endif

MT2 selmsg3	= { 12, 12, "WITH STEERING WHEEL", 0 };
MT  selmsg2	= { 12, 11, "TOURNAMENT CIRCUIT", 2, &selmsg3 };
MT  selmsg1	= { 20, 10,         "ON", 2, &selmsg2 };
MT  selmsg	= { 12,  9, "CHOOSE NEXT COURSE", 2, &selmsg1 };

MT2 swaitmsg3	= { 13, 12, "THE NEXT COURSE!", 0 };
MT  swaitmsg2	= { 15, 11,   "WILL CHOOSE", 2, &swaitmsg3 };
MT  swaitmsg1	= { 17, 10,     "PLAYER", 2, &swaitmsg2 };
MT  swaitmsg	= { 15,  9,   "THE OTHER", 2, &swaitmsg1 };

WORD curx[] = { 38, 38, 38, 38,
               102,166,230,294
               294,294,294 };

WORD cury[] = { 200,144, 88, 32,
                 32, 32, 32, 32,
                 88,144,200 };

WORD trophyx[] = { 1, 1, 1, 1,
                    9,17,25,33,
                   33,33,33 };

WORD trophyy[] = { 21,14, 7, 0,
                    0, 0, 0, 0,
                    7,14,21 }; 

BYTE wldtosel[] = 
             { 0,4,3,9,8, 1,2,7,0,10, 6,5,8 };


BYTE seltowld[] = 
             {  8,5,6,2,1, 11,10,7,4,3,9, };

BYTE wheel_delay[ 32 ] = 
           { 1,2,2,2, 3,3,4,5, 6,7,8,9, 9,9,9,9,
             9,9,9,9, 9,8,7,6, 5,4,3,2, 2,2,2,1, };
MDTYPE *cur_op;
BYTE  cur_pos;
WORD  cur_count;
BYTE  tcard0[ 12];		/* tournament card */
BYTE  tcard1[ 12];		/* tournament card */

BYTE *tctable[ 4 ] = { tcard0, tcard1, tcard0, tcard1 };


/* handle the select mode */
select()
  {
  CTLPKT *pptr;
  if ( gcount == 0 )	/* first time through */
    {
    if ( comp == FALSE)		/* this code is redundant */ 
       selector = plyrno;	/* but who cares */
    initmess();			/* clear alphas */
    kill_canim();
    set_colmobs();		/* load mob palettes */
	select_screen();	/* draw select screen */
    if ( selector == plyrno )
      {
       write( &selmsg, APLT1);
       write( &psmsg, APLT1);
      }
    else
      {
       write( &swaitmsg, APLT1);
       write( &psbmsg, APLT1);
      }
    init_cursor();		/* set up pointer object */
    display_credits();
    }

  move_cursor();
  pdec ( 20, 23, ((SMAXTIME+ 31) - gcount) >> 5,2,0, APLT3);

  if (  (gcount > SMAXTIME) || 			/* timed out */
       ((gcount > SMINTIME) &&
        ((plyrno != selector) || start_check() ) ) )
    {
    pptr = ptable[ selector ]; 	/* point to packet from selector system */
     if ( plyrno == selector ) 	/* if we are the master here */
         gstate = G_TITLE;		/* change our state */
      else
        {
         if ( pptr->pgstate != gstate ) 	/* if selector system is in a new state */ 
         {
         gstate = G_TITLE;		/* change our state to catch up */
         cur_pos = pptr->pgsel & 0x1f;	/* read cursor position one more time */
         }
       }
    if ( gstate == G_TITLE )
        {
    	gcount = 0;
        world = seltowld[ cur_pos ];
        if ( cur_op )
           delobj( cur_op );
        }
    }
  else
    {
    gcount++ ;
    }
  putcomm();			/* tell the world we're selecting */
  }

/* draw the select screen */
select_screen()
   {
   int i;
   BYTE *tptr;

   com_wrt(S_FHAPIMUS);				/* Fade music if on	*/
   tptr = tctable[ plyrno ];
   clrplf(1);
   write_pfpal( hostpal, 0 );
   plf_anim( SEL000,0,0,0 );
   for ( i = 0 ; i <= MAXSEL  ;i++ )
        {
        if ( tptr[ i ] )
           plf_anim( trophy_tbl[ tptr[ i ] - 1 ],
                     trophyx[ i ],
                     trophyy[ i ], 0 );
        }

   com_wrt(S_SELMUS);				/* Start music 		*/
   }

/* find the first selectable track and place the cursor there */
init_cursor()
   {
   BYTE *tptr;
   BYTE *tptr2;
   tptr = tctable[ plyrno ];
   if ( comp )
   		tptr2 = tctable[ plyrno ^ 1 ];
   else
   		tptr2 = tctable[ plyrno ];

   if ( selector == plyrno )
      {
      cur_pos = wldtosel[world];
      while ( tptr[cur_pos] || tptr2[cur_pos] )
         {
         cur_pos++;
         if ( cur_pos > MAXSEL )
            {
            cur_pos = MAXSEL;
      	     while ( tptr[cur_pos] || tptr2[cur_pos] )
               {
               cur_pos-- ;
               if ( cur_pos < 0 )
                  trap();
               }
            }
         }
      }
   else
      cur_pos = oselect(); 	/* get cursor from common ram */
   cur_count = 0;
   cur_op = &obj[setobj(&boxblk,curx[cur_pos]<< 6,cury[cur_pos]<< 6,100,1,0)];
   plf_anim( dial_tbl[cur_pos],DIALX,DIALY,0 );
   }

/* read the wheel and move the cursor */
/* redraw the dial pointer to match the cursor position */
move_cursor()
  {
  BYTE *tptr;
  BYTE *tptr2;
  int i;
  BYTE old_pos;
  old_pos = cur_pos;
  tptr = tctable[ plyrno ];
   if ( comp )
   		tptr2 = tctable[ plyrno ^ 1 ];
   else
   		tptr2 = tctable[ plyrno ];
  if ( selector == plyrno )
        {
        if ( cur_count == 0 )		/* time to move */
          { 
          if ( WHEEL > 0x24 )
             {
             if ( cur_pos > 0 )
                {
                i = cur_pos - 1;
                /* search for an unraced race */
      		    while ( tptr[i] || tptr2[i] )
                  {
                  if ( i == 0 ) break;
                  else i-- ;
                  }
                if ( (tptr[i] || tptr2[i]) == 0 )		/* found one */
                   cur_pos = i; 
                }
             }
          else
          if ( WHEEL < 0x1C )
             {
             if ( cur_pos < MAXSEL )
                {
                i = cur_pos + 1;
                /* search for an unraced race */
      		    while ( tptr[i] || tptr2[i] )
                  {
                  if ( i == MAXSEL ) break;
                  else i++ ;
                  }
                if ( (tptr[i] || tptr2[i]) == 0 )		/* found one */
                   cur_pos = i; 
                }
             }
          }
        else
          cur_count-- ;
       }
    else   	/* not ours to move */
       cur_pos = oselect();
    if ( cur_pos != old_pos )
       {
       com_wrt( S_RAPSNRE );
       cur_op->xpos = curx[cur_pos] << 6;
       cur_op->ypos = cury[cur_pos] << 6;
       cur_op->flags |= MO_NEW;
       cur_count = wheel_delay[ WHEEL >> 1 ];
   	   plf_anim( dial_tbl[cur_pos],DIALX,DIALY,0 );
       }
  }

/* clear the tournament card */
clrtcard( num )
BYTE num;
  {
  BYTE *tptr;
  int i;
  tptr = tctable[ num ];
  for ( i = 0 ; i <= MAXSEL ; i++ )
      tptr[ i ] = 0;
      
  }

/* set the status for this race on the tournament card */
settcard( world, rank )
BYTE world, rank;
  {
  BYTE  i;
  BYTE *tptr;
  if ( world )
     {
     tptr = tctable[ plyrno ];
     i = wldtosel[ world ];
     tptr[ i ] = rank;
     }
  }

/* have we completed all the races? */
allraced()
  {
  BYTE *tptr;
  int i;
  tptr = tctable[ plyrno ];
  for ( i = 0 ; i <= MAXSEL ; i++ )
      {
      if ( tptr[ i ] == 0)
         return( 0 );
      }
   return( 1 );
   }
