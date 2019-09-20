/* 
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
	.global _mousexy,_call_ikbdvec,_call_mousevec
	.global _compare_block,_copy_block
	.global _asm_set_ipl
#ifndef COLDFIRE
	.global ___floatunsidf
#else
	.global _linea000
	.global ___addxf3,___subxf3,___mulxf3,___divxf3
	.global ___nexf2,___eqxf2,___ltxf2,___lexf2,___gtxf2,___gexf2,___cmpxf2
	.global ___extendsfxf2,___extenddfxf2,___floatsixf,___fixxfsi
#endif
#ifdef MINT_IKBD_PATCH 
	.global _M68k_InstrLen
#endif
	.text
	
_mousexy:

#define G_CURX -602
#ifdef COLDFIRE
	lea -16(SP),SP
	movem.l D1-D2/A1-A2,(SP)
	move.l _linea000,D0
	beq.s .mxy2              // no cookie 'A000'  
	move.l D0,A0
	jsr (A0)
	bra.s .mxy1
.mxy2:
	dc.w 0xA920              // 0xA000 is MAC instruction on CF
.mxy1:
	movem.l (SP),D1-D2/A1-A2
	lea 16(SP),SP
#else
	movem.l D1-D2/A1-A2,-(SP)
	dc.w 0xA000
	movem.l (SP)+,D1-D2/A1-A2
#endif
	move.l G_CURX(A0),D0
	rts
 
_call_ikbdvec:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
#else
	movem.l D0-D2/A0-A2,-(SP)
#endif
#ifdef MINT_IKBD_PATCH
	tst.l mint_ikbd_scan
	bne .mint_ok
	move.l 36(SP),A2         // &kbdvecs[-1]
	move.l 0x118,A0          // ACIA MFP interrupt vector
.find_mint_acia:
		cmp.l #0x58425241,-12(A0) // XBRA
		bne .mint_ok
		cmp.l #0x4D694E54,-8(A0)  // MiNT
		beq.s .mint_acia_found
		move.l -4(A0),D0          // next
	move.l D0,A0
	bne.s .find_mint_acia
	bra .mint_ok
.mint_acia_found:
	move.l (A2),A1           // ikbdvec
.find_mint_ikbdvec:
		cmp.l #0x58425241,-12(A1) // XBRA
		bne.s .mint_ikbdvec_not_found
		cmp.l #0x4D694E54,-8(A1)  // MiNT
		beq.s .mint_ok
		move.l -4(A1),D0          // next
	move.l D0,A1
	bne.s .find_mint_ikbdvec
.mint_ikbdvec_not_found:
.loop_find_mint_rte:
		moveq #0,D0
		move.w (A0),D0
		cmp.l #0x4E73,D0 // RTE
		beq.s .loop_find_mint_jsr
		move.l A0,-(SP)
		jsr _M68k_InstrLen
		move.l (SP)+,A0
		add.l D0,A0
		add.l D0,A0
	bra.s .loop_find_mint_rte
.loop_find_mint_jsr:
		moveq #0,D0
		move.w (A0),D0
		cmp.l #0x4E75,D0 // rts
		beq.s .mint_ok
		cmp.l #0x4EB9,D0 // jsr
		beq.s .mint_jsr_found
		move.l A0,-(SP)
		jsr _M68k_InstrLen
		move.l (SP)+,A0
		add.l D0,A0
		add.l D0,A0
	bra.s .loop_find_mint_jsr
.mint_jsr_found:
	move.l 6(A0),D0
	cmp.l #0x5C8F4E75,D0     // addq.l #6,SP rts
	bne.s .mint_ok 
	move.l 2(A0),A0          // jsr address
	move.l A0,mint_ikbd_scan
	lea ikbd_scan(PC),A0
	move.l 36(SP),A2         // &kbdvecs[-1]
	move.l A0,(A2)
.mint_ok:
#endif /* MINT_IKBD_PATCH */
	move.l 28(SP),D0         // ikbd code
	and.l #0xFF,D0
	move.l 32(SP),A0         // iorec
	move.l 36(SP),A2         // &kbdvecs[-1]
	move.l (A2),A2           // ikbdvec
	jsr (A2)
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts

	dc.l 0x58425241          // XBRA
	dc.l 0x4D694E54          // MiNT
	dc.l 0

_call_mousevec:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
#else
	movem.l D0-D2/A0-A2,-(SP)
#endif
	move.l 28(SP),A0         // data
	move.l 32(SP),A2
	move.l (A2),A2           // mousevec
	jsr (A2)
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts
	
_compare_block:

#ifdef COLDFIRE
	lea -56(SP),SP
	movem.l D1-D7/A0-A6,(SP)
#else
	movem.l D1-D7/A0-A6,-(SP)
#endif
	move.l 60(SP),A0         // cmp_buffer
	move.l 64(SP),A1         // frame_buffer
	move.l 68(SP),D0         // bpp
	move.l 72(SP),D1         // block_length width
	ble .cb1
	move.l 76(SP),D2         // block_length height
	ble .cb1
	move.l 80(SP),D3         // line_width
	sub.l D1,D3
	lsr.l #1,D1
	subq.l #1,D2
	cmp.l #4,D0
	beq.s .cb4
	cmp.l #2,D0
	bne .cb1
	lsr.l #1,D1
	move.l D1,D0
	lsr.l #2,D0
	subq.l #1,D0
	move.l D0,A2
	subq.l #1,D1
	add.l D3,D3
	bra.s .cb5
.cb4:
	move.l D1,D0
	lsr.l #2,D0
	subq.l #1,D0
	move.l D0,A2
	subq.l #1,D1
	asl.l #2,D3
.cb5:
		move.l D1,D0
		btst #1,D2
		bne.s .cb10
.cb6:                        // compare 1/2 block
			addq.l #4,A1
			addq.l #4,A0
#ifdef COLDFIRE
			move.l (A1)+,D7
			cmp.l (A0)+,D7
			bne.s .cb2
		subq.l #1,D0
		bpl.s .cb6
#else
			cmpm.l (A1)+,(A0)+
		dbne D0,.cb6
		bne.s .cb2
#endif
		add.l D3,A1
		add.l D3,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cb5
#else
	dbf D2,.cb5
#endif
	bra.s .cb7
.cb10:                       // compare 1/2 block
#ifdef COLDFIRE
			move.l (A1)+,D7
			cmp.l (A0)+,D7
#else
			cmpm.l (A1)+,(A0)+
#endif
			bne.s .cb11
			addq.l #4,A1
			addq.l #4,A0
#ifdef COLDFIRE
		subq.l #1,D0
		bpl.s .cb10
#else
		dbf D0,.cb10
#endif
		add.l D3,A1
		add.l D3,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cb5
#else
	dbf D2,.cb5
#endif
.cb7:
	moveq #1,D0              // same block
	bra.s .cb8
.cb2:
	subq.l #8,A1
	subq.l #8,A0
	bra.s .cb9
.cb11:
	subq.l #4,A1
	subq.l #4,A0
	bra.s .cb9
.cb3:
		move.l A2,D0
.cb12:                       // copy block
#ifdef COLDFIRE
			movem.l (A1),D4-D7/A3-A6
			lea 32(A1),A1
#else
			movem.l (A1)+,D4-D7/A3-A6
#endif
			movem.l D4-D7/A3-A6,(A0)
			lea 32(A0),A0
#ifdef COLDFIRE
		subq.l #1,D0
		bpl.s .cb12
#else
		dbf D0,.cb12
#endif
		add.l D3,A1
		add.l D3,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cb3
#else
	dbf D2,.cb3
#endif
	bra.s .cb1
.cb9:                        // copy end of block
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
#ifdef COLDFIRE
		subq.l #1,D0
		bpl.s .cb9
#else
		dbf D0,.cb9
#endif
		add.l D3,A1
		add.l D3,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cb3
#else
	dbf D2,.cb3
#endif
.cb1:
	moveq #0,D0              // pixel(s) changed inside the block
.cb8:
#ifdef COLDFIRE
	movem.l (SP),D1-D7/A0-A6
	lea 56(SP),SP
#else
	movem.l (SP)+,D1-D7/A0-A6
#endif
	rts

_copy_block:

#ifdef COLDFIRE
	lea -44(SP),SP
	movem.l D0-D7/A0-A2,(SP)
#else
	movem.l D0-D7/A0-A2,-(SP)
#endif
	move.l 48(SP),A0         // vnc_buffer
	move.l 52(SP),A1         // frame_buffer
	move.l 56(SP),D0         // bpp
	move.l 60(SP),D1         // block_length width
	ble .cp1
	move.l 64(SP),D2         // block_length height
	ble .cp1
	move.l 68(SP),D7         // vnc_width
	move.l 72(SP),D3         // line_width
	move.l 76(SP),A2         // tab_65k_colors
	sub.l D1,D7
	sub.l D1,D3
	asl.l #2,D7
	subq.l #1,D1
	subq.l #1,D2
	cmp.l #4,D0
	beq .cp4
	cmp.l #2,D0
	bne .cp1
	add.l D3,D3
	move.l A2,D4
	bne .cp7               // faster
.cp2:
		move.l D1,D0
.cp3:
			move.w (A1)+,D4
			move.l D4,D5
			and.l #0x1F,D5   // blue
			asl.l #3,D5
			move.l D4,D6
			and.l #0x7C0,D6  // green
			asl.l #5,D6
			or.l D5,D6
			move.l D4,D5
			and.l #0xF800,D5 // red
			asl.l #8,D5
			or.l D6,D5
			move.l D5,(A0)+  // 0RGB
#ifdef COLDFIRE
		subq.l #1,D0
		bpl.s .cp3
#else
		dbf D0,.cp3
#endif
		add.l D3,A1
		add.l D7,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cp2
#else
	dbf D2,.cp2
#endif
	bra.s .cp1
.cp7:
	moveq #0,D4
.cp8:
		move.l D1,D0
.cp9:
			move.w (A1)+,D4
			move.l (A2,D4.l*4),(A0)+ // 0RGB
#ifdef COLDFIRE
		subq.l #1,D0
		bpl.s .cp9
#else
		dbf D0,.cp9
#endif
		add.l D3,A1
		add.l D7,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cp8
#else
	dbf D2,.cp8
#endif
	bra.s .cp1
.cp4:
	asl.l #2,D3
.cp5:
		move.l D1,D0
.cp6:
			move.l (A1)+,(A0)+
#ifdef COLDFIRE
		subq.l #1,D0
		bpl.s .cp6
#else
		dbf D0,.cp6
#endif
		add.l D3,A1
		add.l D7,A0
#ifdef COLDFIRE
	subq.l #1,D2
	bpl.s .cp5
#else
	dbf D2,.cp5
#endif
.cp1:
#ifdef COLDFIRE
	movem.l (SP),D0-D7/A0-A2
	lea 44(SP),SP
#else
	movem.l (SP)+,D0-D7/A0-A2
#endif
	rts

_asm_set_ipl:

	link A6,#-8
	movem.l D6-D7,(SP)
	move.w SR,D7             // current SR
	move.l D7,D0             // prepare return value
	and.l #0x0700,D0         // mask out IPL
	lsr.l #8,D0              // IPL
	move.l 8(A6),D6          // get argument
	and.l #7,D6              // least significant three bits
	lsl.l #8,D6              // move over to make mask
	and.l #0x0000F8FF,D7     // zero out current IPL
	or.l D6,D7               // place new IPL in SR
	move.w D7,SR
	movem.l (SP),D6-D7
	lea 8(SP),SP
	unlk A6
	rts

#ifndef COLDFIRE

___floatunsidf:
	fmove.l 4(SP),FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts

#else /* COLDFIRE */

#define GREATER 1
#define LESS    -1
#define EQUAL   0

___addxf3:
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fadd.d FP1,FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___subxf3:
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fsub.d FP1,FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___mulxf3:
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fmul.d FP1,FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___divxf3:
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fdiv.d FP1,FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___nexf2:
___eqxf2:
___ltxf2:
___lexf2:
___gtxf2:
___gexf2:
___cmpxf2:
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fcmp.d FP1,FP0
	fbeq .equal
	fbgt .greater
	moveq #LESS,D0
	rts
.equal:
	moveq #EQUAL,D0
	rts	
.greater:
	moveq #GREATER,D0
	rts
___extendsfxf2:
	fmove.s 4(SP),FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___extenddfxf2:
	fmove.d 4(SP),FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___floatsixf:
	fmove.l 4(SP),FP0
	fmove.d FP0,-(SP)
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___fixunsxfsi:
___fixxfsi:
	fmove.d 4(SP),FP0
	fmove.l FP0,D0
	rts

#endif /* COLDFIRE */
	
	.align 2
#ifdef MINT_IKBD_PATCH 
	.lcomm mint_ikbd_scan,4
#endif
