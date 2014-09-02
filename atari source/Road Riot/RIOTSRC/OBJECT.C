/*======================================================================*/
/*		TITLE:			OBJECT				*/
/*		Function:		Object Data Base routines	*/
/*									*/
/*		First Edit:		10/20/88			*/
/*		Project #:						*/
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

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"

#endif

#define	NULLIST		0xFF			/* Null row list value		*/

extern	MOSET	settbl[];
extern	WORD	world,strip_num;
extern	BYTE	game;

#ifdef DEVELOPMENT
extern	BYTE	moemap[16][16];
#endif

	OBLIST	*oblptr;		/* Object list pointer				*/
	OBLIST	*xobjs;			/* Transition Object list pointer		*/
	BYTE	*striptr;		/* Pointer to strip index array			*/
	BYTE	*xstrip;		/* Pointer to transition strip index array	*/



/*	Setup all objects in current strip			*/
/*	Entry:	(strip) = current strip to setup		*/
/*		striptr = pointer to strip index array		*/
makobj(strip)
int	strip;
{
   	OBLIST	*lp;
	int	i,j,strp;
  	long	strip_vpos;
	BYTE	*bp;

	if (striptr == NULL) return;		/* No objects in this world */

#ifdef DEVELOPMENT
	bp = &moemap[strip & 0x0F][0];		/* Clear current strip map */
	for (i=0; i < STRIP_MAX; i++, bp++)
	  *bp = -1;
#endif

	strp = (WORD)strip % (WORD)strip_num;	/* Get leg strip index	*/
	i = striptr[strp];			/* Get object list index */
	if (i == NULLIST) return;		/* Null strip list	*/
	
   	lp = oblptr + i;			/* Get local list pointer */
   	strip_vpos = strp * STRIP_SIZE;	/* Get ypos of strip	*/

	i = j = 0;				/* Init mob count	*/
	while (1)
	  {					/* Setup object		*/

	  j = setobj(settbl[lp->type].mblk,lp->xpos,strip_vpos+lp->ypos,lp->zpos,0,
		      ((lp->attr & 0x3F) << 16) | ((lp->attr & 0x40) << 8));
#ifdef DEVELOPMENT
	    moemap[strip & 0x0F][i++] = j;
#endif

	  if ((lp++)->attr & 0X80)		/* If end of list	*/
	    return;				/* We're done		*/
   	  }
}
