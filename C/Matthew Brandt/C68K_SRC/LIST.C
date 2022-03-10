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

put_sc(scl)
int     scl;
{       switch(scl) {
                case sc_static:
                        fprintf(list,"Static      ");
                        break;
                case sc_auto:
                        fprintf(list,"Auto        ");
                        break;
                case sc_global:
                        fprintf(list,"Global      ");
                        break;
                case sc_external:
                        fprintf(list,"External    ");
                        break;
                case sc_type:
                        fprintf(list,"Type        ");
                        break;
                case sc_const:
                        fprintf(list,"Constant    ");
                        break;
                case sc_member:
                        fprintf(list,"Member      ");
                        break;
                case sc_label:
                        fprintf(list,"Label");
                        break;
                case sc_ulabel:
                        fprintf(list,"Undefined label");
                        break;
                }
}

put_ty(tp)
TYP     *tp;
{       if(tp == 0)
                return;
        switch(tp->type) {
                case bt_char:
                        fprintf(list,"Char");
                        break;
                case bt_short:
                        fprintf(list,"Short");
                        break;
                case bt_enum:
                        fprintf(list,"enum ");
                        goto ucont;
                case bt_long:
                        fprintf(list,"Long");
                        break;
                case bt_unsigned:
                        fprintf(list,"unsigned long");
                        break;
                case bt_float:
                        fprintf(list,"Float");
                        break;
                case bt_double:
                        fprintf(list,"Double");
                        break;
                case bt_pointer:
                        if( tp->val_flag == 0)
                                fprintf(list,"Pointer to ");
                        else
                                fprintf(list,"Array of ");
                        put_ty(tp->btp);
                        break;
                case bt_union:
                        fprintf(list,"union ");
                        goto ucont;
                case bt_struct:
                        fprintf(list,"struct ");
ucont:                  if(tp->sname == 0)
                                fprintf(list,"<no name> ");
                        else
                                fprintf(list,"%s ",tp->sname);
                        break;
                case bt_ifunc:
                case bt_func:
                        fprintf(list,"Function returning ");
                        put_ty(tp->btp);
                        break;
                }
}

list_var(sp,i)
SYM     *sp;
int     i;
{       int     j;
	char    su[80];
	int     upcase();
        for(j = i; j; --j)
                fprintf(list,"    ");
        fprintf(list,"%-10s =%06x ",sp->name,sp->value.u);
        if( sp->storage_class == sc_external)
        {
                strcpy(su,sp->name);
                upcase(su);		/* Convert to upper case */
                fprintf(output,"\tXREF\t%s\n",su);
	}
        else if( sp->storage_class == sc_global )
        {
                strcpy(su,sp->name);
                upcase(su);		/* convert to upper case */
                fprintf(output,"\tXDEF\t%s\n",su);
        }
        put_sc(sp->storage_class);
        put_ty(sp->tp);
        fprintf(list,"\n");
        if(sp->tp == 0)
                return;
        if((sp->tp->type == bt_struct || sp->tp->type == bt_union) &&
                sp->storage_class == sc_type)
                list_table(&(sp->tp->lst),i+1);
}

list_table(t,i)
TABLE   *t;
int     i;
{       SYM     *sp;
        sp = t->head;
        while(sp != NULL) {
                list_var(sp,i);
                sp = sp->next;
                }
}

