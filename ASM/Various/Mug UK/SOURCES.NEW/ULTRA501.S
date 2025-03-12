;+------------------------------------------------------------+
;|        Ultraload (Uni-load II) for Automation v5.01        |
;|                                                            |
;|            Written by Dack of The Un-Nameables             |
;|               (Based on Uni-load by The Law)               |
;|                                                            |
;|                 Automation v5.01 update by:                |
;| I Wonder Who Wrote This Trash Industries, 9th October 1991 |
;+------------------------------------------------------------+
;
; PLEASE NOTE:-
;
; buff_len  = Max length of a PACKED file
; max_files = No. of files open at once + 6
;
; only packed files are buffered, unpacked data
; is treated as normal...
;
; gam = filename to $4b

		opt o+,ow-,c+,d-

buff_len	equ	$18c0a	; Maximum length of a file here
max_files	equ	32	; Maximum no. of files open +6 goes here

yes	equ	1
no	equ	0

text_on	equ	yes
wait_on	equ	yes
low_res	equ	yes
res_84	equ	yes
flash	equ	yes

	bra	main

execfile dc.b	"loader.exe"	; Executable file to load here
	dc.b	0
	even

	ifne	text_on
		;1234567890123456789012345678901234567890 - 40 chars
text	dc.b	"IWWWTTI presents ...",13,10
	dc.b	"Packed with Ultra 501 !!",13,10
	dc.b	00,00
	even
	endc

;SET TABS TO 10 FOR DISASSEMBLY

	
main	movea.l	4(a7),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$200,d0
	add.l	#buff_len,d0	;add buffer length
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.l	#$4a0000,-(sp)
	trap	#1
	lea	$c(a7),a7

	dc.l	$a000a00a

	ifne	low_res	; low res required ??
	clr.w	-(sp)
	pea	$ffffffff
	move.l	(a7),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	$c(a7),a7
	endc

	dc.w	$a009

	ifne	text_on
	pea	text
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	endc

	ifne	wait_on
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

*
* buffer address
* (Can be absolute....)
* 
	move.l	#buff_start,buff_add	;set buffer start address

	bsr.s	super
	move.l	$84,tr1
	move.l	#T1,$84
	bsr.s	user

stkk	clr.w	in_use
	clr.l	$60000
	pea	$60000
	move.l	(a7),-(sp)
	move.l	#execfile,-(sp)
	move.l	#$4b0000,-(sp)
	trap	#1
	lea	$0c(a7),a7

	ifne	res_84	; Restore Trap #1 ??
	bsr.s	super
	move.l	tr1,$84
	bsr.s	user
	endc

	clr.w	-(sp)
	trap	#1

oldsp	dc.l	0

super	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	rts

user	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

;multi file read 1st October 1989
;fix 11th October 1989 for decode from odd address
;bastard bug to find

T1		tst.w	inside
		bne	bye
		MOVEM.L a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	ok1
		move.l 	usp,a1
ok1		cmpi.w  #0,(a1)
		bne.s next1
		move.l	tr1(pc),$84.w
		bra.s	open
next1		cmpi.w 	#$3d,(a1)
		beq	openup
		cmpi.w	#$3f,(a1)
		beq	read
		cmpi.w	#$3e,(a1)
		beq	close
		cmpi.w	#$42,(a1)
		beq	seek
		cmpi.w	#$4e,(a1)
		beq	ffirst
		cmpi.w  #$3c,(a1)
		beq 	create
		cmpi.w	#$40,(a1)
		beq 	write
open		movem.l reg(pc),a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0

openup		move.w	#1,inside	;do normal traps
		lea	f_names,a0
		add.l	#300,a0
		move.l	#5,d0
s_loop		addq.l	#1,d0
		add.l	#60,a0
		tst.b	(a0)
		bne.s	s_loop		;search for empty slot

;d0=my pretend file handle

		move.l	d0,d7

****		
		move.l d0,d6

		move.l	a0,a5
		move.l	2(a1),a6	;save file name address

;open file
		clr.w	-(a7)
		move.l	a6,-(a7)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7

		tst.l	d0
		bmi	error		;in case file not there

		move.w	d0,d4
		clr.l i_buff
		pea i_buff
		move.l #8,-(a7)
		move.w d4,-(a7)
		move.w #$3f,-(a7)
		trap #1
		lea 12(a7),a7
		clr.w -(a7)
		move.w d4,-(a7)
		clr.l -(a7)
		move.w #$42,-(a7)
		trap #1
		lea 10(a7),a7
		cmp.l #"LSD!",i_buff
		beq.s nermal	
		lea real_hand,a0
		lsl.l #2,d7
		move.l d4,(a0,d7.w)
		move.b #"0",(a5)
		bra not_good

;copy file name to storage

nermal		move.l	#59,d0
c_loop		move.b	(a6)+,(a5)+
		dbra	d0,c_loop

		move.l	i_len,d5
not_com		lea	f_lengths,a0
		lsl.l	#2,d7
		move.l	d5,(a0,d7.w)		;save file length in array
		lea	so_read,a0
		move.l #0,(a0,d7.w)
		lea real_hand,a0
		move.l #-1,(a0,d7.w)
		
;close file as finished

		move.w	d4,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7

not_good
		clr.w	inside		;my traps again
		move.l d6,-(a7)
		movem.l reg,a0-a6/d0-d7	
		move.l	(a7)+,d0	;give back my handle
		rte

read		clr.l	d0
		move.w	2(a1),d0	;get handle
		cmp.l	in_use,d0
		beq	all_in		;already loaded

		move.l d0,d1
		lsl.l #2,d1
		lea real_hand,a0
		move.l (a0,d1.w),d2
		cmp.l #-1,d2
		beq.s cor_blimey

		move.l 4(a1),d0
		move.l 8(a1),d1
		move.w #1,inside
		move.l d1,-(a7)
		move.l d0,-(a7)
		move.w d2,-(a7)
		move.w #$3f,-(a7)
		trap #1
		lea 12(a7),a7
		clr.w inside

		move.l d0,d4
		bra titter

cor_blimey	move.l	a1,a5
		move.w	#1,inside
		move.l	d0,in_use
		mulu 	#60,d0
		lea	f_names,a0
		add.l	d0,a0		;get correct filename
		clr.w	-(a7)
		move.l	a0,-(a7)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7
		move.w	d0,d6
		move.l	buff_add,-(a7)
		move.l	#buff_len,-(a7)
		move.w	d0,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		move.w	d6,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
		clr.w	inside
		move.l	buff_add,a0
		move.l	a0,a1
		add.l	#200,a1
		move.l	4(a0),d7	;length
		bsr	depack
		move.l	buff_add,a0
		move.l	a0,a1
		add.l	#200,a1
m2_back		move.b	(a1)+,(a0)+
		subq.l	#1,d7
		bne.s	m2_back
read_in		move.l	a5,a1		;put stack back in a1
all_in		move.l	4(a1),d0	;bytes to move
		move.l	d0,d4
		move.l	8(a1),a0	;whereto
		move.l	in_use,d1
		lsl.l	#2,d1		;*4
		lea	so_read,a2
		lea	f_lengths,a3
		move.l	(a2,d1.w),d2	;current offset
		move.l	(a3,d1.w),d3	;length of this file
		move.l	buff_add,a1
		add.l	d2,a1
do_it		move.b	(a1)+,(a0)+
		addq.l	#1,d2
		cmp.l	d2,d3
		blt.s	past_end
		subq.l	#1,d0
		bne.s	do_it
		bra.s	wibble
past_end	move.l	d3,d2		;if past end then offset=end
wibble		move.l	d2,(a2,d1.w)	;save new offset
		sub.l	d0,d4		;get number of bytes read
titter		move.l	d4,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return #bytes read
		rte

close		clr.l	d0
		move.w	2(a1),d0
		cmp.l	in_use,d0	;closing file currently loaded
		bne.s	lucky
		move.l	#-1,in_use
lucky		move.l d0,d1
		mulu	#60,d0
		lea	f_names,a0
		move.b	#0,(a0,d0.w)
	lsl.l #2,d1
	lea real_hand,a0
	move.l (a0,d1.w),d0
	cmp.l #-1,d0
	beq.s standard
	move.w #1,inside
	move.w d0,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.w #4,a7
	clr.w inside
standard	movem.l	reg,a0-a6/d0-d7
	clr.l	d0
	rte

seek	lea	so_read,a2
	lea	f_lengths,a3
	clr.l	d0
	move.w	6(a1),d0	;file handle
	lsl.l	#2,d0
	clr.l	d1
	move.w	8(a1),d1	;type of seek
	move.l	2(a1),d2	;offset

	lea real_hand,a0
	move.l (a0,d0.w),d3
	cmp.l #-1,d3
	beq.s com_seek
	move.w #1,inside
	move.w d1,-(a7)
	move.w d3,-(a7)
	move.l d2,-(a7)
	move.w #$42,-(a7)
	trap #1
	lea 10(a7),a7

	move.l d0,d3
	clr.w inside
	bra com_out

com_seek	tst.w	d1		;type 0?
	bne.s	one_two

;absolute move=type 0

	move.l	d2,d3
	bra.s	same_end
one_two	cmp.w	#1,d1
	bne.s	mustbe2

;type 1=from current place

	move.l	(a2,d0.w),d3
	add.l	d2,d3
	bra.s	same_end
mustbe2	move.l	(a3,d0.w),d3
	sub.l	d2,d3

;type 2=from end

same_end	move.l	(a3,d0.w),d4	;get length
	cmp.l	d3,d4
	bgt.s	ok_so_far	;not past end
	move.l	d4,d3
ok_so_far	cmp.l	#0,d3
	bgt.s	still_ok	;not past start
	clr.l	d3
still_ok	move.l	d3,(a2,d0.w)	;save new offset
com_out	move.l	d3,-(a7)
	movem.l	reg,a0-a6/d0-d7
	move.l	(a7)+,d0	;return new offset
	rte

error	clr.w	inside
	movem.l	reg,a0-a6/d0-d7
	move.l	#-1,d0
	rte	

create	move.w #1,inside
	lea f_names,a0
	add.l #300,a0
	move.l #5,d0
fcl	addq.l #1,d0
	add.l #60,a0
	tst.b (a0)
	bne.s fcl

	move.l d0,d7
	move.l a0,a5
	move.w 6(a1),-(a7)
	move.l 2(a1),-(a7)
	move.w #$3c,-(a7)
	trap #1
	addq.l #8,a7

	tst.w d0
	bmi nwc

	move.b #'i',(a5)
	lea real_hand,a0
	move.l d7,d6
	lsl.l #2,d7
	move.l d0,(a0,d7.w)
	move.l d6,d0
nwc	clr.w inside
	move.l d0,-(a7)
	movem.l reg,a0-a6/d0-d7
	move.l (a7)+,d0
	rte

write	clr.l d0
	move.w 2(a1),d0
	lsl.l #2,d0
	lea real_hand,a0
	move.l (a0,d0.w),d1
	move.w d1,2(a1)
	bra open

ffirst	move.l	2(a1),d0
	move.l	d0,d5		;preserve fname
	move.w	6(a1),d1
	move.w	#1,inside
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bne.s	exit_route
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7
	move.l	d0,d7

	clr.w	-(a7)
	move.l	d5,-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d6
	clr.l	tmp_read
	pea	tmp_read
	move.l	#8,-(a7)
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	move.w	d6,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	lea	tmp_read,a0
	cmp.l	#"AU5!",(a0)
	bne.s	doont
	move.l	d7,a1
	move.l	4(a0),26(a1)
doont	clr.l	d0
exit_route clr.w	inside
	move.l	d0,-(a7)
	movem.l	reg,a0-a6/d0-d7
	move.l	(a7)+,d0
	rte

reg	ds.l	16
tmp_read	ds.l	4
crunpos	dc.l 0

;
; Automation v5.01 - A0 -> A1 depacker
;
depack	movem.l	d0-a6,-(sp)
	bsr.s	getinfo		
	cmpi.l	#'AU5!',d0	
	bne.s	not_packed	
	bsr.s	getinfo		
	lea.l	-8(a0,d0.l),a5	
	bsr.s	getinfo		
	move.l	d0,(sp)		
	move.l	a1,a4		
	move.l	a1,a6
	adda.l	d0,a6		
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr.s	normal_bytes

	bsr.s	get_1_bit 	
	bcc.s	not_packed	
	move.w	#$0f9f,d7 	
AU5_00:	moveq	#3,d6		
AU5_01:	move.w	-(a3),d4	
	moveq	#3,d5		
AU5_02:	add.w	d4,d4		
	addx.w	d0,d0		
	add.w	d4,d4		
	addx.w	d1,d1		
	add.w	d4,d4		
	addx.w	d2,d2		
	add.w	d4,d4		
	addx.w	d3,d3		
	dbra	d5,AU5_02 	
	dbra	d6,AU5_01 	
	movem.w	d0-d3,(a3)	
	dbra	d7,AU5_00 	

not_packed:
	movem.l	(sp)+,d0-a6
	rts

getinfo:
	moveq	#3,d1	
getbytes:
	 lsl.l	#8,d0		
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	
	moveq.l	#0,d1		
	bsr.s	get_1_bit
	bcc.s	copy_direkt	
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0	
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		
	dbne	d3,nextgb 	
no_more:
	add.l	20(a1),d1
copy_direkt:	
	move.b	-(a5),-(a6)	

	ifne	flash
	move.w	d0,$ff8240	; Standard Auto v5.01 flash
;	move.b	(a6),$ff8240	; Medway Boys F/X
;	eori.w	#$201,$ff8240	; Dream Warriors F/X 
	endc

	dbf	d1,copy_direkt	
test_if_end:	
	cmpa.l	a4,a6		
	bgt.s	strings		
	rts	

get_1_bit:
	add.b	d7,d7		
	bne.s	bitfound	
	move.b	-(a5),d7	
	addx.b	d7,d7
bitfound:
	rts	

get_d0_bits:	
	moveq.l	#0,d1		
hole_bit_loop:	
	add.b	d7,d7		
	bne.s	on_d0		
	move.b	-(a5),d7	
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		
	dbf	d0,hole_bit_loop
	rts	

strings:
	lea.l	length_tab(pc),a1
	moveq.l	#3,d2		
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit
no_length_bit:	
	moveq.l	#0,d4		
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bmi.s	no_Åber		
get_Åber:
	bsr.s	get_d0_bits
no_Åber:
	move.b	6(a1,d2.w),d4	
	add.w	d1,d4	
	beq.s	get_offset_2	


	lea.l	more_offset(pc),a1	
	moveq.l	#1,d2
getoffs:
	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bsr.s	get_d0_bits
	add.w	d2,d2		
	add.w	6(a1,d2.w),d1	
	bpl.s	depack_bytes	
	sub.w	d4,d1		
	bra.s	depack_bytes

get_offset_2:	
	moveq.l	#0,d1		
	moveq.l	#5,d0		
	moveq.l	#-1,d2		
	bsr.s	get_1_bit
	bcc.s	less_40		
	moveq.l	#8,d0		
	moveq.l	#$3f,d2		
less_40:
	bsr.s	get_d0_bits
	add.w	d2,d1		

depack_bytes:			
	lea.l	2(a6,d4.w),a1	
	adda.w	d1,a1		
	move.b	-(a1),-(a6)	
dep_b:	move.b	-(a1),-(a6)	
	dbf	d4,dep_b	
	bra	normal_bytes	


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l 270-1,15-1,8-1,5-1,2-1

length_tab:
	dc.b 9,1,0,-1,-1	
	dc.b 8,4,2,1,0		

more_offset:
	dc.b	  11,4,7,0
	dc.w	$11f,-1,$1f	

;************ Ende der Unpackroutine *******************

stksav		dc.l	0
in_use		ds.l	1
inside		ds.l	1
buff_add	ds.l	1
whereto		ds.l	1
so_read		dcb.l	0,max_files
f_lengths	dcb.l	0,max_files
f_names		rept	max_files
		dcb.b	0,60
		endr
real_hand	dcb.l	0,max_files
i_buff		ds.l 	1
i_len		ds.l 	1
buff_start	dc.l	0	;start of buffer space

	
