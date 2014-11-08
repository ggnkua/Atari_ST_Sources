* EXEC HEADER FOR TRAINER OPTIONS
* -------------------------------
;
; This source code requires the original program to be UNPACKED
; if alterations are to be made.  Once assembled, you pack the
; trainer'd version !
;

no	equ	0
yes	equ	1

low_res	equ	yes	; Force Low Resolution 
med_res	equ	no	; Force Medium Resolution
pre_reg	equ	no	; Preserve registers
clr_bss	equ	yes	; Clear BSS segment (see above)

	opt	o+

	bra.s	start
	dc.b    "Repacked by MUG U.K",191," - mug_uk@mindless.com"
	dc.b    "- November 1997 :) "
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

	clr.w	$ffff8240.w
	move.w	#$777,$ffff825e.w

print	pea	text(pc)	; Bog standard print
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

; Infinite Lives ?

k_loop	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
;	swap	d0
;
;	cmp.b	#$15,d0		; Y pressed ?
;	bne.s	no_y
;
;        move.b	#$ff,packed+$e682+$1c    ; Infinite Lives
;
;	bra.s	x_loop
;no_y	cmp.b	#$31,d0		; N pressed
;	bne.s	k_loop
;x_loop


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
; Trainer Mode for B.D.T.A by MUG U.K(tm)
;
; Infinite Lives

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


;
; Variables and stuff
;

text	dc.b	27,"E"	; CLS
	dc.b	27,"f"	; Hide cursor
;
; Text Message goes here
;
	;	 01234567890123456789012345678901234567890123456789012345678901234567890123456789 ; 80 chars

	dc.b	27,"p"
	dc.b	"Better Dead Than Alien +",27,'q',13,10
	dc.b 	"------------------------",13,10,10

	dc.b	"Repacked by: MUG U.K",191,13,10,10

	dc.b	"No need for a trainer as there is one",13,10
	dc.b	"built-in!",13,10,10

	dc.b	"Type ELV to activate the cheat mode",13,10
	dc.b	"cheat mode and use F1 to F10 for the",13,10
	dc.b	"extra weapons etc.",13,10,10

	dc.b	"Thanks to Sewer Docs #3 for the cheat!",13,10,10

	dc.b   	"Hi to all on the Pacifist Mailing List.",13,10,10
	dc.b	0
	even

;
; the exec file goes here
;
packed  incbin  "bdta.exe"
endoffile
