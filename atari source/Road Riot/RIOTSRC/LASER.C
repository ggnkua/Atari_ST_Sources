/*======================================================================*/
/*		TITLE:			LASER				*/
/*		Function:		Laser routines			*/
/*									*/
/*		First Edit:		04/18/89			*/
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
#include	"prog/inc/lasinc.h"
#include	"prog/inc/collinc.h"
#include	"prog/inc/comminc.h"
#include	"prog/inc/buttons.h"
#include	"prog/inc/audio.h"
#include	"prog/inc/message.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:lasinc.h"
#include	"inc:collinc.h"
#include	"inc:comminc.h"
#include	"inc:buttons.h"
#include	"inc:audio.h"
#include	"inc:message.h"

#endif


#define LSPEED		0x500

extern	CARBLK	*plrcar;
extern	MDTYPE	obj[];
extern	LSRPKT	*ltable[];
extern	MOBLK	laserblk,rlaserblk,tlaserblk;
extern	ulong	coldsp;
extern	short   plyrno;	
extern	WORD	button;
extern	BYTE	active[];
	
	LASBLK		las_blks[MAX_LASER];			/* Laser control blocks			*/

	LASBLK	*lblks[]={&las_blks[0],&las_blks[MAX_PLASER]};	/* Laser block tables base addresses	*/

	char	laser_tmr;		/* Laser repeat timer		*/
	char	laser_tim;		/* Laser timer save		*/
	char	lascnt;			/* Active counter		*/


/*	Clear ALL lasers 					*/
clr_lasers()
{
	int	i;
	LASBLK	*lasptr;
	LSRPKT	*lpkptr;

	lasptr = lblks[0];
	lpkptr = ltable[0];
    
	for (i=0; i < MAX_LASER; i++, lasptr++, lpkptr++)
	  {
	  lasptr->op = 0;					/* Clear eveything		*/
	  lasptr->lsflags = 0;
	  lasptr->owner = 0;

	  lpkptr->lflags = 0;					/* Clear packet flags		*/
	  }

	laser_tim = 8;						/* 8 Frame laser delay		*/
}


/*	Player shoots gun		*/
plr_shoot()
{
	if ((button & TRIGS) ||				/* If fire pressed	*/
	   ((button & TRIGS_LEV) && (--laser_tmr <= 0)))
	  {
	  set_laser(plrcar);
	  laser_tmr = laser_tim;			/* Wait for next shot	*/
	  com_wrt(S_GUN);				/* Gun sound		*/
	  }
}



/*	Set up a laser on this system			*/
set_laser(carptr)
CARBLK	*carptr;
{
	int	i;
	LASBLK	*lasptr;
	LSRPKT	*lpkptr;
	COLLBLK	*enemy_ptr;
    	short	sindir,cosdir,yoff;

	lasptr = lblks[plyrno];					/* Get table base addrs	*/
	lpkptr = ltable[plyrno];				/* Get pointer to my laser packet block	*/

	for (i=0; i < MAX_PLASER; i++, lasptr++, lpkptr++)
	  {
	  if (lasptr->lsflags == 0)				/* If slot free...	*/
	    {							/* Fill packet slot with stuff		*/
    	    sindir = ssin(carptr->car_pic);			/* Get offsets from car direction	*/
    	    cosdir = scos(carptr->car_pic);

	    yoff = ((CAR_RAD*2) * cosdir) >> 14;

	    lpkptr->lflags = LASER_ACTIVE | LASER_SPEED | plyrno;	/* Flag active slot			*/

	    if (carptr->op->flags & MO_SCRN)				/* If on screen..			*/
      	      lpkptr->lxpos = get_ssx(carptr->op) + ((CAR_RAD * sindir) >> 14); 
	    else
      	      lpkptr->lxpos = carptr->op->xpos + ((CAR_RAD * sindir) >> 14);

    	    lpkptr->lypos = carptr->op->ypos + yoff;
    	    lpkptr->lzpos = (carptr->op->zpos + CAR_ZWIDTH) + ((carptr->slope * yoff) >> 12);
            lpkptr->lxspd = ((LSPEED * sindir) >> 14) + carptr->car_xspd;
            lpkptr->lyspd = ((LSPEED * cosdir) >> 14) + carptr->car_yspd;
            lpkptr->lzspd = (carptr->slope * lpkptr->lyspd) >> 12;

	    enemy_ptr = (COLLBLK *)carptr->op->link0;			/* Get enemy list pointer		*/
            lpkptr->lowner = enemy_ptr->type;				/* Save enemy type as owner		*/
	    return;							/* Exit here				*/
	    }
	  }
}



/*	Do this system's lasers				*/
my_lasers()
{
	lasers(plyrno);
}


/*	Do remote system's laser's			*/
their_lasers()
{
	lasers(plyrno ^ 1);
}



/*	Do laser stuff					*/
lasers(sys)
int	sys;
{
	int	j;
	LASBLK	*lasptr;
	LSRPKT	*lpkptr;
	MOBLK	*mblk;
	short	drn_idx,ssx;

	if (active[sys])					/* If this system is active...			*/
	  {
	  lasptr = lblks[sys];					/* Get table base addrs	*/
	  lpkptr = ltable[sys];					/* Get pointer to my laser packet block	*/

	  for (j=0; j < MAX_PLASER; j++, lasptr++, lpkptr++)	/* Loop through slots				*/
	    {
	    if (lpkptr->lflags & LASER_ACTIVE)			/* If laser packet slot is ACTIVE..	*/
	      {					
	      if (lasptr->lsflags & LASER_DEL)			/* If delete flag on...		*/
	        {
	        delobj(lasptr->op);				/* Delete me now		*/
  	        continue;					/* Skip everything else		*/
	        }

	      if ((lasptr->lsflags & LASER_ACTIVE) == 0)	/* If we have NOT started this one...	*/
	        {
		if (sys != plyrno)				/* If remote...			*/
		  mblk = &rlaserblk;				/* Use fixed laser		*/
		else
		  mblk = &laserblk;				/* Normal laser		*/

	        lasptr->op = &obj[setobj(mblk,lpkptr->lxpos,lpkptr->lypos,lpkptr->lzpos,0,0)];
                lasptr->owner = lpkptr->lowner;			/* Save owner's type code	*/
		lasptr->lsflags = lpkptr->lflags;		/* Get copy of flags	*/

 	        lasptr->op->xspd = lpkptr->lxspd;		/* Set speeds		*/
 	        lasptr->op->yspd = lpkptr->lyspd;
 	        lasptr->op->zspd = lpkptr->lzspd;
		lasptr->op->sys = sys;				/* Save system index	*/
		lasptr->op->goff = j;				/* Save local index	*/
		lascnt++;					/* Count 'em		*/

		coldsp |= C_LASER;

		drn_idx = lpkptr->lowner - DRONE0_TYPE;		/* Get drone type index		*/
		if (drn_idx != plyrno) set_rshot(drn_idx);	/* Set rear view shot		*/
		}

	      if (sys == plyrno)						/* If this is my laser...	*/
		{
	  	lasptr->op->height = get_height(lasptr->op->ypos);		/* Get height under laser	*/

	  	if (lasptr->op->zpos <= lasptr->op->height)			/* If under the track..		*/
	    	  {
	    	  lasptr->op->zpos = lasptr->op->height;			/* Put on track		*/
	    	  lasptr->op->zspd = 0;
		  laser_delete(lasptr->op);					/* Delete me		*/
		  continue;
		  }

		mo_apfmap(lasptr->op);						/* Get PF hoffset			*/
		lasptr->op->ssx = get_ssx(lasptr->op);				/* Get "straight space" xpos		*/

		lpkptr->lxpos = lasptr->op->ssx;				/* Update the position in the packet	*/
		lpkptr->lypos = lasptr->op->ypos;
		lpkptr->lzpos = lasptr->op->zpos;
		}
	      else
		{								/* Here if NOT my laser		*/
		lasptr->op->xpos = lpkptr->lxpos;				/* Get coords from packet	*/
		lasptr->op->ypos = lpkptr->lypos;
		lasptr->op->zpos = lpkptr->lzpos;
		}
	      }
	    else
	      {									/* Here if NOT ACTIVE...	*/
	      if (lasptr->lsflags & LASER_ACTIVE)				/* Was it just active...	*/
		laser_delete(lasptr->op);					/* Delete me			*/
	      }
	    }
	  }
}



/*	Delete laser and link to free list			*/
del_laser(op)
MDTYPE	*op;
{
	LASBLK	*lasptr;
	LSRPKT	*lpkptr;

	if (op->sys == plyrno)							/* If this is MY laser..	*/
	  {
	  lpkptr = ltable[op->sys];						/* Get pointer to my laser packet block	*/
	  lpkptr += op->goff;
	  lpkptr->lflags = 0;							/* Clear the packet	*/
	  }
										/* Clear local flag	*/
	lasptr = lblks[op->sys];						/* Get table base addrs	*/
	lasptr += op->goff;							/* Get local index		*/
	lasptr->lsflags = 0;							/* Clear flags			*/

	if (--lascnt <= 0) coldsp &= ~C_LASER;					/* If none left, disable dispatch	*/
}



/*	General laser delete routine			*/
laser_delete(op)
MDTYPE	*op;
{
	LASBLK	*lasptr;

	if (op->sys == plyrno)							/* If this is MY laser..	*/
	  {
	  lasptr = lblks[op->sys];						/* Get table base addrs		*/
	  lasptr += op->goff;							/* Get local index		*/

	  if (lasptr->lsflags & LASER_ACTIVE)					/* If we're still active..	*/
	    lasptr->lsflags |= LASER_DEL;					/* Flag delete bit		*/
	  }
	else									/* If not my laser...		*/
	  delobj(op);								/* Delete me now		*/
}

