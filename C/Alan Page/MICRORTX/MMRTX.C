/*
 * RTX Bindings for Megamax C
 *
 * Written by: Alan Page
 */
extern rtx_install(), p_create(), p_priority(), p_delete();
extern p_slice(), q_create(), q_delete(), q_send(), q_req();
extern q_jam(), e_signal(), e_wait(), p_pause(), m_alloc();
extern m_free(), m_assign(), p_lookup(), p_vector(), q_lookup();
extern p_suspend(), p_resume(), d_install(), d_cntrl(), q_info();
extern rtx_remove();
extern bios(), gemdos(), xbios();

asm {

rtx_install:
        move.l 4(A7),-(A7)
        move.w #0,-(A7)
        trap #5
        addq.l #6,A7
        rts
p_create:
        link A6,#0
        move.l 26(A6),-(A7)
        move.l 22(A6),-(A7)
        move.w 20(A6),-(A7)
        move.l 16(A6),-(A7)
        move.w 14(A6),-(A7)
        move.w 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #1,-(A7)
        trap #5
        unlk A6
        rts

p_delete:
        move.l 4(A7),-(A7)
        move.w #2,-(A7)
        trap #5
        addq.l #6,A7
        rts


p_priority:
        link A6,#0
        move.w 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #3,-(A7)
        trap #5
        unlk A6
        rts

p_slice:
        link A6,#0
        move.w 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #4,-(A7)
        trap #5
        unlk A6
        rts

q_create:
        link A6,#0
        move.w 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #5,-(A7)
        trap #5
        unlk A6
        rts

q_delete:
        move.l 4(A7),-(A7)
        move.w #6,-(A7)
        trap #5
        addq.l #6,A7
        rts

q_send:
        link A6,#0
        move.l 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #7,-(A7)
        trap #5
        unlk A6
        rts

q_req:
        link A6,#0
        move.l 18(A6),-(A7)
        move.w 16(A6),-(A7)
        move.l 12(A6),-(A7)
        move.l 8(A6),-(A7)
        move.w #8,-(A7)
        trap #5
        unlk A6
        rts

q_jam:
        link A6,#0
        move.l 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #9,-(A7)
        trap #5
        unlk A6
        rts

e_signal:
        link A6,#0
        move.w 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #0xA,-(A7)
        trap #5
        unlk A6
        rts

e_wait:
        link A6,#0
        move.l 14(A6),-(A7)
        move.w 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #0xb,-(A7)
        trap #5
        unlk A6
        rts

p_pause:
        move.l 4(A7),-(A7)
        move.w #0xc,-(A7)
        trap #5
        addq.l #6,A7
        rts

m_alloc:
        move.l 4(A7),-(A7)
        move.w #0xd,-(A7)
        trap #5
        addq.l #6,A7
        rts

m_free:
        move.l 4(A7),-(A7)
        move.w #0xe,-(A7)
        trap #5
        addq.l #6,A7
        rts

m_assign:
        link A6,#0
        move.l 12(A6),-(A7)
        move.l  8(A6),-(A7)
        move.w #0xf,-(A7)
        trap #5
        unlk A6
        rts

p_lookup:
        move.l 4(A7),-(A7)
        move.w #0x10,-(A7)
        trap #5
        addq.l #6,A7
        rts

q_lookup:
        move.l 4(A7),-(A7)
        move.w #0x11,-(A7)
        trap #5
        addq.l #6,A7
        rts

p_vector:
        link A6,#0
        move.l 12(A6),-(A7)
        move.l 8(A6),-(A7)
        move.w #0x13,-(A7)
        trap #5
        unlk A6
        rts


p_suspend:
	link A6,#0
	move.l 8(A6),-(A7)
	move.w #0x14,-(A7)
	trap #5
	unlk A6
	rts


p_resume:
	link A6,#0
	move.l 8(A6),-(A7)
	move.w #0x15,-(A7)	
	trap #5			
	unlk A6
	rts


d_install:
	link A6,#0
	move.l 30(A6),-(A7)
	move.l 26(A6),-(A7)
	move.l 22(A6),-(A7)
	move.l 18(A6),-(A7)
	move.l 14(A6),-(A7)
	move.l 10(A6),-(A7)
	move 8(A6),-(A7)
	move #0x16,-(A7)	
	trap #5
	unlk A6
	rts

d_cntrl:
	link A6,#0
	move.l 10(A6),-(A7)	
	move.w 8(A6),-(A7)	
	move.w #0x17,-(A7)	
	trap #5			
	unlk A6
	rts

q_info:
	link A6,#0
	move.l 16(A6),-(A7)
	move.l 12(A6),-(A7)
	move.l 8(A6),-(A7)
	move.w #0x18,-(A7)
	trap #5
	unlk A6
	rts

rtx_remove:
        move.w #255,-(A7)
        trap #5
        addq.l #2,A7
        rts

bios:
        move #201,-(A7)
        trap #5
        addq.l #6,A7
        trap #13
        move.l D0,-(A7)
        move #203,-(A7)
        trap #5
        addq.l #2,A7
        move.l D0,A0
        move.l (A7)+,D0
        jmp (A0)

xbios:
        move #201,-(A7)
        trap #5
        addq.l #6,A7
        trap #14
        move.l D0,-(A7)
        move #203,-(A7)
        trap #5
        addq.l #2,A7
        move.l D0,A0
        move.l (A7)+,D0
        jmp (A0)

gemdos:
        move #201,-(A7)
        trap #5
        addq.l #6,A7
        trap #1
        move.l D0,-(A7)
        move #203,-(A7)
        trap #5
        addq.l #2,A7
        move.l D0,A0
        move.l (A7)+,D0
        jmp (A0)

}
