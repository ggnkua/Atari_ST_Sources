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

struct ocode    *peep_head = 0,
                *peep_tail = 0;

struct amode    *copy_addr(ap)
/*
 *      copy an address mode structure (these things dont last).
 */
struct amode    *ap;
{       struct amode    *newap;
        if( ap == 0 )
                return 0;
        newap = xalloc(sizeof(struct amode));
        newap->mode = ap->mode;
        newap->preg = ap->preg;
        newap->sreg = ap->sreg;
        newap->tempflag = ap->tempflag;
        newap->deep = ap->deep;
        newap->offset = ap->offset;
        return newap;
}

gen_code(op,len,ap1,ap2)
/*
 *      generate a code sequence into the peep list.
 */
int             op, len;
struct amode    *ap1, *ap2;
{       struct ocode    *new;
        new = xalloc(sizeof(struct ocode));
        new->opcode = op;
        new->length = len;
        new->oper1 = copy_addr(ap1);
        new->oper2 = copy_addr(ap2);
        add_peep(new);
}

add_peep(new)
/*
 *      add the ocoderuction pointed to by new to the peep list.
 */
struct ocode    *new;
{       if( peep_head == 0 )
                {
                peep_head = peep_tail = new;
                new->fwd = 0;
                new->back = 0;
                }
        else
                {
                new->fwd = 0;
                new->back = peep_tail;
                peep_tail->fwd = new;
                peep_tail = new;
                }
}

gen_label(labno)
/*
 *      add a compiler generated label to the peep list.
 */
int     labno;
{       struct ocode    *new;
        new = xalloc(sizeof(struct ocode));
        new->opcode = op_label;
        new->oper1 = labno;
        add_peep(new);
}

flush_peep()
/*
 *      output all code and labels in the peep list.
 */
{       opt3();         /* do the peephole optimizations */
        while( peep_head != 0 )
                {
                if( peep_head->opcode == op_label )
                        put_label(peep_head->oper1);
                else
                        put_ocode(peep_head);
                peep_head = peep_head->fwd;
                }
}

put_ocode(p)
/*
 *      output the instruction passed.
 */
struct ocode    *p;
{       put_code(p->opcode,p->length,p->oper1,p->oper2);
}

peep_move(ip)
/*
 *      peephole optimization for move instructions.
 *      makes quick immediates when possible.
 *      changes move #0,d to clr d.
 *      changes long moves to address registers to short when
 *              possible.
 *      changes move immediate to stack to pea.
 */
struct ocode	*ip;
{       struct enode    *ep;
        if( ip->oper1->mode != am_immed )
                return;
        ep = ip->oper1->offset;
        if( ep->nodetype != en_icon )
                return;
        if( ip->oper2->mode == am_areg )
                {
                if( -32768 <= ep->v.i && ep->v.i <= 32768 )
                        ip->length = 2;
                }
        else if( ip->oper2->mode == am_dreg )
                {
                if( -128 <= ep->v.i && ep->v.i <= 127 )
                        {
                        ip->opcode = op_moveq;
                        ip->length = 0;
                        }
                }
        else
                {
                if( ep->v.i == 0 )
                        {
                        ip->opcode = op_clr;
                        ip->oper1 = ip->oper2;
                        ip->oper2 = 0;
                        }
                else if( ip->oper2->mode == am_adec && ip->oper2->preg == 7 )
                        {
                        ip->opcode = op_pea;
                        ip->length = 0;
                        ip->oper1->mode = am_direct;
                        ip->oper2 = 0;
                        }
                }
}

int     equal_address(ap1,ap2)
/*
 *      compare two address nodes and return true if they are
 *      equivalent.
 */
struct amode    *ap1, *ap2;
{       if( ap1 == 0 || ap2 == 0 )
                return 0;
        if( ap1->mode != ap2->mode )
                return 0;
        switch( ap1->mode )
                {
                case am_areg:   case am_dreg:
                case am_ainc:   case am_adec:
                        return ap1->preg == ap2->preg;
                }
        return 0;
}

peep_add(ip)
/*
 *      peephole optimization for add instructions.
 *      makes quick immediates out of small constants.
 */
struct ocode    *ip;
{       struct enode    *ep;
        if( ip->oper1->mode != am_immed )
                return;
        ep = ip->oper1->offset;
        if( ip->oper2->mode != am_areg )
                ip->opcode = op_addi;
        else
                {
                if( isshort(ep) )
                        ip->length = 2;
                }
        if( ep->nodetype != en_icon )
                return;
        if( 1 <= ep->v.i && ep->v.i <= 8 )
                ip->opcode = op_addq;
        else if( -8 <= ep->v.i && ep->v.i <= -1 )
                {
                ip->opcode = op_subq;
                ep->v.i = -ep->v.i;
                }
}

peep_sub(ip)
/*
 *      peephole optimization for subtract instructions.
 *      makes quick immediates out of small constants.
 */
struct ocode    *ip;
{       struct enode    *ep;
        if( ip->oper1->mode != am_immed )
                return;
        ep = ip->oper1->offset;
        if( ip->oper2->mode != am_areg )
                ip->opcode = op_subi;
        else
                {
                if( isshort(ep) )
                        ip->length = 2;
                }
        if( ep->nodetype != en_icon )
                return;
        if( 1 <= ep->v.i && ep->v.i <= 8 )
                ip->opcode = op_subq;
        else if( -8 <= ep->v.i && ep->v.i <= -1 )
                {
                ip->opcode = op_addq;
                ep->v.i = -ep->v.i;
                }
}

int     peep_cmp(ip)
/*
 *      peephole optimization for compare instructions.
 *      changes compare #0 to tst and if previous instruction
 *      should have set the condition codes properly delete.
 *      return value is true if instruction was deleted.
 */
struct ocode    *ip;
{       struct ocode    *prev;
        struct enode    *ep;
        if( ip->oper1->mode != am_immed )
                return;
        ep = ip->oper1->offset;
        if( ip->oper2->mode == am_areg )
                {
                if( isshort(ep) )
                        ip->length = 2;
                return;
                }
        ip->opcode = op_cmpi;
        if( ep->nodetype != en_icon || ep->v.i != 0 )
                return;
        ip->oper1 = ip->oper2;
        ip->oper2 = 0;
        ip->opcode = op_tst;
        prev = ip->back;
        if( prev == 0 )
                return;
        if( (((prev->opcode == op_move || prev->opcode == op_moveq) &&
                equal_address(prev->oper1,ip->oper1)) &&
                prev->oper2->mode != am_areg) ||
                (prev->opcode != op_label &&
                equal_address(prev->oper2,ip->oper1)) )
                {
                prev->fwd = ip->fwd;
                if( prev->fwd != 0 )
                        prev->fwd->back = prev;
                }
}

peep_muldiv(ip,op)
/*
 *      changes multiplies and divides by convienient values
 *      to shift operations. op should be either op_asl or
 *      op_asr (for divide).
 */
struct ocode    *ip;
{       int     shcnt;
        if( ip->oper1->mode != am_immed )
                return;
        if( ip->oper1->offset->nodetype != en_icon )
                return;
        shcnt = ip->oper1->offset->v.i;
/*      vax c doesn't do this type of switch well       */
        if( shcnt == 2) shcnt = 1;
        else if( shcnt == 4) shcnt = 2;
        else if( shcnt == 8) shcnt = 3;
        else if( shcnt == 16) shcnt = 4;
        else if( shcnt == 32) shcnt = 5;
        else if( shcnt == 64) shcnt = 6;
        else if( shcnt == 128) shcnt = 7;
        else if( shcnt == 256) shcnt = 8;
        else if( shcnt == 512) shcnt = 9;
        else if( shcnt == 1024) shcnt = 10;
        else if( shcnt == 2048) shcnt = 11;
        else if( shcnt == 4096) shcnt = 12;
        else if( shcnt == 8192) shcnt = 13;
        else if( shcnt == 16384) shcnt = 14;
        else return;
        ip->oper1->offset->v.i = shcnt;
        ip->opcode = op;
        ip->length = 4;
}

peep_uctran(ip)
/*
 *      peephole optimization for unconditional transfers.
 *      deletes instructions which have no path.
 *      applies to bra, jmp, and rts instructions.
 */
struct ocode    *ip;
{       while( ip->fwd != 0 && ip->fwd->opcode != op_label )
                {
                ip->fwd = ip->fwd->fwd;
                if( ip->fwd != 0 )
                        ip->fwd->back = ip;
                }
}

opt3()
/*
 *      peephole optimizer. This routine calls the instruction
 *      specific optimization routines above for each instruction
 *      in the peep list.
 */
{       struct ocode    *ip;
        ip = peep_head;
        while( ip != 0 )
                {
                switch( ip->opcode )
                        {
                        case op_move:
                                peep_move(ip);
                                break;
                        case op_add:
                                peep_add(ip);
                                break;
                        case op_sub:
                                peep_sub(ip);
                                break;
                        case op_cmp:
                                peep_cmp(ip);
                                break;
                        case op_muls:
                                peep_muldiv(ip,op_asl);
                                break;
                        case op_bra:
                        case op_jmp:
                        case op_rts:
                                peep_uctran(ip);
                        }
                ip = ip->fwd;
                }
}

