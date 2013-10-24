******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	YES

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC

* star field
*
* My first attempt at one - MSD of P.O.V. 28/9/91 14:32
*
*
*
******** BORIS
*
* I can't fuckin suss out 'cos I can't code
*
* I could do a repetitive star field but that's lame
* I tried to do a random number generator to create the position,speed
* , etc. but it don't work.
*
* You said you would look at it so here it is ALL SHIT CODE anyway
* Just send me a working star field, left to right OK?

;	bsr	set_super
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	bsr	set_up_stars


wait	bsr	v_sync
;	move.w	#$123,$ffff8240.w
	bsr	stars
;	move.w	pic+2,$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait

	bsr	set_old_palette
	bsr	set_med_rez
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	MOVE.W	#$4c,-(SP)
	TRAP	#1


*******************
* CUSTOM ROUTINES *
*******************


***************************************
*				      *
* Nice random number routine by Boris *
*				      *
***************************************

random
	move.l	seed,d0
	mulu	#$1afb,d0
	add.l	#$1fccd,d0
	move.l	d0,seed
	rts

seed	dc.l	53

***************************************


NO_STARS	equ	200
stars
	move.l	screen_base,a2
;	clr.l	d7		;offset into star table
	moveq	#0,d7		; Now used for fast clearing star.
	lea	star_table,a0
	move.w	#NO_STARS-1,d6	;number of stars
.loop
;	lea	star_table,a0
;	add.w	d7,a0
	bsr	do_stars
;	add.w	#8,d7
	addq.w	#8,a0
	dbf	d6,.loop
	rts

do_stars
	move.w	2(a0),d0	;word offset
	moveq	#0,d1		; Make sure high word is clear for later.
	move.w	4(a0),d1	;bit offset

;	move.l	screen_base,a1
		move.l	a2,a1	; Quicker!
	add.w	(a0),a1		; Line offset.
	add.w	d0,a1		;add word offset
;	clr.w	6(a1)		;clear old star
	move.w	d7,6(a1)	; Faster clear old star.

;calc new pos
	move.w	6(a0),d2	;speed of shift
;	lsr.w	d2,d1
;	bcc.s	no_word
	ror.l	d2,d1		; 'Dot' might be shifted into
				; high word so not lost!
	tst.w	d1		; 'Dot' shifted into next column?
	bne.s	no_word		; No!
	swap	d1		; Yes, get back new 'dot' value.

;word overlap so add to next word
;	move.w	2(a0),d2	;get word offset (ALREADY IN d0!)
	addq.w	#8,d0		;goto next word
;	cmp.w	#160-8,d2	;is word over screen width?
	cmp.w	#160,d0		;is word over screen width?
	blt.s	.no		;NO!!

	move.w	d7,2(a0)	; Clear word offset.
;	move.w	#$8000,d1
	move.w	d1,4(a0)	;save star shift for next VBL
	rts


.no	move.w	d0,2(a0)
;	move.w	#$8000,d1
;	or.w	d1,6+8(a1)	;poke to screen
		move.w	d1,6+8(a1)	; With only 1 star per line
					; can use move.
	move.w	d1,4(a0)	;save star shift for next VBL
	rts

no_word
;	or.w	d1,6(a1)
		move.w	d1,6(a1)	; With only 1 star per line
					; can use move.
	move.w	d1,4(a0)
	rts





set_up_stars
	clr.w	d5
	lea	star_table,a6
	move.w	#NO_STARS-1,d7		;number of stars
.loop
	move.w	d5,(a6)+	; Store line offset.
	add.w	#(160*(200/NO_STARS)),d5	; Next line offset.

;now get a RANDOM number for shifts,speed and line offset
	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp
	and.l	#$7fff,d0

	divu	#160,d0
	swap	d0		; Get number within width of screen.
;	lsr.w	#4,d0
;	and.w	#8,d0		; ???
	and.w	#$f8,d0	; Place on column boundary.
	move.w	d0,(a6)+	;word offset

	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp

;	and.w	#$7fff,d1	; ???
	and.w	#15,d0
	move.w	#$8000,d1
	ror.w	d0,d1
	move.w	d1,(a6)+	;pixel shift

	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp

	and.w	#7,d0
	addq.w	#1,d0		; Make sure not stopped!
	move.w	d0,(a6)+	;speed

;	lsr.l	#8,d1		; ???
;	and.w	#32000,d1	; ???
;	add.w	d1,d5		; ???

	dbf	d7,.loop
	rts

***********************
* SUBROUTINES SECTION *
***********************
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
	move.l	screen_base,-(sp)
	move.l	(sp),-(sp)
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


*** star table is made up in the following way..
*
* word:  line offset for screen
* word:  word off on line
* word:  dot shift
* word:  speed dot moves
star_table
	REPT	NO_STARS
	dcb.w	4
	ENDR

pic:	incbin	"h:\pics\oz\grn_man.pi1"	;any pic....


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
