/*======================================================================*/
/*		TITLE:			MIRROR				*/
/*		Function:		Rear view mirror routines	*/
/*									*/
/*		First Edit:		04/08/91			*/
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

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:drninc.h"

#endif

extern	MDTYPE	obj[];
extern	MDTYPE	*pp,*drone_ptr[];
extern	MOBLK	drnblk,rshotblk;
extern	DRNBLK  *drtable[];
extern	long	world_len;
extern	WORD	plyrno;

#define	MIRH_LIM	(0x4000 - MIRRORH)



/*	Delete on of the little drones				*/
del_drn(op)
MDTYPE	*op;
{
	CARBLK	*carptr;

	carptr = (CARBLK *)op->uptr;				/* Get carblk associated with this drone	*/
	carptr->mir_ptr = 0;					/* Clear mirror drone pointer	*/
}



/*	Set rear view shot					*/
/*	Entry:	i = drone index 				*/
set_rshot(i)
int	i;
{
	MDTYPE	*op;
	CARBLK	*carptr;
	WORD	sort;

	carptr = (CARBLK *)drtable[i]->op->uptr;	/* Get car block pointer	*/

	if ((carptr->mir_ptr) && (carptr->mir_ptr->sort))	/* If drone in mirror	*/
	  {
	  op = carptr->mir_ptr;				/* Assign pointer	*/
	  sort = op->sort + 1;				/* Set sort value	*/
	  if (sort > 0xFF) sort = 0xFF;
	  setobj(&rshotblk,op->xpos,op->ypos,sort,0,0);
	  }
}



/*	Rear view mirror			*/
rear_view()
{
	MDTYPE	*drnop;
	CARBLK	*carptr;
	long	dy,hpos,vpos;
	int	i;
	WORD	sort;
    	short   scale;

	for (i=0; i < MAX_DRONE; i++)			/* Put drones in mirror		*/
	  {
	  drnop = drtable[i]->op;

	  if ((drnop) && (i != plyrno))			/* If drone active..		*/
	    {						/* Get deltay			*/
	    dy = wrap_dy(pp->ypos - (drnop->ypos + CAR_RAD));

	    hpos = (drnop->xpos - pp->xpos) << 1;	/* Get position	in mirror	*/
	    hpos = (hpos * (0x8000 - dy)) >> 14;
	    hpos += MIRRORH;
	    vpos = MIRRORV - (dy >> 5);
	    sort = 0xFF - (dy >> 12);
	    scale = -(dy >> 3);

	    carptr = (CARBLK *)drnop->uptr;		/* Get drone's car block ptr	*/

	    if (carptr->mir_ptr == 0) 			/* If not in mirror		*/
	      {
	      if ((dy >= 0) && (dy < (STRIP_SIZE * 8)))		/* If behind in last 8 strips	*/
	        {
		if (ABS(hpos-MIRRORH) <= MIRH_LIM)		/* If within mirror		*/
		  {						/* Setup little drone		*/
	          carptr->mir_ptr = &obj[setobj(&drnblk,hpos,vpos,sort,scale,0)];
	          carptr->mir_ptr->pal = carptr->body_ptr->pal;	/* Get body palette	*/
	          carptr->mir_ptr->ftime = 1;			/* Change palette	*/
	    	  carptr->mir_ptr->uptr = (long)carptr;		/* Save carblk in little drone struct	*/
	          }
		}
	      }
	    else
	      {
	      if ((dy < 0) || (dy >= (STRIP_SIZE * 8)))		/* If in front, or more that 8 strips behind	*/
		delobj(carptr->mir_ptr);			/* Delete drone in mirror	*/
	      else
		{						/* Here if drone active in mirror	*/
		if (ABS(hpos-MIRRORH) > MIRH_LIM)		/* If outside of mirror		*/
		  carptr->mir_ptr->sort = 0;			/* Clip it			*/
		else
		  {
		  carptr->mir_ptr->xpos = hpos;			/* Get position and size in mirror	*/
		  carptr->mir_ptr->ypos = vpos;
		  carptr->mir_ptr->sort = sort;
		  carptr->mir_ptr->scale = (DRN_SCALE << 4) + scale;
		  }
		}
	      }
	    }
	  }
}


