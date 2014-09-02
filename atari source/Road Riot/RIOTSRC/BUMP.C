/*======================================================================*/
/*		TITLE:			BUMP				*/
/*		Function:		Bump routines			*/
/*									*/
/*		First Edit:		01/04/91			*/
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

#define	MAX_OB		20

extern	MDTYPE	obj[];
extern	MOBLK	splashblk;
extern	ulong	coldsp;
	
	LIST_HEAD	ob_list,ob_free;			/* Linked list head pointers		*/
	COLLBLK		ob_blks[MAX_OB];			/* Obsticle control blocks		*/


/*	Init bump obsticle list					*/
init_obs()
{
	COLLBLK	*obptr;
    
	ob_list.next = ob_list.prev = &ob_list;				/* Null active list		*/
	ob_free.next = ob_free.prev = &ob_free;				/* Null free list		*/

	for(obptr = ob_blks; obptr < &ob_blks[MAX_OB]; ++obptr)		/* Put all blocks on free list	*/
	  link_last(&ob_free,obptr);
}


/*	Return address of free bump block to link in, or NULL		*/
COLLBLK *get_obblk()
{
	COLLBLK	*temp;

	if ((temp = ob_free.next) == &ob_free) 		/* no memory left - punt */
 	  return(NULL);

	dlink(temp);					/* De-link from free list	*/
	return(temp);
}



/*	Setup obsticle						*/
set_obs(op)
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



/*	Delete obsticle and link to free list			*/
del_obs(op)
MDTYPE	*op;
{
	dlink(op->uptr);			/* Unlink from active list	*/
	link_first(&ob_free,op->uptr);		/* Link into free list		*/

    	if (ob_list.next == &ob_list)		/* If Null active list		*/
	  coldsp &= ~C_OBSTCLE;
}



/*	Hit bump collision				*/
/*	Entry:	cop = car object pointer		*/
/*		obop = bump object pointer		*/
hit_bump(cop,obop)
MDTYPE	*cop,*obop;
{
	CARBLK	*carptr;

	carptr = (CARBLK *)cop->uptr;			/* Get car block pointer	*/
							/* Slow down by 1/8		*/
	carptr->car_rpm = carptr->car_rpm - (carptr->car_rpm >> 3);
	carptr->jump_spd = (carptr->car_spd >> 5) + 8;	/* Set jump speed		*/
	carptr->car_zspd = carptr->jump_spd;
	carptr->car_case = CC_JUMP;			/* We're jumping		*/
}



/*	Hit mud puddle collision			*/
/*	Entry:	cop = car object pointer		*/
/*		obop = obsticle object pointer		*/
hit_mud(cop,obop)
MDTYPE	*cop,*obop;
{
	CARBLK	*carptr;
	MDTYPE	*sp;
	short	dir;

	carptr = (CARBLK *)cop->uptr;			/* Get car block pointer	*/
	dir = random(1) ? 1 : -1;
	start_spin(carptr,dir);				/* Start spinout		*/
							/* Slow by 1/2			*/
	carptr->car_rpm = carptr->car_rpm - (carptr->car_rpm >> 1);
	sp = &obj[setobj(&splashblk,obop->xpos,obop->ypos,obop->zpos,0,0)];
	sp->yspd = carptr->car_yspd;
}
