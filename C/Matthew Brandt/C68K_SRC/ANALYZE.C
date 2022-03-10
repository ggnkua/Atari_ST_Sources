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

extern struct amode     push[], pop[];

/*
 *      this module will step through the parse tree and find all
 *      optimizable expressions. at present these expressions are
 *      limited to expressions that are valid throughout the scope
 *      of the function. the list of optimizable expressions is:
 *
 *              constants
 *              global and static addresses
 *              auto addresses
 *              contents of auto addresses.
 *
 *      contents of auto addresses are valid only if the address is
 *      never referred to without dereferencing.
 *
 *      scan will build a list of optimizable expressions which
 *      opt1 will replace during the second optimization pass.
 */

static struct cse       *olist;         /* list of optimizable expressions */

equalnode(node1, node2)
/*
 *      equalnode will return 1 if the expressions pointed to by
 *      node1 and node2 are equivalent.
 */
struct enode    *node1, *node2;
{       if( node1 == 0 || node2 == 0 )
                return 0;
        if( node1->nodetype != node2->nodetype )
                return 0;
        if( (node1->nodetype == en_icon || node1->nodetype == en_labcon ||
            node1->nodetype == en_nacon || node1->nodetype == en_autocon) &&
            node1->v.i == node2->v.i )
                return 1;
        if( lvalue(node1) && equalnode(node1->v.p[0], node2->v.p[0]) )
                return 1;
        return 0;
}

struct cse      *searchnode(node)
/*
 *      searchnode will search the common expression table for an entry
 *      that matches the node passed and return a pointer to it.
 */
struct enode    *node;
{       struct cse      *csp;
        csp = olist;
        while( csp != 0 ) {
                if( equalnode(node,csp->exp) )
                        return csp;
                csp = csp->next;
                }
        return 0;
}

struct enode    *copynode(node)
/*
 *      copy the node passed into a new enode so it wont get
 *      corrupted during substitution.
 */
struct enode    *node;
{       struct enode    *temp;
        if( node == 0 )
                return 0;
        temp = xalloc(sizeof(struct enode));
        temp->nodetype = node->nodetype;
        temp->v.p[0] = node->v.p[0];
        temp->v.p[1] = node->v.p[1];
        return temp;
}

enternode(node,duse)
/*
 *      enternode will enter a reference to an expression node into the
 *      common expression table. duse is a flag indicating whether or not
 *      this reference will be dereferenced.
 */
struct enode    *node;
int             duse;
{       struct cse      *csp;
        if( (csp = searchnode(node)) == 0 ) {   /* add to tree */
                csp = xalloc(sizeof(struct cse));
                csp->next = olist;
                csp->uses = 1;
                csp->duses = (duse != 0);
                csp->exp = copynode(node);
                csp->voidf = 0;
                olist = csp;
                return csp;
                }
        ++(csp->uses);
        if( duse )
                ++(csp->duses);
        return csp;
}

struct cse      *voidauto(node)
/*
 *      voidauto will void an auto dereference node which points to
 *      the same auto constant as node.
 */
struct enode    *node;
{       struct cse      *csp;
        csp = olist;
        while( csp != 0 ) {
                if( lvalue(csp->exp) && equalnode(node,csp->exp->v.p[0]) ) {
                        if( csp->voidf )
                                return 0;
                        csp->voidf = 1;
                        return csp;
                        }
                csp = csp->next;
                }
        return 0;
}

scanexpr(node,duse)
/*
 *      scanexpr will scan the expression pointed to by node for optimizable
 *      subexpressions. when an optimizable expression is found it is entered
 *      into the tree. if a reference to an autocon node is scanned the
 *      corresponding auto dereferenced node will be voided. duse should be
 *      set if the expression will be dereferenced.
 */
struct enode    *node;
{       struct cse      *csp, *csp1;
        int             n;
        if( node == 0 )
                return;
        switch( node->nodetype ) {
                case en_icon:
                case en_labcon:
                case en_nacon:
                        enternode(node,duse);
                        break;
                case en_autocon:
                        if( (csp = voidauto(node)) != 0 ) {
                                csp1 = enternode(node,duse);
                                csp1->uses = (csp1->duses += csp->uses);
                                }
                        else
                                enternode(node,duse);
                        break;
                case en_b_ref:
                case en_w_ref:
                case en_l_ref:
                        if( node->v.p[0]->nodetype == en_autocon ) {
                                csp = enternode(node,duse);
                                if( csp->voidf )
                                        scanexpr(node->v.p[0],1);
                                }
                        else
                                scanexpr(node->v.p[0],1);
                        break;
                case en_cbl:    case en_cwl:
                case en_cbw:    case en_uminus:
                case en_compl:  case en_ainc:
                case en_adec:   case en_not:
                        scanexpr(node->v.p[0],duse);
                        break;
                case en_asadd:  case en_assub:
                case en_add:    case en_sub:
                        scanexpr(node->v.p[0],duse);
                        scanexpr(node->v.p[1],duse);
                        break;
                case en_mul:    case en_div:
                case en_lsh:    case en_rsh:
                case en_mod:    case en_and:
                case en_or:     case en_xor:
                case en_lor:    case en_land:
                case en_eq:     case en_ne:
                case en_gt:     case en_ge:
                case en_lt:     case en_le:
                case en_asmul:  case en_asdiv:
                case en_asmod:  case en_aslsh:
                case en_asrsh:  case en_asand:
                case en_asor:   case en_cond:
                case en_void:   case en_assign:
                        scanexpr(node->v.p[0],0);
                        scanexpr(node->v.p[1],0);
                        break;
                case en_fcall:
                        scanexpr(node->v.p[0],1);
                        scanexpr(node->v.p[1],0);
                        break;
                }
}

scan(block)
/*
 *      scan will gather all optimizable expressions into the expression
 *      list for a block of statements.
 */
struct snode    *block;
{       while( block != 0 ) {
                switch( block->stype ) {
                        case st_return:
                        case st_expr:
                                opt4(&block->exp);
                                scanexpr(block->exp,0);
                                break;
                        case st_while:
                        case st_do:
                                opt4(&block->exp);
                                scanexpr(block->exp,0);
                                scan(block->s1);
                                break;
                        case st_for:
                                opt4(&block->label);
                                scanexpr(block->label,0);
                                opt4(&block->exp);
                                scanexpr(block->exp,0);
                                scan(block->s1);
                                opt4(&block->s2);
                                scanexpr(block->s2,0);
                                break;
                        case st_if:
                                opt4(&block->exp);
                                scanexpr(block->exp,0);
                                scan(block->s1);
                                scan(block->s2);
                                break;
                        case st_switch:
                                opt4(&block->exp);
                                scanexpr(block->exp,0);
                                scan(block->s1);
                                break;
                        case st_case:
                                scan(block->s1);
                                break;
                        }
                block = block->next;
                }
}

exchange(c1)
/*
 *      exchange will exchange the order of two expression entries
 *      following c1 in the linked list.
 */
struct cse      **c1;
{       struct cse      *csp1, *csp2;
        csp1 = *c1;
        csp2 = csp1->next;
        csp1->next = csp2->next;
        csp2->next = csp1;
        *c1 = csp2;
}

int     desire(csp)
/*
 *      returns the desirability of optimization for a subexpression.
 */
struct cse      *csp;
{       if( csp->voidf || (csp->exp->nodetype == en_icon &&
                        csp->exp->v.i < 16 && csp->exp->v.i >= 0))
                return 0;
        if( lvalue(csp->exp) )
                return 2 * csp->uses;
        return csp->uses;
}

int     bsort(list)
/*
 *      bsort implements a bubble sort on the expression list.
 */
struct cse      **list;
{       struct cse      *csp1, *csp2;
        int             i;
        csp1 = *list;
        if( csp1 == 0 || csp1->next == 0 )
                return 0;
        i = bsort( &(csp1->next));
        csp2 = csp1->next;
        if( desire(csp1) < desire(csp2) ) {
                exchange(list);
                return 1;
                }
        return 0;
}

allocate()
/*
 *      allocate will allocate registers for the expressions that have
 *      a high enough desirability.
 */
{       struct cse      *csp;
        struct enode    *exptr;
        int             datareg, addreg, mask, rmask, i;
        struct amode    *ap, *ap2;
        datareg = 3;
        addreg = 10;
        mask = 0;
	rmask = 0;
        while( bsort(&olist) );         /* sort the expression list */
        csp = olist;
        while( csp != 0 ) {
                if( desire(csp) < 3 )
                        csp->reg = -1;
                else if( csp->duses > csp->uses / 4 && addreg < 14 )
                        csp->reg = addreg++;
                else if( datareg < 8 )
                        csp->reg = datareg++;
                else
                        csp->reg = -1;
                if( csp->reg != -1 )
				{
			rmask = rmask | (1 << (15 - csp->reg));
                        mask = mask | (1 << csp->reg);
				}
                csp = csp->next;
                }
        if( mask != 0 )
                gen_code(op_movem,4,make_mask(rmask),push);
        save_mask = rmask;
        csp = olist;
        while( csp != 0 ) {
                if( csp->reg != -1 )
                        {               /* see if preload needed */
                        exptr = csp->exp;
                        if( !lvalue(exptr) || (exptr->v.p[0]->v.i > 0) )
                                {
                                initstack();
                                ap = gen_expr(exptr,F_ALL,4);
                                if( csp->reg < 8 )
                                        ap2 = makedreg(csp->reg);
                                else
                                        ap2 = makeareg(csp->reg - 8);
                                gen_code(op_move,4,ap,ap2);
                                freeop(ap);
                                }
                        }
                csp = csp->next;
                }
}

repexpr(node)
/*
 *      repexpr will replace all allocated references within an expression
 *      with tempref nodes.
 */
struct enode    *node;
{       struct cse      *csp;
        if( node == 0 )
                return;
        switch( node->nodetype ) {
                case en_icon:
                case en_nacon:
                case en_labcon:
                case en_autocon:
                        if( (csp = searchnode(node)) != 0 )
                                if( csp->reg > 0 ) {
                                        node->nodetype = en_tempref;
                                        node->v.i = csp->reg;
                                        }
                        break;
                case en_b_ref:
                case en_w_ref:
                case en_l_ref:
                        if( (csp = searchnode(node)) != 0 ) {
                                if( csp->reg > 0 ) {
                                        node->nodetype = en_tempref;
                                        node->v.i = csp->reg;
                                        }
                                else
                                        repexpr(node->v.p[0]);
                                }
                        else
                                repexpr(node->v.p[0]);
                        break;
                case en_cbl:    case en_cbw:
                case en_cwl:    case en_uminus:
                case en_not:    case en_compl:
                case en_ainc:   case en_adec:
                        repexpr(node->v.p[0]);
                        break;
                case en_add:    case en_sub:
                case en_mul:    case en_div:
                case en_mod:    case en_lsh:
                case en_rsh:    case en_and:
                case en_or:     case en_xor:
                case en_land:   case en_lor:
                case en_eq:     case en_ne:
                case en_lt:     case en_le:
                case en_gt:     case en_ge:
                case en_cond:   case en_void:
                case en_asadd:  case en_assub:
                case en_asmul:  case en_asdiv:
                case en_asor:   case en_asand:
                case en_asmod:  case en_aslsh:
                case en_asrsh:  case en_fcall:
                case en_assign:
                        repexpr(node->v.p[0]);
                        repexpr(node->v.p[1]);
                        break;
                }
}

repcse(block)
/*
 *      repcse will scan through a block of statements replacing the
 *      optimized expressions with their temporary references.
 */
struct snode    *block;
{       while( block != 0 ) {
                switch( block->stype ) {
                        case st_return:
                        case st_expr:
                                repexpr(block->exp);
                                break;
                        case st_while:
                        case st_do:
                                repexpr(block->exp);
                                repcse(block->s1);
                                break;
                        case st_for:
                                repexpr(block->label);
                                repexpr(block->exp);
                                repcse(block->s1);
                                repexpr(block->s2);
                                break;
                        case st_if:
                                repexpr(block->exp);
                                repcse(block->s1);
                                repcse(block->s2);
                                break;
                        case st_switch:
                                repexpr(block->exp);
                                repcse(block->s1);
                                break;
                        case st_case:
                                repcse(block->s1);
                                break;
                        }
                block = block->next;
                }
}

opt1(block)
/*
 *      opt1 is the externally callable optimization routine. it will
 *      collect and allocate common subexpressions and substitute the
 *      tempref for all occurrances of the expression within the block.
 *
 *		optimizer is currently turned off...
 */
struct snode    *block;
{
		olist = 0;
        scan(block);            /* collect expressions */
        allocate();             /* allocate registers */
        repcse(block);          /* replace allocated expressions */
}
