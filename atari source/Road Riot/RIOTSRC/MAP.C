/*======================================================================*/
/*		TITLE:			MAP				*/
/*		Function:		Map routines and editor		*/
/*									*/
/*		First Edit:		03/25/91			*/
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
#include	"prog/inc/buttons.h"
#include	"prog/inc/message.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"
#include	"grafix/mobs.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:buttons.h"
#include	"inc:message.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"sg:mobs.h"

#endif

typedef	struct	mappos
	{
	short	mapx;
	short	mapy;
	} MAPPOS;

typedef	struct	cardot
	{
	MDTYPE	*op;
	MDTYPE	*carop;
	} CARDOT;

extern	MAPPOS	map1[],map2[],map3[],map4[],map5[],map6[],map7[],map8[];
extern	MAPPOS	map9[],map10[],map11[],map12[];
extern	MDTYPE	obj[];
extern	MOBLK	dotblk;
extern	WORD	*maps[];
extern	WORD	dotxplo[];
extern	WORD	plyrno;
extern	BYTE	map_mode;

#ifdef	DEVELOPMENT
extern	BYTE	edtflg;
#endif

	CARDOT	dots[4];		/* Dot objects		*/
	MAPPOS	*map_ptr;
	MDTYPE	*dotop;
	short	dot_xoff;

	MAPPOS	*map_tbls[]={map1,map2,map3,map4,
			     map5,map6,map7,map8,
			     map9,map10,map11,map12};

	char	dotx[]={-0x40,0x40,-0x40,0x40};
	char	doty[]={-0x40,-0x40,0x40,0x40};


/*	Setup map for this race			*/
set_map(wld)
int	wld;
{
	short	xpos;

#ifdef	DEVELOPMENT
	if (edtflg)
	  {
	  if (map_mode)
	    {
	    xpos = 0;
	    dot_xoff = 0;
	    }
	  else
	    return;
	  }
	else
#endif
	  {
	  if (plyrno)
	    {
	    xpos = 32;
	    dot_xoff = (32 * 8) * 0x40;
	    }
	  else
	    {
	    xpos = 0;
	    dot_xoff = 0;
	    }
	  }

	alf_anim(maps[wld],xpos,6,APLT6);		/* Draw the map		*/
	map_ptr = map_tbls[wld];
	clr_dots();					/* Clear dot array	*/

#ifdef	DEVELOPMENT
	if (edtflg)					/* If editor..		*/
	  {						/* Setup single dot	*/
	  dotop = &obj[setobj(&dotblk,map_ptr->mapx+dot_xoff,map_ptr->mapy,0xFF,0,0)];
	  dotop->mo_pri = 0xE00;			/* High priority	*/
	  }
#endif
}


/*	Clear dots					*/
clr_dots()
{
	CARDOT	*cardot;
	int	i;

	for (i=0, cardot = dots; i < 4; i++, cardot++)			/* Dot loop			*/
	  cardot->op = 0;						/* Clear slot			*/
}
	


/*	Setup a car's dot				*/
set_dot(carptr)
CARBLK	*carptr;
{
	CARDOT	*cardot;
	int	i;
	short	scale;

#ifdef	DEVELOPMENT
	if (edtflg) return;
#endif

	for (i=0, cardot = dots; i < 4; i++, cardot++)			/* Find a dot slot		*/
	  {
	  if (cardot->op == 0)						/* If slot found...		*/
	    {								/* Get dot pointer		*/
	    cardot->carop = carptr->op;					/* Save car object pointer	*/
									/* Get dot object		*/
	    cardot->op = &obj[setobj(&dotblk,map_ptr->mapx+dot_xoff,map_ptr->mapy,0xFF,0,0)];
	    cardot->op->mo_pri = 0xE00;					/* High priority	*/
	    cardot->op->pal = carptr->body_ptr->pal;			/* Get body palette	*/
	    cardot->op->ftime = 1;					/* Change palette		*/
	    return(0);
	    }
	  }

	return(-1);
}



/*	Move the dots					*/
move_dots()
{
	CARDOT	*cardot;
	int	i,j;
	WORD	strip[4];

	for (i=0, cardot = dots; i < 4; i++, cardot++)
	  {
	  if (cardot->op)						/* If active...			*/
	    {
	    strip[i] = cardot->carop->ypos >> 12;			/* Get strip			*/
	    cardot->op->xpos = map_ptr[strip[i]].mapx + dot_xoff;
	    cardot->op->ypos = map_ptr[strip[i]].mapy;
	    }
	  }

	for (i=0, cardot = dots; i < 4; i++, cardot++)
	  {
	  for (j=0; j < 4; j++)
	    {
	    if ((i != j) && (strip[i] == strip[j]))			/* If in the same strip as someone else		*/
	      {
	      if (cardot->op)						/* If active...			*/
		{
		cardot->op->xpos += dotx[i];
	      	cardot->op->ypos += doty[i];
	      	break;
		}
	      }
	    }
	  }
}
	  
	

/*	Move the dot to the right place		*/
move_dot(strip)
WORD	strip;
{
	dotop->xpos = map_ptr[strip].mapx;
	dotop->ypos = map_ptr[strip].mapy;
}



/*	Start Dot explosion			*/
dot_xplo(carptr)
CARBLK	*carptr;
{
	CARDOT	*cardot;
	int	i;

	for (i=0, cardot = dots; i < 4; i++, cardot++)			/* Find owner			*/
	  {
	  if (cardot->carop == carptr->op)				/* If we found it...		*/
	    {								/* Get dot object		*/
	    cardot->op->seqn = dotxplo;				/* Goto explosion picture	*/
	    cardot->op->flags &= ~MO_DIR;				/* Not a direct pix		*/
	    cardot->op->satime = 4;					/* Start animation		*/
	    return;
	    }
	  }
}


/*	End of dot explosion			*/
end_dxpl(op)
MDTYPE	*op;
{
	op->seqn = (WORD *)DOT300;				/* Restore the dot		*/
	op->flags |= (MO_DIR | MO_NEW);				/* Goto direct picture mode	*/
	op->satime = op->catime = 0;				/* No animation			*/
}

