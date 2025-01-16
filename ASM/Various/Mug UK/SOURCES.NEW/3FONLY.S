;+------------------------------------------------------------------+
;| New & improved Gemdos $3F only loader for Automation v.501 files |
;|                                                                  |
;| Improvements by:  I Wonder Who Wrote This Trash Industries       |
;|                   7th - 9th October 1991                         |
;+------------------------------------------------------------------+
;
	opt o+,c+,d-

yes	equ	1
no	equ	0

text_on	equ	yes	; text displayed ??
wait_on	equ	yes	; wait for key ??
low_res	equ	no	; set low res ??
flash	equ	yes	; flash colours whilst depacking ??
res_84	equ	yes	; restore $84 after quitting ?? (GEM programs !!)


main	movea.l	4(a7),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0

	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.l	#$4a0000,-(a7)
	trap	#1
	lea	12(a7),a7

	bsr.s	super
	move.l	$84.w,tr1	; Store old Trap #1
	move.l	#T1,$84.w	; Install new Trap #1
	bsr.s	user

	ifne	low_res
	clr.w	-(a7)
	pea 	-1
	pea	-1
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	endc

	ifne	text_on
	pea	text
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	endc

	ifne	wait_on
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	endc

stkk	clr.l	$60000
	
	pea	$60000
	pea	$60000
	move.l	#execfile,-(a7)
	move.l	#$4b0000,-(a7)
	trap	#1
	lea	16(a7),a7

	ifne	res_84
	bsr.s	super
	move.l	tr1,$84.w
	bsr.s	user
	endc

	clr.w	-(a7)
	trap	#1

oldsp	dc.l	0

super	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldsp
	rts

user	move.l	#oldsp,-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	rts
;
; Standard GEMDOS load & depack routine
;
T1	movem.l	a0-a6/d0-d7,reg
	movea.l	a7,a1
	addq.l 	#6,a1
	move.w 	(a7),d0
	btst 	#$d,d0
	bne.s 	ok1
	move.l 	usp,a1
ok1	cmpi.w 	#$3f,(a1)
	beq.s 	read
open	movem.l reg,a0-a6/d0-d7
bye	dc.w 	$4ef9		; JMP instruction
tr1	dc.l 	$0
read	move.l 	$8(a1),loadadd
	move.l	$2(a7),ex3f
	move.l	#cls,$2(a7)
	bra.s	open
loadadd	dc.l 0
siz2	dc.l 0
cls	movem.l	d0-d7/a0-a6,-(a7)
	move.l	d0,siz2
	pea	close
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d0-d7/a0-a6
	move.l	siz2,d0

	dc.w	$4ef9		; JMP
ex3f	dc.l	0

close	move.l	loadadd,a0
	bsr.s	depack
	rts

;
; A0 -> A0 depacker
;
depack
AU5_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(a7)
	lea	120(a0),a4	
	move.l	a4,a6		
	bsr.s	.getinfo
	cmpi.l	#'AU5!',d0	
	bne.s	.not_packed
	bsr.s	.getinfo	
	lea.l	-8(a0,d0.l),a5	
	bsr.s	.getinfo	
	move.l	d0,(a7)		
	adda.l	d0,a6		
	move.l	a6,a1

	moveq	#119,d0		
.save:	move.b	-(a1),-(a3)	
	dbf	d0,.save
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr.s	.normal_bytes
	move.l	a3,a5		

	bsr	.get_1_bit	
	bcc.s	.no_picture	
	move.w	#$0f9f,d7 	
.AU5_00:
	moveq	#3,d6	
.AU5_01:
	move.w	-(a3),d4
	moveq	#3,d5		
.AU5_02:
	add.w	d4,d4	
	addx.w	d0,d0		
	add.w	d4,d4		
	addx.w	d1,d1		
	add.w	d4,d4		
	addx.w	d2,d2		
	add.w	d4,d4		
	addx.w	d3,d3		
	dbra	d5,.AU5_02	
	dbra	d6,.AU5_01	
	movem.w	d0-d3,(a3)	
	dbra	d7,.AU5_00	
.no_picture
	movem.l	(a7),d0-a3	

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		
.rest	move.b	-(a3),-(a5)	
	dbf	d0,.rest
.not_packed:
	movem.l	(a7)+,d0-a6
	unlk	a3
	rts
.getinfo: 
	moveq	#3,d1		
.getbytes:
	lsl.l	#8,d0	
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	
	moveq.l	#0,d1		
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:
	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		
	dbne	d3,.nextgb	
.no_more: 
	add.l	20(a1),d1 	
.copy_direkt:	

	ifne	flash		; flash colours if required !!
	move.w	d0,$ff8240	; Standard Auto v5.01 flash
;	move.b	(a6),$ff8240	; Medway Boys F/X
;	eori.w	#$201,$ff8240	; Dream Warriors F/X 
	endc

	move.b	-(a5),-(a6)	
	dbf	d1,.copy_direkt	
.test_if_end:	
	cmpa.l	a4,a6		
	bgt.s	.strings	
	rts	

.get_1_bit:
	add.b	d7,d7		
	bne.s	.bitfound 	
	move.b	-(a5),d7	
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		
.hole_bit_loop:	
	add.b	d7,d7		
	bne.s	.on_d0		
	move.b	-(a5),d7	
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		
	dbf	d0,.hole_bit_loop	
	rts	

.strings: 
	lea.l	.length_tab(pc),a1	
	moveq.l	#3,d2		
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4		
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bmi.s	.no_Åber	
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4	
	beq.s	.get_offset_2	

	lea.l	.more_offset(pc),a1 
	moveq.l	#1,d2
.getoffs: 
	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bsr.s	.get_d0_bits
	add.w	d2,d2		
	add.w	6(a1,d2.w),d1	
	bpl.s	.depack_bytes	
	sub.w	d4,d1		
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		
	moveq.l	#5,d0		
	moveq.l	#-1,d2		
	bsr.s	.get_1_bit
	bcc.s	.less_40	
	moveq.l	#8,d0		
	moveq.l	#$3f,d2		
.less_40: 
	bsr.s	.get_d0_bits
	add.w	d2,d1		

.depack_bytes:			
	lea.l	2(a6,d4.w),a1	
	adda.w	d1,a1		
	move.b	-(a1),-(a6)	
.dep_b:	move.b	-(a1),-(a6)	
	dbf	d4,.dep_b 	
	bra	.normal_bytes	


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	
	dc.l 270-1,15-1,8-1,5-1,2-1	

.length_tab:
	dc.b 9,1,0,-1,-1	
	dc.b 8,4,2,1,0		

.more_offset:
	dc.b	  11,   4,   7,  0	
	dc.w	$11f,  -1, $1f	

ende_AU5_decrunch_2:
;
;************ Ende der Unpackroutine *********************

reg	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	even
;
; File to p_exec
;
execfile dc.b 'loader.exe',0
	even

	ifne	text_on
		;1234567890123456789012345678901234567890 - 40 chars
text	dc.b	$1b,69
	dc.b	"A Game",13,10
	dc.b	"Packed by IWWWTTI",13,10
	dc.b	0
	even
	endc	
