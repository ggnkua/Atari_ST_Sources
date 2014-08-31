;----------------------------------------------------------------------------
;File name:	MagRomFx.S			Revision date: 	1996.12.05
;Revised by:	Ulf Ronald Andersson		Disassembled:	1996.12.05
;----------------------------------------------------------------------------
;Origin:
;
;The original code disassembled was the MAGTOROM.PRG program of the MagiC
;distribution package.  (NB: Only this part of that package is Freeware)
;
;----------------------------------------------------------------------------
;Revision purpose:
;
;To make the program return some of the system RAM before using Malloc,
;since that operation is otherwise _very_ likely to fail inadvertently.
;This made the program impossible for me to use, except by starting it
;later, when fragmented blocks exist in memory.
;
;Doing that would defeat the protective purpose of MagToRom, so this
;patch is definitely needed.
;
;----------------------------------------------------------------------------
; QED-ASMPAR 4 0006  $DSDR:Z:181,M:4
;Desert	Drain V1.52   680x0er Disassembler  05.12.1996 16:15:04
;DATEI:	MAGTOROM.TOS   768 Bytes
;TEXT:	  518	$00206
;DATA:	  214	$000D6
;BSS:	    4  $000004
;----------------------------------------------------------------------------
;Program header data:
;	Fast-Load-Bit	gesetzt
;	Programm ins Fast-Ram	laden (128kB)
;	malloc() aus dem Fast-Ram
;----------------------------------------------------------------------------
;
	SECTION	TEXT
;
;----------------------------------------------------------------------------
start:
	movem.l	(sp),a4-a5		;\
	lea	loc_st_end(pc),sp	; X Set up local stack
	movem.l	a4-a5,-(sp)		;/
;
	lea	bss_end(pc),a0
	sub.l	a5,a0
	pea	(a0)			;Push program size needed
	pea	(a5)			;Push basepage ptr
	clr	-(sp)			;Push dummy argument (never implemented)
	move	#$4A,-(sp)		;Push Mshrink function code
	trap	#1			;Shrink program memory
	lea	12(sp),sp		;clean up stack
;
;URAn NB: My code patch ends here, the rest is original code,
;	  but I have also added some stuff to the BSS section,
;	  and corrected an erroneous register reference.
;	  (seek for "patch" below)
;
	clr.l	-(SP)
	move.w	#$20,-(SP)
	trap	#1			 ;Super
	addq.l	#6,SP
	move.l	D0,D7
	move.l	#'_CPU',D0
	bsr	T_198
	lea	D_25E(PC),A6
	beq	T_174
	cmp.w	#$1E,D2
	bne	T_174
	move.l	#'MagX',D0
	bsr	T_198
	lea	D_278(PC),A6
	beq	T_174
	move.l	#'PMMU',D0
	bsr	T_198
	lea	D_297(PC),A6
	bne	T_174
	pea	$84F.w
	move.w	#$48,-(SP)
	trap	#1			 ;Malloc
	addq.l	#6,SP
	lea	D_2C1(PC),A6
	move.l	D0,D6			;Patch !!!  Original used "move.l  a0,d6"
	beq	T_174
	add.l	#15,D6
	and.w	#-$10,D6
	movea.l	D6,A5
	lea	$40(A5),A4
	movea.l	$4F2.w,A0		 ;_sysbase
	move.l	8(A0),D1
	add.l	#$7FFF,D1
	and.w	#-$8000,D1
	movea.l	D1,A1
	movea.l	D1,A3
	cmpa.l	#$1000000,A1
	bcc.s	T_A2
	movea.l	$14(A0),A2
	cmpi.l	#$87654321,(A2)+
	beq.s	T_9E
	lea	12(A0),A2
T_9E:	movea.l	(A2),A2
	bra.s	T_A6
T_A2:	movea.l	$49E.w,A2		 ;themdmd
T_A6:	move.l	A2,D2
	sub.l	A1,D2
	ptestr	#7,(a3),#3,a0
	move.l	(A0),D1
	and.w	#$8000,D1
	or.w	#1,D1
	moveq	#15,D0
T_BA:	move.l	D1,(A5)+
	add.l	#$100000,D1
	dbra	D0,T_BA
	cmp.l	#$1000001,D1
	bne.s	T_D6
	ori.l	#$40,-$4(A5)
T_D6:	move.l	D2,D0
	divu.l	#$1000000,D0
	movea.l	D6,A1
	move.l	A4,D1
	or.w	#2,D1
T_E8:	move.l	D1,(A1)+
	add.l	#$80,D1
	dbra	D0,T_E8
	move.l	(A0),D1
	and.w	#-$8000,D1
	or.w	#1,D1
	move.w	#$1FF,D0
T_102:	move.l	D1,(A5)+
	add.l	#$8000,D1
	dbra	D0,T_102
	ptestr	#7,(a3),#2,a0
	or.w	#2,D6
	move.l	D6,(A0)
	pflusha
	pmove.l	tt0_dummy,tt0
	movea.l	$4F2.w,A0		 ;_sysbase
	move.l	8(A0),D1
	add.l	#$7FFF,D1
	and.w	#-$8000,D1
	ptestr	#7,(d1.l),#7,a4
	divu.w	#$8000,d2
	bra.s	T_148
T_142:	ori.l	#4,(A4)+
T_148:	dbra	D2,T_142
	pflusha
	bsr.s	T_1B0
	move.l	D7,-(SP)
	move.w	#$20,-(SP)
	trap	#1			 ;Super
	addq.l	#6,SP
	pea	D_206(PC)
	move.w	#9,-(SP)
	trap	#1			 ;Cconws
	addq.l	#6,SP
	clr.w	-(SP)
	pea	$80.w
	move.w	#$31,-(SP)
	trap	#1			 ;Ptermres
;
;----------------------------------------------------------------------------
;
T_174:	move.l	D7,-(SP)
	move.w	#$20,-(SP)
	trap	#1			 ;Super
	addq.l	#6,SP
	pea	(A6)
	move.w	#9,-(SP)
	trap	#1			 ;Cconws
	addq.l	#6,SP
	pea	D_23E(PC)
	move.w	#9,-(SP)
	trap	#1			 ;Cconws
	addq.l	#6,SP
	clr.w	-(SP)
	trap	#1			 ;Pterm0
;
;----------------------------------------------------------------------------
;
T_198:	move.l	$5A0.w,D1		 ;_p_cookies
	beq.s	T_1AE
	movea.l	D1,A0
T_1A0:	movem.l	(A0)+,D1/D2
	tst.l	D1
	beq.s	T_1AE
	cmp.l	D0,D1
	bne.s	T_1A0
	moveq	#1,D0
T_1AE:	rts
;
;----------------------------------------------------------------------------
;
T_1B0:	movea.l	$5A0.w,A0		 ;_p_cookies
T_1B4:	movem.l	(A0)+,D0/D1
	tst.l	D0
	bne.s	T_1B4
	move.l	A0,D2
	sub.l	$5A0.w,D2		 ;_p_cookies
	lsr.l	#3,D2
	addq.l	#1,D2
	cmp.l	D1,D2
	bcs.s	T_1F6
	addq.l	#8,D2
	asl.l	#3,D2
	move.l	D2,-(SP)
	move.w	#$48,-(SP)
	trap	#1			 ;Malloc
	addq.l	#6,SP
	tst.l	D0
	beq.s	T_204
	movea.l	$5A0.w,A1		 ;_p_cookies
	movea.l	D0,A0
	movea.l	D0,A2
T_1E4:	movem.l	(A1)+,D0/D1
	movem.l	D0/D1,(A0)
	addq.l	#8,A0
	tst.l	D0
	bne.s	T_1E4
	move.l	A2,$5A0.w		 ;_p_cookies
T_1F6:	subq.l	#8,A0
	move.l	#$504D4D55,(A0)+
	clr.l	(A0)+
	movem.l	D0/D1,(A0)
T_204:	rts
;
;----------------------------------------------------------------------------
;
	SECTION	DATA
;
;----------------------------------------------------------------------------
;
D_206:	dc.b	$D,$A,$1B,'pMAGTOROM V1.0 installiert',$1B,'q'
	dc.b	$D,$A,'Ω 1994 by Uwe Seimet',$D,$A,$0
D_23E:	dc.b	$D,$A,'MAGTOROM nicht installiert!',$D,$A,$0
D_25E:	dc.b	$D,$A,'Kein MC68030 vorhanden!',$0
D_278:	dc.b	$D,$A,'MagiC ist nicht installiert!',$0
D_297:	dc.b	$D,$A,'Es ist bereits ein PMMU-Programm akt'
	dc.b	'iv!',$0
D_2C1:	dc.b	$A,$A,'Zu wenig Hauptspeicher!',$0,'è'
;
;----------------------------------------------------------------------------
;
	SECTION	BSS
;
;----------------------------------------------------------------------------
;
loc_stack:
	ds.l	256
loc_st_end:
tt0_dummy:
	ds.l	1			 ;=4
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
