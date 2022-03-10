#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include        "gen.h"
#include        "cglbdec.h"

/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

SYM     *search(na,thead)
char    *na;
SYM     *thead;
{       while( thead != 0) {
                if(strcmp(thead->name,na) == 0)
                        return thead;
                thead = thead->next;
                }
        return 0;
}

SYM     *gsearch(na)
char    *na;
{       SYM     *sp;
        if( (sp = search(na,lsyms.head)) == 0)
                sp = search(na,gsyms.head);
        return sp;
}

insert(sp,table)
SYM     *sp;
TABLE   *table;
{       if( search(sp->name,table->head) == 0) {
                if( table->head == 0)
                        table->head = table->tail = sp;
                else    {
                        table->tail->next = sp;
                        table->tail = sp;
                        }
                sp->next = 0;
                }
        else
                error(ERR_DUPSYM);
}
