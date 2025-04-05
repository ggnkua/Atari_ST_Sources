#include <stdio.h>
#include "proff.h"

struct _proffitem {
		int	Xinval;
		int	Xrmval;
		int	Xoffset;
		int	Xlsval;
		int	Xplval;
		int	Xm1val;
		int	Xm2val;
		int	Xm3val;
		int	Xm4val;
		int	Xfill;
		int	Xrjust;

		char	Xcchar;
		char	Xgenesc;
		char	Xroman;
		char	Xbolding;
		char	Xpaging;
		char	Xautopar;

		struct 	_proffitem *prev;
};

static struct
_proffitem *head = NULL;
static struct
_proffitem *top  = NULL;


char *pusherr = "save: stack overflow.\n";
char *poperr  = "restore: stack underflow.\n";

/*
 * save - save proff parameters
 *
 */
save()
{
	struct _proffitem *sp;
	char *malloc();

	if ((sp = (struct _proffitem *) malloc(sizeof(*sp))) == NULL) {
		fprintf(stderr,pusherr);
		return(FALSE);
	}
	else {
		p_memoryus += sizeof(struct _proffitem);
		if (head == NULL) {	/* first element in stack */
			head = sp;
			top = NULL;	
		}
		
		sp->Xinval = inval;
		sp->Xrmval = rmval;
		sp->Xoffset= offset;
		sp->Xlsval = lsval;
		sp->Xplval = plval;
		sp->Xm1val = m1val;
		sp->Xm2val = m2val;
		sp->Xm3val = m3val;
		sp->Xm4val = m4val;
		sp->Xfill  = fill;
		sp->Xrjust = rjust;
		sp->Xcchar = cchar;
		sp->Xgenesc= genesc;
		sp->Xroman = roman;
		sp->Xbolding = bolding;
		sp->Xpaging = paging;
		sp->Xautopar = autopar;

		sp->prev = top;
		top = sp;
	}
	return(TRUE);
}

restore()
{
	struct _proffitem *sp;

	if (top != NULL) {

		inval = top->Xinval;
		rmval = top->Xrmval;
		offset= top->Xoffset;
		lsval = top->Xlsval;
		plval = top->Xplval;
		m1val = top->Xm1val;
		m2val = top->Xm2val;
		m3val = top->Xm3val;
		m4val = top->Xm4val;
		fill  = top->Xfill;
		rjust = top->Xrjust;
		cchar = top->Xcchar;
		genesc= top->Xgenesc;
		roman = top->Xroman;
		bolding = top->Xbolding;
		paging = top->Xpaging;
		autopar = top->Xautopar;

		sp = top->prev;
		free(top);
		p_memoryus -= sizeof(struct _proffitem);
		if ((top = sp) == NULL)
			head = NULL;
	}
	else
		fprintf(stderr,poperr);
}
