/*======================================================================*/
/*		TITLE:			OBSTICLE			*/
/*		Function:		Obsticle routines		*/
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

#define	MAX_OB		32

extern	MDTYPE	obj[];
extern	MOBLK	splashblk;
extern	MOBLK	gate0fblk,gate1fblk,gate2fblk;
extern	ulong	frgdsp,coldsp;
extern	short	plyrno;

#ifdef	DEVELOPMENT
extern	BYTE	edtflg;
#endif
	
	LIST_HEAD	ob_list,ob_free;			/* Linked list head pointers		*/
	COLLBLK		ob_blks[MAX_OB];			/* Obsticle control blocks		*/
	MDTYPE		*toyptr;				/* Toyota truck pointer			*/


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
	obptr->xoff = 0;				/* Clear Xoffset		*/
	obptr->yoff = 0;				/* Clear Yoffset		*/
	op->link0 = (long)obptr;			/* Save COLLBLK pointer in obj	*/
	link_first(&ob_list,obptr);			/* Link into active list	*/
	coldsp |= C_OBSTCLE;				/* Enable collsion		*/

	return(0);					/* Everything, OK!		*/
}



/*	Check for type 1 obsticle 				*/
set_obs1(op)
MDTYPE	*op;
{
	if (op->attr == 1)				/* If type #1			*/
	  return(set_obs(op));				/* Setup as obsticle		*/
	else
	  return(0);
}



/*	Delete a tree						*/
del_tree(op)
MDTYPE	*op;
{
	if (op->attr == 1)				/* If type #1			*/
	  del_obs(op);					/* Delete obsticle		*/
	else
	  return(0);
}



/*	Setup starting gate					*/
set_gate(op)
MDTYPE	*op;
{
#define	GATE_XOFF	0x740

	COLLBLK	*obptr;

	if ((obptr = get_obblk()) == NULL)		/* If none left...		*/
	  return(-1);

	obptr->op = op;					/* Save object pointer		*/
	obptr->yoff = 0;				/* Set yoffset			*/

	if (op->flags & MO_FLIP)
	  obptr->xoff = GATE_XOFF;			/* Set Xoffset			*/
	else
	  obptr->xoff = -GATE_XOFF;			/* Set Xoffset			*/

	op->link0 = (long)obptr;			/* Save COLLBLK pointer in obj	*/
	link_first(&ob_list,obptr);			/* Link into active list	*/
	coldsp |= C_OBSTCLE;				/* Enable collsion		*/

	return(0);					/* Everything, OK!		*/
}



/*	Setup rocks					*/
set_rock(op)
MDTYPE	*op;
{
#define	ROCK0_XOFF	0x80
#define	ROCK1_XOFF	-0x200

	COLLBLK	*obptr;
	short	xoff;

	if (op->type == ROCK0_TYPE)
	  xoff = ROCK0_XOFF;
	else
	  xoff = ROCK1_XOFF;

	if ((obptr = get_obblk()) == NULL)		/* If none left...		*/
	  return(-1);

	obptr->op = op;					/* Save object pointer		*/
	obptr->yoff = 0;				/* Set yoffset			*/

	if (op->flags & MO_FLIP)
	  obptr->xoff = -xoff;				/* Set Xoffset			*/
	else
	  obptr->xoff = xoff;				/* Set Xoffset			*/

	op->link0 = (long)obptr;			/* Save COLLBLK pointer in obj	*/
	link_first(&ob_list,obptr);			/* Link into active list	*/
	coldsp |= C_OBSTCLE;				/* Enable collsion		*/

	return(0);					/* Everything, OK!		*/
}



/*	Delete obsticle and link to free list			*/
del_obs(op)
MDTYPE	*op;
{
	if (op->link0)				/* If we haven't done this	*/
	  {
	  dlink(op->link0);			/* Unlink from active list	*/
	  link_first(&ob_free,op->link0);	/* Link into free list		*/
	  op->link0 = 0;			/* Clear this pointer		*/

     	  if (ob_list.next == &ob_list)		/* If Null active list		*/
	    coldsp &= ~C_OBSTCLE;
	  }
}



/*	Hit bump collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = bump object pointer		*/
hit_bump(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	if (chg_ccase(carptr,CC_JUMP))				/* Can we goto jump mode	*/
	  {							/* Slow down by 1/8		*/
	  carptr->car_rpm = carptr->car_rpm - (carptr->car_rpm >> 3);
	  carptr->jump_spd = (carptr->car_spd >> 5) + 8;	/* Set jump speed		*/
	  carptr->car_zspd = carptr->jump_spd;
          }
}



/*	Hit mud puddle collision			*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_mud(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	MDTYPE	*sp;
	short	dir;

	if (start_spin(carptr))				/* If start is ok		*/
	  {						/* Slow by 1/2			*/
	  carptr->car_rpm = carptr->car_rpm - (carptr->car_rpm >> 1);
	  sp = &obj[setobj(&splashblk,obop->xpos,obop->ypos,obop->zpos,0,0)];
	  sp->yspd = carptr->car_yspd;

	  com_wrt(S_MDSPLSH);				/* Spash sound			*/
	  }
}



/*	Hit obsticle collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_obs(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	if (carptr->car_spd < 0x100)			/* If going slow...		*/
	  {
	  if (carptr->op->xpos >= obop->xpos)		/* Right or Left?		*/
	    carptr->car_xext = 0x80;
	  else
	    carptr->car_xext = -0x80;

	  carptr->car_yext = -(carptr->car_yspd >> 1);	/* Take 1/2 speed		*/
	  }
	else
	  {
	  if (start_xplo(carptr))			/* Explode car			*/
	    {
	    carptr->op->zpos = obop->zpos;		/* Use obsticle's zpos for explosion	*/

	    if (carptr->car_flag & PLR_CAR)		/* If this is the player...	*/
	      {
	      plr_xplo();				/* Explode player mode		*/
	      add_score(700);				/* 700 point for exploding	*/
	      }
	    }
	  }

}



/*	Hit sign collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_sign(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	obop->satime = 1;				/* Downed sign			*/
	del_obs(obop);					/* No more collision		*/
	com_wrt(S_SIGNHT);				/* Hit sign sound		*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(250);				/* 250 points			*/
}



/*	Hit toyota collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_toy(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	obop->satime = 4;				/* Turn on animation		*/
	obop->flags &= ~(MO_ZMAP | MO_FIX);		/* Not stuck to PF		*/
	obop->yspd = carptr->car_yspd;			/* Give player's speed		*/
	obop->zspd = 0x20;				/* Up in air			*/
	obop->type = DUMMY_TYPE;			/* Not just a truck anymore	*/
	del_obs(obop);					/* No more collision		*/

	carptr->car_zspd = 0x10;
	start_endo(carptr,1,1);				/* Do endo			*/

	toyptr = obop;					/* Save object pointer		*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(1000);				/* 1000	points!			*/

	com_wrt(S_GCANHIT);

	if (carptr->car_flag & PLR_CAR)
	  announce( plyrno ? S_BLUHPAY : S_REDHPAY, 0, 45 );

	frgdsp |= F_TOY;				/* Plot it			*/
}


/*	Plot toyota truck				*/
move_toy()
{
	short	height;

	height = get_height(toyptr->ypos);		/* Get height under truck	*/
	
	if (toyptr->zpos <= height)			/* If on the ground..		*/
	  {
	  toyptr->zpos = height;			/* Put on the ground		*/
	  toyptr->yspd = 0;				/* Don't move			*/
	  toyptr->zspd = 0;
	  frgdsp &= ~F_TOY;				/* Turn off dispatch		*/
	  }
	else
	  toyptr->zspd -= 4;				/* Gravity			*/
}



/*	Hit crowd collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_crowd(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	del_obs(obop);					/* No more collision		*/
	obop->type = DUMMY_TYPE;

	if (random(1))
	  com_wrt(S_FEAR1);				/* Screams			*/
	else
	  com_wrt(S_FEAR2);				/* Screams			*/

	if (carptr->car_flag & PLR_CAR)
	  add_score(250);				/* 250 points			*/
}


/*	Hit rock collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_rock(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	hit_obs(carptr,obop);					/* Hit the obsticle			*/

	if ((carptr->car_flag & PLR_CAR) && (carptr->car_case == CC_XPLO))
	  announce( plyrno ? S_BLUROCK : S_REDROCK, PER_RACE, 45 );	/* Announcer				*/
}



/*	Hit tree collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_tree(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	hit_obs(carptr,obop);				/* Hit the obsticle			*/

	if ((carptr->car_flag & PLR_CAR) && (carptr->car_case == CC_XPLO))
	  announce( S_WATCHTREE, PER_RACE, 45 );	/* Announcer				*/
}


/*	Setup taxi				*/
set_taxi(op)
MDTYPE	*op;
{
#ifdef	DEVELOPMENT
	if (edtflg == 0)
#endif
	  {
	  if (op->flags & MO_FLIP)			/* If right taxi		*/
	    op->xspd = 0x40;
	  else
	    op->xspd = -0x40;
	  }

	return(set_obs(op));				/* Setup as obsticle		*/
}



/*	Hit big CATT collision				*/
/*	Entry:	carptr = car pointer			*/
/*		obop = obsticle object pointer		*/
hit_cat(carptr,obop)
CARBLK	*carptr;
MDTYPE	*obop;
{
	if (carptr->car_spd < 0x100)			/* If going slow...		*/
	  {
	  if (carptr->op->xpos >= obop->xpos)		/* Right or Left?		*/
	    carptr->car_xext = 0x80;
	  else
	    carptr->car_xext = -0x80;

	  carptr->car_yext = -(carptr->car_yspd >> 1);	/* Take 1/2 speed		*/
	  }
	else
	  {						/* Top is smaller than bottom	*/
	  if ((carptr->op->zpos >= 0x60) && (ABS(carptr->op->xpos - obop->xpos) > 0x500))
	    return;

	  if (start_xplo(carptr))			/* Explode car			*/
	    {
	    carptr->op->zpos = obop->zpos;		/* Use obsticle's zpos for explosion	*/

	    if (carptr->car_flag & PLR_CAR)		/* If this is the player...	*/
	      {
	      plr_xplo();				/* Explode player mode		*/
	      add_score(2000);				/* 700 point for exploding	*/
	      }
	    }
	  }

}




/*	Setup cars					*/
set_cars(op)
MDTYPE	*op;
{
	COLLBLK	*obptr;
	short	xoff;

	if ((op->attr & 1) == 0)			/* If NOT type #1		*/
	  return(0);

	if (op->attr & 2) 				/* If D1 set			*/
	  op->flags &= ~MO_ODEL;			/* Don't offscreen delete	*/

	if ((obptr = get_obblk()) == NULL)		/* If none left...		*/
	  return(-1);

	switch (op->type)
	  {
	  default:
	    xoff = 0;
	    break;

	  case CAR5_TYPE:
	    xoff = 0x260;
	    break;

	  case CAR6_TYPE:
	    xoff = 0xE0;
	    break;

	  case CAR7_TYPE:
	    xoff = 0x278;
	    break;

	  case CAR8_TYPE:
	    xoff = 0x180;
	    break;

	  case CAR11_TYPE:
	    xoff = -0x60;
	    break;
	  }

	obptr->op = op;					/* Save object pointer		*/
	obptr->yoff = 0;				/* Set yoffset			*/

	if (op->flags & MO_FLIP)
	  obptr->xoff = -xoff;				/* Set Xoffset			*/
	else
	  obptr->xoff = xoff;				/* Set Xoffset			*/

	op->link0 = (long)obptr;			/* Save COLLBLK pointer in obj	*/
	link_first(&ob_list,obptr);			/* Link into active list	*/
	coldsp |= C_OBSTCLE;				/* Enable collsion		*/

	return(0);					/* Everything, OK!		*/
}



