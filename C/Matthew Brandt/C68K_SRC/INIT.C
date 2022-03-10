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

doinit(sp)
SYM     *sp;
{       dseg();                 /* initialize into data segment */
        nl();                   /* start a new line in object */
        if(sp->storage_class == sc_static)
                put_label(sp->value.i);
        else
                gen_strlab(sp->name);
        if( lastst != assign)
                genstorage(sp->tp->size);
        else    {
                getsym();
                inittype(sp->tp);
                }
        endinit();
}

int     inittype(tp)
TYP     *tp;
{       int     nbytes;
        switch(tp->type) {

                case bt_char:
                        nbytes = initchar();
                        break;
                case bt_short:
                case bt_enum:
                        nbytes = initshort();
                        break;
                case bt_pointer:
                        if( tp->val_flag)
                                nbytes = initarray(tp);
                        else
                                nbytes = initpointer();
                        break;
                case bt_long:
                        nbytes = initlong();
                        break;
                case bt_struct:
                        nbytes = initstruct(tp);
                        break;
                default:
                        error(ERR_NOINIT);
                        nbytes = 0;
                }
        return nbytes;
}

initarray(tp)
TYP     *tp;
{       int     nbytes;
        char    *p;
        nbytes = 0;
        if( lastst == begin) {
                getsym();               /* skip past the brace */
                while(lastst != end) {
                        nbytes += inittype(tp->btp);
                        if( lastst == comma)
                                getsym();
                        else if( lastst != end)
                                error(ERR_PUNCT);
                        }
                getsym();               /* skip closing brace */
                }
        else if( lastst == sconst && tp->btp->type == bt_char) {
                nbytes = strlen(laststr) + 1;
                p = laststr;
                while( *p )
                        genbyte(*p++);
                genbyte(0);
                getsym();
                }
        else if( lastst != semicolon)
                error(ERR_ILLINIT);
        if( nbytes < tp->size) {
                genstorage( tp->size - nbytes);
                nbytes = tp->size;
                }
        else if( tp->size != 0 && nbytes > tp->size)
                error(ERR_INITSIZE);    /* too many initializers */
        return nbytes;
}

initstruct(tp)
TYP     *tp;
{       SYM     *sp;
        int     nbytes;
        needpunc(begin);
        nbytes = 0;
        sp = tp->lst.head;      /* start at top of symbol table */
        while(sp != 0) {
                while(nbytes < sp->value.i)     /* align properly */
                        nbytes += genbyte(0);
                nbytes += inittype(sp->tp);
                if( lastst == comma)
                        getsym();
                else if(lastst == end)
                        break;
                else
                        error(ERR_PUNCT);
                sp = sp->next;
                }
        if( nbytes < tp->size)
                genstorage( tp->size - nbytes);
        needpunc(end);
        return tp->size;
}

initchar()
{       genbyte(intexpr());
        return 1;
}

initshort()
{       genword(intexpr());
        return 2;
}

initlong()
{       genlong(intexpr());
        return 4;
}

initpointer()
{       SYM     *sp;
        if(lastst == and) {     /* address of a variable */
                getsym();
                if( lastst != id)
                        error(ERR_IDEXPECT);
                else if( (sp = gsearch(lastid)) == 0)
                        error(ERR_UNDEFINED);
                else    {
                        getsym();
                        if( lastst == plus || lastst == minus)
                                genref(sp,intexpr());
                        else
                                genref(sp,0);
                        if( sp->storage_class == sc_auto)
                                error(ERR_NOINIT);
                        }
                }
        else if(lastst == sconst) {
                gen_labref(stringlit(laststr));
                getsym();
                }
        else
                genlong(intexpr());
        endinit();
        return 4;       /* pointers are 4 bytes long */
}

endinit()
{       if( lastst != comma && lastst != semicolon && lastst != end) {
                error(ERR_PUNCT);
                while( lastst != comma && lastst != semicolon && lastst != end)
                        getsym();
                }
}

