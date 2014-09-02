/*======================================================================*/
/*		TITLE:			ANNOUNCER			*/
/*		Function:		Track Announcer routines	*/
/*									*/
/*		First Edit:		05/07/91			*/
/*		Project #:		532xx				*/
/*		Programmer:		Dennis Harper			*/
/*									*/
/*		COPYRIGHT 1990/1991 ATARI GAMES CORP.			*/
/*	  UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,		*/
/*	  PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR		*/
/*	THE ASSOCIATED AUDIOVISUAL WORK	IS STRICTLY PROHIBITED.		*/
/*	       		ALL RIGHTS RESERVED.				*/
/*									*/
/*----------------------------------------------------------------------*/

#ifdef ARIUM

#include	"prog/inc/rrdef.h"
#include	"prog/inc/mobinc.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"
#include	"prog/inc/drninc.h"
#include	"prog/inc/audio.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:drninc.h"
#include	"inc:audio.h"

#endif

#define	FIRST_ANC	S_LOOKOUT
#define	LAST_ANC	S_BLUFALLS
#define	MAX_ANC		((LAST_ANC - FIRST_ANC) + 1)

extern	LIST_HEAD car_list;
extern	DRNBLK  *drone_last;
extern	CARBLK	*plrcar;
extern	long	world_len;
extern	long	p0_yabs,p1_yabs;
extern	ulong	frgdsp;
extern	WORD	frame;
extern	WORD	gcount;
extern	short	plyrno;
extern	BYTE	rankpal[];
extern	BYTE	comp;
extern	char 	plr_rank;

	short	anc_delay,anc_active;		/* Announce timers		*/
	BYTE	anc_snd;
	BYTE	anc_flag;
	BYTE	fin_tmr;			/* Finish timer			*/
	BYTE	fin_case;			/* Finish case			*/
	BYTE	fin_good;			/* Good finish flag		*/
	BYTE	left_behind;
	char	last_rank;

struct	anc_freq				/* Announcment frequency table	*/
	{
	BYTE	race;				/* Once per race flag		*/
	BYTE	lap;				/* Once per lap flag		*/
	} anc_tbl[MAX_ANC];
			     
	BYTE	hostnames[]={0,S_HOSTLUKE,S_HOSTSHEIK,S_HOSTBEN,
			     S_HOSTNASTY,S_HOSTELVIS,S_HOSTAUNT,S_HOSTBAJA,
			     S_HOSTCHA,S_HOSTKARL,S_HOSTHELGA,S_HOSTIDI,
			     0,0,0,0};

/*	Say host name			*/
say_host(wld)
WORD	wld;
{
	BYTE	name;

	name = hostnames[wld];

	if (name)
	  com_wrt(hostnames[wld]);
}



/*	Do announcements				*/
announce(snd,flags,delay)
BYTE	snd;
BYTE	flags;
short	delay;
{
#define	ANC_DELAY	( 5  * 30 )

	int	i;

	if (delay)					/* If delay request			*/
	  {
	  anc_snd = snd;				/* Save the sound			*/
	  anc_flag = flags;
	  anc_delay = delay;				/* Set delay timer			*/
	  frgdsp |= F_ANCDELAY;				/* Enable routine			*/
	  }
	else
	  {
	  if (anc_active == 0)				/* If NOT saying a comment		*/
	    {
	    i = snd - FIRST_ANC;			/* Get table index			*/
							/* Do race/lap filtering		*/
	    if (((flags & PER_RACE) && (anc_tbl[i].race == TRUE)) ||
	       ((flags & PER_LAP) && (anc_tbl[i].lap == TRUE)))
	      return;					/* Already said this			*/

	    com_wrt(snd);				/* Say it				*/
	    anc_tbl[i].race = TRUE;			/* Flag we said this one		*/
	    anc_tbl[i].lap = TRUE;

	    anc_active = ANC_DELAY;			/* Set next delay			*/
	    frgdsp |= F_DECANC;				/* Decrement timer			*/
	    }
	  }
}


/*	Decrement announce active timer			*/
dec_anc()
{
	if (anc_active > 0)				/* Decrement delay timer		*/
	  anc_active--;
	else
	  frgdsp &= ~F_DECANC;
}



/*	Delayed annoucement				*/
say_delay()
{
	if (anc_delay-- <= 0)				/* If delay timer out			*/
	  {
	  announce(anc_snd, anc_flag, 0);		/* Say comment				*/
	  frgdsp &= ~F_ANCDELAY;			/* Disable dispatch			*/
	  }
}



/*	Init commentary						*/
init_comments()
{
	int	i;

	anc_delay = 0;
	anc_active = 0;
	left_behind = FALSE;

	for (i=0; i < MAX_ANC; i++)				/* Clear announcment table		*/
	  anc_tbl[i].race = anc_tbl[i].lap = 0;
}


/*	Clear announce table at lap				*/
lap_clr()
{
	int	i;

	for (i=0; i < MAX_ANC; i++)				/* Clear announcment table		*/
	  anc_tbl[i].lap = 0;
}

    

/*	Announcer commentary scan				*/
comments()
{
	int	mess,offrd,fast;
	DRNBLK *drptr;
	CARBLK	*carptr;

	mess = 0;
	offrd = 0;
	fast = 0;
								/* Loop through all cars			*/
	for (carptr = (CARBLK *)car_list.next; carptr != &car_list; carptr = (CARBLK *)carptr->carlnk.next)
	  {
	  if ((carptr->op->satime) && (carptr->op->flags & MO_SCRN))	/* If in animation mode				*/
	    ++mess;							/* Count 'em					*/

	  if (carptr->car_flag & ON_DIRT)				/* If off road				*/
	    ++offrd;

	  if (carptr->car_yspd > 0x280)					/* If fast...				*/
	    ++fast;

	  if (carptr->car_flag & PLR_CAR)			/* If this is the player			*/
	    {
	    if ((carptr->op->zpos - carptr->car_ztrg) > 0x400)	/* If BIG AIR					*/
	      announce( random(1) ? S_WOW : S_ALLRIGHT, 0, 0 );

	    if (plr_rank == 1)

	    if ((frame & 0x1F) == 0)					/* Every 16 frames				*/
	      {
	      drptr = drone_last;					/* Get 4th place	*/
	      drptr = drptr->drn_next;					/* Get 3rd place	*/
	      drptr = drptr->drn_next;					/* Get 2nd place	*/
	      drptr = drptr->drn_next;					/* Get 1st place	*/

	      if (left_behind)						/* If I've been left behind			*/
	        {
	        if ((drptr->drn_yabs - p0_yabs) < (world_len >> 3))	/* If 1/8 track behind 1st			*/
		  {
		  announce( plyrno ? S_BLUGAIN : S_REDGAIN, 0, 0 );	/* We're gaining			*/
		  left_behind = FALSE;
		  }
	        }
	      else
		{
	        if ((plr_rank == 4) &&					/* If 4th place and,			*/
	           ((drptr->drn_yabs - p0_yabs) > (world_len >> 2)))	/* 1/4 track behind 1st			*/
		  left_behind = TRUE;
		}

	      if (last_rank == 1)
		{
		if (plr_rank == 4)					/* If 1st to 4th			*/
		  announce( plyrno ? S_BLUFALLS : S_REDFALLS, PER_RACE, 0 );

		if ((comp) && (plr_rank != 1) &&			/* If was 1st 				*/
		   (plrcar->car_yspd < 0x40) && (p1_yabs > p0_yabs))	/* And other player is passed me	*/
		  announce( plyrno ? S_REDRORSBY : S_BLURORSBY, 0, 0 );
		}

	      last_rank = plr_rank;				/* Save last rank				*/
	      }
	    }
	  }

	if ((plr_rank == 1) && (fast == 4))			/* If all cars are fast				*/
	  announce( S_FASTCAT, PER_RACE, 0 );

	if (mess >= 3)						/* If three cars in trouble			*/
	  announce( random(1) ? S_WATAMES : S_OOOW, 0, 0 );

	if (offrd >= 3)						/* If three cars off road			*/
	  announce( S_CATOFF, PER_RACE, 0 );
}



/*	Init finish line announcements			*/
init_fin()
{
	DRNBLK *drptr;
	long	yabs;

	fin_case = 0;
	fin_tmr = 0;
	fin_good = FALSE;
	yabs = 0;

	if ((drone_last) == 0)					/* If in single car mode	*/
	  return;

	if (plr_rank == 1) 					/* If I'm first		*/
	  yabs = p0_yabs;					/* Get abs y position	*/
	else
	  {
	  if ((comp) && (rankpal[0] != 0x40))			/* If competition and real player won	*/
	    yabs = p1_yabs;
	  }

	if (yabs)						/* If a real player won	*/
	  {							/* Loop through drones	*/
	  for (drptr = drone_last; drptr != drptr->drn_next; drptr = drptr->drn_next)
	    {
	    if ((yabs - drptr->drn_yabs) < (STRIP_SIZE * 2))	/* If within a strip...	*/
	      fin_good = TRUE;					/* Good finish		*/
	    }
	  }

}



/*	Finish line announcement			*/
say_finish()
{
	BYTE	fin_snd;

	fin_snd = 0;					/* Default		*/

	if ( fin_tmr-- == 0)				/* If time out		*/
	  {
	  switch ( fin_case )
	    {
	    case 0:
	      if ( fin_good )				/* If good finish	*/
		com_wrt( S_FINISH );

	      fin_tmr = 45;
	      fin_case++;
	      break;

	    case 1:
	      switch ( rankpal[0] )			/* Who won?		*/
	        {
	        case 0:
	          fin_snd = S_REDWINS;
		  fin_tmr = 45;
	          break;

	        case 0x20:
	          fin_snd = S_BLUWINS;
		  fin_tmr = 45;
	          break;

	        default:
	          fin_snd = S_HOSTOP;
		  fin_tmr = 50;
	          break;
	        }

	      fin_case++;
	      break;

	    case 2:
	      switch ( rankpal[1] )				/* Who's second?	*/
	        {
	        case 0:
	          fin_snd = S_REDSEC;
		  fin_tmr = 60;
	          break;

	        case 0x20:
	          fin_snd = S_BLUSEC;
		  fin_tmr = 60;
	          break;

	        default:
		  fin_tmr = 0;
	          break;
	        }

	      fin_case++;
	      break;

	    case 3:
	      switch ( rankpal[2] )				/* Who's third	*/
	        {
	        case 0:
	          fin_snd = S_REDTHRD;
		  fin_tmr = 45;
	          break;

	        case 0x20:
	          fin_snd = S_BLUTHRD;
		  fin_tmr = 45;
	          break;

	        default:
		  fin_tmr = 0;
	          break;
	        }

	      fin_case++;
	      break;

	    case 4:
	      switch ( rankpal[3] )				/* Who's last	*/
	        {
	        case 0:
	          fin_snd = S_REDLAST;
		  fin_tmr = 75;
	          break;

	        case 0x20:
	          fin_snd = S_BLULAST;
		  fin_tmr = 75;
	          break;

	        default:
	          fin_snd = S_HOSTLAST;
		  fin_tmr = 90;
	          break;
	        }

	      fin_case++;
	      break;

	    case 5:
	      if (gcount > ENDWMIN)				/* Set count timer to end this mode	*/
	        gcount = ENDWTIME;
	      else
		gcount = ENDWTIME - (ENDWMIN - gcount);

	      fin_case++;

	    default:
	      break;
	    }
	  }

	if ( fin_snd )						/* Say what needs to be said!	*/
	  com_wrt ( fin_snd );
}


