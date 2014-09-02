/*======================================================================*/
/*		TITLE:			COW				*/
/*		Function:		Cow routines			*/
/*									*/
/*		First Edit:		03/20/91			*/
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
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"
#include	"prog/inc/audio.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:collinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:audio.h"

#endif

#define	MAX_OB1		8

extern	ulong	coldsp;
extern	WORD	arab0_end[],crowd2_end[],crowd3_end[],crowd4_end[];
extern	short	viewz;
	
	LIST_HEAD	ob1_list,ob1_free;			/* Linked list head pointers		*/
	COLLBLK		ob1_blks[MAX_OB1];			/* obsticle control blocks		*/


/*	Init list				*/
init_ob1()
{
	COLLBLK	*ob1ptr;
    
	ob1_list.next = ob1_list.prev = &ob1_list;				/* Null active list		*/
	ob1_free.next = ob1_free.prev = &ob1_free;				/* Null free list		*/

	for(ob1ptr = ob1_blks; ob1ptr < &ob1_blks[MAX_OB1]; ++ob1ptr)		/* Put all blocks on free list	*/
	  link_last(&ob1_free,ob1ptr);
}


/*	Return address of free bump block to link in, or NULL		*/
COLLBLK *get_ob1blk()
{
	COLLBLK	*temp;

	if ((temp = ob1_free.next) == &ob1_free) 		/* no memory left - punt */
 	  return(NULL);

	dlink(temp);					/* De-link from free list	*/
	return(temp);
}



/*	Setup object 1 type				*/
set_ob1(op)
MDTYPE	*op;
{
	COLLBLK	*ob1ptr;

	if ((ob1ptr = get_ob1blk()) == NULL)		/* If none left...		*/
	  return(-1);

	if (op->attr & 2) 				/* If D1 set			*/
	  op->flags &= ~MO_ODEL;			/* Don't offscreen delete	*/

	ob1ptr->op = op;				/* Save object pointer		*/
	ob1ptr->xoff = 0;				/* Clear Xoffset		*/
	op->link0 = (long)ob1ptr;			/* Save COLLBLK pointer in obj	*/
	link_first(&ob1_list,ob1ptr);			/* Link into active list	*/
	coldsp |= C_OB1;				/* Enable collsion		*/

	return(0);					/* Everything, OK!		*/
}


/*	Delete obsticle and link to free list			*/
del_ob1(op)
MDTYPE	*op;
{
	if (op->link0)				/* If we haven't done this	*/
	  {
	  dlink(op->link0);			/* Unlink from active list	*/
	  link_first(&ob1_free,op->link0);	/* Link into free list		*/
	  op->link0 = 0;			/* Clear this pointer		*/

     	  if (ob1_list.next == &ob1_list)		/* If Null active list		*/
	    coldsp &= ~C_OB1;
	  }
}




/*	Scare cow collision				*/
/*	Entry:	carptr = car pointer			*/
/*		op = obsticle object pointer		*/
scare_cow(carptr,op)
CARBLK	*carptr;
MDTYPE	*op;
{
	op->satime = 4;					/* Scare the cow animation	*/

	if (carptr->car_flag & PLR_CAR)
	  announce( random(1) ? S_LOOKOUT : S_OHNO, 0, 0 );
}


/*	Hit cow				*/
/*	Entry:	carptr = car block pointer		*/
/*		obop = obsticle object pointer		*/
hit_cow(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	carptr->car_zspd = ENDO_ZMIN;			/* Fly into air		*/
	carptr->car_yext += 0x40;			/* And forward		*/
	start_endo(carptr,1,1);				/* With endo		*/
	com_wrt(S_COW);					/* MOO!				*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(1000);				/* 1000 points		*/
}



/*	Scare arab collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
scare_arab(carptr,op)
CARBLK	*carptr;
MDTYPE	*op;
{
	set_seqn(op,arab0_end);

	if (carptr->car_flag & PLR_CAR)
	  announce( random(1) ? S_LOOKOUT : S_OHNO, 0, 0 );
}




/*	Hit arab collision				*/
/*	Entry:	carptr = car block pointer		*/
/*		obop = obsticle object pointer		*/
hit_arab(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	del_ob1(obop);					/* No more collision		*/
	obop->type = DUMMY_TYPE;

	obop->satime = 4;				/* Start animating 		*/
	obop->flags &= ~(MO_FIX | MO_ZMAP);		/* Enable motion		*/
	obop->yspd = carptr->car_yspd - 0xC0;		/* They come at us		*/
	obop->zspd = (viewz - obop->zpos) >> 5;

	com_wrt(S_FARROKH);				/* Farrokh curses in arabic	*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(250);				/* 250 points			*/
}



/*	Hit Rhino					*/
/*	Entry:	carptr = car block pointer		*/
/*		obop = obsticle object pointer		*/
hit_rhino(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	carptr->car_zspd = ENDO_ZMIN;			/* Fly into air		*/
	carptr->car_yext += 0x40;			/* And forward		*/
	start_endo(carptr,1,1);				/* With endo		*/
	com_wrt(S_RINO);				/* MOO!				*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(2000);				/* 2000 points		*/
}




/*	Scare crowd1 collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
scare_crowd1(carptr,op)
CARBLK	*carptr;
MDTYPE	*op;
{
	WORD	*seqn;

	switch (op->type)
	  {
	  default:
	  case CRWD4_TYPE:
	    seqn = crowd4_end;
	    break;

	  case CRWD2_TYPE:
	    seqn = crowd2_end;
	    break;

	  case CRWD3_TYPE:
	    seqn = crowd3_end;
	    break;
	  }

	set_seqn(op,seqn);

	if (carptr->car_flag & PLR_CAR)
	  announce( random(1) ? S_LOOKOUT : S_OHNO, 0, 0 );
}




/*	Hit crowds					*/
/*	Entry:	carptr = car block pointer		*/
/*		obop = obsticle object pointer		*/
hit_crowd1(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	del_ob1(obop);					/* No more collision		*/
	obop->type = DUMMY_TYPE;

	obop->satime = 4;				/* Start animating 		*/
	obop->flags &= ~(MO_FIX | MO_ZMAP);		/* Enable motion		*/
	obop->yspd = carptr->car_yspd - 0xC0;		/* They come at us		*/
	obop->zspd = (viewz - obop->zpos) >> 5;

	if (random(1))
	  com_wrt(S_FEAR1);				/* Screams			*/
	else
	  com_wrt(S_FEAR2);				/* Screams			*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(500);				/* 250 points			*/
}



