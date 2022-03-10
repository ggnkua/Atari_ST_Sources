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

dooper(node)
/*
 *      dooper will execute a constant operation in a node and
 *      modify the node to be the result of the operation.
 */
struct enode    **node;
{       struct enode    *ep;
        ep = *node;
        switch( ep->nodetype ) {
                case en_add:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i + ep->v.p[1]->v.i;
                        break;
                case en_sub:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i - ep->v.p[1]->v.i;
                        break;
                case en_mul:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i * ep->v.p[1]->v.i;
                        break;
                case en_div:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i / ep->v.p[1]->v.i;
                        break;
                case en_lsh:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i << ep->v.p[1]->v.i;
                        break;
                case en_rsh:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i >> ep->v.p[1]->v.i;
                        break;
                case en_and:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i & ep->v.p[1]->v.i;
                        break;
                case en_or:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i | ep->v.p[1]->v.i;
                        break;
                case en_xor:
                        ep->nodetype = en_icon;
                        ep->v.i = ep->v.p[0]->v.i ^ ep->v.p[1]->v.i;
                        break;
                }
}

int     pwrof2(i)
/*
 *      return which power of two i is or -1.
 */
int     i;
{       int     p, q;
        q = 2;
        p = 1;
        while( q > 0 )
                {
                if( q == i )
                        return p;
                q <<= 1;
                ++p;
                }
        return -1;
}

int     mod_mask(i)
/*
 *      make a mod mask for a power of two.
 */
int     i;
{       int     m;
        m = 0;
        while( i-- )
                m = (m << 1) | 1;
        return m;
}

opt0(node)
/*
 *      opt0 - delete useless expressions and combine constants.
 *
 *      opt0 will delete expressions such as x + 0, x - 0, x * 0,
 *      x * 1, 0 / x, x / 1, x mod 0, etc from the tree pointed to
 *      by node and combine obvious constant operations. It cannot
 *      combine name and label constants but will combine icon type
 *      nodes.
 */
struct enode    **node;
{       struct enode    *ep;
        int             val, sc;
        ep = *node;
        if( ep == 0 )
                return;
        switch( (*node)->nodetype ) {
                case en_b_ref:
                case en_w_ref:          /* optimize unary node */
                case en_l_ref:
				case en_cbw:
				case en_cbl:
				case en_cwl:
				case en_ainc:
				case en_adec:
				case en_not:
				case en_compl:
                        opt0( &((*node)->v.p[0]));
                        return;
                case en_uminus:
                        opt0( &(ep->v.p[0]));
                        if( ep->v.p[0]->nodetype == en_icon )
                                {
                                ep->nodetype = en_icon;
                                ep->v.i = -ep->v.p[0]->v.i;
                                }
                        return;
                case en_add:
                case en_sub:
                        opt0(&(ep->v.p[0]));
                        opt0(&(ep->v.p[1]));
                        if( ep->v.p[0]->nodetype == en_icon ) {
                                if( ep->v.p[1]->nodetype == en_icon ) {
                                        dooper(node);
                                        return;
                                        }
                                if( ep->v.p[0]->v.i == 0 ) {
					if( ep->nodetype == en_sub )
					{
						ep->v.p[0] = ep->v.p[1];
                                        	ep->nodetype = en_uminus;
					}
					else
						*node = ep->v.p[1];
                                        return;
                                        }
                                }
                        else if( ep->v.p[1]->nodetype == en_icon ) {
                                if( ep->v.p[1]->v.i == 0 ) {
                                        *node = ep->v.p[0];
                                        return;
                                        }
                                }
                        return;
                case en_mul:
                        opt0(&(ep->v.p[0]));
                        opt0(&(ep->v.p[1]));
                        if( ep->v.p[0]->nodetype == en_icon ) {
                                if( ep->v.p[1]->nodetype == en_icon ) {
                                        dooper(node);
                                        return;
                                        }
                                val = ep->v.p[0]->v.i;
                                if( val == 0 ) {
                                        *node = ep->v.p[0];
                                        return;
                                        }
                                if( val == 1 ) {
                                        *node = ep->v.p[1];
                                        return;
                                        }
                                sc = pwrof2(val);
                                if( sc != -1 )
                                        {
                                        swap_nodes(ep);
                                        ep->v.p[1]->v.i = sc;
                                        ep->nodetype = en_lsh;
                                        }
                                }
                        else if( ep->v.p[1]->nodetype == en_icon ) {
                                val = ep->v.p[1]->v.i;
                                if( val == 0 ) {
                                        *node = ep->v.p[1];
                                        return;
                                        }
                                if( val == 1 ) {
                                        *node = ep->v.p[0];
                                        return;
                                        }
                                sc = pwrof2(val);
                                if( sc != -1 )
                                        {
                                        ep->v.p[1]->v.i = sc;
                                        ep->nodetype = en_lsh;
                                        }
                                }
                        break;
                case en_div:
                        opt0(&(ep->v.p[0]));
                        opt0(&(ep->v.p[1]));
                        if( ep->v.p[0]->nodetype == en_icon ) {
                                if( ep->v.p[1]->nodetype == en_icon ) {
                                        dooper(node);
                                        return;
                                        }
                                if( ep->v.p[0]->v.i == 0 ) {    /* 0/x */
                                        *node = ep->v.p[0];
                                        return;
                                        }
                                }
                        else if( ep->v.p[1]->nodetype == en_icon ) {
                                val = ep->v.p[1]->v.i;
                                if( val == 1 ) {        /* x/1 */
                                        *node = ep->v.p[0];
                                        return;
                                        }
                                sc = pwrof2(val);
                                if( sc != -1 )
                                        {
                                        ep->v.p[1]->v.i = sc;
                                        ep->nodetype = en_rsh;
                                        }
                                }
                        break;
                case en_mod:
                        opt0(&(ep->v.p[0]));
                        opt0(&(ep->v.p[1]));
                        if( ep->v.p[1]->nodetype == en_icon )
                                {
                                if( ep->v.p[0]->nodetype == en_icon )
                                        {
                                        dooper(node);
                                        return;
                                        }
                                sc = pwrof2(ep->v.p[1]->v.i);
                                if( sc != -1 )
                                        {
                                        ep->v.p[1]->v.i = mod_mask(sc);
                                        ep->nodetype = en_and;
                                        }
                                }
                        break;
                case en_and:    case en_or:
                case en_xor:    case en_rsh:
                case en_lsh:
                        opt0(&(ep->v.p[0]));
                        opt0(&(ep->v.p[1]));
                        if( ep->v.p[0]->nodetype == en_icon &&
                                ep->v.p[1]->nodetype == en_icon )
                                dooper(node);
                        break;
                case en_land:   case en_lor:
				case en_lt:		case en_le:
				case en_gt:		case en_ge:
				case en_eq:		case en_ne:
                case en_asand:  case en_asor:
                case en_asadd:  case en_assub:
                case en_asmul:  case en_asdiv:
                case en_asmod:  case en_asrsh:
                case en_aslsh:  case en_cond:
                case en_fcall:  case en_void:
                case en_assign:
                        opt0(&(ep->v.p[0]));
                        opt0(&(ep->v.p[1]));
                        break;
                }
}

int     xfold(node)
/*
 *      xfold will remove constant nodes and return the values to
 *      the calling routines.
 */
struct enode    *node;
{       int     i;
        if( node == 0 )
                return 0;
        switch( node->nodetype )
                {
                case en_icon:
                        i = node->v.i;
                        node->v.i = 0;
                        return i;
                case en_add:
                        return xfold(node->v.p[0]) + xfold(node->v.p[1]);
                case en_sub:
                        return xfold(node->v.p[0]) - xfold(node->v.p[1]);
                case en_mul:
                        if( node->v.p[0]->nodetype == en_icon )
                                return xfold(node->v.p[1]) * node->v.p[0]->v.i;
                        else if( node->v.p[1]->nodetype == en_icon )
                                return xfold(node->v.p[0]) * node->v.p[1]->v.i;
                        else return 0;
                case en_lsh:
                        if( node->v.p[0]->nodetype == en_icon )
                                return xfold(node->v.p[1]) << node->v.p[0]->v.i;
                         else if( node->v.p[1]->nodetype == en_icon )
                                return xfold(node->v.p[0]) << node->v.p[1]->v.i;
                         else return 0;
                case en_uminus:
                        return - xfold(node->v.p[0]);
                case en_rsh:    case en_div:
                case en_mod:    case en_asadd:
                case en_assub:  case en_asmul:
                case en_asdiv:  case en_asmod:
                case en_and:    case en_land:
                case en_or:     case en_lor:
                case en_xor:    case en_asand:
                case en_asor:   case en_void:
                case en_fcall:  case en_assign:
                        fold_const(&node->v.p[0]);
                        fold_const(&node->v.p[1]);
                        return 0;
                case en_b_ref:  case en_w_ref:
                case en_l_ref:  case en_compl:
                case en_not:
                        fold_const(&node->v.p[0]);
                        return 0;
                }
        return 0;
}

fold_const(node)
/*
 *      reorganize an expression for optimal constant grouping.
 */
struct enode    **node;
{       struct enode    *ep;
        int             i;
        ep = *node;
        if( ep == 0 )
                return;
        if( ep->nodetype == en_add )
                {
                if( ep->v.p[0]->nodetype == en_icon )
                        {
                        ep->v.p[0]->v.i += xfold(ep->v.p[1]);
                        return;
                        }
                else if( ep->v.p[1]->nodetype == en_icon )
                        {
                        ep->v.p[1]->v.i += xfold(ep->v.p[0]);
                        return;
                        }
                }
        else if( ep->nodetype == en_sub )
                {
                if( ep->v.p[0]->nodetype == en_icon )
                        {
                        ep->v.p[0]->v.i -= xfold(ep->v.p[1]);
                        return;
                        }
                else if( ep->v.p[1]->nodetype == en_icon )
                        {
                        ep->v.p[1]->v.i -= xfold(ep->v.p[0]);
                        return;
                        }
                }
        i = xfold(ep);
        if( i != 0 )
                {
                ep = makenode(en_icon,i,0);
                ep = makenode(en_add,ep,*node);
                *node = ep;
                }
}

opt4(node)
/*
 *      apply all constant optimizations.
 */
struct enode    **node;
{
		opt0(node);
        fold_const(node);
        opt0(node);
}
