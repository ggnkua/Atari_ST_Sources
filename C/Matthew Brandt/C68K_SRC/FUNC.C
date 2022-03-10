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
 *	as this notice stays intact. Please forward any enhancements or question
s
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*      function compilation routines           */

funcbody(sp)
/*
 *      funcbody starts with the current symbol being either
 *      the first parameter id or the begin for the local
 *      block. If begin is the current symbol then funcbody
 *      assumes that the function has no parameters.
 */
SYM     *sp;
{       char    *names[20];             /* 20 parameters maximum */
        int     nparms, poffset, i;
        SYM     *sp1, *makeint();
        global_flag = 0;
        poffset = 8;            /* size of return block */
        nparms = 0;
        if(lastst == id) {              /* declare parameters */
                while(lastst == id) {
                        names[nparms++] = litlate(lastid);
                        getsym();
                        if( lastst == comma)
                                getsym();
                        else
                                break;
                        }
                needpunc(closepa);
                dodecl(sc_member);      /* declare parameters */
                for(i = 0;i < nparms;++i) {
                        if( (sp1 = search(names[i],lsyms.head)) == 0)
                                sp1 = makeint(names[i]);
						if( sp1->tp->size < 4 )
						{
							sp1->value.i = poffset +
 (4 - sp1->tp->size);
							poffset += 4;
						}
						else
						{
							sp1->value.i = poffset;
							poffset += sp1->tp->size
;
						}
                        sp1->storage_class = sc_auto;
					}
                }
        if(lastst != begin)
                error(ERR_BLOCK);
        else    {
                cseg();
                gen_strlab(sp->name);
                block();
                funcbottom();
                }
        global_flag = 1;
}

SYM     *makeint(name)
char    *name;
{       SYM     *sp;
        TYP     *tp;
        sp = xalloc(sizeof(SYM));
        tp = xalloc(sizeof(TYP));
        tp->type = bt_long;
        tp->size = 4;
        tp->btp = tp->lst.head = 0;
        tp->sname = 0;
        sp->name = name;
        sp->storage_class = sc_auto;
        sp->tp = tp;
        insert(sp,&lsyms);
        return sp;
}

check_table(head)
SYM     *head;
{       while( head != 0 ) {
                if( head->storage_class == sc_ulabel )
                        fprintf(list,"*** UNDEFINED LABEL - %s\n",head->name);
                head = head->next;
                }
}

funcbottom()
{       nl();
        check_table(lsyms.head);
        lc_auto = 0;
        fprintf(list,"\n\n*** local symbol table ***\n\n");
        list_table(&lsyms,0);
        fprintf(list,"\n\n\n");
        release_local();        /* release local symbols */
}

block()
{       needpunc(begin);
        dodecl(sc_auto);
		cseg();
        genfunc(compound());
        flush_peep();
}

