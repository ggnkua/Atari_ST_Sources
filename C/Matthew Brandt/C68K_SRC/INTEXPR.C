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

intexpr()       /* simple integer value */
{       int     temp;
        SYM     *sp;
        if(lastst == id) {
                sp = search(lastid,lsyms.head);
                if( sp == NULL)
                        sp = search(lastid,gsyms.head);
                if(sp == NULL) {
                        error(ERR_UNDEFINED);
                        getsym();
                        return 0;
                        }
                if(sp->storage_class != sc_const) {
                        error(ERR_SYNTAX);
                        getsym();
                        return 0;
                        }
                getsym();
                return sp->value.i;
                }
        else if(lastst == iconst) {
                temp = ival;
                getsym();
                return temp;
                }
        getsym();
        error(ERR_SYNTAX);
        return 0;
}
