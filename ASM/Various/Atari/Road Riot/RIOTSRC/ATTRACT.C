/*======================================================================*/
/*		TITLE:			ATTRACT				*/
/*		Function:		Attract code and & related routines	*/
/*									*/
/*		First Edit:		03/07/91			*/
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
#include	"prog/inc/mobinc.h"
#include	"prog/inc/hrdwmap.h"
#include	"prog/inc/message.h"
#include	"prog/inc/gcode.h"
#include	"prog/inc/plrcase.h"
#include	"prog/inc/audio.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:hrdwmap.h"
#include	"inc:message.h"
#include	"inc:gcode.h"
#include	"inc:plrcase.h"
#include	"inc:audio.h"
#include	"inc:eeprom.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"

#endif


#define DEMOTIME 25

#define DO_MUSIC 0x0008

typedef	struct	scnlin
	  {
	  short	lineh;			/* Hscroll values for each line	*/
	  short	linev;			/* Vscroll values for each line	*/
	  short	lcurve;			/* Curve offset for each line (holding buffer)	*/
	  } SCNLIN;

extern 	SCNLIN	scan_data[SCANLINES];	/* Scan line frame buffer 0	*/
extern  SCNLIN	*scan_ptr;		/* Pointers for above		*/
extern  short   horizon_line;
extern  PFSCRL  *horizon_ptr;
extern  BYTE    pf_scroll;
extern  PFSCRL  *get_scroll();
/* end of copied lines */

extern  BYTE	acc_case;		/* Viewpoint acceleration mode	*/
extern  BYTE    active[];		/* active systems */
extern  ulong	bckdsp;			/* Background routine dispatches */
extern  ulong	frgdsp;			/* Foreground routine dispatches */
extern  MT2		gomsg;
extern  BYTE    etimer;			/* timer for erasing messages */
extern  BYTE	game;			/* TRUE if playing game		*/
extern  WORD	gcount;
extern  WORD	gstate;
extern  WORD    mcpno;			/* number of controlling player */
extern  WORD	nstate;
extern  char    pausetmr;
extern	CARBLK	*plrcar;
extern  BYTE	plr_case;
extern  WORD	plr_flag;
extern  char    plr_lap;			/* laps completed */
extern  WORD    plyrno;			/* number for this player */
extern  MDTYPE	*pp;
extern  BYTE    ramp;
extern  BYTE    solo;
extern  PFI	setup;
extern  BYTE	start_ok;		/* TRUE if ok to start game	*/
extern  long	viewx,viewy;		/* View point			*/
extern	short	viewx_spd;
extern	short	viewy_spd;
extern	short	viewz_spd;
extern  WORD	world;
extern  BYTE	xlock;			/* Window xlock case 		*/
extern  long    credits;
extern  BYTE    decline;
extern  BYTE    wincnt;		/* number of consecutive wins */
extern	BYTE	kskid_snd;
extern	MOBLK	redblk,blueblk;
extern  BYTE    linkwrks;
extern  WORD    oalive;
extern  WORD    game_opt;

		WORD    atstate;		/* attract state */
        char    aframe;			/* attract counter */
        BYTE    scancase;		/* scan line effect number */
        WORD    scancnt;		/* scan line effect count */
        WORD    insync;			/* true if attracts are in sync */


static	MT2	ttlmsg11 = { 24, 25, "Team Director", 0 };
static	MT	ttlmsg10 = { 24, 24, "NU/OMEGA", 2, &ttlmsg11 };
static	MT	ttlmsg9  = { 01, 24, "Hardware Supervisor", 2, &ttlmsg10 };
static	MT	ttlmsg8  = { 24, 21, "Marketing Manager", 2, &ttlmsg9 };
static	MT	ttlmsg7  = { 01, 21, "Video Imaging", 2, &ttlmsg8 };
static	MT	ttlmsg6  = { 24, 18, "Animation", 2, &ttlmsg7 };
static	MT	ttlmsg5  = { 01, 18, "Expert Technician", 2, &ttlmsg6 };
static	MT	ttlmsg4  = { 24, 15, "Music and Audio", 2, &ttlmsg5 };
static	MT	ttlmsg3  = { 01, 15, "Controls", 2, &ttlmsg4 };
static	MT	ttlmsg2  = { 11, 12, "Hardware Engineer", 2, &ttlmsg3 };
static	MT	ttlmsg1  = { 04, 09, "Software Design and Implementation", 2, &ttlmsg2 };
static	MT	ttlmsg   = { 01, 06, "Project Leader, Game Designer, Graphics", 2, &ttlmsg1 };

static	MT2	namemsg10 = { 24, 23, "JOHN RAY", 0 };
static	MT	namemsg9 = { 01, 23, "PAT McCARTHY", 2, &namemsg10 };
static	MT	namemsg8 = { 24, 20, "LINDA BENZLER", 2, &namemsg9 };
static	MT	namemsg7 = { 01, 20, "ROB ROWE", 2, &namemsg8 };
static	MT	namemsg6 = { 24, 17, "SEAN MURPHY", 2, &namemsg7 };
static	MT	namemsg5 = { 01, 17, "FARROKH KHODADADI", 2, &namemsg6 };
static	MT	namemsg4 = { 24, 14, "DON DIEKNEITE", 2, &namemsg5 };
static	MT	namemsg3 = { 01, 14, "MILT LOPER", 2, &namemsg4 };
static	MT	namemsg2 = { 16, 11, "SAM LEE", 2, &namemsg3 };
static	MT	namemsg1 = { 05, 08, "DENNIS HARPER and DAVID S. AKERS", 2, &namemsg2 };
static	MT	namemsg  = { 11, 05, "MARK STEPHEN PIERCE", 2, &namemsg1 };

static	MT	catsmsg  = { 05, 28, "(THOSE CATS ARE DRIVIN' FAST...)", 0 };
static	MT	sqdmsg   = { 11, 01, "RIOT SQUAD", 0 };

static	MT2 	strt1msg = {10,13,"PRESS START", 0 };
static	MT2 	coin1msg = {12,13,"ADD COINS TO START", 0 };

static	MT2 	strt2msg = {11,27,"PRESS START", 0 };
static	MT2 	coin2msg = {13,27,"ADD COINS TO START", 0 };

static	MT2 	strt3msg = {19,25,"PRESS START", 0 };
static	MT2 	coin3msg = {21,25,"ADD COINS TO START", 0 };

	MT	*start_msgs[]={0,&strt1msg,&strt1msg,&strt1msg,&strt1msg,0,&strt2msg,&strt3msg, 0, 0, 0};
	MT	*coin_msgs[]={0,&coin1msg,&coin1msg,&coin1msg,&coin1msg,0,&coin2msg,&coin3msg, 0,  0, 0};


/* handle the attract mode */
attract()
  {
  MT	*mptr;

  if (credits >= (0x01 << 16))				/* If we have credits		*/
    {
    mptr = start_msgs[atstate];				/* Get start message		*/

    if (mptr)						/* If we have one...		*/
      msg_blink(mptr,APLT3,0x0F,1);			/* Blink it			*/
    else
      blink_lamp(0x0F);					/* Just Blink lamp		*/
							/* If game is starting, and	*/
    if ((start_check()) && (atstate != A_EXIT))      	/* The demo running 		*/
      {
      atstate = A_EXIT;					/* if so, let it clean itself up */
      gcount = 0;
      }
    }
  else
    {
    mptr = coin_msgs[atstate];				/* Get start message		*/

    if (mptr)						/* If we have one...		*/
      write(mptr,APLT3);				/* Write message		*/
    else
      lamp(0);						/* Turn off lamp		*/

    }

    /* see if other system wants to test Ram */
    if ((ocram() && 
        (atstate != A_TESTRAM) &&
        (atstate != A_GETSYNC) &&
        (atstate != A_EXIT) ))      	
       {
       atstate = A_TESTRAM;					/* if so, let it clean itself up */
       gcount = 0;
       }
  else 
   if ( linkwrks && osync() &&
        (atstate != A_TESTRAM) &&
        (atstate != A_GETSYNC) &&
        (atstate != A_EXIT) )      	
       {
       atstate = A_GETSYNC;					/* if so, let it clean itself up */
       gcount = 0;
       }

  if ( atstate != A_EXIT )
     midpots();						/* auto center the steering wheel */

  switch( atstate)
    {
    case A_TITLE:
        atitle();
       break;
    case A_COUNT:
       acount();
        break;
    case A_PLAY:
        aplay();
        break;
    case A_GETSYNC:
    case A_TESTRAM:
	case A_EXIT:
    case A_QUIT:
      aquit();
     break;

    case A_CREDS:
      acreds();
      break;

    case A_LOGO:
      alogo();
      break;

    case A_HISCORE:
      ahiscore();
      break;
   }
}


/*	Credits 				*/
cred_screen()
{
        clrplf(0);				/* Clear screen			*/
	initmess();
        PF_COLOR0 = 0x000F;			/* Dark Green			*/

	bwrite(&sqdmsg,APLT2);			/* Riot squad			*/
	write(&namemsg,APLT3);			/* Write names			*/
	write(&ttlmsg,APLT0);
	write(&catsmsg,APLT2);
	start_rotate(ALF_BASE,0,2,4,11);	/* Start color rotate		*/
}
	
	
/* put up the title screen and its animations */
atitle()
   {
   int offset;
   offset = ( plyrno) ? 0 : 6 ;
   if ( gcount == 0 )
      {
	   initmess();
	   update_coins();
       kill_canim();
       set_colmobs();
 	   ttl_test();
       putcomm();
       vcr_stop();		/* make sure we don't record attract */
       init_scansfx( 1 + scancase);
       if ( (aframe & 0x0f) == 0 )
          {
          aframe = ( aframe ^ 0x10) + 5;
       	  if ( (game_opt & DO_MUSIC) && 
               ( ( linkwrks == 0 ) ||
                 (insync && 
                 (ocheck() == G_ATTRACT) ) ) )
              {
              if ( aframe & 0xf0 )
          	  	  com_wrt( S_RRATR );
              else
          	  	  com_wrt( S_HAPIMUS );
              }
          }
       else
          aframe-- ;
      }

   if ( gcount == (56 + offset ) )
	  setobj(&redblk,64,(195 << 6 ),0xf8,0,0);
   if ( gcount == ((5 * 32 ) + offset ) )
	  setobj(&blueblk,64,(195 << 6 ),0xf8,0,0);
   if ( gcount == (((5 * 32 ) - 20 ) + offset ) )
         set_ttlmud();
   if ( gcount > ( 10 * 32 ) )
      {
      game = TRUE;
      eer_play(0);
	  plyrno = PLRID; 			/* Assign player number		*/
      mcpno = plyrno;
      world = random( 5 ) + 1;
      initcomm();					/* init communications */
      set_world( world);
      plr_flag &= ~PLR_START;
      plr_lap = 0;
      solo = 0;
      start_drones();				/* start up drone cars */
      pausetmr = 6;			/* 3 seconds */
	  gstate = G_FWAIT1;		/* Wait for fadeup	*/
	  atstate = A_COUNT;		/* Wait for fadeup	*/
	  nstate = G_ATTRACT;
	  gcount = 0;					/* zero count */
      ramp = 8;
   	  setup = &start_pfrot();		/* Post setup		*/
      display_credits();
      }
   else
      {
      gcount++;
      scansfx();
      }
   }

/* put up the credit screen */
acreds()
   {
      if (gcount++ == 0)
        cred_screen();
      else
	{
        if (gcount >= (8 * 30))			/* If 8 seconds				*/
	  {
	  gcount = 0;
          atstate = A_LOGO;
	  }
	}
   }

/* display the distinctive atari logo */
alogo()
   {
   if (gcount++ == 0)
	 {
     clrplf(0);				/* Draw the logo			*/
	  kill_canim();				/* Kill color anim			*/
      PF_COLOR0 = 0;				/* Black				*/
      draw_logo();
      display_credits();
#if 0
      frgdsp |= F_FIRE;		/* test fireworks *REMOVE* */
#endif
	  }
   else
	  {
      if (gcount >= (4 * 30))			/* If 6 seconds				*/
	     {
	     gcount = 0;
         atstate = A_HISCORE;
	     }
	   }
   }

/* put up high score screen for attract */
ahiscore()
  {
  if (gcount++ == 0)
	{
	initmess();				/* Clear screen	*/
        disp_hiscore();				/* Display high score table	*/
        display_credits();
        putcomm();
	}
  else
	{
        if (gcount >= (8 * 30))			/* If 8 seconds				*/
	  {
	  gcount = 0;
	  atstate = A_TITLE;			/* Display title screen			*/
      /* if the other system seeems to be alive but the link is broken */
      if ( oalive && ( linkwrks == 0 ))
         gstate = G_CRAMTST;
      else
      if ( oalive && (( insync == 0 ) ||
       ( aframe == 0 ) ) )
         gstate = G_GETSYNC;
	  }
	}
  }

/* countdown the demo race */
acount()
  {
  if ( gcount == 0 ) /* first time */
     {
     bwrite( &gomsg, APLT1 );
     etimer = 32;						/* in a second */
     bckdsp |= B_EGO;					/* Erase go	*/
     acc_case = 0;
     xlock = 2;					/* lock on drone player */
     viewx = pp->xpos;
     start_ok = FALSE;			/* pedal up and down to exit */
     active[ 0 ] = active[1] = active[2] = active[3] = 0;
     active[ plyrno ] = 1;
     }
  gcount++ ;
  if ( gcount > 32 ) 
     {
     atstate = A_PLAY;
     gcount = 0;
     }
  }

/* pretend to play the game */
aplay()
   {
   if ( gcount > (DEMOTIME * 32) ) 
      {
      atstate = A_QUIT;
      gcount = 0;
      viewx_spd = 0;
	  viewy_spd = 0;
	  viewz_spd = 0;
      }
   else
	  {
      com_wrt(S_SOFF);
      plr_flag |= PLR_START;
      do_drone();				/* Move drones if we are in control	*/
      if ( gcount > ((DEMOTIME - 4) * 32 ) )
          acc_case = 2;			/* slow down camera */
      else if (plrcar->car_case == CC_DRIVE)		/* reset acc_case after xplo */
      	acc_case = 0;				/* Normal scrolling	*/
      speedo();					/* Do speedometer	*/
      rear_view();				/* Do rear view mirror	*/
      my_lasers();				/* Move existing lasers		*/
      view_window();				/* Window movement	*/
      move_view();				/* Move the viewpoint	*/
      plot_drone();				/* Plot new drone positions	*/
      mo_coll();				/* Motion object collision */
      move_dots();				/* Move map dots	*/
      gcount++;
	  }
   }

/* exit from attract mode */
aquit()
   {
   if ( gcount == 0 )
	  {
	  game = FALSE;				/* Turn on game state	*/
	  plr_flag &= ~PLR_START;			/* stop the cars */
	  plr_case = P_START;
	  if ( plrcar )
			{
	    	plrcar->car_spd = 0;
	    	plrcar->car_xspd = 0;
	    	plrcar->car_yspd = 0;
			}
	  stop_drones();
	  com_wrt(kskid_snd);			/* Kill the skid sound	*/
      bckdsp &= ~B_TTLMUD;		/* turn off the mud */
	  }
  gcount++ ;
  move_view();				/* Move the viewpoint	*/
  viewx_spd = 0;
  viewy_spd = 0;
  viewz_spd = 0;
  if ( gcount > 8 )
	 {
	 kill_canim();
	 clr_all();					/* get rid of mobs */
	 initmess();
	 active[ 0 ] = active[1] = active[2] = active[3] = 0;
	 com_wrt(S_SON);
	 world = 0;
	 gcount = 0;
 	 ramp = 4;						/* start at middle difficulty */
     if ( aframe & 0xf0 )
      	  com_wrt( S_FRRATR );
     else
      	  com_wrt( S_FHAPIMUS );
	 if ( atstate == A_QUIT )
		{
	    gstate = G_ATTRACT;
	    atstate = A_CREDS;				/* Display credits		*/
		}
	 else		/* A_EXIT */
	    if ( atstate == A_EXIT )
		   {
           if ( new_debit() == 0 )			/* we should have credit */
               trap();
	        start_fadeoff(PF0_BASE,0,2);		/* Fade screen				*/
	        gstate = G_FWAIT1;			/* Wait for fade			*/
   	        nstate = G_CHOOSE;
	        setup = &new_game();				/* Setup routine NEWG			*/
            insync = 0;					/* attracts are out of sync */
			}
        else		/* A_TESTRAM */
	      if ( atstate == A_TESTRAM )
            {
	        gstate = G_CRAMTST;			/* Go test ram 	*/
            atstate = A_TITLE;
            }
        else		/* A_GETSYNC */
            {
	        gstate = G_GETSYNC;			/* Go test ram 	*/
            atstate = A_TITLE;
            clrplf(0);
            }
     }
   }

#define VPIXEL 0x0040
#define HPIXEL 0x0020
#define LINECNT 120
#define SOMELINES (SCANLINES - 28 )
#define SLANT 42 
#define DELAY ( 2 * 32 )
#define TITLEBANK 1

#define SC_LEAN    1
#define SC_MERGE   2
#define SC_RTSLIDE 3
#define SC_SLIDE   4
#define SC_RANDOM  5
#define SC_HEAT    6
#define SC_SPIN    7


init_scansfx( caseno)
BYTE caseno;
  {
  int h,v,i;
  SCNLIN *scptr;
  short step;

  pf_scroll = FALSE;
  horizon_line = 0;
  horizon_ptr = get_scroll( horizon_line );
  scancase = caseno;		/* select scan case */
  if ( scancase > SC_RANDOM )
     scancase = SC_LEAN;
  scancnt = 0;
  switch( scancase)
     {
     case SC_MERGE:		/* two images converge into one */
        {
        v = TITLEBANK;
        h = 0;
        scptr = scan_data;
        for( i = 0 ; i < SCANLINES ; i++ )
          {
           scptr->linev = v;
           if ( i < SOMELINES )
             {
             if ( ( i & 0x01) )
           	    scptr->lineh = ( 160 * HPIXEL );
             else
           	    scptr->lineh = -( 160 * HPIXEL );
             }
           else
               scptr->lineh = 0;
           v += VPIXEL;
          scptr++ ;
          }
        break;
        }
     case SC_RTSLIDE:		/* random lines converge from right */
     case SC_SLIDE:        /* random lines converge from sides */
     case SC_RANDOM:		/* random noise */
     case SC_HEAT:		/* waves */
        {
        v = TITLEBANK;
        h = 0;
        scptr = scan_data;
        for( i = 0 ; i < SCANLINES ; i++ )
          {
          scptr->linev = v;
          if ( i < SOMELINES )
             {
             if ( scancase == SC_RTSLIDE )
          	     h = random( 330 ) * HPIXEL; 
             else
             if ( scancase == SC_HEAT )
          	     h += ( 1 - random( 2 )) * HPIXEL; 
             else
                 h = ( 330 - random( 660 )) * HPIXEL;
             }
          else
             h = 0;
          scptr->lineh = h;
          v += VPIXEL;
          scptr++ ;
          }
        break;
        }
     case SC_LEAN:	/* straight up letters lean over */
        {
        h =  ( SLANT * HPIXEL) << 8;
        step = h  / ( short )LINECNT; 
        v = TITLEBANK;
        scptr = scan_data;
        for( i = 0 ; i < SCANLINES ; i++ )
          {
           scptr->linev = v;
			   scptr->lineh = ( h >> 8 ) & 0xffe0;
           h -= step;
           if ( h < 0 )
             h = 0;
           v += VPIXEL;
          scptr++ ;
          }
        }
     }
  dump_scroll();
  }

char stab[] = { 0, 1, 2, 3, 4, 5, 6, 7,
                8, 8, 8, 7, 7, 6, 5, 6 };
/* move scan lines for special effects */
scansfx()
  {
  int h,v;
  WORD i;
  short step;
  SCNLIN *scptr;
  if ( scancnt > ( 5 * 32 ) )
    {
    v = TITLEBANK;
    h = 0;
    scptr = scan_data;
    for( i = 0 ; i < SCANLINES ; i++ )
       {
       scptr->lineh = h;
       scptr->linev = v;
       v += VPIXEL;
       scptr++ ;
       }
    }
  else
    {
     switch( scancase)
      {
      case SC_SLIDE:
      case SC_RTSLIDE:
      case SC_MERGE:
        {
        scptr = scan_data;
        for( i = 0 ; i < SCANLINES ; i++ )
           {
           if ( scptr->lineh < -0x40  ) 
              { 
              scptr->lineh += 0x80;
              }
           else if ( scptr->lineh > 0x40 ) 
              { 
              scptr->lineh -= 0x80;
              }
           else
             scptr->lineh = 0;
           scptr++ ;
           }
        break;
        }
      case SC_LEAN:
        {
        if ( scancnt >= DELAY )
           {
           scptr = scan_data;
           h =  (( SLANT * HPIXEL) - ( stab[ scancnt - DELAY ] << 8 )) << 8;
    	   v = TITLEBANK;
           step = h  / ( short )LINECNT; 
           for( i = 0 ; i < LINECNT ; i++ )
             {
             if ( scancnt < ( DELAY + 15 ) )
                scptr->lineh = ( h >> 8 ) & 0xffe0;
             else
                scptr->lineh = 0;
             h = h - step;
             scptr->linev = v;
             v += VPIXEL;
             scptr++ ;
             }
          }
          scptr = scan_data;
          v = TITLEBANK;
          for( i = 0 ; i < SCANLINES ; i++ )
             {
             if ( i > LINECNT )
             	scptr->lineh = 0;
             scptr->linev = v;
             v += VPIXEL;
             scptr++ ;
             }
        break;
        }
     case SC_RANDOM:
     case SC_HEAT:
        {
    	v = TITLEBANK;
        h = 0;
        scptr = scan_data;
        step = 192 - ( scancnt << 1 );
        if ( step < 0 ) step = 0;
        for( i = 0 ; i < SOMELINES ; i++ )
          {
          scptr->linev = v;
         if ( scancase == SC_RANDOM )
             {
             if ( ( scancnt & 0x03) == 0x01 )
          	 	scptr->lineh = ( step  - random( step << 1 )) * HPIXEL;
             }
          else 
             {
             step  = scptr->lineh;
             if ( scancnt  < 140 )
               {
               if ( i == 0 )
          	    	h = step  + ( 1 - random( 2 )) * HPIXEL; 
               scptr->lineh = h;
               h = step;
               }
             else 
               if ( scptr->lineh < -0x40  ) 
                  scptr->lineh += 0x40;
               else if ( scptr->lineh > 0x40 ) 
                  scptr->lineh -= 0x40;
               else
                  scptr->lineh = 0;
             }
          v += VPIXEL;
          scptr++ ;
          }
        for( i = SOMELINES; i < SCANLINES ; i++ )
          {
          scptr->lineh = 0;
          scptr++ ;
          }
        break;
        }
      case SC_SPIN:
        {
        v = TITLEBANK;
        h = 0;
        scptr = scan_data;
        for( i = 0 ; i < SCANLINES ; i++ )
          {
           scptr->linev = v;;
           if ( scancnt < 32 )
               step = 0;
           else
               step = ( (scancnt - 32 ) >> 4 ) * 20;
           if ( ( i < SOMELINES ) &&
                ( i > step ) )
             {
           	    scptr->lineh = -( (scancnt & 0x0f) 
                                * HPIXEL * 32 );
             }
           else
               scptr->lineh = 0;
           v += VPIXEL;
          scptr++ ;
          }
        break;
        }
      }
    scancnt++ ;
    }
    dump_scroll();
  }
