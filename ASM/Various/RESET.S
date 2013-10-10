*************************************************************************
*									*
*	 Reset demo route written by Pontus Sk”ld for Devpac 2		*
*									*
*************************************************************************
;
;Reset.S
;Written by Pontus Sk”ld (Winnie The Pooh) 28/12/90
;Copyright (c) 1990, Winnie The Pooh
;Feel free to use any or all of this source code.
;
;My tabs set to 8...
;
; GET PG, my address stands there...
;
;

	section text

start:
 	clr.l	-(sp)			*Join supervisor mode
 	move.w	#$20,-(sp)		*Gemdos $20 is _super
 	trap	#1			*Do it
 	addq.l	#6,sp			*Restore Stackpointer
 	move.l	d0,save_ssp		*Save old value

 	move.l	#route,$42a.w		*Resvector, points to my route
 	move.l	#$31415926,$426.w	*Resvalid = pi if reset route 

	pea	text			*Pointer to message
	move.w	#9,-(sp)		*Cconws (print a text string)
	trap	#1			*Do !!!
	addq.l	#6,sp			*Heal stack

	move.w	#7,-(sp)		*Wait for key...
	trap	#1			*Do it
	addq.l	#2,sp			*Correct the stack pointer

 	move.l	save_ssp,-(sp)		*Goto user mode
 	move.w	#$20,-(sp)		*Gemdos $20 is _super
 	trap	#1			*Do it!
 	addq.l	#6,sp			*Restore stack pointer

 	clr.w	-(sp)			*Return code
 	move.l	#50000,-(sp)		*Bytes to keep
 	move.w	#$31,-(sp)		*Gemdos $31 is ptermres
 	trap	#1			*Do it!

*
*Here is the beginning of the reset route
*

route:
	nop				*No OPeration

	lea	stack,sp		*I want MY OWN stack

	move.b	#$48,$fffffa17.w	*MFP Vectors at $100, Softw End Int

	move.l	#before_pic,d0		*Get pointer 
	and.l	#$ffffff00,d0		*No low byte
	move.l	d0,screen_ptr		*Save d0

 	move.l	d0,a0			*Copy d0  to a0

	lea	$ffff8201.w,a1		*Vbase
	lsl.l	#8,d0			*Rotate so we can write it good.
	movep.l	d0,0(a1)		*Set new Vbase

	lea	pic_area+128,a1		*Address to picture
 	move.l	#7999,d0		*8000 longwords to copy

pic:	move.l	(a1)+,(a0)+		*Copy from a1 to a0 and inc both  
 	dbra 	d0,pic			*zero stop looping, else loop

	movem.l	pic_area+4,d0-d7	*Get colors
	movem.l	d0-d7,$ffff8240.w	*Put colors

	move.l	#first_vbi,$70.w	*Set up rez setting vbi

	move.w	#$2300,sr		*Status so an vbi can occure

	clr.w	rez_set			*So I'm sure it's cleared.
not_set:
	tst.w	rez_set			*Flag set (vbi 	occured) ???
	beq.s	not_set			*No, goto not_set

	move.l	#new_vbi,$70.w		*Install vbi

main:	bra.s	main			*Endless loop

*
*Here are the sub routine.
*

wait_vbl:			
	move.b	#1,vbi_flag		*Set vbi flag
wait:
	tst.b	vbi_flag		*Is vbi flag cleared ?
	bne.s	wait			*No, goto wait
	rts				*Yes, return

*
*Here are the VBIs
*

first_vbi:

*
*Hz and rez should be set on the VBI, else the bps might crap up
*

	clr.b	$ffff8260.w		*Set low rez
	move.b	#2,$ffff820a.w		*Set 50 hz
	move.w	#-1,rez_set		*Set flag so I know it has occured
	rte				*Return

new_vbi:
	clr.b	vbi_flag		*Clear vbi flag so I know
	rte				*Return

	section data
	
pic_area:	incbin	a:\picture.neo	*A Neo picture...
text:		dc.b	$1b,"E","Reset Code Demonstration Source",$a,$d
		dc.b	"by WTP... (I feel kind today)",0


	section bss

save_ssp:	ds.l	1		*Space for save of sp 
understack:	ds.l	100		*Stack space
stack:		ds.l	1		*Stack ptr
overstack:	ds.w	10		*Safety margin
vbi_flag:	ds.w	1		*Space for vbi flag
rez_set:	ds.w	1		*Space for rez is set flag 
screen_ptr:	ds.l	1		*Space for save of screenptr
before_pic:	ds.b	256		*Space for even boundary
pic_space:	ds.b	32000		*Space for screen

	end