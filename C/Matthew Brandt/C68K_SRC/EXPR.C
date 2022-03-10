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
 *as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

TYP             stdint = { bt_long, 0, 4, {0, 0}, 0, 0 };
TYP             stdchar = {bt_char, 0, 1, {0, 0}, 0, 0 };
TYP             stdstring = {bt_pointer, 1, 4, {0, 0}, &stdchar, 0};
TYP             stdfunc = {bt_func, 1, 0, {0, 0}, &stdint, 0};
extern TYP      *head;          /* shared with decl */

/*
 *      expression evaluation
 *
 *      this set of routines builds a parse tree for an expression.
 *      no code is generated for the expressions during the build,
 *      this is the job of the codegen module. for most purposes
 *      expression() is the routine to call. it will allow all of
 *      the C operators. for the case where the comma operator is
 *      not valid (function parameters for instance) call exprnc().
 *
 *      each of the routines returns a pointer to a describing type
 *      structure. each routine also takes one parameter which is a
 *      pointer to an expression node by reference (address of pointer).
 *      the completed expression is returned in this pointer. all
 *      routines return either a pointer to a valid type or NULL if
 *      the hierarchy of the next operator is too low or the next
 *      symbol is not part of an expression.
 */

TYP     *expression();  /* forward declaration */
TYP     *exprnc();      /* forward declaration */
TYP     *unary();       /* forward declaration */

struct enode    *makenode(nt, v1, v2)
/*
 *      build an expression node with a node type of nt and values
 *      v1 and v2.
 */
int			     nt;
char            *v1, *v2;
{       struct enode    *ep;
        ep = xalloc(sizeof(struct enode));
        ep->nodetype = nt;
        ep->constflag = 0;
        ep->v.p[0] = v1;
        ep->v.p[1] = v2;
        return ep;
}

deref(node,tp)
/*
 *      build the proper dereference operation for a node using the
 *      type pointer tp.
 */
struct enode    **node;
TYP             *tp;
{       switch( tp->type ) {
                case bt_char:
                        *node = makenode(en_b_ref,*node,0);
                        tp = &stdint;
                        break;
                case bt_short:
                case bt_enum:
                        *node = makenode(en_w_ref,*node,0);
                        tp = &stdint;
                        break;
                case bt_long:
                case bt_pointer:
                case bt_unsigned:
                        *node = makenode(en_l_ref,*node,0);
                        break;
                default:
                        error(ERR_DEREF);
                        break;
                }
        return tp;
}

TYP     *nameref(node)
/*
 *      nameref will build an expression tree that references an
 *      identifier. if the identifier is not in the global or
 *      local symbol table then a look-ahead to the next character
 *      is done and if it indicates a function call the identifier
 *      is coerced to an external function name. non-value references
 *      generate an additional level of indirection.
 */
struct enode    **node;
{       SYM             *sp;
        TYP             *tp;
        sp = gsearch(lastid);
        if( sp == 0 ) {
                while( isspace(lastch) )
                        getch();
                if( lastch == '(') {
                        ++global_flag;
                        sp = xalloc(sizeof(SYM));
                        sp->tp = &stdfunc;
                        sp->name = litlate(lastid);
                        sp->storage_class = sc_external;
                        insert(sp,&gsyms);
                        --global_flag;
                        tp = &stdfunc;
                        *node = makenode(en_nacon,sp->name,0);
                        (*node)->constflag = 1;
                        }
                else    {
                        tp = 0;
                        error(ERR_UNDEFINED);
                        }
                }
        else    {
                if( (tp = sp->tp) == 0 ) {
                        error(ERR_UNDEFINED);
                        return 0;       /* guard against untyped entries */
                        }
                switch( sp->storage_class ) {
                        case sc_static:
                                *node = makenode(en_labcon,sp->value.i,0);
                                (*node)->constflag = 1;
                                break;
                        case sc_global:
                        case sc_external:
                                *node = makenode(en_nacon,sp->name,0);
                                (*node)->constflag = 1;
                                break;
                        case sc_const:
                                *node = makenode(en_icon,sp->value.i,0);
                                (*node)->constflag = 1;
                                break;
                        default:        /* auto and any errors */
                                if( sp->storage_class != sc_auto)
                                        error(ERR_ILLCLASS);
                                *node = makenode(en_autocon,sp->value.i,0);
                                break;
                        }
                if( tp->val_flag == 0)
                        tp = deref(node,tp);
                }
        getsym();
        return tp;
}

struct enode    *parmlist()
/*
 *      parmlist will build a list of parameter expressions in
 *      a function call and return a pointer to the last expression
 *      parsed. since parameters are generally pushed from right
 *      to left we get just what we asked for...
 */
{       struct enode    *ep1, *ep2;
        ep1 = 0;
        while( lastst != closepa) {
                exprnc( &ep2);          /* evaluate a parameter */
                ep1 = makenode(en_void,ep2,ep1);
                if( lastst != comma)
                        break;
                getsym();
                }
        return ep1;
}

int     castbegin(st)
/*
 *      return 1 if st in set of [ kw_char, kw_short, kw_long, kw_int,
 *      kw_float, kw_double, kw_struct, kw_union ]
 */
int     st;
{       return  st == kw_char || st == kw_short || st == kw_int ||
                st == kw_long || st == kw_float || st == kw_double ||
                st == kw_struct || st == kw_union || st== kw_unsigned;
}

TYP     *primary(node)
/*
 *      primary will parse a primary expression and set the node pointer
 *      returning the type of the expression parsed. primary expressions
 *      are any of:
 *                      id
 *                      constant
 *                      string
 *                      ( expression )
 *                      primary[ expression ]
 *                      primary.id
 *                      primary->id
 *                      primary( parameter list )
 */
struct enode    **node;
{       struct enode    *pnode, *qnode, *rnode;
        SYM             *sp;
        TYP             *tptr;
        switch( lastst ) {

                case id:
                        tptr = nameref(&pnode);
                        break;
                case iconst:
                        tptr = &stdint;
                        pnode = makenode(en_icon,ival,0);
                        pnode->constflag = 1;
                        getsym();
                        break;
                case sconst:
                        tptr = &stdstring;
                        pnode = makenode(en_labcon,stringlit(laststr),0);
                        pnode->constflag = 1;
                        getsym();
                        break;
                case openpa:
                        getsym();
                        if( !castbegin(lastst) ) {
                                tptr = expression(&pnode);
                                needpunc(closepa);
                                }
                        else    {       /* cast operator */
                                decl(); /* do cast declaration */
                                decl1();
                                tptr = head;
                                needpunc(closepa);
                                if( unary(&pnode) == 0 ) {
                                        error(ERR_IDEXPECT);
                                        tptr = 0;
                                        }
                                }
                        break;
                default:
                        return 0;
                }
        for(;;) {
                switch( lastst ) {
                        case openbr:    /* build a subscript reference */
                                if( tptr->type != bt_pointer )
                                        error(ERR_NOPOINTER);
                                else
                                        tptr = tptr->btp;
                                getsym();
                                qnode = makenode(en_icon,tptr->size,0);
                                qnode->constflag = 1;
                                expression(&rnode);
/*
 *      we could check the type of the expression here...
 */
                                qnode = makenode(en_mul,qnode,rnode);
                                qnode->constflag = rnode->constflag &&
                                        qnode->v.p[0]->constflag;
                                pnode = makenode(en_add,qnode,pnode);
                                pnode->constflag = qnode->constflag &&
                                        pnode->v.p[1]->constflag;
                                if( tptr->val_flag == 0 )
                                        tptr = deref(&pnode,tptr);
                                needpunc(closebr);
                                break;
                        case pointsto:
                                if( tptr->type != bt_pointer )
                                        error(ERR_NOPOINTER);
                                else
                                        tptr = tptr->btp;
                                if( tptr->val_flag == 0 )
                                        pnode = makenode(en_l_ref,pnode,0);
/*
 *      fall through to dot operation
 */
                        case dot:
                                getsym();       /* past -> or . */
                                if( lastst != id )
                                        error(ERR_IDEXPECT);
                                else    {
                                        sp = search(lastid,tptr->lst.head);
                                        if( sp == 0 )
                                                error(ERR_NOMEMBER);
                                        else{
                                            tptr = sp->tp;
                                            qnode = makenode(en_icon,sp->value.i,0);
                                            qnode->constflag = 1;
                                            pnode = makenode(en_add,pnode,qnode);
                                            pnode->constflag = pnode->v.p[0]->constflag;
                                            if( tptr->val_flag == 0 )
                                                tptr = deref(&pnode,tptr);
                                            }
                                        getsym();       /* past id */
                                        }
                                break;
                        case openpa:    /* function reference */
                                getsym();
                                if( tptr->type != bt_func &&
                                        tptr->type != bt_ifunc )
                                        error(ERR_NOFUNC);
                                else
                                        tptr = tptr->btp;
                                pnode = makenode(en_fcall,pnode,parmlist());
                                needpunc(closepa);
                                break;
                        default:
                                goto fini;
                        }
                }
fini:   *node = pnode;
        return tptr;
}

int     lvalue(node)
/*
 *      this function returns true if the node passed is an lvalue.
 *      this can be qualified by the fact that an lvalue must have
 *      one of the dereference operators as it's top node.
 */
struct enode    *node;
{       switch( node->nodetype ) {
                case en_b_ref:
                case en_w_ref:
                case en_l_ref:
                case en_ub_ref:
                case en_uw_ref:
                case en_ul_ref:
                        return 1;
                case en_cbl:
                case en_cwl:
                case en_cbw:
                        return lvalue(node->v.p[0]);
                }
        return 0;
}

TYP     *unary(node)
/*
 *      unary evaluates unary expressions and returns the type of the
 *      expression evaluated. unary expressions are any of:
 *
 *                      primary
 *                      primary++
 *                      primary--
 *                      !unary
 *                      ~unary
 *                      ++unary
 *                      --unary
 *                      -unary
 *                      *unary
 *                      &unary
 *                      (typecast)unary
 *                      sizeof(typecast)
 *
 */
struct enode    **node;
{       TYP             *tp, *tp1;
        struct enode    *ep1, *ep2;
        int             flag, i;
        flag = 0;
        switch( lastst ) {
                case autodec:
                        flag = 1;
                /* fall through to common increment */
                case autoinc:
                        getsym();
                        tp = unary(&ep1);
                        if( tp == 0 ) {
                                error(ERR_IDEXPECT);
                                return 0;
                                }
                        if( lvalue(ep1)) {
                                if( tp->type == bt_pointer )
                                        ep2 = makenode(en_icon,tp->btp->size,0);
                                 else
                                        ep2 = makenode(en_icon,1,0);
                                ep2->constflag = 1;
                                ep1 = makenode(flag ? en_assub : en_asadd,ep1,ep2);
                                }
                        else
                                error(ERR_LVALUE);
                        break;
                case minus:
                        getsym();
                        tp = unary(&ep1);
                        if( tp == 0 ) {
                                error(ERR_IDEXPECT);
                                return 0;
                                }
                        ep1 = makenode(en_uminus,ep1,0);
                        ep1->constflag = ep1->v.p[0]->constflag;
                        break;
                case not:
                        getsym();
                        tp = unary(&ep1);
                        if( tp == 0 ) {
                                error(ERR_IDEXPECT);
                                return 0;
                                }
                        ep1 = makenode(en_not,ep1,0);
                        ep1->constflag = ep1->v.p[0]->constflag;
                        break;
                case compl:
                        getsym();
                        tp = unary(&ep1);
                        if( tp == 0 ) {
                                error(ERR_IDEXPECT);
                                return 0;
                                }
                        ep1 = makenode(en_compl,ep1,0);
                        ep1->constflag = ep1->v.p[0]->constflag;
                        break;
                case star:
                        getsym();
                        tp = unary(&ep1);
                        if( tp == 0 ) {
                                error(ERR_IDEXPECT);
                                return 0;
                                }
                        if( tp->btp == 0 )
                                error(ERR_DEREF);
                        else
                                tp = tp->btp;
                        if( tp->val_flag == 0 )
                                tp = deref(&ep1,tp);
                        break;
                case and:
                        getsym();
                        tp = unary(&ep1);
                        if( tp == 0 ) {
                                error(ERR_IDEXPECT);
                                return 0;
                                }
                        if( lvalue(ep1))
                                ep1 = ep1->v.p[0];
                        tp1 = xalloc(sizeof(TYP));
                        tp1->size = 4;
                        tp1->type = bt_pointer;
                        tp1->btp = tp;
                        tp1->val_flag = 0;
                        tp1->lst.head = 0;
                        tp1->sname = 0;
                        tp = tp1;
                        break;
                case kw_sizeof:
                        getsym();
                        needpunc(openpa);
                        decl();
                        decl1();
                        if( head != 0 )
                                ep1 = makenode(en_icon,head->size,0);
                        else    {
                                error(ERR_IDEXPECT);
                                ep1 = makenode(en_icon,1,0);
                                }
                        ep1->constflag = 1;
                        tp = &stdint;
                        needpunc(closepa);
                        break;
                default:
                        tp = primary(&ep1);
                        if( tp != 0 ) {
                                if( tp->type == bt_pointer )
                                        i = tp->btp->size;
                                else
                                        i = 1;
                                if( lastst == autoinc) {
                                        if( lvalue(ep1) )
                                                ep1 = makenode(en_ainc,ep1,i);
                                        else
                                                error(ERR_LVALUE);
                                        getsym();
                                        }
                                else if( lastst == autodec ) {
                                        if( lvalue(ep1) )
                                                ep1 = makenode(en_adec,ep1,i);
                                        else
                                                error(ERR_LVALUE);
                                        getsym();
                                        }
                                }
                        break;
                }
        *node = ep1;
        return tp;
}

TYP     *forcefit(node1,tp1,node2,tp2)
/*
 *      forcefit will coerce the nodes passed into compatable
 *      types and return the type of the resulting expression.
 */
struct enode    **node1, **node2;
TYP             *tp1, *tp2;
{       switch( tp1->type ) {
                case bt_char:
                case bt_short:
                case bt_long:
                        if( tp2->type == bt_long ||
                                tp2->type == bt_short ||
                                tp2->type == bt_char)
                                return &stdint;
                        else if( tp2->type == bt_pointer ||
                                tp2->type == bt_unsigned )
                                return tp2;
                        break;
                case bt_pointer:
                        if( isscalar(tp2) || tp2->type == bt_pointer)
                                return tp1;
                        break;
                case bt_unsigned:
                        if( tp2->type == bt_pointer )
                                return tp2;
                        else if( isscalar(tp2) )
                                return tp1;
                        break;
                }
        error( ERR_MISMATCH );
        return tp1;
}

int     isscalar(tp)
/*
 *      this function returns true when the type of the argument is
 *      one of char, short, unsigned, or long.
 */
TYP             *tp;
{       return  tp->type == bt_char ||
                tp->type == bt_short ||
                tp->type == bt_long ||
                tp->type == bt_unsigned;
}

TYP     *multops(node)
/*
 *      multops parses the multiply priority operators. the syntax of
 *      this group is:
 *
 *              unary
 *              multop * unary
 *              multop / unary
 *              multop % unary
 */
struct enode    **node;
{       struct enode    *ep1, *ep2;
        TYP             *tp1, *tp2;
        int		      oper;
        tp1 = unary(&ep1);
        if( tp1 == 0 )
                return 0;
        while( lastst == star || lastst == divide || lastst == modop ) {
                oper = lastst;
                getsym();       /* move on to next unary op */
                tp2 = unary(&ep2);
                if( tp2 == 0 ) {
                        error(ERR_IDEXPECT);
                        *node = ep1;
                        return tp1;
                        }
                tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                switch( oper ) {
                        case star:
                                if( tp1->type == bt_unsigned )
                                        ep1 = makenode(en_umul,ep1,ep2);
                                else
                                        ep1 = makenode(en_mul,ep1,ep2);
                                break;
                        case divide:
                                if( tp1->type == bt_unsigned )
                                        ep1 = makenode(en_udiv,ep1,ep2);
                                else
                                        ep1 = makenode(en_div,ep1,ep2);
                                break;
                        case modop:
                                if( tp1->type == bt_unsigned )
                                        ep1 = makenode(en_umod,ep1,ep2);
                                else
                                        ep1 = makenode(en_mod,ep1,ep2);
                                break;
                        }
                ep1->constflag = ep1->v.p[0]->constflag &&
                        ep1->v.p[1]->constflag;
                }
        *node = ep1;
        return tp1;
}

TYP     *addops(node)
/*
 *      addops handles the addition and subtraction operators.
 */
struct enode    **node;
{       struct enode    *ep1, *ep2, *ep3;
        TYP             *tp1, *tp2;
        int             oper, i;
        tp1 = multops(&ep1);
        if( tp1 == 0 )
                return 0;
        while( lastst == plus || lastst == minus ) {
                oper = (lastst == plus);
                getsym();
                tp2 = multops(&ep2);
                if( tp2 == 0 ) {
                        error(ERR_IDEXPECT);
                        *node = ep1;
                        return tp1;
                        }
                if( tp1->type == bt_pointer ) {
                        tp2 = forcefit(0,&stdint,&ep2,tp2);
                        ep3 = makenode(en_icon,tp1->btp->size,0);
                        ep3->constflag = 1;
                        ep2 = makenode(en_mul,ep3,ep2);
                        ep2->constflag = ep2->v.p[1]->constflag;
                        }
                else if( tp2->type == bt_pointer ) {
                        tp1 = forcefit(0,&stdint,&ep1,tp1);
                        ep3 = makenode(en_icon,tp2->btp->size,0);
                        ep3->constflag = 1;
                        ep1 = makenode(en_mul,ep3,ep1);
                        ep1->constflag = ep1->v.p[1]->constflag;
                        }
                tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                ep1 = makenode( oper ? en_add : en_sub,ep1,ep2);
                ep1->constflag = ep1->v.p[0]->constflag &&
                        ep1->v.p[1]->constflag;
                }
        *node = ep1;
        return tp1;
}

TYP     *shiftop(node)
/*
 *      shiftop handles the shift operators << and >>.
 */
struct enode    **node;
{       struct enode    *ep1, *ep2;
        TYP             *tp1, *tp2;
        int             oper;
        tp1 = addops(&ep1);
        if( tp1 == 0)
                return 0;
        while( lastst == lshift || lastst == rshift) {
                oper = (lastst == lshift);
                getsym();
                tp2 = addops(&ep2);
                if( tp2 == 0 )
                        error(ERR_IDEXPECT);
                else    {
                        tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                        ep1 = makenode(oper ? en_lsh : en_rsh,ep1,ep2);
                        ep1->constflag = ep1->v.p[0]->constflag &&
                                ep1->v.p[1]->constflag;
                        }
                }
        *node = ep1;
        return tp1;
}

TYP     *relation(node)
/*
 *      relation handles the relational operators < <= > and >=.
 */
struct enode    **node;
{       struct enode    *ep1, *ep2;
        TYP             *tp1, *tp2;
        int             nt;
        tp1 = shiftop(&ep1);
        if( tp1 == 0 )
                return 0;
        for(;;) {
                switch( lastst ) {

                        case lt:
                                if( tp1->type == bt_unsigned )
                                        nt = en_ult;
                                else
                                        nt = en_lt;
                                break;
                        case gt:
                                if( tp1->type == bt_unsigned )
                                        nt = en_ugt;
                                else
                                        nt = en_gt;
                                break;
                        case leq:
                                if( tp1->type == bt_unsigned )
                                        nt = en_ule;
                                else
                                        nt = en_le;
                                break;
                        case geq:
                                if( tp1->type == bt_unsigned )
                                        nt = en_uge;
                                else
                                        nt = en_ge;
                                break;
                        default:
                                goto fini;
                        }
                getsym();
                tp2 = shiftop(&ep2);
                if( tp2 == 0 )
                        error(ERR_IDEXPECT);
                else    {
                        tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                        ep1 = makenode(nt,ep1,ep2);
                        ep1->constflag = ep1->v.p[0]->constflag &&
                                ep1->v.p[1]->constflag;
                        }
                }
fini:   *node = ep1;
        return tp1;
}

TYP     *equalops(node)
/*
 *      equalops handles the equality and inequality operators.
 */
struct enode    **node;
{       struct enode    *ep1, *ep2;
        TYP             *tp1, *tp2;
        int             oper;
        tp1 = relation(&ep1);
        if( tp1 == 0 )
                return 0;
        while( lastst == eq || lastst == neq ) {
                oper = (lastst == eq);
                getsym();
                tp2 = relation(&ep2);
                if( tp2 == 0 )
                        error(ERR_IDEXPECT);
                else    {
                        tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                        ep1 = makenode( oper ? en_eq : en_ne,ep1,ep2);
                        ep1->constflag = ep1->v.p[0]->constflag &&
                                ep1->v.p[1]->constflag;
                        }
                }
        *node = ep1;
        return tp1;
}

TYP     *binop(node,xfunc,nt,sy)
/*
 *      binop is a common routine to handle all of the legwork and
 *      error checking for bitand, bitor, bitxor, andop, and orop.
 */
struct enode    **node;
TYP             *(*xfunc)();
int             nt, sy;
{       struct enode    *ep1, *ep2;
        TYP             *tp1, *tp2;
        tp1 = (*xfunc)(&ep1);
        if( tp1 == 0 )
                return 0;
        while( lastst == sy ) {
                getsym();
                tp2 = (*xfunc)(&ep2);
                if( tp2 == 0 )
                        error(ERR_IDEXPECT);
                else    {
                        tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                        ep1 = makenode(nt,ep1,ep2);
                        ep1->constflag = ep1->v.p[0]->constflag &&
                                ep1->v.p[1]->constflag;
                        }
                }
        *node = ep1;
        return tp1;
}

TYP     *bitand(node)
/*
 *      the bitwise and operator...
 */
struct enode    **node;
{       return binop(node,equalops,en_and,and);
}

TYP     *bitxor(node)
struct enode    **node;
{       return binop(node,bitand,en_xor,uparrow);
}

TYP     *bitor(node)
struct enode    **node;
{       return binop(node,bitxor,en_or,or);
}

TYP     *andop(node)
struct enode    **node;
{       return binop(node,bitor,en_land,land);
}

TYP     *orop(node)
struct enode    **node;
{       return binop(node,andop,en_lor,lor);
}

TYP     *conditional(node)
/*
 *      this routine processes the hook operator.
 */
struct enode    **node;
{       TYP             *tp1, *tp2, *tp3;
        struct enode    *ep1, *ep2, *ep3;
        tp1 = orop(&ep1);       /* get condition */
        if( tp1 == 0 )
                return 0;
        if( lastst == hook ) {
                getsym();
                if( (tp2 = conditional(&ep2)) == 0) {
                        error(ERR_IDEXPECT);
                        goto cexit;
                        }
                needpunc(colon);
                if( (tp3 = conditional(&ep3)) == 0) {
                        error(ERR_IDEXPECT);
                        goto cexit;
                        }
                tp1 = forcefit(&ep2,tp2,&ep3,tp3);
                ep2 = makenode(en_void,ep2,ep3);
                ep1 = makenode(en_cond,ep1,ep2);
                }
cexit:  *node = ep1;
        return tp1;
}

TYP     *asnop(node)
/*
 *      asnop handles the assignment operators. currently only the
 *      simple assignment is implemented.
 */
struct enode    **node;
{       struct enode    *ep1, *ep2, *ep3;
        TYP             *tp1, *tp2;
        int             op;
        tp1 = conditional(&ep1);
        if( tp1 == 0 )
                return 0;
        for(;;) {
                switch( lastst ) {
                        case assign:
                                op = en_assign;
ascomm:                         getsym();
                                tp2 = asnop(&ep2);
ascomm2:                        if( tp2 == 0 || !lvalue(ep1) )
                                        error(ERR_LVALUE);
                                else    {
                                        tp1 = forcefit(&ep1,tp1,&ep2,tp2);
                                        ep1 = makenode(op,ep1,ep2);
                                        }
                                break;
                        case asplus:
                                op = en_asadd;
ascomm3:                        tp2 = asnop(&ep2);
                                if( tp1->type == bt_pointer ) {
                                        ep3 = makenode(en_icon,tp1->btp->size,0);
                                        ep2 = makenode(en_mul,ep2,ep3);
                                        }
                                goto ascomm;
                        case asminus:
                                op = en_assub;
                                goto ascomm3;
                        case astimes:
                                op = en_asmul;
                                goto ascomm;
                        case asdivide:
                                op = en_asdiv;
                                goto ascomm;
                        case asmodop:
                                op = en_asmod;
                                goto ascomm;
                        case aslshift:
                                op = en_aslsh;
                                goto ascomm;
                        case asrshift:
                                op = en_asrsh;
                                goto ascomm;
                        case asand:
                                op = en_asand;
                                goto ascomm;
                        case asor:
                                op = en_asor;
                                goto ascomm;
                        default:
                                goto asexit;
                        }
                }
asexit: *node = ep1;
        return tp1;
}

TYP     *exprnc(node)
/*
 *      evaluate an expression where the comma operator is not legal.
 */
struct enode    **node;
{       TYP     *tp;
        tp = asnop(node);
        if( tp == 0 )
                *node = 0;
        return tp;
}

TYP     *commaop(node)
/*
 *      evaluate the comma operator. comma operators are kept as
 *      void nodes.
 */
struct enode    **node;
{       TYP             *tp1;
        struct enode    *ep1, *ep2;
        tp1 = asnop(&ep1);
        if( tp1 == 0 )
                return 0;
        if( lastst == comma ) {
                tp1 = commaop(&ep2);
                if( tp1 == 0 ) {
                        error(ERR_IDEXPECT);
                        goto coexit;
                        }
                ep1 = makenode(en_void,ep1,ep2);
                }
coexit: *node = ep1;
        return tp1;
}

TYP     *expression(node)
/*
 *      evaluate an expression where all operators are legal.
 */
struct enode    **node;
{       TYP     *tp;
        tp = commaop(node);
        if( tp == 0 )
                *node = 0;
        return tp;
}

