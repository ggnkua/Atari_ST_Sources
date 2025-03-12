;+------------------------------------------------------------------+
;| New & improved Gemdos $3F only loader for Automation v.501 files |
;|                                                                  |
;| Improvements by:  I Wonder Who Wrote This Trash Industries       |
;|                   7th - 9th October 1991                         |
;+------------------------------------------------------------------+
;
	opt o+,c+,d+

yes	equ	1
no	equ	0

text_on	equ	no	; text displayed ??
wait_on	equ	no	; wait for key ??
low_res	equ	no	; set low res ??
flash	equ	no	; flash colours whilst depacking ??
res_84	equ	no	; restore $84 after quitting ??
testmeg	equ	yes	; test for 1 meg ??

main	movea.l	4(a7),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$200,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.l	#$4a0000,-(sp)
	trap	#1
	lea	$c(a7),a7

	bsr.s	super	; supervisor mode

	ifne	testmeg
	cmpi.b	#4,$424.w	; 512K only available ??
	beq.s	megonly	; Jump to '1 meg only' routine
	endc

	move.l	$84.w,tr1
	move.l	#T1,$84.w
	bsr.s	user

	ifne	low_res
	clr.w	-(sp)
	pea 	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	$c(a7),a7
	endc

	ifne	text_on
	pea	text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

cont	ifne	wait_on
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

	pea	null
	pea	null
	move.l	#exec,-(sp)
	clr.w	-(sp)		; 0 = load & execute
	move.w	#$4b,-(sp)	; $4b = p_exec
	trap	#1
	lea	18(a7),a7

	ifne	res_84
	bsr.s	super
	move.l	tr1,$84.w
	bsr.s	user
	endc

go_away	clr.w	-(sp)
	trap	#1

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	rts

user	move.l	#oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
;
; This routine is called if pack requires 1040K & user only has 512K
;
	ifne	testmeg
megonly bsr.s	user
	pea	not1040(pc)	; print 'not 512K' message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)	; wait for key
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)		; quit
	trap	#1
	endc
;
; Standard GEMDOS load & depack routine
;
T1	movem.l	a0-a6/d0-d7,regs
	movea.l	a7,a1
	addq.l 	#6,a1
	move.w 	(a7),d0
	btst 	#$d,d0
	bne.s 	ok1
	move.l 	usp,a1
ok1	cmpi.w 	#$3f,(a1)
	beq.s 	read
open	movem.l regs,a0-a6/d0-d7
bye	dc.w 	$4ef9
tr1	dc.l 	$0
read	move.l 	$8(a1),loadadd
	move.l	$2(a7),ex3f
	move.l	#cls,$2(a7)
	bra.s	open
loadadd	dc.l 0
siz2	dc.l 0
cls	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,siz2
	pea	close
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
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
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	
	move.l	a4,a6		
	bsr.s	.getinfo
	cmpi.l	#'AU5!',d0	
	bne.s	.not_packed
	bsr.s	.getinfo	
	lea.l	-8(a0,d0.l),a5	
	bsr.s	.getinfo	
	move.l	d0,(sp)		
	adda.l	d0,a6		
	move.l	a6,a1

	moveq	#119,d0		
.save:	move.b	-(a1),-(a3)	
	dbf	d0,.save
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr.s	.normal_bytes
	move.l	a3,a5		

	bsr.s	.get_1_bit	
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
	movem.l	(sp),d0-a3	

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		
.rest	move.b	-(a3),-(a5)	
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
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

	section	data

oldsp	dc.l	0
;
; Executable file to load
;
exec	dc.b	'monst.tos',0
	even

null	dc.l	0

regs	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ifne	text_on
		;1234567890123456789012345678901234567890 - 40 chars
text	dc.b	27,69
	dc.b	"A Game",13,10
	dc.b	"Packed by IWWWTTI",0
	dc.b	0
	endc	
	
	ifne	testmeg
not1040	dc.b	'Sorry, but this pack requires',13,10
	dc.b	'at least 1 megabyte to work !!',13,10
	dc.b	0
	endc
