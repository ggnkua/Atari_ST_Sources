vsync	macro 
	move.l	_vsync,d0
\@1	cmp.l	_vsync,d0
	beq.s	\@1
	endm
	
sprite	macro
	
	move.l (a1)+,d0
	move.w (a1)+,d1
	move.l (a3)+,d2
	move.l (a0),d3
	move.l 4(a0),d4
	swap d4
	
	and.l d2,d3
	and.l d2,d4
	or.l d0,d3
	or.w d1,d4
	swap d4
	move.l d3,(a0)+
	move.l d4,(a0)+
	
	endm
	
eff_l1	macro

	and.l d1,(a6)
	and.l d1,4(a6)
	and.l d6,(a5)
	and.l d6,4(a5)
	
	rol.l #1,d6
	bcs.s \@3
	
	subq.l #8,a5
	
\@3	ror.l #1,d1
	bcs.s \@1
	
	addq.l #8,a6
\@1	
	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm

eff_l2	macro

	and.l d1,(a6)
	and.l d1,4(a6)
	and.l d6,(a5)
	and.l d6,4(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	bcs.s \@2
	
	subq.l #8,a5
	
\@2	ror.l #1,d1
	bcs.s \@1
	
	addq.l #8,a6
\@1	
	endm
	
ligne_1_0	macro

	or.w d0,(a6)
	and.l d1,2(a6)
	and.w d1,6(a6)
	or.w d5,(a5)
	and.l d6,2(a5)
	and.w d6,6(a5)
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_1_1	macro

	or.w d0,(a6)
	and.l d1,2(a6)
	and.w d1,6(a6)
	or.w d5,(a5)
	and.l d6,2(a5)
	and.w d6,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_2_0	macro

	and.w d1,(a6)
	or.w d0,2(a6)
	and.l d1,4(a6)
	and.w d6,(a5)
	or.w d5,2(a5)
	and.l d6,4(a5)
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_2_1	macro

	and.w d1,(a6)
	or.w d0,2(a6)
	and.l d1,4(a6)
	and.w d6,(a5)
	or.w d5,2(a5)
	and.l d6,4(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_3_0	macro

	or.l d0,(a6)
	and.l d1,4(a6)
	or.l d5,(a5)
	and.l d6,4(a5)
	
	rol.l #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.l #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_3_1	macro

	or.l d0,(a6)
	and.l d1,4(a6)
	or.l d5,(a5)
	and.l d6,4(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.l #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_4_0	macro

	and.l d1,(a6)
	or.w d0,4(a6)
	and.w d1,6(a6)
	and.l d6,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_4_1	macro

	and.l d1,(a6)
	or.w d0,4(a6)
	and.w d1,6(a6)
	and.l d6,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_5_0	macro

	or.w d0,(a6)
	and.w d1,2(a6)
	or.w d0,4(a6)
	and.w d1,6(a6)
	or.w d5,(a5)
	and.w d6,2(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	
	rol.w #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.w #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_5_1	macro

	or.w d0,(a6)
	and.w d1,2(a6)
	or.w d0,4(a6)
	and.w d1,6(a6)
	or.w d5,(a5)
	and.w d6,2(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.w #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_6_0	macro

	and.w d1,(a6)
	or.l d0,2(a6)
	and.w d1,6(a6)
	and.w d6,(a5)
	or.l d5,2(a5)
	and.w d6,6(a5)
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_6_1	macro

	and.w d1,(a6)
	or.l d0,2(a6)
	and.w d1,6(a6)
	and.w d6,(a5)
	or.l d5,2(a5)
	and.w d6,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_7_0	macro

	or.l d0,(a6)
	or.w d0,4(a6)
	and.w d1,6(a6)
	or.l d5,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_7_1	macro

	or.l d0,(a6)
	or.w d0,4(a6)
	and.w d1,6(a6)
	or.l d5,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_8_0	macro

	and.l d1,(a6)
	and.w d1,4(a6)
	or.w d0,6(a6)
	and.l d6,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_8_1	macro

	and.l d1,(a6)
	and.w d1,4(a6)
	or.w d0,6(a6)
	and.l d6,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_9_0	macro

	or.w d0,(a6)
	and.l d1,2(a6)
	or.w d0,6(a6)
	or.w d5,(a5)
	and.l d6,2(a5)
	or.w d5,6(a5)
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_9_1	macro

	or.w d0,(a6)
	and.l d1,2(a6)
	or.w d0,6(a6)
	or.w d5,(a5)
	and.l d6,2(a5)
	or.w d5,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.l #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_a_0	macro

	and.w d1,(a6)
	or.w d0,2(a6)
	and.w d1,4(a6)
	or.w d0,6(a6)
	and.w d6,(a5)
	or.w d5,2(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	
	rol.w #1,d6
	add.w d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	moveq #1,d5
	
\@3	ror.w #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_a_1	macro

	and.w d1,(a6)
	or.w d0,2(a6)
	and.w d1,4(a6)
	or.w d0,6(a6)
	and.w d6,(a5)
	or.w d5,2(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.w d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	moveq #1,d5
	
\@2	ror.w #1,d1
	ror.w #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_b_0	macro

	or.l d0,(a6)
	and.w d1,4(a6)
	or.w d0,6(a6)
	or.l d5,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_b_1	macro

	or.l d0,(a6)
	and.w d1,4(a6)
	or.w d0,6(a6)
	or.l d5,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_c_0	macro

	and.l d1,(a6)
	or.l d0,4(a6)
	and.l d6,(a5)
	or.l d5,4(a5)
	
	rol.l #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.l #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_c_1	macro

	and.l d1,(a6)
	or.l d0,4(a6)
	and.l d6,(a5)
	or.l d5,4(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.l #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.l #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_d_0	macro

	or.w d0,(a6)
	and.w d1,2(a6)
	or.l d0,4(a6)
	or.w d5,(a5)
	and.w d6,2(a5)
	or.l d5,4(a5)
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_d_1	macro

	or.w d0,(a6)
	and.w d1,2(a6)
	or.l d0,4(a6)
	or.w d5,(a5)
	and.w d6,2(a5)
	or.l d5,4(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_e_0	macro

	and.w d1,(a6)
	or.l d0,2(a6)
	or.w d0,6(a6)
	and.w d6,(a5)
	or.l d5,2(a5)
	or.w d5,6(a5)
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_e_1	macro

	and.w d1,(a6)
	or.l d0,2(a6)
	or.w d0,6(a6)
	and.w d6,(a5)
	or.l d5,2(a5)
	or.w d5,6(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	rol.w #1,d6
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.w #1,d1
	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

ligne_f_0	macro

	or.l d0,(a6)
	or.l d0,4(a6)
	or.l d5,(a5)
	or.l d5,4(a5)
	
	add.l d5,d5
	bcc.s \@3
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@3	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
	
\@1	add.w d3,d4
	
	bmi.s \@2
	
	sub.w d2,d4
	add.w a3,a6
	sub.w a3,a5
\@2	
	endm
	
ligne_f_1	macro

	or.l d0,(a6)
	or.l d0,4(a6)
	or.l d5,(a5)
	or.l d5,4(a5)
	
	add.w a3,a6
	sub.w a3,a5
	add.w d2,d4
	
	bmi.s \@1
	
	sub.w d3,d4
	
	add.l d5,d5
	bcc.s \@2
	
	subq.l #8,a5
	move.l #$00010001,d5
	
\@2	ror.l #1,d0
	bcc.s \@1
	
	addq.l #8,a6
\@1	
	endm

		