/*======================================================================*/
/*		TITLE:			MUD				*/
/*		Function:		Mud muddle routines		*/
/*									*/
/*		First Edit:		01/09/91			*/
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
#include	"prog/inc/collinc.h"
#include	"prog/inc/carinc.h"
#include	"prog/inc/audio.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:collinc.h"
#include	"inc:carinc.h"
#include	"inc:audio.h"

#endif


/*	Setup mud puddle					*/
set_mud(op)
MDTYPE	*op;
{
	COLLBLK	*obptr;

	if ((obptr = get_obblk()) == NULL)		/* If none left...		*/
	  return(-1);

	obptr->op = op;					/* Save object pointer		*/
	op->uptr = (long)obptr;				/* Save COLLBLK pointer in obj	*/
	link_first(&ob_list,obptr);			/* Link into active list	*/
	coldsp |= C_OBSTCLE;				/* Enable collsion		*/

	return(0);					/* Everything, OK!		*/
}



/*	Delete mud and link to free list			*/
del_mud(op)
MDTYPE	*op;
{
	dlink(op->uptr);			/* Unlink from active list	*/
	link_first(&ob_free,op->uptr);		/* Link into free list		*/

    	if (ob_list.next == &ob_list)		/* If Null active list		*/
	  coldsp &= ~C_OBSTCLE;
}



/*	Hit mud collision				*/
/*	Entry:	cop = car object pointer		*/
/*		obop = mud object pointer		*/
hit_mud(cop,obop)
MDTYPE	*cop,*obop;
{
	CARBLK	*carptr;

	carptr = (CARBLK *)cop->uptr;			/* Get car block pointer	*/
	carptr->jump_spd = carptr->car_spd >> 4;	/* Set jump speed		*/
	carptr->car_zspd = carptr->jump_spd;
	carptr->car_case = CC_JUMP;			/* We're jumping		*/
}

