/*****************************************************************************/
/* HISTORY:								     */
/*		setslvlist()						     */
/* 11/10/89  -  dotext()    - Added cpabt = 0;				     */
/*		              Problems resulted in that the routine doesn't  */
/*			      clear the flag if no errors occur, thereby     */
/*			      leaving the old state in the flag.	     */
/*****************************************************************************/
#include	<obdefs.h>
#include	<gemdefs.h>
#include	"comp.h"

#define		DEBUG		0

#define		LBRK		1
#define		SLAVE		2
#define		LBRKSLAVE	3
#define		OUTPUT		4
#define		SLAVEOUTPUT	6
#define		LBRKSLAVEOUTPUT	7

/*	Device Type = sdevm	*/
#define		DNUM		4	/* number of graphics devices	*/
#define		SLOR		0	/* Low    Res	320  x 200 	*/
#define		SMDR		1	/* Medium Res	640  x 200 	*/
#define		SHIR		2	/* High   Res	640  x 400	*/
#define		PRNT		3	/* Laser  Ptr	2400 x 3180	*/

extern	unsigned	sdevm;		/* Current device mode		*/
extern	unsigned	zrat;		/* Output zoom ratio in 10ths	*/
extern 	char		cpabt;		/* composition abort flag	*/
extern	char		*fend(), *bend(), *malloc();
extern	unsigned long	init_y;
extern	unsigned	init_x;

struct slvll	*slv;		/* slave list pointer		*/
FDB		*orect_MFDB;	/* output rectangle MFDB	*/
int		clip_X0;	/* output rectangle clip X0	*/
int		clip_X1;	/* output rectangle clip X1	*/
int		clip_Y0;	/* output rectangle clip Y0	*/
int		clip_Y1;	/* output rectangle clip Y1	*/
static
struct txtattr	savecp;		/* save cp struct for multi-op	*/

/****************************************************************
			Text Object Handler
	Returns pointer to next text if cpabt is 0 or 8
	else -1L for all other values of cpabt and 0L if
	OUTPUT only is specified.
	cpabt	0	-- no error
		1	-- char has no flash position
		2	-- double floating accent found
		3	-- double space char found
		4	-- line measure too short
		5	-- line break error (no space)
		6	-- text buffer full
		7	-- no memory for slave or tag
		8	-- Hit Region Feed
****************************************************************/
char	*dotext(text,ptsarray,dmfdb,operation,done)
struct textobj	*text;
int		ptsarray[];
FDB		*dmfdb;
int		operation;
int		*done;
{
	char	*cptr;

	cpabt = 0;
	switch(operation) {
	case	LBRK:			/* 1 */
		cptr = fend(text,done);
		break;
	case	SLAVE:			/* 2 */
		setcpXY(ptsarray);
		cptr = bend(text,done);
		break;
	case	OUTPUT:			/* 4 */
		slv = text->slvlist;
		outslave(ptsarray,dmfdb);
		cptr = (char *)0L;
		break;
	case	LBRKSLAVE:		/* 3 */
	case	LBRKSLAVEOUTPUT:	/* 7 */
		f_move(&cp,&savecp,sizeof(cp));	/* save cp for bend()	*/
		cptr = fend(text,done);
		if (!cpabt || cpabt == 4 || cpabt == 8)
			f_move(&savecp,&cp,sizeof(cp));	/* restore cp..	*/
		else	break;
	case	SLAVEOUTPUT:		/* 6 */
		setcpXY(ptsarray);
		cptr = bend(text,done);
		if (operation != LBRKSLAVE) {	/* if output required	*/
			if (!cpabt || cpabt == 4 || cpabt == 8)
				outslave(ptsarray,dmfdb);
		}
		break;
	}
	return(cptr);
}

outslave(ptsarray,dmfdb)
int	ptsarray[];
FDB	*dmfdb;
{
	orect_MFDB = dmfdb;
	zrat = ptsarray[8];
	if (ptsarray[10]) {
		clip_X0 = ptsarray[11];
		clip_Y0 = ptsarray[12];
		clip_X1 = ptsarray[13];
		clip_Y1 = ptsarray[14];
	}
	else {
		clip_X0 = 0;
		clip_Y0 = 0;
		clip_X1 = dmfdb->fd_w;
		clip_Y1 = dmfdb->fd_h;
	}
	if (sdevm == PRNT)
		newdev(1);
	show_slv();
	if (sdevm == PRNT)
		newdev(0);
}

setcpXY(ptsarray)
int	ptsarray[];
{
	init_x	= ptsarray[0];
	init_y	= *((unsigned long *)(ptsarray + 1));
}

struct slvll	*getslvbuf()
{
	struct slvll	*slvptr;

	if (!(slvptr = (struct slvll *)malloc(sizeof(struct slvll))))
        {
	    IF_close();
	    IF_open(0);
	    if (!(slvptr = (struct slvll *)malloc(sizeof(struct slvll))))
		     return(0L);
        }

	if (!(slvptr->bufptr = malloc(UTSIZE)))
        {
	     IF_close();
	     IF_open(0);
	     if (!(slvptr->bufptr = malloc(UTSIZE)))
             {
		free(slvptr);
		return(0L);
	     }
	}
	slvptr->fptr = (struct slvll *)0L;
	return(slvptr);
}

setslvlist(text)
struct	textobj *text;
{
	struct	slvll	*nslv;

	cpabt = 0;
	if (text->slvlist) {
		slv = text->slvlist;		/* set to begin list	*/
		while (slv->fptr)		/* not end of list...	*/
			slv	= slv->fptr;
		if (!(nslv = getslvbuf()))	/* get new list member	*/
			cpabt = 7;
		else {
			slv->fptr = nslv;	/* add member to list	*/
			slv	= nslv;
		}
	}
	else
	if (!(slv = getslvbuf()))
		cpabt = 7;
	else	text->slvlist = slv;
}

freeslvlist(slvlist)
struct	slvll	*slvlist;
{
	struct	slvll	*slvptr = slvlist;

	if (slvptr != (struct slvll *)0L)
	  for (; ;) {
		free(slvptr->bufptr);
		free(slvptr);
		if (slvptr->fptr == (struct slvll *)0L)
			break;
		else	slvptr = slvptr->fptr;
	  }
}
