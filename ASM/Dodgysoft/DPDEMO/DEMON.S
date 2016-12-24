	opt	d+
***********************in/out supervisor macros***************
super	MACRO
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	ENDM

unsuper	MACRO
	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
****************************shrink memory*********************
	move.l	4(a7),a3		; base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		; text len
	add.l	$14(a3),d0		; data len
	add.l	$1c(a3),d0		; BSS len
	add.l	#$100,d0		; basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			; release memory
	add.l	#12,sp
***************************goto supervisor***********************
	super			;goto supervisor mode
************************revector vbl rout for music**************
	move.l $70.w,oldint			save old vbl
	bclr #0,$484.w				no keyclick
	moveq #1,d0				music #1
	jsr music				call init
	move.l #zippy,$70.w			install new vbl
************get screen addr and move it to a5********************
	move.w	#3,-(sp)	;move function no onto stack
	trap	#14		;call trap
	addq.w	#2,sp		;tidy up stack
	move.l	d0,a5		;copy screen addr to a5
*****************copy main screen to a5**************************
	move.l	#7999,d0	;no of copys to do
	move.l	a5,a0		;screen address to a0
	move.l	#pic1,a1	;orig screen addr to a1
	add.l	#34,a1		;ignore palette information
piccpy	move.l	(a1)+,(a0)+	;copy a1 l-word to a0 l-word+inc
	dbf	d0,piccpy	;copy next if not finished
*******************set up palette********************************
	move.l	#15,d0		;no of copys to do
	move.l	#$ff8240,a0	;new palette addr to a0
	move.l	#pic1,a1	;old palette addr to a1
	addq.l	#2,a1		;ignore useless data
palcpy	move.w	(a1)+,(a0)+	;copy from old to new
	dbf	d0,palcpy	;copy next if not finished
*************************set regs********************************
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.l	#0,a0
	move.l	#0,a1
	move.l	#0,a2
	move.l	#0,a3
	move.l	#0,a4
	move.l	#0,a6
	move.l	a5,vbl_p
	add.l	#31184,vbl_p
	jsr	dodfg
	jsr	dodf2
********************character pos work out**********************
	move.w	#$8000,d4	;'and' word for data transfers
	move.w	#3,buff
resmes	move.l	#message,mes_p	;move message addr to mes pointer
nxtlet	movea.l	mes_p,a2	;move pointer to a2
	moveq.l	#0,d0		;clear d reg
	move.b	(a2)+,d0	;get char and increment pointer
	cmpi.w	#$ff,d0		;end of message?
	beq	resmes		;yes? restart
	subi.w	#32,d0		;so space=0, not 32 etc.
	move.l	a2,mes_p	;copy pointer back to buffer
	asl.w	#2,d0		;multi by 4, use l-words not bytes
	movea.l	#fnt_tbl,a2	;font table addr
	adda.l	d0,a2		;plus char no=addr of offset
	move.l	#font,a6	;font data
	adda.l	(a2),a6		;plus offset
	adda.l	#34,a6		;ignore palette data
	add.l	#5120,a6
	move.l	a6,chr_ptr	;move font ops to buffer
***********************scroll routine***************************
	moveq.l	#1,d1		;two halves of char
	moveq.w	#15,d7		;do half a 32 pixel char at a time
scr	movea.l	a5,a4		;move scr addr for working with
	adda.w	#31998,a4	;offset to start of work area
	moveq.w	#31,d6		;no of lines+1 to scroll
lines	andi.w  #$ffef,sr	;clear extend bit in status register
	roxl.w	(a4)		;logical shift word left one bit
	roxl.w	-8(a4)		;logical shift word left one bit
	roxl.w	-16(a4)		;logical shift word left one bit
	roxl.w	-24(a4)		;logical shift word left one bit
	roxl.w	-32(a4)		;logical shift word left one bit
	roxl.w	-40(a4)		;logical shift word left one bit
	roxl.w	-48(a4)		;logical shift word left one bit
	roxl.w	-56(a4)		;logical shift word left one bit
	roxl.w	-64(a4)		;logical shift word left one bit
	roxl.w	-72(a4)		;logical shift word left one bit
	roxl.w	-80(a4)		;logical shift word left one bit
	roxl.w	-88(a4)		;logical shift word left one bit
	roxl.w	-96(a4)		;logical shift word left one bit
	roxl.w	-104(a4)	;logical shift word left one bit
	roxl.w	-112(a4)	;logical shift word left one bit
	roxl.w	-120(a4)	;logical shift word left one bit
	roxl.w	-128(a4)	;logical shift word left one bit
	roxl.w	-136(a4)	;logical shift word left one bit
	roxl.w	-144(a4)	
	roxl.w	-152(a4)

	move.w	(a6),d0		;start copying new char
	and.w	d4,d0		;has bit got to be copied
	beq	no_coa		;no? miss some code
	or.w	#1,(a4)		;add bit required
no_coa	sub.l	#160,a6
	sub.l	#160,a4
	dbf	d6,lines	;do all rows
	sub.w	#1,buff
	beq	duck
cont	ror.w	d4		;next mask
	move.l	chr_ptr,a6
	dbf	d7,scr		;do half char
	addq.l	#8,chr_ptr
	move.l	chr_ptr,a6
	subq.l	#1,d1
	bmi	nxtlet
	moveq.l	#15,d7
	bra	scr

edd	move.l	d2,buff2
	move.l	a1,buff1
	move.l	#vbl_p,a1
vbl2	move.b	$ff8209,d2
	sub.b	3(a1),d2
	bmi	vbl2
	move.b	$ff8207,d2
	sub.b	2(a1),d2
	bmi	vbl2
	move.w	#3,buff
	move.l	buff1,a1
	move.l	buff2,d2
	bra	cont

*****************the wiggle********************

dodfg	move.l	#mov_tbl,ba6
	move.l	#mov_lst,ba4
	rts

duck	movem.l	d0-a6,-(sp)
	move.l	ba4,a4
	move.l	ba6,a6
	move.l	a5,a3
	add.l	#10240,a3

	move.l	70(a4),72(a4)
	move.l	66(a4),68(a4)
	move.l	62(a4),64(a4)
	move.l	58(a4),60(a4)
	move.l	54(a4),56(a4)
	move.l	50(a4),52(a4)
	move.l	46(a4),48(a4)
	move.l	42(a4),44(a4)
	move.l	38(a4),40(a4)
	move.l	34(a4),36(a4)
	move.l	30(a4),32(a4)
	move.l	26(a4),28(a4)
	move.l	22(a4),24(a4)
	move.l	18(a4),20(a4)
	move.l	14(a4),16(a4)
	move.l	10(a4),12(a4)
	move.l	6(a4),8(a4)
	move.l	2(a4),4(a4)
	move.w	(a4),2(a4)

	move.w	(a6)+,(a4)
	moveq.l	#37,d7
l_38	cmp.w	#$ff,(a4)
	bne	n_rs_mt
	move.w	#0,(a4)
	move.l	#mov_tbl,a6
n_rs_mt	moveq.l	#0,d0
	move.w	(a4)+,d0
	tst.w	d0
	beq	matt
	bmi	scrol
	bpl	scror
matt	add.l	#160,a3
	dbf	d7,l_38
	move.l	#mov_lst,ba4
	move.l	a6,ba6
	movem.l	(sp)+,d0-a6
	jmp	duc2

scrol	bra	scr_l
lt_a	addq.w	#1,d0
	bmi	scrol
	bra	matt

scror	bra	scr_r
rt_a	subq.l	#1,d0
	beq	matt
	bpl	scror
	bra	matt

scr_r	and.w	#$ffef,sr
	roxr.w	(a3)		;scroll right
	roxr.w	8(a3)
	roxr.w	16(a3)
	roxr.w	24(a3)
	roxr.w	32(a3)
	roxr.w	40(a3)
	roxr.w	48(a3)
	roxr.w	56(a3)
	roxr.w	64(a3)
	roxr.w	72(a3)
	roxr.w	80(a3)
	roxr.w	88(a3)
	roxr.w	96(a3)
	roxr.w	104(a3)
	roxr.w	112(a3)
	roxr.w	120(a3)
	roxr.w	128(a3)
	roxr.w	136(a3)
	roxr.w	144(a3)
	roxr.w	152(a3)
	and.w	#$ffef,sr
	roxr.w	2(a3)
	roxr.w	10(a3)
	roxr.w	18(a3)
	roxr.w	26(a3)
	roxr.w	34(a3)
	roxr.w	42(a3)
	roxr.w	50(a3)
	roxr.w	58(a3)
	roxr.w	66(a3)
	roxr.w	74(a3)
	roxr.w	82(a3)
	roxr.w	90(a3)
	roxr.w	98(a3)
	roxr.w	106(a3)
	roxr.w	114(a3)
	roxr.w	122(a3)
	roxr.w	130(a3)
	roxr.w	138(a3)
	roxr.w	146(a3)
	roxr.w	154(a3)
	and.w	#$ffef,sr
	roxr.w	4(a3)
	roxr.w	12(a3)
	roxr.w	20(a3)
	roxr.w	28(a3)
	roxr.w	36(a3)
	roxr.w	44(a3)
	roxr.w	52(a3)
	roxr.w	60(a3)
	roxr.w	68(a3)
	roxr.w	76(a3)
	roxr.w	84(a3)
	roxr.w	92(a3)
	roxr.w	100(a3)
	roxr.w	108(a3)
	roxr.w	116(a3)
	roxr.w	124(a3)
	roxr.w	132(a3)
	roxr.w	140(a3)
	roxr.w	148(a3)
	roxr.w	156(a3)
	and.w	#$ffef,sr
	roxr.w	6(a3)
	roxr.w	14(a3)
	roxr.w	22(a3)
	roxr.w	30(a3)
	roxr.w	38(a3)
	roxr.w	46(a3)
	roxr.w	54(a3)
	roxr.w	62(a3)
	roxr.w	70(a3)
	roxr.w	78(a3)
	roxr.w	86(a3)
	roxr.w	94(a3)
	roxr.w	102(a3)
	roxr.w	110(a3)
	roxr.w	118(a3)
	roxr.w	126(a3)
	roxr.w	134(a3)
	roxr.w	142(a3)
	roxr.w	150(a3)
	roxr.w	158(a3)
	bra	rt_a

scr_l	and.w	#$ffef,sr	;scroll right
	roxl.w	152(a3)
	roxl.w	144(a3)
	roxl.w	136(a3)
	roxl.w	128(a3)
	roxl.w	120(a3)
	roxl.w	112(a3)
	roxl.w	104(a3)
	roxl.w	96(a3)
	roxl.w	88(a3)
	roxl.w	80(a3)
	roxl.w	72(a3)
	roxl.w	64(a3)
	roxl.w	56(a3)		
	roxl.w	48(a3)
	roxl.w	40(a3)
	roxl.w	32(a3)
	roxl.w	24(a3)
	roxl.w	16(a3)
	roxl.w	8(a3)
	roxl.w	(a3)
	and.w	#$ffef,sr
	roxl.w	154(a3)
	roxl.w	146(a3)
	roxl.w	138(a3)
	roxl.w	130(a3)
	roxl.w	122(a3)
	roxl.w	114(a3)
	roxl.w	106(a3)
	roxl.w	98(a3)
	roxl.w	90(a3)
	roxl.w	82(a3)
	roxl.w	74(a3)
	roxl.w	66(a3)
	roxl.w	58(a3)
	roxl.w	50(a3)
	roxl.w	42(a3)
	roxl.w	34(a3)
	roxl.w	26(a3)
	roxl.w	18(a3)
	roxl.w	10(a3)
	roxl.w	2(a3)
	and.w	#$ffef,sr
	roxl.w	156(a3)
	roxl.w	148(a3)
	roxl.w	140(a3)
	roxl.w	132(a3)
	roxl.w	124(a3)
	roxl.w	116(a3)
	roxl.w	108(a3)
	roxl.w	100(a3)
	roxl.w	92(a3)
	roxl.w	84(a3)
	roxl.w	76(a3)
	roxl.w	68(a3)
	roxl.w	60(a3)
	roxl.w	52(a3)
	roxl.w	44(a3)
	roxl.w	36(a3)
	roxl.w	28(a3)
	roxl.w	20(a3)
	roxl.w	12(a3)
	roxl.w	4(a3)
	and.w	#$ffef,sr
	roxl.w	158(a3)
	roxl.w	150(a3)
	roxl.w	142(a3)
	roxl.w	134(a3)
	roxl.w	126(a3)
	roxl.w	118(a3)
	roxl.w	110(a3)
	roxl.w	102(a3)
	roxl.w	94(a3)
	roxl.w	86(a3)
	roxl.w	78(a3)
	roxl.w	70(a3)
	roxl.w	62(a3)
	roxl.w	54(a3)
	roxl.w	46(a3)
	roxl.w	38(a3)
	roxl.w	30(a3)
	roxl.w	22(a3)
	roxl.w	14(a3)
	roxl.w	6(a3)
	bra	lt_a

*****************program space etc************

mov_lst	ds.w	38
mov_tbl	dc.w	-1,0,0,-1,0,0,0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,0,0,-1,0,0,-1,0,0,0
	dc.w	$ff

*************wiggle 2*************************

*****************the wiggle********************

dodf2	move.l	#mov_tb2,ba62
	move.l	#mov_ls2,ba42
	rts

duc2	movem.l	d0-a6,-(sp)
	move.l	ba42,a4
	move.l	ba62,a6
	move.l	a5,a3
	add.l	#26240,a3

	move.w	118(a4),120(a4)
	move.l	114(a4),116(a4)
	move.l	110(a4),112(a4)
	move.l	106(a4),108(a4)
	move.l	102(a4),104(a4)
	move.l	98(a4),100(a4)
	move.l	94(a4),96(a4)
	move.l	90(a4),92(a4)
	move.l	86(a4),88(a4)
	move.l	82(a4),84(a4)
	move.l	78(a4),80(a4)
	move.l	74(a4),76(a4)
	move.l	70(a4),72(a4)
	move.l	66(a4),68(a4)
	move.l	62(a4),64(a4)
	move.l	58(a4),60(a4)
	move.l	54(a4),56(a4)
	move.l	50(a4),52(a4)
	move.l	46(a4),48(a4)
	move.l	42(a4),44(a4)
	move.l	38(a4),40(a4)
	move.l	34(a4),36(a4)
	move.l	30(a4),32(a4)
	move.l	26(a4),28(a4)
	move.l	22(a4),24(a4)
	move.l	18(a4),20(a4)
	move.l	14(a4),16(a4)
	move.l	10(a4),12(a4)
	move.l	6(a4),8(a4)
	move.l	2(a4),4(a4)
	move.w	(a4),2(a4)

	move.w	(a6)+,(a4)
	moveq.l	#60,d7
l_60	cmp.w	#$ff,(a4)
	bne	n_rs_m2
	move.w	#0,(a4)
	move.l	#mov_tb2,a6
n_rs_m2	moveq.l	#0,d0
	move.w	(a4)+,d0
	tst.w	d0
	beq	mat2
	bmi	scrol2
	bpl	scror2
mat2	sub.l	#160,a3
	dbf	d7,l_60
	move.l	#mov_ls2,ba42
	move.l	a6,ba62
	movem.l	(sp)+,d0-a6
	jmp	edd

scrol2	bra	scr_l2
lt_2	addq.w	#1,d0
	bmi	scrol2
	bra	mat2

scror2	bra	scr_r2
rt_2	subq.l	#1,d0
	beq	mat2
	bpl	scror2
	bra	mat2

scr_r2	and.w	#$ffef,sr
	roxr.w	(a3)		;scroll right
	roxr.w	8(a3)
	roxr.w	16(a3)
	roxr.w	24(a3)
	roxr.w	32(a3)
	roxr.w	40(a3)
	roxr.w	48(a3)
	roxr.w	56(a3)
	roxr.w	64(a3)
	roxr.w	72(a3)
	roxr.w	80(a3)
	roxr.w	88(a3)
	roxr.w	96(a3)
	roxr.w	104(a3)
	roxr.w	112(a3)
	roxr.w	120(a3)
	roxr.w	128(a3)
	roxr.w	136(a3)
	roxr.w	144(a3)
	roxr.w	152(a3)
	and.w	#$ffef,sr
	roxr.w	2(a3)
	roxr.w	10(a3)
	roxr.w	18(a3)
	roxr.w	26(a3)
	roxr.w	34(a3)
	roxr.w	42(a3)
	roxr.w	50(a3)
	roxr.w	58(a3)
	roxr.w	66(a3)
	roxr.w	74(a3)
	roxr.w	82(a3)
	roxr.w	90(a3)
	roxr.w	98(a3)
	roxr.w	106(a3)
	roxr.w	114(a3)
	roxr.w	122(a3)
	roxr.w	130(a3)
	roxr.w	138(a3)
	roxr.w	146(a3)
	roxr.w	154(a3)
	and.w	#$ffef,sr
	roxr.w	4(a3)
	roxr.w	12(a3)
	roxr.w	20(a3)
	roxr.w	28(a3)
	roxr.w	36(a3)
	roxr.w	44(a3)
	roxr.w	52(a3)
	roxr.w	60(a3)
	roxr.w	68(a3)
	roxr.w	76(a3)
	roxr.w	84(a3)
	roxr.w	92(a3)
	roxr.w	100(a3)
	roxr.w	108(a3)
	roxr.w	116(a3)
	roxr.w	124(a3)
	roxr.w	132(a3)
	roxr.w	140(a3)
	roxr.w	148(a3)
	roxr.w	156(a3)
	bra	rt_2

scr_l2	and.w	#$ffef,sr	;scroll right
	roxl.w	152(a3)
	roxl.w	144(a3)
	roxl.w	136(a3)
	roxl.w	128(a3)
	roxl.w	120(a3)
	roxl.w	112(a3)
	roxl.w	104(a3)
	roxl.w	96(a3)
	roxl.w	88(a3)
	roxl.w	80(a3)
	roxl.w	72(a3)
	roxl.w	64(a3)
	roxl.w	56(a3)		
	roxl.w	48(a3)
	roxl.w	40(a3)
	roxl.w	32(a3)
	roxl.w	24(a3)
	roxl.w	16(a3)
	roxl.w	8(a3)
	roxl.w	(a3)
	and.w	#$ffef,sr
	roxl.w	154(a3)
	roxl.w	146(a3)
	roxl.w	138(a3)
	roxl.w	130(a3)
	roxl.w	122(a3)
	roxl.w	114(a3)
	roxl.w	106(a3)
	roxl.w	98(a3)
	roxl.w	90(a3)
	roxl.w	82(a3)
	roxl.w	74(a3)
	roxl.w	66(a3)
	roxl.w	58(a3)
	roxl.w	50(a3)
	roxl.w	42(a3)
	roxl.w	34(a3)
	roxl.w	26(a3)
	roxl.w	18(a3)
	roxl.w	10(a3)
	roxl.w	2(a3)
	and.w	#$ffef,sr
	roxl.w	156(a3)
	roxl.w	148(a3)
	roxl.w	140(a3)
	roxl.w	132(a3)
	roxl.w	124(a3)
	roxl.w	116(a3)
	roxl.w	108(a3)
	roxl.w	100(a3)
	roxl.w	92(a3)
	roxl.w	84(a3)
	roxl.w	76(a3)
	roxl.w	68(a3)
	roxl.w	60(a3)
	roxl.w	52(a3)
	roxl.w	44(a3)
	roxl.w	36(a3)
	roxl.w	28(a3)
	roxl.w	20(a3)
	roxl.w	12(a3)
	roxl.w	4(a3)
	bra	lt_2

*****************program space etc************

mov_ls2	ds.w	61
mov_tb2	dc.w	0,0,1,0,1,1,2,1,1,0,1,0,0
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,0,1,0,1,1,2,1,1,0,1,0,0
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,0,-1,0,-1,-1,-2,-1,-1,0,-1,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,-1,0,-1,-1,-2,-1,-1,0,-1,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,-1,0,-1,-1,-2,-1,-1,0,-1,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,-1,0,-1,-1,-2,-1,-1,0,-1,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,1,0,1,1,2,1,1,0,1,0,0
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,0,1,0,1,1,2,1,1,0,1,0,0
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,0,1,0,1,1,2,1,1,0,1,0,0
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,0,1,0,1,1,2,1,1,0,1,0,0
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,0,-1,0,-1,-1,-2,-1,-1,0,-1,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,-1,0,-1,-1,-2,-1,-1,0,-1,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	-1,0,0,-1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,-1,0,0,-1,0,0
	dc.w	-1,0,0,-1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,-1,0,0,-1,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	-1,0,0,-1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,-1,0,0,-1,0,0
	dc.w	-1,0,0,-1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,-1,0,0,-1,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	-1,-1,1,1,1,1,-1,-1
	dc.w	-1,-1,1,1,1,1,-1,-1
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	-1,0,0,-1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,-1,0,0,-1,0,0
	dc.w	-1,0,0,-1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,-1,0,0,-1,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	-1,-1,1,1,1,1,-1,-1
	dc.w	-1,-1,1,1,1,1,-1,-1
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	-1,-1,1,1,1,1,-1,-1
	dc.w	-1,-1,1,1,1,1,-1,-1
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$ff


**********************some buffers***************************
ba4	dc.l	0
ba6	dc.l	0
ba42	dc.l	0
ba62	dc.l	0
buff1	dc.l	0
buff2	dc.l	0
buff	dc.w	0
vbl_p	dc.l	0
*********************terminate routine*************************
term	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	move.l	oldint,$70.w
	move.l	#$8080000,$ff8800
	move.l	#$9090000,$ff8800
	move.l	#$a0a0000,$ff8800
	unsuper
	clr.w	-(sp)
	trap	#1
*********************vbl music routine driver******************
zippy	movem.l d0-a6,-(sp)			save registers
	jsr (music+8)				call playback
	movem.l (sp)+,d0-a6			restore registers
	move.l oldint,-(sp)			old vbl on sp
	rts					call old vbl
********************old vbl interrupt vector*******************
oldint	dc.l 0
*******************present char pointer************************
chr_ptr	dc.l 0
**********************just another flag or two*****************
mes_p	dc.l 0
count	dc.l 0
******************font offset table****************************
fnt_tbl	dc.l	0,16,32,48,64,80,96,112,128,144
	dc.l	5120,5136,5152,5168,5184,5200,5216,5232,5248,5264
	dc.l	10240,10256,10272,10288,10304,10320,10336,10352,10368,10384
	dc.l	15360,15376,15392,15408,15424,15440,15456,15472,15488,15504
	dc.l	20480,20496,20512,20528,20544,20560,20576,20592,20608,20624
	dc.l	25600,25616,25632,25648,25664,25680,25696,25712,25728,25744
*************************message*******************************
message	dc.b	"..THE DEMON PENGUIN DEMO"
	dc.b	" HAS ARRIVED AT LAST......     "
	DC.B	"  HERE ARE SOME TEST CHARACTERS.  "
	DC.B	"!",34,"#$%&'()*+,-./0123456789:;<="
	DC.B	">?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[####"
	dc.b	$ff
*****************************stack*****************************
	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)
*********************old stack pointer,(user sp)***************
oldsp	dc.l	0
*************************binary files for inclusion************
pic1	incbin	"a:\dpdemo\the_D_P_.pi1"
font	incbin	"a:\dpdemo\bold1fnt.pi1"
music	incbin	"a:\dpdemo\atomix.mus"
music2	incbin	"a:\dpdemo\rings1.mus"
music3	incbin	"a:\dpdemo\rings2.mus"
music4	incbin	"a:\dpdemo\shaolin2.mus"
music5	incbin	"a:\dpdemo\shaolin3.mus"
music6	incbin	"a:\dpdemo\shaolin4.mus"
music7	incbin	"a:\dpdemo\cuddly.mus"
music8	incbin	"a:\dpdemo\cuddly1.mus"
music9	incbin	"a:\dpdemo\cuddly2.mus"
music10	incbin	"a:\dpdemo\cuddly3.mus"
music11	incbin	"a:\dpdemo\sowhat.mus"
music12	incbin	"a:\dpdemo\sowhat1.mus"
music13	incbin	"a:\dpdemo\sowhat2.mus"
music14	incbin	"a:\dpdemo\sowhat3.mus"
music15	incbin	"a:\dpdemo\sowhat4.mus"

