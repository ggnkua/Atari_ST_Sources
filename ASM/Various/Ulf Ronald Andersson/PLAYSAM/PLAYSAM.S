; File name:     PLAYSAM.SRC          Revised:  1992.07.26
;
; Sample playback subroutine in Devpac format
; Assemble as DRI object for linkability
;
;
	include	uran_sys.s
	include	uran_dos.s
;
;
	text
;
rz:	;relative zero for internal refs
;
	XDEF	playsam
;
;
playsam:	;void	playsam(void *sample,long length,short rate)
	movem.l	d0-d2/a0-a2,-(sp)
	lea	vbls(pc),a0
	movem.l	7*4(sp),d0-d2
	movem.l	d0-d2,(a0)
	gemdos	Super,!
	move.l	d0,-(sp)
	move.b	#0,(hw_tbcr).w
	xbios	Giaccess,!,#7	;read sound chip port 7
	move.b	d0,port7
	and.w	#$C0,d0
	or.w	#$3F,d0
	xbios	Giaccess,d0,#$87	;load new value to port 7
	lea	(hw_psgsel).w,a0
	lea	(hw_psgwr).w,a1
	lea	setup(pc),a2		;->data for setting up sound chip
	moveq	#9,d0
slp:
  MOVE.B  (A2)+,(A0)
  MOVE.B  (A2)+,(A1)
  DBRA    D0,slp        ;set up sound chip
  LEA     spa(pc),A0        ;address of interrupt routine variables
  LEA     vbls(pc),A1       ;address of basic variables
  MOVE.L  (A1)+,(A0)+   ;transfer address of sample data
  MOVE.L  (A1)+,(A0)+   ;transfer length of sample
  MOVE.W  (A1),D0       ;load coded sample rate
  MULU    #4,D0         ;multiply for position in data table
  LEA     sdt,A2        ;load address of data table
	move	0(a2,d0),d1
	move	2(a2,d0),d2
	xbios	Xbtimer,#1,d2,d1,ntbint(pc)
	gemdos	Super,()
	xbios	Jenabint,#8	;enable timer b interrupt
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
;TIMER B INTERRUPT
;
ntbint:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	spa(pc),a2
	subq.l	#1,4(a2)
	beq.s	spexit			;decrement and test counter
	move.l	(a2),a0			;a0 =  current sample address
	addq.l	#1,(a2)			;increment stored sample address
	clr	d1
	move.b	(a0),d1			;d1 =  sample data byte
	bchg	#7,d1			;resign sample byte
	lsl	#1,D1			;byte to word index
	lea	stable(pc,d1),a2
	lea	(hw_psgsel).w,a0	;a0 -> PSG select reg
	lea	(hw_psgwr).w,a1		;a1 -> PSG write reg
	move.b	#$8,(a0)		;select voice a
	move.b	(a2)+,(a1)		;write volume a
	move.b	#$9,(a0)		;select voice b
	move.b	(a2)+,(a1)		;write volume b
	move.b	#$A,(a0)		;select voice c
	move.b	(a2),(a1)		;write volume c
	movem.l	(sp)+,d0-d2/a0-a2
	bclr	#0,(hw_isra).w		;acknowledge interrupt
	rte
;
;
spexit:
	lea	(hw_psgsel).w,a0	;a0 -> PSG select reg
	lea	(hw_psgwr).w,a1		;a1 -> PSG write reg
	lea	shutup(pc),a2	;data for sound chip shut down
	moveq	#5,d0
.selp:
	move.b	(a2)+,(a0)
	move.b	(a2)+,(a1)
	dbra	d0,.selp
	move.b	#7,(a0)
	move.b	port7(pc),(a1)
	movem.l	(sp)+,d0-d2/a0-a2
	move.b	#0,(hw_tbcr).w	;timer b off
	bclr	#0,(hw_isra).w	;acknowledge interrupt
	rte
;
;
  dc.b	00,00,00, 00,00,00, 00,00,00, 00,00,00
stable:   ;64*12 ==  768 bytes in 256 triplets
	dc.b	$0,$0,$0, $0,$0,$0, $0,$0,$1, $0,$0,$2	;$00..03
	dc.b	$0,$0,$3, $0,$0,$4, $0,$0,$4, $0,$0,$5
	dc.b	$0,$0,$5, $0,$0,$5, $0,$0,$6, $0,$0,$6
	dc.b	$0,$0,$6, $0,$0,$6, $0,$0,$7, $0,$0,$7
	dc.b	$0,$0,$7, $0,$0,$7, $0,$0,$7, $0,$0,$8	;$10..13
	dc.b	$0,$0,$8, $0,$0,$8, $0,$0,$8, $0,$0,$8
	dc.b	$0,$2,$8, $0,$3,$8, $0,$3,$8, $0,$4,$8
	dc.b	$0,$4,$8, $0,$0,$9, $0,$0,$9, $0,$0,$9
	dc.b	$0,$0,$9, $0,$2,$9, $0,$3,$9, $0,$3,$9	;$20..23
	dc.b	$0,$4,$9, $0,$4,$9, $0,$5,$9, $0,$5,$9
	dc.b	$0,$5,$9, $0,$5,$9, $0,$6,$9, $0,$6,$9
	dc.b	$0,$6,$9, $0,$6,$9, $0,$0,$A, $0,$2,$A
	dc.b	$0,$3,$A, $0,$4,$A, $0,$4,$A, $0,$5,$A	;$30..33
	dc.b	$0,$5,$A, $0,$5,$A, $0,$6,$A, $0,$6,$A
	dc.b	$0,$6,$A, $1,$6,$A, $1,$6,$A, $0,$0,$B
	dc.b	$0,$0,$B, $0,$0,$B, $0,$1,$B, $0,$1,$B
;
	dc.b	$0,$2,$B, $0,$3,$B, $0,$3,$B, $0,$4,$B	;$40..43
	dc.b	$0,$4,$8, $0,$5,$B, $0,$5,$B, $0,$6,$B
	dc.b	$0,$6,$B, $0,$6,$B, $1,$6,$B, $0,$7,$B
	dc.b	$0,$7,$B, $0,$7,$B, $1,$7,$B, $1,$7,$B
	dc.b	$2,$7,$B, $0,$8,$B, $1,$8,$B, $2,$8,$B	;$50..53
	dc.b	$3,$8,$B, $3,$8,$B, $4,$8,$B, $4,$8,$B
	dc.b	$4,$8,$B, $0,$0,$C, $0,$1,$C, $0,$2,$C
	dc.b	$0,$3,$C, $0,$3,$C, $0,$4,$C, $0,$4,$C
	dc.b	$0,$5,$C, $2,$5,$C, $0,$6,$C, $0,$6,$C	;$60..63
	dc.b	$3,$6,$C, $0,$7,$C, $2,$7,$C, $3,$7,$C
	dc.b	$4,$7,$C, $4,$7,$C, $0,$8,$C, $2,$8,$C
	dc.b	$2,$8,$C, $3,$8,$C, $3,$8,$C, $4,$8,$C
	dc.b	$4,$8,$C, $5,$8,$C, $5,$8,$C, $0,$9,$C	;$70..73
	dc.b	$2,$9,$C, $3,$9,$C, $4,$9,$C, $4,$9,$C
	dc.b	$5,$9,$C, $5,$9,$C, $0,$0,$D, $0,$1,$D
	dc.b	$0,$2,$D, $0,$3,$D, $0,$4,$D, $0,$4,$D
;
	dc.b	$0,$5,$D, $0,$5,$D, $0,$6,$D, $0,$6,$D	;$80..83
	dc.b	$0,$7,$D, $0,$7,$D, $2,$7,$D, $2,$7,$D
	dc.b	$3,$7,$D, $3,$7,$D, $0,$8,$D, $0,$8,$D
	dc.b	$1,$8,$D, $2,$8,$D, $2,$8,$D, $3,$8,$D
	dc.b	$4,$8,$D, $0,$9,$D, $2,$9,$D, $3,$9,$D	;$90..93
	dc.b	$4,$9,$D, $5,$9,$D, $6,$9,$D, $0,$A,$D
	dc.b	$2,$A,$D, $3,$A,$D, $4,$A,$D, $5,$A,$D
	dc.b	$5,$A,$D, $6,$A,$D, $6,$A,$D, $7,$A,$D
	dc.b	$7,$A,$D, $0,$B,$D, $0,$B,$D, $3,$B,$D	;$A0..A3
	dc.b	$4,$B,$D, $4,$B,$D, $5,$B,$D, $5,$B,$D
	dc.b	$6,$B,$D, $6,$B,$D, $6,$B,$D, $7,$B,$D
	dc.b	$7,$B,$D, $7,$B,$D, $8,$B,$D, $8,$B,$D
	dc.b	$8,$B,$D, $8,$B,$D, $8,$B,$D, $0,$0,$E	;$B0..B3
	dc.b	$0,$0,$E, $0,$1,$E, $0,$2,$E, $0,$3,$E
	dc.b	$0,$4,$E, $0,$4,$E, $0,$5,$E, $0,$5,$E
	dc.b	$0,$6,$E, $0,$6,$E, $2,$6,$E, $0,$7,$E
;
	dc.b	$0,$7,$E, $2,$7,$E, $0,$8,$E, $0,$8,$E	;$C0..C3
	dc.b	$0,$9,$E, $4,$9,$E, $5,$9,$E, $6,$9,$E
	dc.b	$0,$A,$E, $0,$A,$E, $3,$A,$E, $3,$A,$E
	dc.b	$5,$A,$E, $5,$A,$E, $6,$A,$E, $6,$A,$E
	dc.b	$7,$A,$E, $7,$A,$E, $0,$B,$E, $4,$B,$E	;$D0..D3
	dc.b	$4,$B,$E, $5,$B,$E, $5,$B,$E, $6,$B,$E
	dc.b	$6,$B,$E, $7,$B,$E, $7,$B,$E, $8,$B,$E
	dc.b	$8,$B,$E, $9,$B,$E, $9,$B,$E, $9,$B,$E
	dc.b	$9,$B,$E, $0,$C,$E, $0,$C,$E, $3,$C,$E	;$E0..E3
	dc.b	$7,$C,$E, $8,$C,$E, $8,$C,$E, $8,$C,$E
	dc.b	$8,$C,$E, $8,$C,$E, $9,$C,$E, $9,$C,$E
	dc.b	$9,$C,$E, $9,$C,$E, $9,$C,$E, $9,$C,$E
	dc.b	$9,$C,$E, $A,$C,$E, $A,$C,$E, $A,$C,$E	;$F0..F3
	dc.b	$A,$C,$E, $A,$C,$E, $A,$C,$E, $0,$0,$F
	dc.b	$0,$6,$F, $0,$6,$F, $0,$7,$F, $0,$7,$F
	dc.b	$0,$7,$F, $0,$8,$F, $0,$8,$F, $0,$8,$F
;end of sample nybbles
;
;
vbls:
	ds.l	3	;variables: sample_address,length,rate
spa:      DS.L 2        ;IRQ routine variables PTR++, --COUNT
setup:    DC.B 10,0,9,0,8,0,11,0,12,0  ;data for sound chip set up
shutup:   DC.B 10,0,9,0,8,0       ;data for sound chip shut down
port7:    DC.L 0        ;port7
;
;
sdt:
  DC.W    $E2,2,$E2,2,$76,2,$CA,1,$98,1
  DC.W    $79,1,$65,1,$56,1,$50,1,$45,1
  DC.W    $39,1,$36,1,$33,1,$30,1,$27,1
  DC.W    $21,1,$10,1
; data table for sample rates(data,control(timer b registers)
;
  END     ;Ends file: PLAYSAM.SRC
