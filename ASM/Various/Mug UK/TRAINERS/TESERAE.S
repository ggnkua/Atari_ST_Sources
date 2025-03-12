* EXEC HEADER FOR EXEC FILES PACKED WITH ATOMIC PACKER v3.3
* ---------------------------------------------------------
*
* Main code: Pompey Pirates (from Pompey Packer v1.9a)
*
* Additional code: I Wonder Who Wrote This Trash Industries, 1991
*
* Instructions
* ------------
*
* Pack your main program file as a data file, alter this source to your
* own requirements (text etc.) and assemble it to disk.
*
* Add your own code alterations from label marked 'alter_me' onwards
* (eg. trainer mode).
*

no	equ	0
yes	equ	1

low_res	equ	yes	; Force Low Resolution 
text_on	equ	yes	; Print Text
wait_on	equ	yes	; Wait for key
pre_reg	equ	no	; Preserve registers
clr_bss	equ	no	; Clear BSS segment (see above)
fade_on	equ	yes	; Fade Colours In/Out (Low res)
music_on	equ	yes	; Add Chip music to the intro ??

	opt	o+,p+,d+

	bra.s	start
	dc.b	"A MUG U.K(tm) Trainer Version in 1992 !!  "
	dc.b	"Don't rip me off you lamer !!  "
	dc.b	"Trainer done on: 8/8/1992 !!  "
	even

start
	ifne	pre_reg
	movem.l	d0-d7/a0-a6,start-128
	endc

	move.l	4(sp),a5		base page address

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	old_sp(pc),a0
	move.l	d0,a0
	
intro	bclr	#0,$484.w

	ifne	music_on
	move.w	#1,d0
	lea	music(pc),a0
	jsr	(a0)
	lea	old_70(pc),a0
	move.l	$4d2.w,(a0)
	lea	new_vbl(pc),a0
	move.l	a0,$4d2.w
	endc

	ifne	low_res		; Low resolution
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	lea	oldrez+2(pc),a0
	move.w	d0,a0

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	fade_on
	movem.l	empty(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$666,d6		Fade background to black
.loop1	move.w	d6,$ffff8240.w
	bsr	delay
	sub.w	#$111,d6
	bpl.s	.loop1
	endc

	ifne	text_on		; Print text
	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifne	fade_on
	move.w	#$111,d6		Fade text to white
.loop2	move.w	d6,$ffff825e.w
	bsr	delay
	add.w	#$111,d6
	cmp.w	#$888,d6
	bne.s	.loop2
	endc

k_loop	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	ifne	music_on
;	lea	old_70(pc),a0
	move.l	old_70(pc),$4d2.w
	move.w	#0,d0
	lea	music(pc),a0
          jsr	(a0)
	endc

	bset	#0,$484.w

	ifne	low_res
oldrez	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc
          rts

	lea	old_sp(pc),a0
	move.l	(a0),-(sp)
	move.w	#$20,-(sp)
	trap	#1		; user mode
	addq.l	#6,sp

proggy	lea	packed(pc),a3	; start of packed file in a3

* a3 is pointing to start of depacked program

	move.l	2(a3),a0		text segment
	add.l	6(a3),a0		+ data segment
	add.l	14(a3),a0		+ symbol table
	lea	28(a0),a0		+ header
	add.l	a3,a0		+ start of program
* a0 now points to relocation table
	move.l	8(a5),d0		d0 points to TEXT
	lea	28(a3),a3		a3 points to program
	move.l	a3,a6
	tst.l	(a0)		zero 1st relocation?
	beq.s	done_reloc

	moveq	#0,d1
	add.l	(a0)+,a3		+ offset
relocate	add.l	d0,(a3)		relocate it
add_no_reloc	move.b	(a0)+,d1		next byte
	beq.s	done_reloc		zero is end
	cmp.b	#1,d1		1 is add 254, but
	bne.s	not1		don't relocate
	lea	254(a3),a3
	bra.s	add_no_reloc
not1	add.l	d1,a3		+ offset
	bra.s	relocate

done_reloc	lea	packed+2(pc),a2	past $601a
	move.l	(a2),12(a5)		write real TEXT len
	add.l	(a2),d0		TEXT len + TEXT addr
	move.l	d0,16(a5)		write real DATA addr
	move.l	4(a2),20(a5)		write real DATA len
	add.l	4(a2),d0		+ DATA len
	move.l	d0,24(a5)		write real BSS addr
	move.l	8(a2),28(a5)		write real BSS len

* now move code somewhere safe
	move.l	sp,a0
	lea	-256(a0),a0
	pea	(a0)
	lea	mover(pc),a1
	moveq	#(endofmover-mover)/2-1,d0
copy_mover	move.w	(a1)+,(a0)+
	dbf	d0,copy_mover
	rts

* move the program down to the correct address
mover	move.l	12(a5),d0		TEXT len
	add.l	20(a5),d0		+ DATA len
	lsr.l	#1,d0		divide by 2
	addq.l	#1,d0		one for luck
	move.l	8(a5),a4		pointer to TEXT addr
	pea	(a4)		run address
copydown	move.w	(a6)+,(a4)+
	subq.l	#1,d0
	bne.s	copydown
	ifne	clr_bss
* clear the BSS
	move.l	28(a5),d1
	add.l	#(packed-start)+28,d1
	lsr.l	#2,d1		bug fixed...!
	addq.l	#1,d1
clrbss	move.l	d0,(a4)+
	subq.l	#1,d1
	bne.s	clrbss
	endc

* if you wish to modify part of your program file, but don't wish to repack
* it, you can put a piece of code like this at this point:
*	move.l	8(a5),a5	a5 now points to TEXT area of prog.
* now you can carry out modifications off (a5), etc. such as:
*	move.w	#$4e71,20(a5)
* or whatever you want!

here
	ifne	pre_reg
	movem.l	start-128,d0-d7/a0-a6
	movem.l	d0-d7/a0-a6,-(sp)
	lea	start-128,a0
	moveq	#15-1,d0
clregs	clr.l	(a0)+
	dbf	d0,clregs
	movem.l	(sp)+,d0-d7/a0-a6
	endc
	rts			run the program
endofmover
	

	ifne	fade_on
delay	moveq	#7,d7		Delay used in fading colours
.1	move.w	#$25,-(a7)	Wait for VBL
	trap	#14
	addq.l	#2,a7
	dbf	d7,.1
	rts

empty	ds.w	16
	even
	endc
;
; Variables and stuff
;

	ifne	text_on
text	dc.b	27,"E"	; CLS
	dc.b	27,"f"	; Hide cursor
;
; Text Message goes here
;
	;	 0123456789012345678901234567890123456789 ; 40 chars

	dc.b	"****************************************",13,10
	dc.b	"*               TESERAE+               *",13,10
	dc.b	"*               --------               *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"*              Trained by              *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"*       MUG U.K  (of The Source)       *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"* During the game, press the '+' & '-' *",13,10
	dc.b	"* keys to increase or decrease the     *",13,10
	dc.b	"* current level !!  I've also fixed a  *",13,10
	dc.b	"* bug in that the speed of the blocks  *",13,10
	dc.b	"* from the previous game was not reset *",13,10
	dc.b	"* to that of Level 1 !!                *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"****************************************",13,10,10
	dc.b	0
	even
	endc


	ifne	music_on

new_vbl	movem.l	d0-a6,-(sp)
	lea	music+4(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rts

music	incbin	'd:\musichak.mug\j_buggin\ride_sky.acf'
	even

old_70	ds.l	1

	endc

old_sp	ds.l	1

;
; the packed exec file goes here
;
packed	incbin	"d:\teserae.prg"
endoffile	even
