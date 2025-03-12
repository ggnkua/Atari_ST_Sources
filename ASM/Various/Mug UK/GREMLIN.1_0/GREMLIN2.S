;
; Gremlin Deprotector v1.0
;
; Definitelty NOT coded by J.I.M.M.Y of Mantronix
; aka (T)ruthless of Awefull
;
; Disassembled and partly commentated by MUG U.K(tm) in 1997 (Bored!)
; All hacking done with TOSBox emulator.
;
	text
begin
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7

start	pea	introtext
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7

	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#6,a7
	swap	d0
	cmp.b	#1,d0		; Pressed escape ?
	beq	quit_prog		; get out if user has

	move.w	#9,l000c
	move.w	#$a,-(a7)
	move.w	#0,-(a7)
	move.w	#$d,-(a7)
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	clr.l	-(a7)
	move.l	#l000d,-(a7)
	move.w	#8,-(a7)		;floprd
	trap	#$e
	adda.l	#$14,a7
	tst.w	d0
	bmi	l0001

	move.w	#$a,l000c

l0001	pea	examining
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7
	move.l	#1,d7

l0002	move.w	l000c,-(a7)
	move.w	#0,-(a7)
	move.w	d7,-(a7)
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	clr.l	-(a7)
	move.l	#l000d,-(a7)
	move.w	#8,-(a7)		;floprd
	trap	#$e
	adda.l	#$14,a7

	movea.l	#l000d,a0
	move.l	#$1770,d6
l0003	cmpi.b	#$1d,$fffc02.l	; Control pressed ?
	beq	start		; if so, restart program
	move.w	(a0),d5

	cmp.w	#$67fe,d5
	beq	l0004

	cmp.w	#$68fe,d5
	beq	l0004

	cmp.w	#$6afe,d5
	beq	l0004

	cmp.w	#$4e71,d5
	bne	l0005

l0004	move.w	#$4e71,(a0)
	adda.l	#2,a0
	move.b	#1,l000e
	bra	l0007

l0005	move.l	(a0),d5
	cmp.l	#$48e77f7e,d5
	bne	l0006
	move.l	#$70004e75,(a0)
	adda.l	#2,a0
	move.b	#2,l000e
	bra	l0007

l0006	move.l	4(a0),d5
	cmp.l	#$70ff33c0,d5
	bne	l0008
	move.l	8(a0),d5
	cmp.l	#$ffff8240,d5
	bne	l0008
	move.l	12(a0),d5
	cmp.l	#$51c8fff8,d5
	bne	l0008
	move.w	16(a0),d5
	cmp.w	#$60f2,d5
	bne	l0008
	move.b	#$60,(a0)
	adda.l	#2,a0
	move.b	#3,l000e

l0007	move.b	l000e,d5
	addi.b	#$30,d5

	move.w	d5,-(a7)
	move.w	#6,-(a7)		;crawio
	trap	#1
	addq.l	#4,a7
	move.l	a0,-(a7)
	move.w	l000c,-(a7)
	move.w	#0,-(a7)
	move.w	d7,-(a7)
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	clr.l	-(a7)
	move.l	#l000d,-(a7)
	move.w	#9,-(a7)		;flopwr
	trap	#$e
	adda.l	#$14,a7

	movea.l	(a7)+,a0
l0008	adda.l	#2,a0
	dbf	d6,l0003
	addi.b	#1,d7
	cmp.b	#$50,d7
	bne	l0002
	cmpi.b	#0,l000e
	beq	l0009
	pea	crack_done

	bra	printwait

l0009	pea	no_crack

printwait	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7

	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	bra	start

quit_prog	clr.l	-(a7)
	trap	#1

l000c	dc.b	0,0

l000d	dcb.w	6000

l000e	dc.b	0

introtext	dc.b	27,'E'
	dc.b	13,10,10
	dc.b	'           ',27,'p'
	dc.b	'*** GREMLIN CRACKER V.1 - WRITTEN BY J.I.M.M.Y OF MANTRONIX 1990 ***'
	dc.b	27,'q'
	dc.b	'        ',13,10,10,10
	dc.b	'HANDLES: 1 SOME PROTECTION TYPES WHICH CAUSE COMPUTER TO LOCK UP (EG. E-MOTION)',13,10
	dc.b	'         2 EARLY ROB/DMA (TAKEN FROM THE MEDWAY BOYS CRACKER V.1)',13,10
	dc.b	'         3 PROTECTION WHICH FLASHES VIOLENTLY (EG. NEWER GREMLIN GAMES)',13,10,10,10
	dc.b	'               INSERT DISK TO ATTEMPT TO CRACK AND PRESS A KEY...'

examining	
	dc.b	13,10
	dc.b	10
	dc.b	10
	dc.b	'               READING DISK, HOLD CONTROL TO ABORT: ',0
	even

no_crack	
	dc.b	13,10
	dc.b	10
	dc.b	10
	dc.b	'SORRY, UNABLE TO CRACK THAT DISK!',0
	even

crack_done
	dc.b	13,10
	dc.b	10
	dc.b	10
	dc.b	'POSSIBLY CRACKED, TRY IT AND SEE!',0
	even

zuend	end
