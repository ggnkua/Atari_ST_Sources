* tune analyser
	bsr	set_super
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
;	bsr	set_low_rez

	move.l	#0,d0
	bsr	tune
	move.l	#tune+$e,$4da
wait:	bsr	v_sync
;	move.w	#$123,$ff8240

	bsr	spec
;	clr.w	$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait

exit	clr.l	$4da
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	bsr	search
	bsr	print_most
	bsr	get_key
bp	bsr	set_old_palette
	bsr	set_med_rez
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
ERR:	bra.s	ERR


*******************
* CUSTOM ROUTINES *
*******************
enable	dc.w	0
print_most
	move.w	#$11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq.s	.not_ready
	move.w	#$ffff,enable	;printer ready
	bra.s	sas
.not_ready
	clr.w	enable
sas	lea	most_results,a6
.next	tst.w	(a6)
	bne.s	.do
	rts
.do	moveq	#0,d0
	move.w	(a6)+,d0
	bsr	printn
	tst.w	enable
	beq.s	.no_printer
	move.w	#7-1,d6
.prt	move.w	#32,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	dbf	d6,.prt
.no_printer
	pea	space
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#0,d0
	move.w	(a6)+,d0
	bsr	printn

	tst.w	enable
	beq.s	.no_printer2
.prt2	move.w	#13,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	#10,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp

	pea	cr
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
.no_printer2
	bra.s	.next
cr	dc.b	13,10,0,0
space	dc.b	"       ",0
	even	

search	lea	spec_values,a0
	lea	spec_lookup,a1
	lea	search_results,a2
	moveq	#0,d3
	move.w	#8192-1,d0
.loop	move.b	(a0)+,d1
	beq.s	.over
	move.w	(a1,d3.w),d2
	move.w	d2,(a2)+
.over	add.w	#4,d3
	dbf	d0,.loop
; Results of notes found is in SEARCH_RESULTS.

; Now find the most used notes used...... (rock hard job!)
; er.... how the fuck do I do this?

	lea	most_results,a2
	lea	search_results,a0
	move.l	a0,search_pos
find	lea	spec_lookup,a1
	move.l	search_pos,a0
	tst.w	(a0)
	bne.s	find_most
	rts
find_most
	add.l	#2,search_pos
	move.w	(a0)+,d1
.loop	cmp.w	(a1),d1
	bne.s	.no
	move.w	(a1),(a2)+
	move.w	2(a1),(a2)+
	bra.s	find
.no	add.w	#4,a1
	cmp.l	#most_results,a1
	bne	.loop
	bra.s	find

search_pos	dc.l	0
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

spec	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_lookup,a3

	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	bchan
	moveq.l	#0,d0
	move.b	#ACOURSE,(a1)		;A course tune, octave!
	move.b	(a1),d0
	and.w	#$f,d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)		;A fine tune note
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	moveq	#0,d3
	move.w	#8192-1,d1
loopa	cmp.w	(a3),d0
	bgt.s	bchan
	beq.s	.yes
	add.w	#4,a3
	add.w	#1,d3
	dbf	d1,loopa
.yes	move.b	#1,(a2,d3.w)
	cmp.w	#$ffff,2(a3)
	beq.s	bchan
	add.w	#1,2(a3)


******************
bchan	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	cchan
	lea	spec_lookup,a3
	lea	spec_values,a2
	moveq.l	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	moveq	#0,d3
	move.w	#8192-1,d1
loopb	cmp.w	(a3),d0
	bgt.s	cchan
	beq.s	.yes
	add.w	#2,a3
	add.w	#1,d3
	dbf	d1,loopb
.yes	move.b	#1,(a2,d3.w)
	cmp.w	#$ffff,2(a3)
	beq.s	cchan
	add.w	#1,2(a3)

******************
cchan	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	ps

	lea	spec_lookup,a3
	lea	spec_values,a2
	moveq.l	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	moveq	#0,d3
	move.w	#8192-1,d1
loopc	cmp.w	(a3),d0
	bgt.s	ps
	beq.s	.yes
	add.w	#2,a3
	add.w	#1,d3
	dbf	d1,loopc
.yes	move.b	#1,(a2,d3.w)
	cmp.w	#$ffff,2(a3)
	beq.s	ps
	add.w	#1,2(a3)
ps	rts



***********************
* SUBROUTINES SECTION *
***********************
;************************************
;* Print out any number in any base *
;*     D0.L=number / D1.L=base      *
;*         Uses D0, D1, A0          *
;************************************
printn
	move.l	#16,d1
	LEA buffer(PC),A0 A0=buffer
	CLR.L (A0)+       Zero buffer
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+       A0->buffer end
loop1
	DIVU D1,D0        D0 DIV D1
	SWAP D0           D0.low=remainder
	ADDI #'0',D0      Make into digit
	CMPI #'9',D0      Digit or letter?
	BLE ok
	ADDQ #7,D0        Make into letter
ok
	MOVE.B D0,-(A0)   Store character
	CLR D0
	SWAP D0           D0.low=quotient
	BNE loop1         Another one?
	MOVE.L A0,-(A7)

loop2	tst.w	enable
	beq.s	.no_printer
	move.l	a0,a5
.prt
	move.b	(a5)+,d0
	beq.s	.no_printer
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	bra.s	.prt
.no_printer

_conws
	MOVE #9,-(A7)     Print string
	TRAP #1           GEMDOS 9
	ADDQ.L #6,A7      Tidy stack
	RTS
buffer
	DS.L 5            Number$ - 20 digits
	DC.B 0            Buffer end marker
	EVEN

v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

get_old_palette:
	move.w	#8-1,d0
	lea	$ff8240,a0
	lea	old_palette,a1
get_old:
	move.l	(a0)+,(a1)+
	dbf	D0,get_old
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16

tune	incbin	301.img
pic:	incbin	pov55.pi1

spec_values
	dcb.b	8192,0
spec_lookup
	incbin	analyser.dat

search_results
	dcb.w	4096,0

most_results
	dcb.w	4096,0
