/*======================================================================*/
/*		TITLE:			RAIL				*/
/*		Function:		Rail routines			*/
/*									*/
/*		First Edit:		03/18/91			*/
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
extern	ulong	coldsp;
extern	WORD	frame;

	BALEBLK	rails[MAX_RAIL];			/* Rail blocks				*/
	BALEBLK	*rail_ptr;				/* Pointer to current rails to setup	*/
	BYTE	rail_cnt;



/*	Clear all rail structures		*/
clr_rail()
{
	int	i;

	for (i=0; i < MAX_RAIL; i++)
	  {
	  rail_ptr = &rails[i];
	  rail_ptr->start = rail_ptr->end = rail_ptr->dy = rail_ptr->flag = rail_ptr->xpos = 0;
	  }

	rail_cnt = 0;
	coldsp &= ~C_RAIL;
}



/*	Setup guard rail					*/
set_rail(op,i)
MDTYPE	*op;
int	i;
{
	int	i;

	switch (op->attr)
	  {
	  default:
	  case 0:
	    find_rail(op);

	    if ((rail_ptr->flag & 0x8000) && (rail_ptr->dy == 0))	/* If we need dy		*/
	      rail_ptr->dy = op->ypos - rail_ptr->start;		/* Set deltay check		*/
	    break;

	  case 1:							/* First rail			*/
	    for (i=0; i < MAX_RAIL; i++)				/* Find emply slot		*/
	      {
	      rail_ptr = &rails[i];

	      if (rail_ptr->flag == 0)					/* Got one!			*/
	        goto got_rail;
	      }
	    return(-1);							/* Setup error			*/

got_rail:   rail_ptr->flag = 0x8000;					/* Flag active			*/
	    rail_ptr->flag |= op->type;					/* Save type code		*/
	    ++rail_cnt;							/* Count em			*/

	    rail_ptr->start = op->ypos;					/* Save starting Ypos		*/
	    rail_ptr->xpos = op->xpos;					/* Save xpos			*/
	    coldsp |= C_RAIL;						/* Enable rail collision	*/
	    break;

	  case 2:
	    find_rail(op);						/* Last rail			*/
	    rail_ptr->flag |= 0x4000;					/* Set end flag			*/
	    rail_ptr->end = op->ypos;					/* Save ending Ypos		*/
	    break;
	  }

	return(0);					/* Setup OK			*/
}


/*	Find our rail					*/
find_rail(op)
MDTYPE	*op;
{
	int	i;

	for (i=0; i < MAX_RAIL; i++)				/* Find our list		*/
	  {
	  rail_ptr = &rails[i];

	  if (abs(rail_ptr->xpos - op->xpos) < 0x100)		/* Found it!			*/
	    {
	    if ((op->attr == 2) && (rail_ptr->flag & 0x4000))	/* And slot is already taken..	*/
	      continue;
	    else
	      return;
	    }
	  }
}



/*	Delete a rail structure				*/
del_rail(rptr)
BALEBLK	*rptr;
{
	rptr->start = rptr->end = rptr->dy = rptr->flag = rptr->xpos = 0;

	if (--rail_cnt == 0)				/* If last one...		*/
	  coldsp &= ~C_RAIL;				/* Disable dispatch		*/
}



/*	Hit Guard Rail collision			*/
/*	Entry:	cop = car object pointer		*/
/*		rptr = rail struct pointer		*/
hit_rail(cop,rptr)
MDTYPE	*cop;
BALEBLK	*rptr;
{
	CARBLK	*carptr;
	long	rxpos;
	short	da;

	carptr = (CARBLK *)cop->uptr;			/* Get car block pointer	*/
							/* Slow by 1/16			*/
	carptr->car_rpm = carptr->car_rpm - (carptr->car_rpm >> 4);

	if (rptr->xpos > 0)
	  {
	  da = -2;
	  rxpos = rptr->xpos - (BALE_RAD+CAR_RAD);
	  if (cop->xpos > rxpos) cop->xpos = rxpos;
	  carptr->car_xext -= 6;
	  }
	else
	  {
	  da = 2;
	  rxpos = rptr->xpos + (BALE_RAD+CAR_RAD);
	  if (cop->xpos < rxpos) cop->xpos = rxpos;
	  carptr->car_xext += 6;
	  }

	bump_angle(carptr,da);
	com_wrt(S_GRDRAIL);


	if (carptr->car_flag & PLR_CAR)			/* If it's the player...	*/
	  {
	  add_score(10);				/* 10 points		*/
	  set_shake(2);					/* 2 Frame shake		*/
	  }
}
