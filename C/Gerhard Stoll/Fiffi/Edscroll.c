/****************************************************************
*
* Makes an F(BOX)TEXT object scrollable when MagiC is running
*
* If <is_scroll> is FALSE, then the text field will only be 
* converted to a user character-string.
*
* In the RCS the text field should be left empty, the mask and 
* the validation character-string must, however, be input as the
* RCS otherwise goes on strike.
* For scrolling fields a new mask has to be created, the one 
* installed in the .RSC file can not be used because it is too short.
* The mask created here consists only of '_' characters, because this 
* covers 99.9% of all application cases for scrolling objects. 
* The length of the validation character-string is of no importance, 
* i.e. it must be at least 1, because the AES automatically replicates 
* the last character of the validation string until it reaches the 
* length of the text field.
*
* The maximum length for the input character-string is in each 
* case (TEDINFO.te_txtlen - 1).
*
****************************************************************/

#include	<portab.h>
#include	<mt_aes.h>
#include <string.h>
#include	"edscroll.h"

#ifndef NULL
#define NULL 0L
#endif

void InitScrlted(OBJECT *o, WORD is_scroll, XTED *xted, char *txt, char *tmplt, WORD len)
{
	TEDINFO *t;

	t = o->ob_spec.tedinfo;
	t->te_just = TE_LEFT;		/* Important! */
	t->te_ptext = txt;
	if	(is_scroll)
		{
		memset(tmplt, '_', len);	/* New mask */
		tmplt[len] = '\0';
		xted->xte_ptmplt = tmplt;
		xted->xte_pvalid = t->te_pvalid;
		xted->xte_vislen = t->te_tmplen - 1;
		xted->xte_scroll = 0;
		
		t->te_tmplen = len+1;
		t->te_ptmplt = NULL;
		t->te_pvalid = (void *) xted;
		}
	t->te_txtlen = t->te_tmplen;
}
