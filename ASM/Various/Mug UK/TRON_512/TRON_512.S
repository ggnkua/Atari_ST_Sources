* EXEC HEADER FOR TRAINER OPTIONS
* -------------------------------
*

no	equ	0
yes	equ	1

low_res	equ	no	; Force Low Resolution 
med_res	equ	yes	; Force Medium Resolution
pre_reg	equ	no	; Preserve registers
clr_bss	equ	no	; Clear BSS segment (see above)
fade_on	equ	yes	; Fade Colours In/Out (Low res)

	opt	o+

	bra.s	start
	dc.b	"A MUG U.K¿ Trainer - July 1st 1993 !!  "
	dc.b	"You can contact me at: 'Anncott', Hylas Lane, "
	dc.b	"Rhuddlan, Clwyd.  LL18 5AG ",13,10
	even

start
	ifne	pre_reg
	movem.l	d0-d7/a0-a6,start-128
	endc
	move.l	4(sp),a5		base page address
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)

	bclr	#0,$484.w

	ifne	low_res		; Low resolution
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	med_res		; Medium resolution
	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	fade_on
	move.w	#$666,d6		Fade background to black
.loop1	move.w	d6,$ffff8240.w
	bsr	delay
	sub.w	#$111,d6
	bpl.s	.loop1
	clr.w	$ffff8246.w
	endc

print	pea	text(pc)	; Bog standard print
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	ifne	fade_on
	move.w	#$111,d6		Fade text to white
.loop2	move.w	d6,$ffff8246.w
	bsr	delay
	add.w	#$111,d6
	cmp.w	#$888,d6
	bne.s	.loop2
	endc

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

; Infinite Lives

	pea	text1(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

k_loop	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0

	cmp.b	#$15,d0		; Y pressed ?
	bne.s	no_y
	move.w	#$4a79,packed+$1c+$b72 ; infinite lives
	bra.s	x_loop
no_y	cmp.b	#$31,d0		; N pressed
	bne.s	k_loop
x_loop

	trap	#1		; user mode
	addq.l	#6,sp

	lea	packed,a3	; start of packed file in a3

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

;
; Trainer Mode for Abombinaball by MUG U.K
;

alter_me	move.l	8(a5),a5		; points to TEXT area of program
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
	endc

;
; Variables and stuff
;

text	dc.b	27,"E"	; CLS
	dc.b	27,"f"	; Hide cursor
;
; Text Message goes here
;
	;	 01234567890123456789012345678901234567890123456789012345678901234567890123456789 ; 80 chars

	dc.b	"              ",27,"pLLAMATRON 512K - Trained by MUG U.K¿ on July 1st 1993",27,'q',13,10,10
	
	dc.b	"Well, why have I taken so long to train this brilliant game ?  Simple answer is",13,10
	dc.b	"that I've never bothered to look at it before now !",13,10,10
	
	dc.b	"I have done this trainer especially for Adrenalin because they asked me for as",13,10
	dc.b	"as many trained PD games as I could get hold of for their legal PD compacts !",13,10,10

	dc.b	"It was one of the easiest games I've ever trained (with the exception of the",13,10
	dc.b	"games where the programmer has kindly left the labels in!) as all that was",13,10
	dc.b	"required was a 'SUBQ.W' changing to a 'TST.W' !!  See, with my trainers you",13,10
	dc.b	"get a free lesson in how NOT to train a PD game !!",13,10,10

	dc.b	"Press any key for the trainer options !!",13,10
	dc.b	0
	even

text1	dc.b	27,'E'
	dc.b	"+------------------------------------------------------------------------------+",13,10
	dc.b	"|                                                                              |",13,10
	dc.b	"|              LLAMTRON 512 - Trained by MUG U.K¿ on July 1st 1993             |",13,10
	dc.b	"|                                                                              |",13,10
	dc.b	"+------------------------------------------------------------------------------+",13,10,10

	dc.b	"Do you want infinite lives ? (Y/N)",13,10,10
	dc.b	0
	even

;
; the exec file goes here
;
packed	incbin	"tron_512.exe"
endoffile
