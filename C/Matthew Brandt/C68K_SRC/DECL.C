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
 *	as this notice stays intact. Please forward any enhancements or
 *      questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

TYP             *head = 0;
TYP             *tail = 0;
char            *declid = 0;
TABLE           tagtable = {0,0};
TYP             stdconst = { bt_long, 1, 4, {0, 0}, 0, "stdconst"};

int     imax(i,j)
int     i,j;
{       return (i > j) ? i : j;
}

char    *litlate(s)
char    *s;
{       char    *p;
        p = xalloc(strlen(s) + 1);
        strcpy(p,s);
        return p;
}

TYP     *maketype(bt,siz)
int     bt, siz;
{       TYP     *tp;
        tp = xalloc(sizeof(TYP));
        tp->val_flag = 0;
        tp->size = siz;
        tp->type = bt;
        tp->sname = 0;
        tp->lst.head = 0;
        return tp;
}

int     decl(table)
TABLE   *table;
{       switch (lastst) {
                case kw_char:
                        head = tail = maketype(bt_char,1);
                        getsym();
                        break;
                case kw_short:
                        head = tail = maketype(bt_short,2);
                        getsym();
                        break;
                case kw_int: case kw_long:
                        head = tail = maketype(bt_long,4);
                        getsym();
                        break;
                case kw_unsigned:
                        head = tail = maketype(bt_unsigned,4);
                        getsym();
                        if( lastst == kw_int )
                                getsym();
                        break;
                case id:                /* no type declarator */
                        head = tail = maketype(bt_long,4);
                        break;
                case kw_float:
                        head = tail = maketype(bt_float,4);
                        getsym();
                        break;
                case kw_double:
                        head = tail = maketype(bt_double,8);
                        getsym();
                        break;
                case kw_enum:
                        getsym();
                        declenum(table);
                        break;
                case kw_struct:
                        getsym();
                        declstruct(bt_struct);
                        break;
                case kw_union:
                        getsym();
                        declstruct(bt_union);
                        break;
                }
}

decl1()
{       TYP     *temp1, *temp2, *temp3, *temp4;
        switch (lastst) {
                case id:
                        declid = litlate(lastid);
                        getsym();
                        decl2();
                        break;
                case star:
                        temp1 = maketype(bt_pointer,4);
                        temp1->btp = head;
                        head = temp1;
                        if(tail == NULL)
                                tail = head;
                        getsym();
                        decl1();
                        break;
                case openpa:
                        getsym();
                        temp1 = head;
                        temp2 = tail;
                        head = tail = NULL;
                        decl1();
                        needpunc(closepa);
                        temp3 = head;
                        temp4 = tail;
                        head = temp1;
                        tail = temp2;
                        decl2();
                        temp4->btp = head;
                        if(temp4->type == bt_pointer &&
                                temp4->val_flag != 0 && head != NULL)
                                temp4->size *= head->size;
                        head = temp3;
                        break;
                default:
                        decl2();
                        break;
                }
}

decl2()
{       TYP     *temp1;
        switch (lastst) {
                case openbr:
                        getsym();
                        temp1 = maketype(bt_pointer,0);
                        temp1->val_flag = 1;
                        temp1->btp = head;
                        if(lastst == closebr) {
                                temp1->size = 0;
                                getsym();
                                }
                        else if(head != NULL) {
                                temp1->size = intexpr() * head->size;
                                needpunc(closebr);
                                }
                        else {
                                temp1->size = intexpr();
                                needpunc(closebr);
                                }
                        head = temp1;
                        if( tail == NULL)
                                tail = head;
                        decl2();
                        break;
                case openpa:
                        getsym();
                        temp1 = maketype(bt_func,0);
                        temp1->val_flag = 1;
                        temp1->btp = head;
                        head = temp1;
                        if( lastst == closepa) {
                                getsym();
                                if(lastst == begin)
                                        temp1->type = bt_ifunc;
                                }
                        else
                                temp1->type = bt_ifunc;
                        break;
                }
}

int     alignment(tp)
TYP     *tp;
{       switch(tp->type) {
                case bt_char:           return AL_CHAR;
                case bt_short:          return AL_SHORT;
                case bt_long:           return AL_LONG;
                case bt_enum:           return AL_SHORT;
                case bt_pointer:
                        if(tp->val_flag)
                                return alignment(tp->btp);
                        else
                                return AL_POINTER;
                case bt_float:          return AL_FLOAT;
                case bt_double:         return AL_DOUBLE;
                case bt_struct:
                case bt_union:          return AL_STRUCT;
                default:                return AL_CHAR;
                }
}

int     declare(table,al,ilc,ztype)
/*
 *      process declarations of the form:
 *
 *              <type>  <decl>, <decl>...;
 *
 *      leaves the declarations in the symbol table pointed to by
 *      table and returns the number of bytes declared. al is the
 *      allocation type to assign, ilc is the initial location
 *      counter. if al is sc_member then no initialization will
 *      be processed. ztype should be bt_struct for normal and in
 *      structure declarations and sc_union for in union declarations.
 */
TABLE           *table;
int		       al;
int             ilc;
int		       ztype;
{       SYM     *sp, *sp1;
        TYP     *dhead;
        int     nbytes;
        nbytes = 0;
        decl(table);
        dhead = head;
        for(;;) {
                declid = 0;
                decl1();
                if( declid != 0) {      /* otherwise just struct tag... */
                        sp = xalloc(sizeof(SYM));
                        sp->name = declid;
                        sp->storage_class = al;
                        while( (ilc + nbytes) % alignment(head)) {
                                if( al != sc_member &&
                                        al != sc_external &&
                                        al != sc_auto) {
                                        dseg();
                                        genbyte(0);
                                        }
                                ++nbytes;
                                }
                        if( al == sc_static)
                                sp->value.i = nextlabel++;
                        else if( ztype == bt_union)
                                sp->value.i = ilc;
                        else if( al != sc_auto )
                                sp->value.i = ilc + nbytes;
                        else
                                sp->value.i = -(ilc + nbytes + head->size);
                        sp->tp = head;
                        if( sp->tp->type == bt_func &&
                                sp->storage_class == sc_global )
                                sp->storage_class = sc_external;
                        if(ztype == bt_union)
                                nbytes = imax(nbytes,sp->tp->size);
                        else if(al != sc_external)
                                nbytes += sp->tp->size;
                        if( sp->tp->type == bt_ifunc &&
                                (sp1 = search(sp->name,table->head)) != 0 &&
                                sp1->tp->type == bt_func )
                                {
                                sp1->tp = sp->tp;
                                sp1->storage_class = sp->storage_class;
                                sp1->value.i = sp->value.i;
                                sp = sp1;
                                }
                        else
                                insert(sp,table);
                        if( sp->tp->type == bt_ifunc) { 
/* function body follows */
                                funcbody(sp);
                                return nbytes;
                                }
                        if( (al == sc_global || al == sc_static) &&
                                sp->tp->type != bt_func)
                                doinit(sp);
                        }
                if(lastst == semicolon)
                        break;
                needpunc(comma);
                if(declbegin(lastst) == 0)
                        break;
                head = dhead;
                }
        getsym();
        return nbytes;
}

int     declbegin(st)
int		       st;
{       return st == star || st == id || st == openpa ||
                st == openbr;
}

declenum(table)
TABLE   *table;
{       SYM     *sp;
        TYP     *tp;
        int     evalue;
        if( lastst == id) {
                if((sp = search(lastid,tagtable.head)) == 0) {
                        sp = xalloc(sizeof(SYM));
                        sp->tp = xalloc(sizeof(TYP));
                        sp->tp->type = bt_enum;
                        sp->tp->size = 2;
                        sp->tp->lst.head = sp->tp->btp = 0;
                        sp->storage_class = sc_type;
                        sp->name = litlate(lastid);
                        sp->tp->sname = sp->name;
                        getsym();
                        if( lastst != begin)
                                error(ERR_INCOMPLETE);
                        else    {
                                insert(sp,&tagtable);
                                getsym();
                                enumbody(table);
                                }
                        }
                else
                        getsym();
                head = sp->tp;
                }
        else    {
                tp = xalloc(sizeof(tp));
                tp->type = bt_short;
                if( lastst != begin)
                        error(ERR_INCOMPLETE);
                else    {
                        getsym();
                        enumbody(table);
                        }
                head = tp;
                }
}

enumbody(table)
TABLE   *table;
{       int     evalue;
        SYM     *sp;
        evalue = 0;
        while(lastst == id) {
                sp = xalloc(sizeof(SYM));
                sp->value.i = evalue++;
                sp->name = litlate(lastid);
                sp->storage_class = sc_const;
                sp->tp = &stdconst;
                insert(sp,table);
                getsym();
                if( lastst == comma)
                        getsym();
                else if(lastst != end)
                        break;
                }
        needpunc(end);
}

declstruct(ztype)
/*
 *      declare a structure or union type. ztype should be either
 *      bt_struct or bt_union.
 */
int		       ztype;
{       SYM     *sp;
        TYP     *tp;
        int     slc;
        if(lastst == id) {
                if((sp = search(lastid,tagtable.head)) == 0) {
                        sp = xalloc(sizeof(SYM));
                        sp->name = litlate(lastid);
                        sp->tp = xalloc(sizeof(TYP));
                        sp->tp->type = ztype;
                        sp->tp->lst.head = 0;
                        sp->storage_class = sc_type;
                        sp->tp->sname = sp->name;
                        getsym();
                        if(lastst != begin)
                                error(ERR_INCOMPLETE);
                        else    {
                                insert(sp,&tagtable);
                                getsym();
                                structbody(sp->tp,ztype);
                                }
                        }
                else
                        getsym();
                head = sp->tp;
                }
        else    {
                tp = xalloc(sizeof(TYP));
                tp->type = ztype;
                tp->sname = 0;
                tp->lst.head = 0;
                if( lastst != begin)
                        error(ERR_INCOMPLETE);
                else    {
                        getsym();
                        structbody(tp,ztype);
                        }
                head = tp;
                }
}

structbody(tp,ztype)
TYP             *tp;
int		       ztype;
{       int     slc;
        slc = 0;
        tp->val_flag = 1;
        while( lastst != end) {
                if(ztype == bt_struct)
                        slc += declare(&(tp->lst),sc_member,slc,ztype);
                else
                        slc = imax(slc,declare(&tp->lst,sc_member,0,ztype));
                }
        tp->size = slc;
        getsym();
}

compile()
/*
 *      main compiler routine. this routine parses all of the
 *      declarations using declare which will call funcbody as
 *      functions are encountered.
 */
{       while(lastst != eof) {
                dodecl(sc_global);
                if( lastst != eof)
                        getsym();
                }
        dumplits();
}

dodecl(defclass)
int		       defclass;
{       int     size;
        for(;;) {
            switch(lastst) {
                case kw_register:
                        getsym();
                        if( defclass != sc_auto && defclass != sc_member )
                                error(ERR_ILLCLASS);
                        goto do_decl;
                case id:
                        if(defclass == sc_auto)
                                return;
/*                      else fall through to declare    */
                case kw_char: case kw_int: case kw_short: case kw_unsigned:
                case kw_long: case kw_struct: case kw_union:
                case kw_enum: case kw_void:
                case kw_float: case kw_double:
do_decl:            if( defclass == sc_global)
                        lc_static +=
                            declare(&gsyms,sc_global,lc_static,bt_struct);
                    else if( defclass == sc_auto)
                        lc_auto +=
                            declare(&lsyms,sc_auto,lc_auto,bt_struct);
                    else
                        declare(&lsyms,sc_auto,0,bt_struct);
                    break;
                case kw_static:
                        getsym();
                        if( defclass == sc_member)
                            error(ERR_ILLCLASS);
						if( defclass == sc_auto )
						  lc_static +=
					            declare(&lsyms,sc_static,lc_static,bt_struct);
						else
					          lc_static +=
						    declare(&gsyms,sc_static,lc_static,bt_struct);
                        break;
                case kw_extern:
                        getsym();
                        if( defclass == sc_member)
                            error(ERR_ILLCLASS);
                        ++global_flag;
                        declare(&gsyms,sc_external,0,bt_struct);
                        --global_flag;
                        break;
                default:
                        return;
                }
            }
}

