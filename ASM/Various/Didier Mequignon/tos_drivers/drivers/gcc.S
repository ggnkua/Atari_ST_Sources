
#define GREATER 1
#define LESS    -1
#define EQUAL   0

/* TOS 4.04 calls */
#define _form_center_tos 0xE491BE
#define _form_dial_tos 0xE49180
#define _form_do_tos 0xE49164
#define _evnt_multi 0xE490D2
#define _objc_draw_tos 0xE492E2
#define _objc_offset_tos 0xE492BA
#define _menu_icheck_tos 0xE49286
#define _menu_popup_tos 0xE3781E
#define _wind_get_tos 0xE493AE
#define _wind_update_tos 0xE49386
#define _graf_handle_tos 0xE491DC
#define _graf_mkstate_tos 0xE49210
#define _graf_mouse_tos 0xE378D8
#define _gr_slidebox 0xE2574E
#define _copy16 0xE49216

	.global _form_center,_form_dial,_form_do
	.global _objc_draw,_objc_offset
	.global _menu_icheck,_menu_popup
	.global _wind_get,_wind_update
	.global _graf_handle,_graf_mkstate,_graf_mouse,_graf_slidebox
#ifdef COLDFIRE
	.global ___udivsi3,___divsi3,___umodsi3,___modsi3
#ifndef MCF5445X /* MCF5445X has no FPU */
	.global ___addsf3,___adddf3,___subsf3,___subdf3
	.global ___mulsf3,___muldf3,___divsf3,___divdf3
	.global ___nesf2,___eqsf2,___ltsf2,___lesf2,___gtsf2,___gesf2,___cmpsf2,___nedf2,___eqdf2,___ltdf2,___ledf2,___gtdf2,___gedf2,___cmpdf2
	.global ___truncdfsf2,___extendsfdf2
	.global ___floatsisf,___floatsidf,___fixunssfsi,___fixsfsi,___fixunsdfsi,___fixdfsi
	.global ___isnan,___isnanf
#endif

___udivsi3:
	moveq #0,D0
	move.l 8(SP),D1
	beq.s  .zero_divide
	move.l 4(SP),D0
	.chip 68020
	divu.l D1,D0
	.chip 5200
.zero_divide:
	rts
___divsi3:
	moveq #0,D0
	move.l 8(SP),D1
	beq.s  .zero_divide
	move.l 4(SP),D0
	.chip 68020
	divs.l D1,D0
	.chip 5200
	rts
___umodsi3:
	move.l 8(SP),D1          // d1 = divisor
	move.l 4(SP),D0          // d0 = dividend
	move.l D1,-(SP)
	move.l D0,-(SP)
	bsr ___udivsi3
	addq.l #8,SP
	move.l 8(SP),D1          // d1 = divisor
	muls.l D1,D0
	move.l 4(SP),D1          // d1 = dividend
	sub.l D0,D1              // d1 = a - (a/b)*b
	move.l D1,D0
	rts
___modsi3:
	move.l 8(SP),D1          // d1 = divisor
	move.l 4(SP),D0          // d0 = dividend
	move.l D1,-(SP)
	move.l D0,-(SP)
	bsr ___divsi3
	addq.l #8,SP
	move.l 8(SP),D1          // d1 = divisor
	muls.l D1,D0
	move.l 4(SP),D1          // d1 = dividend
	sub.l D0,D1              // d1 = a - (a/b)*b
	move.l D1,D0
	rts

#ifndef MCF5445X /* MCF5445X has no FPU */

___addsf3:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.s 8(SP),FP1
	fadd.x FP1,FP0
	fmove.s FP0,D0
	.chip 5200
	rts
___adddf3:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fadd.x FP1,FP0
	fmove.d FP0,-(SP)
	.chip 5200
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___subsf3:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.s 8(SP),FP1
	fsub.x FP1,FP0
	fmove.s FP0,D0
	.chip 5200
	rts
___subdf3:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fsub.x FP1,FP0
	fmove.d FP0,-(SP)
	.chip 5200
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___mulsf3:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.s 8(SP),FP1
	fmul.x FP1,FP0
	fmove.s FP0,D0
	.chip 5200
	rts
___muldf3:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fmul.x FP1,FP0
	fmove.d FP0,-(SP)
	.chip 5200
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___divsf3:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.s 8(SP),FP1
	fdiv.x FP1,FP0
	fmove.s FP0,D0
	.chip 5200
	rts
___divdf3:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fdiv.x FP1,FP0
	fmove.d FP0,-(SP)
	.chip 5200
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___nesf2:
___eqsf2:
___ltsf2:
___lesf2:
___gtsf2:
___gesf2:
___cmpsf2:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.s 8(SP),FP1
	fcmp.x FP1,FP0
	fbeq .equal
	fbgt .greater
	.chip 5200
	moveq #LESS,D0
	rts
___nedf2:
___eqdf2:
___ltdf2:
___ledf2:
___gtdf2:
___gedf2:
___cmpdf2:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.d 12(SP),FP1
	fcmp.x FP1,FP0
	fbeq .equal
	fbgt .greater
	.chip 5200
	moveq #LESS,D0
	rts
.equal:
	moveq #EQUAL,D0
	rts	
.greater:
	moveq #GREATER,D0
	rts
___truncdfsf2:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.s FP0,D0
	.chip 5200
	rts
___extendsfdf2:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.d FP0,-(SP)
	.chip 5200
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___floatsisf:
	.chip 68040
	fmove.l 4(SP),FP0
	fmove.s FP0,D0
	.chip 5200
	rts
___floatsidf:
	.chip 68040
	fmove.l 4(SP),FP0
	fmove.d FP0,-(SP)
	.chip 5200
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts
___fixunssfsi:
___fixsfsi:
	.chip 68040
	fmove.s 4(SP),FP0
	fmove.l FP0,D0
	.chip 5200
	rts
___fixunsdfsi:
___fixdfsi:
	.chip 68040
	fmove.d 4(SP),FP0
	fmove.l FP0,D0
	.chip 5200
	rts
___isnan:
	move.l 4(SP),D0          // hx
	move.l 8(SP),D1          // lx
	move.l D2,-(SP)
	move.l D3,-(SP)
	bclr #31,D0
	move.l D1,D2             // lx
	neg.l D2
	or.l D1,D2
	moveq #31,D3
	lsr.l D3,D2
	or.l D2,D0               // hx |= (u_int32_t)(lx|(-lx))>>31;
	neg.l D0
	add.l #0x7FF00000,D0
	lsr.l D3,D0
	move.l (SP)+,D3
	move.l (SP)+,D2
	rts
___isnanf:
	move.l 4(SP),D0
	bclr #31,D0
	neg.l D0
	add.l #0x7F800000,D0
	moveq #31,D1
	lsr.l D1,D0
	rts

#endif /* MCF5445X */
#endif /* COLDFIRE */

// short form_center(OBJECT *fo_ctree, short *fo_cx, short *fo_cy, short *fo_cw, short *fo_ch)
_form_center:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2/A0-A1
	move.l A1,-(SP)
	move.l A0,-(SP)
	move.l D2,-(SP)
	move.l D1,-(SP)	
	move.l D0,-(SP)
	jsr _form_center_tos
	lea 20(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short form_dial(short fo_diflag, short fo_dilittlx, short fo_dilittly, short fo_dilittlw, short fo_dilittlh, short fo_dibigx, short fo_dibigy, short fo_dibigw, short fo_dibigh)
_form_dial:
	lea -28(SP),SP
	movem.l D2-D7/A2,(SP)
	movem.l 32(SP),D0-D7/A0
	move.w A0,-(SP)
	move.w D7,-(SP)
	move.w D6,-(SP)	
	move.w D5,-(SP)
	move.w D4,-(SP)
	move.w D3,-(SP)
	move.w D2,-(SP)
	move.w D1,-(SP)	
	move.w D0,-(SP)
	jsr _form_dial_tos
	lea 18(SP),SP
	movem.l (SP),D2-D7/A2
	lea 28(SP),SP
             rts

// short form_do(OBJECT *fo_dotree, short fo_dostartob)
_form_do:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.w D1,-(SP)
	move.l D0,-(SP)
	jsr _form_do_tos
	addq.l #6,SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short objc_draw(OBJECT *ob_drtree, short ob_drstartob, short ob_drdepth, short ob_drxclip, short ob_dryclip, short ob_drwclip, short ob_drhclip)
_objc_draw:
	lea -24(SP),SP
	movem.l D2-D6/A2,(SP)
	movem.l 28(SP),D0-D6
	move.w D6,-(SP)
	move.w D5,-(SP)
	move.w D4,-(SP)
	move.w D3,-(SP)
	move.w D2,-(SP)
	move.w D1,-(SP)
	move.l D0,-(SP)
	jsr _objc_draw_tos
	lea 16(SP),SP
	movem.l (SP),D2-D6/A2
	lea 24(SP),SP
             rts

// short objc_offset(OBJECT *ob_oftree, short ob_ofobject, short *ob_ofxoff, short *ob_ofyoff)
_objc_offset:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1/A0-A1
	move.l A1,-(SP)
	move.l A0,-(SP)
	move.w D1,-(SP)
	move.l D0,-(SP)
	jsr _objc_offset_tos
	lea 14(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short menu_popup(MENU *me_menu, short me_xpos, short me_ypos, MENU *me_mdata)
_menu_popup:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2/A0
	move.l A0,-(SP)
	move.w D2,-(SP)	
	move.w D1,-(SP)
	move.l D0,-(SP)
	jsr _menu_popup_tos
	lea 12(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short wind_get(short whdl, short subfn, short *g1, short *g2, short *g3, short *g4)
_wind_get:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2/A0-A2
	move.l A2,-(SP)
	move.l A1,-(SP)
	move.l A0,-(SP)
	move.l D2,-(SP)	               
	move.w D1,-(SP)
	move.w D0,-(SP)
	jsr _wind_get_tos
	lea 20(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short wind_update(short wi_ubegend)
_wind_update:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.w D0,-(SP)
	jsr _wind_update_tos
	addq.l #2,SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short graf_handle(short *gr_hwchar, short *gr_hhchar, short *gr_hwbox, short *gr_hhbox)
_graf_handle:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1/A0-A1
	move.l A1,-(SP)
	move.l A0,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	jsr _graf_handle_tos
	lea 16(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short graf_mkstate(short *gr_mkmx, short *gr_mkmy, short *gr_mkmstate, short *gr_mkkstate)
_graf_mkstate:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1/A0-A1
	move.l A1,-(SP)
	move.l A0,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	jsr _graf_mkstate_tos
	lea 16(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short graf_mouse(short gr_monumber, MFORM *gr_mofaddr)
_graf_mouse:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0/A0
	move.l A0,-(SP)
	move.w D0,-(SP)	
             jsr _graf_mouse_tos
             addq.l #6,SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

// short graf_slidebox(OBJECT *gr_slptree, short gr_slparent, short gr_slobject, short gr_slvh) 
_graf_slidebox:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2/A0
	move.w A0,-(SP)
	move.w D2,-(SP)
	move.w D1,-(SP)
	move.l D0,-(SP)
	bsr _graf_slidebox_tos
	lea 10(SP),SP
             move.l (SP)+,A2
             move.l (SP)+,D2
             rts

_graf_slidebox_tos:
	lea _gr_slidebox,A0
	jmp _copy16
