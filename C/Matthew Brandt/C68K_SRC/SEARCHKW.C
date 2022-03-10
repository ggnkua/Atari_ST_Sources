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

struct kwblk {
        char            *word;
        int		      stype;
        }       keywords[] = {

        {"int", kw_int}, {"char", kw_char}, {"long", kw_long},
        {"float", kw_float}, {"double", kw_double}, {"return", kw_return},
        {"struct", kw_struct}, {"union", kw_union}, {"typedef", kw_typedef},
        {"enum", kw_enum}, {"static", kw_static}, {"auto", kw_auto},
        {"sizeof", kw_sizeof}, {"do", kw_do}, {"if", kw_if},
        {"else", kw_else}, {"for", kw_for},{"switch", kw_switch},
        {"while", kw_while},{"short", kw_short}, {"extern", kw_extern},
        {"case", kw_case}, {"goto", kw_goto}, {"default", kw_default},
        {"register", kw_register}, {"unsigned", kw_unsigned},
        {"break", kw_break}, {"continue", kw_continue}, {"void", kw_void},
        {0, 0} };

searchkw()
{       struct kwblk    *kwbp;
        kwbp = keywords;
        while(kwbp->word != 0) {
                if(strcmp(lastid,kwbp->word) == 0)
                        return lastst = kwbp->stype;
                else
                        ++kwbp;
                }
}

