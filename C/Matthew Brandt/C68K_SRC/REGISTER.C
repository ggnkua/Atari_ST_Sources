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
 *      this module handles the allocation and de-allocation of
 *      temporary registers. when a temporary register is allocated
 *      the stack depth is saved in the field deep of the address
 *      mode structure. when validate is called on an address mode
 *      structure the stack is popped until the register is restored
 *      to it's pre-push value.
 */

struct amode    push[] = { {am_adec,7} },
                pop[] = { {am_ainc,7} };
int             next_data,
                next_addr;
int             max_data,
                max_addr;

gen_push(reg,rmode)
/*
 *      this routine generates code to push a register onto the stack
 */
int     reg, rmode;
{       struct amode    *ap1;
        ap1 = xalloc(sizeof(struct amode));
        ap1->preg = reg;
        ap1->mode = rmode;
        gen_code(op_move,4,ap1,push);
}

gen_pop(reg,rmode)
/*
 *      generate code to pop the primary register in ap from the
 *      stack.
 */
int     reg, rmode;
{       struct amode    *ap1;
        ap1 = xalloc(sizeof(struct amode));
        ap1->preg = reg;
        ap1->mode = rmode;
        gen_code(op_move,4,pop,ap1);
}

initstack()
/*
 *      this routine should be called before each expression is
 *      evaluated to make sure the stack is balanced and all of
 *      the registers are marked free.
 */
{       next_data = 0;
        next_addr = 0;
        max_data = 2;
        max_addr = 1;
}

validate(ap)
/*
 *      validate will make sure that if a register within an address
 *      mode has been pushed onto the stack that it is popped back
 *      at this time.
 */
struct amode    *ap;
{       switch( ap->mode )
                {
                case am_direct:
                case am_immed:
                        return;         /* no registers used */
                case am_dreg:
                        if( ap->preg > 2 )
                                return; /* not a temporary */
                        if( max_data - ap->deep >= 3 )
                                {
                                gen_pop(ap->preg,am_dreg);
                                --max_data;
                                }
                        break;
                default:
                        if( ap->preg > 1 )
                                return; /* not a temp register */
                        if( max_addr - ap->deep >= 2 )
                                {
                                gen_pop(ap->preg,am_areg);
                                --max_addr;
                                }
                        break;
                }
}

struct amode    *temp_data()
/*
 *      allocate a temporary data register and return it's
 *      addressing mode.
 */
{       struct amode    *ap;
        ap = xalloc(sizeof(struct amode));
        ap->mode = am_dreg;
        ap->preg = next_data % 3;
        ap->deep = next_data;
        if( next_data > max_data )
                {
                gen_push(next_data % 3,am_dreg);
                max_data = next_data;
                }
        ++next_data;
        return ap;
}

struct amode    *temp_addr()
/*
 *      allocate a temporary address register and return it's
 *      addressing mode.
 */
{       struct amode    *ap;
        ap = xalloc(sizeof(struct amode));
        ap->mode = am_areg;
        ap->preg = next_addr % 2;
        ap->deep = next_addr;
        if( next_addr > max_addr )
                {
                gen_push(next_addr % 2,am_areg);
                max_addr = next_addr;
                }
        ++next_addr;
        return ap;
}

freeop(ap)
/*
 *      release any temporary registers used in an addressing mode.
 */
struct amode    *ap;
{       if( ap->mode == am_immed || ap->mode == am_direct )
                return;         /* no registers used */
        if( ap->mode == am_dreg && ap->preg < 3 )
                --next_data;
        else if( ap->preg < 2 )
                --next_addr;
}

