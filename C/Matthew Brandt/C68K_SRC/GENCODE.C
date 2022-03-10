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

/*
 *      this module contains all of the code generation routines
 *      for evaluating expressions and conditions.
 */

extern struct amode     push[], pop[];

struct amode    *gen_expr();            /* forward declaration */

struct amode    *make_label(lab)
/*
 *      construct a reference node for an internal label number.
 */
int     lab;
{       struct enode    *lnode;
        struct amode    *ap;
        lnode = xalloc(sizeof(struct enode));
        lnode->nodetype = en_labcon;
        lnode->v.i = lab;
        ap = xalloc(sizeof(struct amode));
        ap->mode = am_direct;
        ap->offset = lnode;
        return ap;
}

struct amode    *make_immed(i)
/*
 *      make a node to reference an immediate value i.
 */
int     i;
{       struct amode    *ap;
        struct enode    *ep;
        ep = xalloc(sizeof(struct enode));
        ep->nodetype = en_icon;
        ep->v.i = i;
        ap = xalloc(sizeof(struct amode));
        ap->mode = am_immed;
        ap->offset = ep;
        return ap;
}

struct amode    *make_offset(node)
/*
 *      make a direct reference to a node.
 */
struct enode    *node;
{       struct amode    *ap;
        ap = xalloc(sizeof(struct amode));
        ap->mode = am_direct;
        ap->offset = node;
        return ap;
}

make_legal(ap,flags,size)
/*
 *      make_legal will coerce the addressing mode in ap1 into a
 *      mode that is satisfactory for the flag word.
 */
struct amode    *ap;
int             flags, size;
{       struct amode    *ap2;
        if( ((flags & F_VOL) == 0) || ap->tempflag )
                {
                switch( ap->mode )
                        {
                        case am_immed:
                                if( flags & F_IMMED )
                                        return;         /* mode ok */
                                break;
                        case am_areg:
                                if( flags & F_AREG )
                                        return;
                                break;
                        case am_dreg:
                                if( flags & F_DREG )
                                        return;
                                break;
                        case am_ind:    case am_indx:
                        case am_indx2:  case am_xpc:
                        case am_direct: case am_indx3:
                                if( flags & F_MEM )
                                        return;
                                break;
                        }
                }
        if( flags & F_DREG )
                {
                freeop(ap);             /* maybe we can use it... */
                ap2 = temp_data();      /* allocate to dreg */
                gen_code(op_move,size,ap,ap2);
                ap->mode = am_dreg;
                ap->preg = ap2->preg;
                ap->deep = ap2->deep;
                ap->tempflag = 1;
                return;
                }
        if( size == 1 )
                {
                freeop(ap);
                ap2 = temp_data();
                gen_code(op_move,1,ap,ap2);
                gen_code(op_ext,2,ap2,0);
                freeop(ap);
                ap->mode = ap2->mode;
                ap->preg = ap2->preg;
                ap->deep = ap2->deep;
                size = 2;
                }
        freeop(ap);
        ap2 = temp_addr();
        gen_code(op_move,size,ap,ap2);
        ap->mode = am_areg;
        ap->preg = ap2->preg;
        ap->deep = ap2->deep;
        ap->tempflag = 1;
}

do_extend(ap,isize,osize,flags)
/*
 *      if isize is not equal to osize then the operand ap will be
 *      loaded into a register (if not already) and if osize is
 *      greater than isize it will be extended to match.
 */
struct amode    *ap;
int             isize, osize, flags;
{       if( isize == osize )
                return;
        if( ap->mode != am_areg && ap->mode != am_dreg )
                make_legal(ap,flags & (F_AREG | F_DREG),isize);
        if( ap->mode == am_areg )
                return;         /* extend is automagic */
        switch( isize )
                {
                case 1:
                        gen_code(op_ext,2,ap,0);
                case 2:
                        if( osize == 4 )
                                gen_code(op_ext,4,ap,0);
                }
}

int     isshort(node)
/*
 *      return true if the node passed can be generated as a short
 *      offset.
 */
struct enode    *node;
{       return node->nodetype == en_icon &&
                (node->v.i >= -65536 && node->v.i <= 65535);
}

int     isbyte(node)
/*
 *      return true if the node passed can be evaluated as a byte
 *      offset.
 */
struct enode    *node;
{       return node->nodetype == en_icon &&
                (-128 <= node->v.i && node->v.i <= 127);
}

struct amode    *gen_index(node)
/*
 *      generate code to evaluate an index node (^+) and return
 *      the addressing mode of the result. This routine takes no
 *      flags since it always returns either am_ind or am_indx.
 */
struct enode    *node;
{       struct amode    *ap1, *ap2;
        if( node->v.p[0]->nodetype == en_tempref &&
                node->v.p[1]->nodetype == en_tempref &&
                ( node->v.p[0]->v.i >= 8 || node->v.p[1]->v.i >= 8 ))
                {       /* both nodes are registers, one is address */
                if( node->v.p[0]->v.i < 8 )
                        {
                        ap1 = gen_expr(node->v.p[1],F_AREG,4);
                        ap1->sreg = node->v.p[0]->v.i;
                        ap1->mode = am_indx2;   /* 0(Ax,Dx) */
                        ap1->offset = makenode(en_icon,0,0);
                        return ap1;
                        }
                ap1 = gen_expr(node->v.p[0],F_AREG,4);
                ap2 = gen_expr(node->v.p[1],F_AREG | F_DREG,4);
                if( ap2->mode == am_dreg )
                        {
                        ap1->mode = am_indx2;
                        ap1->sreg = ap2->preg;
                        }
                else
                        {
                        ap1->mode = am_indx3;
                        ap1->sreg = ap2->preg;
                        }
                ap1->offset = makenode(en_icon,0,0);
                return ap1;
                }
        ap1 = gen_expr(node->v.p[0],F_AREG | F_IMMED,4);
        if( ap1->mode == am_immed && isshort(ap1->offset) )
                {
                ap2 = gen_expr(node->v.p[1],F_AREG,4);
                ap2->mode = am_indx;
                ap2->offset = ap1->offset;
                return ap2;
                }
        ap2 = gen_expr(node->v.p[1],F_ALL,4);   /* get right op */
        if( ap2->mode == am_immed && isshort(ap2->offset) &&
			ap1->mode == am_areg ) /* make am_indx */
                {
                ap2->mode = am_indx;
                ap2->preg = ap1->preg;
                ap2->deep = ap1->deep;
                return ap2;
                }
        validate(ap1);
        make_legal(ap1,F_AREG | F_VOL,4);
        gen_code(op_add,4,ap2,ap1);             /* add left to address reg */
        ap1->mode = am_ind;             /* make indirect */
        freeop(ap2);                    /* release any temps in ap2 */
        return ap1;                     /* return indirect */
}

struct amode    *gen_deref(node,flags,size)
/*
 *      return the addressing mode of a dereferenced node.
 */
struct enode    *node;
int             flags, size;
{       struct amode    *ap1;
        int             siz1;
        switch( node->nodetype )        /* get load size */
                {
                case en_b_ref:
                        siz1 = 1;
                        break;
                case en_w_ref:
                        siz1 = 2;
                        break;
                case en_l_ref:
                        siz1 = 4;
                        break;
                }
        if( node->v.p[0]->nodetype == en_add )
                {
                ap1 = gen_index(node->v.p[0]);
                do_extend(ap1,siz1,size,flags);
                make_legal(ap1,flags,size);
                return ap1;
                }
        else if( node->v.p[0]->nodetype == en_autocon )
                {
                ap1 = xalloc(sizeof(struct amode));
                ap1->mode = am_indx;
                ap1->preg = 6;
                ap1->offset = makenode(en_icon,node->v.p[0]->v.i);
                do_extend(ap1,siz1,size,flags);
                make_legal(ap1,flags,size);
                return ap1;
                }
        ap1 = gen_expr(node->v.p[0],F_AREG | F_IMMED,4); /* generate address */
        if( ap1->mode == am_areg )
                {
                ap1->mode = am_ind;
                do_extend(ap1,siz1,size,flags);
                make_legal(ap1,flags,size);
                return ap1;
                }
        ap1->mode = am_direct;
        do_extend(ap1,siz1,size,flags);
        make_legal(ap1,flags,size);
        return ap1;
}

struct amode    *gen_unary(node,flags,size,op)
/*
 *      generate code to evaluate a unary minus or complement.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap;
        ap = gen_expr(node->v.p[0],F_DREG | F_VOL,size);
        gen_code(op,size,ap,0);
        make_legal(ap,flags,size);
        return ap;
}

struct amode    *gen_binary(node,flags,size,op)
/*
 *      generate code to evaluate a binary node and return
 *      the addressing mode of the result.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap1, *ap2;
        ap1 = gen_expr(node->v.p[0],F_VOL | F_DREG | F_AREG,size);
        ap2 = gen_expr(node->v.p[1],F_ALL,size);
        validate(ap1);          /* in case push occurred */
        gen_code(op,size,ap2,ap1);
        freeop(ap2);
        make_legal(ap1,flags,size);
        return ap1;
}

struct amode    *gen_xbin(node,flags,size,op)
/*
 *      generate code to evaluate a restricted binary node and return
 *      the addressing mode of the result.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap1, *ap2;
        ap1 = gen_expr(node->v.p[0],F_VOL | F_DREG,size);
        ap2 = gen_expr(node->v.p[1],F_DREG,size);
        validate(ap1);          /* in case push occurred */
        gen_code(op,size,ap2,ap1);
        freeop(ap2);
        make_legal(ap1,flags,size);
        return ap1;
}
struct amode    *gen_shift(node,flags,size,op)
/*
 *      generate code to evaluate a shift node and return the
 *      address mode of the result.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap1, *ap2;
        ap1 = gen_expr(node->v.p[0],F_DREG | F_VOL,size);
        ap2 = gen_expr(node->v.p[1],F_DREG | F_IMMED,1);
        validate(ap1);
        gen_code(op,size,ap2,ap1);
        freeop(ap2);
        make_legal(ap1,flags,size);
        return ap1;
}

struct amode    *gen_modiv(node,flags,size,op,modflag)
/*
 *      generate code to evaluate a mod operator or a divide
 *      operator. these operations are done on only long
 *      divisors and word dividends so that the 68000 div
 *      instruction can be used.
 */
struct enode    *node;
int             flags, op, size, modflag;
{       struct amode    *ap1, *ap2;
        if( node->v.p[0]->nodetype == en_icon )
                swap_nodes(node);
        ap1 = gen_expr(node->v.p[0],F_DREG | F_VOL,4);
        ap2 = gen_expr(node->v.p[1],F_ALL,2);
        validate(ap1);
        gen_code(op,0,ap2,ap1);
        if( modflag )
                gen_code(op_swap,0,ap1,0);
        gen_code(op_ext,4,ap1,0);
        make_legal(ap1,flags,4);
        freeop(ap2);
        return ap1;
}

swap_nodes(node)
/*
 *      exchange the two operands in a node.
 */
struct enode    *node;
{       struct enode    *temp;
        temp = node->v.p[0];
        node->v.p[0] = node->v.p[1];
        node->v.p[1] = temp;
}

struct amode    *gen_mul(node,flags,size,op)
/*
 *      generate code to evaluate a multiply node. both operands
 *      are treated as words and the result is long and is always
 *      in a register so that the 68000 mul instruction can be used.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap1, *ap2;
        if( node->v.p[0]->nodetype == en_icon )
                swap_nodes(node);
        ap1 = gen_expr(node->v.p[0],F_DREG | F_VOL,2);
        ap2 = gen_expr(node->v.p[1],F_ALL,2);
        validate(ap1);
        gen_code(op,0,ap2,ap1);
        freeop(ap2);
        make_legal(ap1,flags,4);
        return ap1;
}

struct amode    *gen_hook(node,flags,size)
/*
 *      generate code to evaluate a condition operator node (?:)
 */
struct enode    *node;
int             flags, size;
{       struct amode    *ap1, *ap2;
        int             false_label, end_label;
        false_label = nextlabel++;
        end_label = nextlabel++;
        flags = (flags & (F_AREG | F_DREG)) | F_VOL;
        falsejp(node->v.p[0],false_label);
        node = node->v.p[1];
        ap1 = gen_expr(node->v.p[0],flags,size);
        freeop(ap1);
        gen_code(op_bra,0,make_label(end_label),0);
        gen_label(false_label);
        ap2 = gen_expr(node->v.p[1],flags,size);
        if( !equal_address(ap1,ap2) )
                {
                freeop(ap2);
                if( ap1->mode == am_dreg )
                        temp_data();
                else
                        temp_addr();
                gen_code(op_move,size,ap2,ap1);
                }
        gen_label(end_label);
        return ap1;
}

struct amode    *gen_asadd(node,flags,size,op)
/*
 *      generate a plus equal or a minus equal node.
 */
struct enode    *node;
int             flags,size,op;
{       struct amode    *ap1, *ap2;
        int             ssize, mask0, mask1;
        ssize = natural_size(node->v.p[0]);
        if( ssize > size )
                size = ssize;
        ap1 = gen_expr(node->v.p[0],F_ALL,ssize);
        ap2 = gen_expr(node->v.p[1],F_DREG | F_AREG | F_IMMED,size);
        validate(ap1);
        gen_code(op,ssize,ap2,ap1);
        freeop(ap2);
        do_extend(ap1,ssize,size);
        make_legal(ap1,flags,size);
        return ap1;
}

struct amode    *gen_aslogic(node,flags,size,op)
/*
 *      generate a and equal or a or equal node.
 */
struct enode    *node;
int             flags,size,op;
{       struct amode    *ap1, *ap2, *ap3;
        int             ssize, mask0, mask1;
        ssize = natural_size(node->v.p[0]);
        if( ssize > size )
                size = ssize;
        ap1 = gen_expr(node->v.p[0],F_ALL,ssize);
        ap2 = gen_expr(node->v.p[1],F_DREG | F_IMMED,size);
        validate(ap1);
        if( ap1->mode != am_areg )
                gen_code(op,ssize,ap2,ap1);
        else
                {
                ap3 = temp_data();
                gen_code(op_move,4,ap1,ap3);
                gen_code(op,size,ap2,ap3);
                gen_code(op_move,size,ap3,ap1);
                freeop(ap3);
                }
        freeop(ap2);
        do_extend(ap1,ssize,size);
        make_legal(ap1,flags,size);
        return ap1;
}

gen_asshift(node,flags,size,op)
/*
 *      generate shift equals operators.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap1, *ap2, *ap3;
        ap1 = gen_expr(node->v.p[0],F_ALL,size);
        if( ap1->mode != am_dreg )
                {
                ap3 = temp_data();
                gen_code(op_move,size,ap1,ap3);
                }
        else
                ap3 = ap1;
        ap2 = gen_expr(node->v.p[1],F_DREG | F_IMMED,size);
        validate(ap3);
        gen_code(op,size,ap2,ap3);
        freeop(ap2);
        if( ap3 != ap1 )
                {
                gen_code(op_move,size,ap3,ap1);
                freeop(ap3);
                }
        make_legal(ap1,flags,size);
        return ap1;
}

struct amode    *gen_asmul(node,flags,size)
/*
 *      generate a *= node.
 */
struct enode    *node;
int             flags, size;
{       struct amode    *ap1, *ap2, *ap3;
        int             siz1;
        siz1 = natural_size(node->v.p[0]);
        ap1 = gen_expr(node->v.p[1],F_DREG | F_VOL,2);
        ap2 = gen_expr(node->v.p[0],F_ALL,siz1);
        if( siz1 == 1 || ap2->mode == am_areg )
                {
                ap3 = temp_data();
                gen_code(op_move,siz1,ap2,ap3);
                if( siz1 == 1 )
                        gen_code(op_ext,2,ap3,0);
                freeop(ap3);
                }
        else
                ap3 = ap2;
        gen_code(op_muls,0,ap3,ap1);
        gen_code(op_move,siz1,ap1,ap2);
        freeop(ap2);
        return ap1;
}

struct amode    *gen_asmodiv(node,flags,size,op)
/*
 *      generate /= and %= nodes.
 */
struct enode    *node;
int             flags, size, op;
{       struct amode    *ap1, *ap2, *ap3;
        int             siz1;
        siz1 = natural_size(node->v.p[0]);
        ap1 = temp_data();
        ap2 = gen_expr(node->v.p[0],F_ALL,siz1);
        validate(ap1);
        gen_code(op_move,siz1,ap2,ap1);
        do_extend(ap1,siz1,4);
        ap3 = gen_expr(node->v.p[1],F_ALL & ~F_AREG,2);
        validate(ap2);
        validate(ap1);
        gen_code(op_divs,0,ap3,ap1);
        freeop(ap3);
        if( op != op_divs )
                gen_code(op_swap,0,ap1,0);
        gen_code(op_ext,4,ap1,0);
        gen_code(op_move,siz1,ap1,ap2);
        freeop(ap2);
        make_legal(ap1,flags,size);
        return ap1;
}

struct amode    *gen_assign(node,flags,size)
/*
 *      generate code for an assignment node. if the size of the
 *      assignment destination is larger than the size passed then
 *      everything below this node will be evaluated with the
 *      assignment size.
 */
struct enode    *node;
int             flags, size;
{       struct amode    *ap1, *ap2;
        int             ssize;
        switch( node->v.p[0]->nodetype )
                {
                case en_b_ref:
                        ssize = 1;
                        break;
                case en_w_ref:
                        ssize = 2;
                        break;
                case en_l_ref:
                case en_tempref:
                        ssize = 4;
                        break;
                }
        if( ssize > size )
                size = ssize;
        ap2 = gen_expr(node->v.p[1],F_ALL,size);
        ap1 = gen_expr(node->v.p[0],F_ALL,ssize);
        validate(ap2);
        gen_code(op_move,ssize,ap2,ap1);
        freeop(ap1);
        return ap2;
}

struct amode    *gen_aincdec(node,flags,size,op)
/*
 *      generate an auto increment or decrement node. op should be
 *      either op_add (for increment) or op_sub (for decrement).
 */
struct enode    *node;
int             flags, size;
{       struct amode    *ap1, *ap2;
        int             siz1;
        siz1 = natural_size(node->v.p[0]);
        if( flags & F_NOVALUE )         /* dont need result */
                {
                ap1 = gen_expr(node->v.p[0],F_ALL,siz1);
                gen_code(op,siz1,make_immed(node->v.p[1]),ap1);
                freeop(ap1);
                return ap1;
                }
        if( flags & F_DREG )
                ap1 = temp_data();
        else
                ap1 = temp_addr();
        ap2 = gen_expr(node->v.p[0],F_ALL,siz1);
        validate(ap1);
        gen_code(op_move,siz1,ap2,ap1);
        gen_code(op,siz1,make_immed(node->v.p[1]),ap2);
        freeop(ap2);
        do_extend(ap1,siz1,size);
        return ap1;
}

push_param(ep)
/*
 *      push the operand expression onto the stack.
 */
struct enode    *ep;
{       struct amode    *ap;
        ap = gen_expr(ep,F_ALL,4);
        gen_code(op_move,4,ap,push);
        freeop(ap);
}

int     gen_parms(plist)
/*
 *      push a list of parameters onto the stack and return the
 *      number of parameters pushed.
 */
struct enode    *plist;
{       int     i;
        i = 0;
        while( plist != 0 )
                {
                push_param(plist->v.p[0]);
                plist = plist->v.p[1];
                ++i;
                }
        return i;
}

struct amode    *gen_fcall(node,flags)
/*
 *      generate a function call node and return the address mode
 *      of the result.
 */
struct enode    *node;
{       struct amode    *ap, *result;
        int             i;
        result = temp_addr();
        temp_addr();                    /* push any used addr temps */
        freeop(result); freeop(result);
        result = temp_data();
        temp_data(); temp_data();       /* push any used data registers */
        freeop(result); freeop(result); freeop(result);
        i = gen_parms(node->v.p[1]);    /* generate parameters */
        if( node->v.p[0]->nodetype == en_nacon )
                gen_code(op_jsr,0,make_offset(node->v.p[0]),0);
        else
                {
                ap = gen_expr(node->v.p[0],F_AREG,4);
                ap->mode = am_ind;
                freeop(ap);
                gen_code(op_jsr,0,ap,0);
                }
        if( i != 0 )
                gen_code(op_add,4,make_immed(i * 4),makeareg(7));
        if( flags & F_DREG )
                result = temp_data();
        else
                result = temp_addr();
        if( result->preg != 0 || (flags & F_DREG) == 0 )
                gen_code(op_move,4,makedreg(0),result);
        return result;
}

struct amode    *gen_expr(node,flags,size)
/*
 *      general expression evaluation. returns the addressing mode
 *      of the result.
 */
struct enode    *node;
int             flags, size;
{       struct amode    *ap1, *ap2;
        int             lab0, lab1;
        int             natsize;
        if( node == 0 )
                {
                printf("DIAG - null node in gen_expr.\n");
                return 0;
                }
        switch( node->nodetype )
                {
                case en_icon:
                case en_labcon:
                case en_nacon:
                        ap1 = xalloc(sizeof(struct amode));
                        ap1->mode = am_immed;
                        ap1->offset = node;
                        make_legal(ap1,flags,size);
                        return ap1;
                case en_autocon:
                        ap1 = temp_addr();
                        ap2 = xalloc(sizeof(struct amode));
                        ap2->mode = am_indx;
                        ap2->preg = 6;          /* frame pointer */
                        ap2->offset = node;     /* use as constant node */
                        gen_code(op_lea,0,ap2,ap1);
                        make_legal(ap1,flags,size);
                        return ap1;             /* return reg */
                case en_b_ref:
                case en_w_ref:
                case en_l_ref:
                        return gen_deref(node,flags,size);
                case en_tempref:
                        ap1 = xalloc(sizeof(struct amode));
                        if( node->v.i < 8 )
                                {
                                ap1->mode = am_dreg;
                                ap1->preg = node->v.i;
                                }
                        else
                                {
                                ap1->mode = am_areg;
                                ap1->preg = node->v.i - 8;
                                }
                        ap1->tempflag = 0;      /* not a temporary */
                        make_legal(ap1,flags,size);
                        return ap1;
                case en_uminus:
                        return gen_unary(node,flags,size,op_neg);
                case en_compl:
                        return gen_unary(node,flags,size,op_not);
                case en_add:
                        return gen_binary(node,flags,size,op_add);
                case en_sub:
                        return gen_binary(node,flags,size,op_sub);
                case en_and:
                        return gen_binary(node,flags,size,op_and);
                case en_or:
                        return gen_binary(node,flags,size,op_or);
				case en_xor:
						return gen_xbin(node,flags,size,
op_eor);
                case en_mul:
                        return gen_mul(node,flags,size,op_muls);
                case en_umul:
                        return gen_mul(node,flags,size,op_mulu);
                case en_div:
                        return gen_modiv(node,flags,size,op_divs,0);
                case en_udiv:
                        return gen_modiv(node,flags,size,op_divu,0);
                case en_mod:
                        return gen_modiv(node,flags,size,op_divs,1);
                case en_umod:
                        return gen_modiv(node,flags,size,op_divu,1);
                case en_lsh:
                        return gen_shift(node,flags,size,op_asl);
                case en_rsh:
                        return gen_shift(node,flags,size,op_asr);
                case en_asadd:
                        return gen_asadd(node,flags,size,op_add);
                case en_assub:
                        return gen_asadd(node,flags,size,op_sub);
                case en_asand:
                        return gen_aslogic(node,flags,size,op_and);
                case en_asor:
                        return gen_aslogic(node,flags,size,op_or);
                case en_aslsh:
                        return gen_asshift(node,flags,size,op_asl);
                case en_asrsh:
                        return gen_asshift(node,flags,size,op_asr);
                case en_asmul:
                        return gen_asmul(node,flags,size);
                case en_asdiv:
                        return gen_asmodiv(node,flags,size,op_divs);
                case en_asmod:
                        return gen_asmodiv(node,flags,size,op_muls);
                case en_assign:
                        return gen_assign(node,flags,size);
                case en_ainc:
                        return gen_aincdec(node,flags,size,op_add);
                case en_adec:
                        return gen_aincdec(node,flags,size,op_sub);
                case en_land:   case en_lor:
                case en_eq:     case en_ne:
                case en_lt:     case en_le:
                case en_gt:     case en_ge:
                case en_ult:    case en_ule:
                case en_ugt:    case en_uge:
                case en_not:
                        lab0 = nextlabel++;
                        lab1 = nextlabel++;
                        falsejp(node,lab0);
                        ap1 = temp_data();
                        gen_code(op_moveq,0,make_immed(1),ap1);
                        gen_code(op_bra,0,make_label(lab1),0);
                        gen_label(lab0);
                        gen_code(op_clr,4,ap1,0);
                        gen_label(lab1);
                        return ap1;
                case en_cond:
                        return gen_hook(node,flags,size);
                case en_void:
                        natsize = natural_size(node->v.p[0]);
                        freeop(gen_expr(node->v.p[0],F_ALL | F_NOVALUE,natsize))
;
                        return gen_expr(node->v.p[1],flags,size);
                case en_fcall:
                        return gen_fcall(node,flags);
                default:
                        printf("DIAG - uncoded node in gen_expr.\n");
                        return 0;
                }
}

int     natural_size(node)
/*
 *      return the natural evaluation size of a node.
 */
struct enode    *node;
{       int     siz0, siz1;
        if( node == 0 )
                return 0;
        switch( node->nodetype )
                {
                case en_icon:
                        if( -128 <= node->v.i && node->v.i <= 127 )
                                return 1;
                        if( -32768 <= node->v.i && node->v.i <= 32767 )
                                return 2;
                        return 4;
                case en_fcall:  case en_labcon:
                case en_nacon:  case en_autocon:
                case en_l_ref:  case en_tempref:
                case en_cbl:    case en_cwl:
                        return 4;
                case en_b_ref:
                        return 1;
                case en_cbw:
                case en_w_ref:
                        return 2;
                case en_not:    case en_compl:
                case en_uminus: case en_assign:
                case en_ainc:   case en_adec:
                        return natural_size(node->v.p[0]);
                case en_add:    case en_sub:
                case en_mul:    case en_div:
                case en_mod:    case en_and:
                case en_or:     case en_xor:
                case en_lsh:    case en_rsh:
                case en_eq:     case en_ne:
                case en_lt:     case en_le:
                case en_gt:     case en_ge:
                case en_land:   case en_lor:
                case en_asadd:  case en_assub:
                case en_asmul:  case en_asdiv:
                case en_asmod:  case en_asand:
                case en_asor:   case en_aslsh:
                case en_asrsh:
                        siz0 = natural_size(node->v.p[0]);
                        siz1 = natural_size(node->v.p[1]);
                        if( siz1 > siz0 )
                                return siz1;
                        else
                                return siz0;
                case en_void:   case en_cond:
                        return natural_size(node->v.p[1]);
                default:
                        printf("DIAG - natural size error.\n");
                        break;
                }
        return 0;
}

gen_compare(node)
/*
 *      generate code to do a comparison of the two operands of
 *      node.
 */
struct enode    *node;
{       struct amode    *ap1, *ap2;
        int             size;
        size = natural_size(node);
        ap1 = gen_expr(node->v.p[0],F_AREG | F_DREG, size);
        ap2 = gen_expr(node->v.p[1],F_ALL,size);
        validate(ap1);
        gen_code(op_cmp,size,ap2,ap1);
        freeop(ap2);
        freeop(ap1);
}

truejp(node,label)
/*
 *      generate a jump to label if the node passed evaluates to
 *      a true condition.
 */
struct enode    *node;
int             label;
{       struct amode    *ap1;
        int             siz1;
        int             lab0;
        if( node == 0 )
                return;
        switch( node->nodetype )
                {
                case en_eq:
                        gen_compare(node);
                        gen_code(op_beq,0,make_label(label),0);
                        break;
                case en_ne:
                        gen_compare(node);
                        gen_code(op_bne,0,make_label(label),0);
                        break;
                case en_lt:
                        gen_compare(node);
                        gen_code(op_blt,0,make_label(label),0);
                        break;
                case en_le:
                        gen_compare(node);
                        gen_code(op_ble,0,make_label(label),0);
                        break;
                case en_gt:
                        gen_compare(node);
                        gen_code(op_bgt,0,make_label(label),0);
                        break;
                case en_ge:
                        gen_compare(node);
                        gen_code(op_bge,0,make_label(label),0);
                        break;
                case en_ult:
                        gen_compare(node);
                        gen_code(op_blo,0,make_label(label),0);
                        break;
                case en_ule:
                        gen_compare(node);
                        gen_code(op_bls,0,make_label(label),0);
                        break;
                case en_ugt:
                        gen_compare(node);
                        gen_code(op_bhi,0,make_label(label),0);
                        break;
                case en_uge:
                        gen_compare(node);
                        gen_code(op_bhs,0,make_label(label),0);
                        break;
                case en_land:
                        lab0 = nextlabel++;
                        falsejp(node->v.p[0],lab0);
                        truejp(node->v.p[1],label);
                        gen_label(lab0);
                        break;
                case en_lor:
                        truejp(node->v.p[0],label);
                        truejp(node->v.p[1],label);
                        break;
                case en_not:
                        falsejp(node->v.p[0],label);
                        break;
                default:
                        siz1 = natural_size(node);
                        ap1 = gen_expr(node,F_ALL,siz1);
                        gen_code(op_tst,siz1,ap1,0);
                        freeop(ap1);
                        gen_code(op_bne,0,make_label(label),0);
                        break;
                }
}

falsejp(node,label)
/*
 *      generate code to execute a jump to label if the expression
 *      passed is false.
 */
struct enode    *node;
int             label;
{       struct amode    *ap;
        int             siz1;
        int             lab0;
        if( node == 0 )
                return;
        switch( node->nodetype )
                {
                case en_eq:
                        gen_compare(node);
                        gen_code(op_bne,0,make_label(label),0);
                        break;
                case en_ne:
                        gen_compare(node);
                        gen_code(op_beq,0,make_label(label),0);
                        break;
                case en_lt:
                        gen_compare(node);
                        gen_code(op_bge,0,make_label(label),0);
                        break;
                case en_le:
                        gen_compare(node);
                        gen_code(op_bgt,0,make_label(label),0);
                        break;
                case en_gt:
                        gen_compare(node);
                        gen_code(op_ble,0,make_label(label),0);
                        break;
                case en_ge:
                        gen_compare(node);
                        gen_code(op_blt,0,make_label(label),0);
                        break;
                case en_ult:
                        gen_compare(node);
                        gen_code(op_bhs,0,make_label(label),0);
                        break;
                case en_ule:
                        gen_compare(node);
                        gen_code(op_bhi,0,make_label(label),0);
                        break;
                case en_ugt:
                        gen_compare(node);
                        gen_code(op_bls,0,make_label(label),0);
                        break;
                case en_uge:
                        gen_compare(node);
                        gen_code(op_blo,0,make_label(label),0);
                        break;
                case en_land:
                        falsejp(node->v.p[0],label);
                        falsejp(node->v.p[1],label);
                        break;
                case en_lor:
                        lab0 = nextlabel++;
                        truejp(node->v.p[0],lab0);
                        falsejp(node->v.p[1],label);
                        gen_label(lab0);
                        break;
                case en_not:
                        truejp(node->v.p[0],label);
                        break;
                default:
                        siz1 = natural_size(node);
                        ap = gen_expr(node,F_ALL,siz1);
                        gen_code(op_tst,siz1,ap,0);
                        freeop(ap);
                        gen_code(op_beq,0,make_label(label),0);
                        break;
                }
}


