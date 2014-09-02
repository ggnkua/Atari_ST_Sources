/*======================================================================*/
/*		TITLE:			BALE				*/
/*		Function:		Bale routines			*/
/*									*/
/*		First Edit:		01/14/91			*/
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
#include	"prog/inc/baleinc.h"
#include	"prog/inc/audio.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:baleinc.h"
#include	"inc:audio.h"

#endif

extern	MDTYPE	obj[];
extern	MOBLK	balexpblk,tirexpblk,trashxpblk,bagxpblk;
extern	ulong	coldsp;
extern	WORD	frame;

	BALEBLK	bales[MAX_BALE];			/* Bale/Tire blocks		*/
	BALEBLK	*bale_ptr;				/* Pointer to current bales to setup	*/
	BYTE	bale_cnt;



/*	Clear all bale structures		*/
clr_bale()
{
	int	i;

	for (i=0; i < MAX_BALE; i++)
	  {
	  bale_ptr = &bales[i];
	  bale_ptr->start = bale_ptr->end = bale_ptr->dy = bale_ptr->flag = bale_ptr->xpos = 0;
	  }

	bale_cnt = 0;
	coldsp &= ~C_BALE;
}



/*	Setup hay bale					*/
set_bale(op,i)
MDTYPE	*op;
int	i;
{
	int	i;

	switch (op->attr)
	  {
	  default:
	  case 0:
	    find_bale(op);

	    if ((bale_ptr->flag & 0x8000) && (bale_ptr->dy == 0))	/* If we need dy		*/
	      bale_ptr->dy = op->ypos - bale_ptr->start;		/* Set deltay check		*/
	    break;

	  case 1:							/* First bale			*/
	    for (i=0; i < MAX_BALE; i++)				/* Find emply slot		*/
	      {
	      bale_ptr = &bales[i];

	      if (bale_ptr->flag == 0)					/* Got one!			*/
	        goto got_bale;
	      }
	    return(-1);							/* Setup error			*/

got_bale:   bale_ptr->flag = 0x8000;					/* Flag active			*/
	    bale_ptr->flag |= op->type;					/* Save type code		*/
	    ++bale_cnt;							/* Count em			*/

	    bale_ptr->start = op->ypos;					/* Save starting Ypos		*/
	    bale_ptr->xpos = op->xpos;					/* Save xpos			*/
	    coldsp |= C_BALE;						/* Enable bale collision	*/
	    break;

	  case 2:					/* Last bale			*/
	    find_bale(op);
	    bale_ptr->flag |= 0x4000;			/* Set end flag			*/
	    bale_ptr->end = op->ypos;			/* Save ending Ypos		*/
	    break;
	  }

	return(0);					/* Setup OK			*/
}



/*	Find the bale pointer			*/
find_bale(op)
MDTYPE	*op;
{
	int	i;

	for (i=0; i < MAX_BALE; i++)				/* Find our list		*/
	  {
	  bale_ptr = &bales[i];

	  if (abs(bale_ptr->xpos - op->xpos) < 0x100)		/* Found it!			*/
	    {
	    switch (op->attr)
	      {
	      default:
	      case 0:
		if ((bale_ptr->flag & 0x4000) &&			/* If end is set		*/
	           (op->ypos > bale_ptr->end))				/* If this isn't us..		*/
	        continue;
	      else
	        return;
	      break;

	      case 2:
	        if (bale_ptr->flag & 0x4000)				/* If slot is already taken..	*/
		  continue;
		else
		  return;
	      }
	    }
	  }
}



/*	Delete a bale structure				*/
del_bale(bptr)
BALEBLK	*bptr;
{
	bptr->start = bptr->end = bptr->dy = bptr->flag = bptr->xpos = 0;

	if (--bale_cnt == 0)				/* If last one...		*/
	  coldsp &= ~C_BALE;				/* Disable dispatch		*/
}



/*	Hit Hay Bale collision				*/
/*	Entry:	cop = car object pointer		*/
/*		bptr = bale struct pointer		*/
hit_bale(cop,bptr)
MDTYPE	*cop;
BALEBLK	*bptr;
{
	CARBLK	*carptr;
	MDTYPE	*bp;
	MOBLK	*mblk;
	short	zspd,zoff;
	WORD	snd;

	carptr = (CARBLK *)cop->uptr;			/* Get car block pointer	*/
							/* Slow by 1/16			*/
	carptr->car_rpm = carptr->car_rpm - (carptr->car_rpm >> 4);

	if (bptr->xpos > 0)
	  {
	  bump_angle(carptr,-8);
	  carptr->car_xext -= 0x30;
	  }
	else
	  {
	  bump_angle(carptr,8);
	  carptr->car_xext += 0x30;
	  }

	if (cop->flags & MO_SCRN)			/* If car is on screen...	*/
	  {
	  switch (bptr->flag & 0x3FFF)			/* Set explosion type		*/
	    {
	    case BALE0_TYPE:
	    case BALE1_TYPE:
	    case BALE2_TYPE:
	    case DBALE0_TYPE:
	    case DBALE2_TYPE:
	      mblk = &balexpblk;
	      zoff = 0;
	      zspd = 0;
	      snd = S_HAYHIT;
	      break;

	    case TIRE0_TYPE:
	    case TIRE1_TYPE:
	    case TIRE2_TYPE:
	    case DTIRE0_TYPE:
	    case DTIRE2_TYPE:
	      mblk = &tirexpblk;
	      zspd = 0x10;				/* Launch tires			*/
	      zoff = 0x20;
	      snd = S_TIREHIT;
	      break;

	    case TRASH0_TYPE:
	    case TRASH1_TYPE:
	    case TRASH2_TYPE:
	      mblk = &trashxpblk;
	      zspd = 0x10;				/* Launch tires			*/
	      zoff = 0x20;
	      snd = S_GCANHIT;
	      break;

	    case BAG0_TYPE:
	    case BAG1_TYPE:
	    case BAG2_TYPE:
	    case DBAG0_TYPE:
	    case DBAG2_TYPE:
	      mblk = &bagxpblk;
	      zspd = 0x10;				/* Launch tires			*/
	      zoff = 0x20;
	      snd = S_CRUNCH;
	      break;
	    }
							/* Setup explosion		*/
	  bp = &obj[setobj(mblk,cop->xpos + cop->pfhoff,cop->ypos,cop->zpos+zoff,0,0)];
	  bp->yspd = carptr->car_yspd;			/* Move bale along		*/
	  bp->zspd = zspd;				/* Launch tires			*/

	  com_wrt(snd);

	  if (carptr->car_flag & PLR_CAR)		/* If it's the player...	*/
	    {
	    add_score(25);				/* 25 points			*/
	    set_shake(4);				/* 4 frame shake		*/
	    }
	  }
}
