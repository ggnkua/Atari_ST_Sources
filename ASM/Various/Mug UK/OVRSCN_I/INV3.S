; Bolt-on Type Trainer
; --------------------
;
; Set TABS to 14 for a readable listing
;
;------------------------------------------------------------------------
; As used on numerous occasions by Mike Mee, under my pseudonym of
; MUG U.K(tm).
;
; The majority of the following code was written by JPM/Pompey Pirates
; It is based on his executable header code as included with his
; Pompey Pirates Packer v1.9 - seeing as this group and the coders 
; are no longer on the Atari ST/E and have moved to the PC, I have
; assumed that this source is public domain.
;
; Released as a part of an article on training games which appeared in
; ST Applications, 1994.
; -----------------------------------------------------------------------
;
; Handy hex numbers ....
;
; $5279	=	replace a SUBI.x ($5379) with an ADDI.x !!
; $4a39	=	replace a SUBI.x ($5379) with a TST.x !!
; $60xx	=	used to jump past code
; -----------------------------------------------------------------------

no	equ	0
yes	equ	1

pre_reg	equ	no	; Preserve registers
clr_bss	equ	no	; Clear BSS segment

low_res	equ	yes	; Force Low Resolution 
med_res	equ	no	; Force Medium Resolution
fade_on	equ	yes	; Fade Colours In/Out (Low res)

	opt	o+,p+	; Optimize code on & PC-relative on

	bra.s	start
	dc.b	"A MUG U.K¿ Trainer - sometime in 1994"
	even

start
	ifne	pre_reg
	movem.l	d0-d7/a0-a6,start-128
	endc

	move.l	4(sp),a5	;Base page address

	clr.l	-(sp)	;Supervisor mode
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)

	bclr	#0,$484.w	; Silence keyclick

	ifne	low_res	; Low resolution option
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	med_res	; Medium resolution option
	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	fade_on
	lea	oldpal(pc),a0
	movem.l	$ffff8240.w,d0-d7	; Store old palette
	movem.l	d0-d7,(a0)

	lea	newpal(pc),a0	; Set up new palette
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	endc

	ifne	fade_on	; Fade background to black option
	move.w	#$666,d6
.loop1	move.w	d6,$ffff8240.w
	bsr	delay
	sub.w	#$111,d6
	bpl.s	.loop1
	clr.w	$ffff8246.w
	endc

print	pea	text(pc)	; GEMDOS print
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	ifne	fade_on	; Fade text to white option
	move.w	#$111,d6
.loop2	move.w	d6,$ffff8246.w
	bsr	delay
	add.w	#$111,d6
	cmp.w	#$888,d6
	bne.s	.loop2
	endc

	move.w	#7,-(sp)	; Wait for a key press
	trap	#1
	addq.l	#2,sp

; Infinite Lives

	pea	text2(pc)	; GEMDOS print
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

k_loop	move.w	#7,-(sp)	; Get key press
	trap	#1
	addq.l	#2,sp
	swap	d0

; Check for Y or N, if neither pressed, keyboard is re-read

	cmp.b	#$15,d0	; Y pressed ?
	bne.s	no_y

	lea	packed(pc),a0	; Start address of game
	add.l	#$1c,a0	; Jump past Program, Data 
			; & BSS segments etc. (28 bytes)
;
; All 3 trainer options are included here
;
; #1 - Changes the 'SUBQ.B #1,lives' into a 'TST.B lives'
; #2 - Changes the 'SUBQ.B #1,lives' into a 'ADDQ.W #1,lives'
; #3 - Changes the 'SUBQ.B #1,lives' into a 'BRA address'
;
; Just remove the ; lines to make the correct trainer mode appear
;
; Trainer #1
	move.w	#$4a39,$453e(a0)
	move.w	#$4a39,$5244(a0)
;
; Trainer #2
;
;	move.w	#$5279,$3fe(a0)
;
; Trainer #3
;	move.l	#$60084d55,$3fe(a0)	; infinite lives patch + 'MU'
;	move.l	#$4720554b,$402(a0)	; 'G UK'
;	move.w	#$bf00,$406(a0) 	; 'tm'
;
; Continue with rest of code from here on
;
	bra.s	x_loop

no_y	cmp.b	#$31,d0	; N pressed
	bne.s	k_loop	; Y or N *NOT* pressed
x_loop


	ifne	fade_on
	lea	oldpal(pc),a0
	movem.l	(a0)+,d0-d7		; Restore old palette
	movem.l	d0-d7,$ffff8240.w
	endc

	trap	#1	; Back into User mode
	addq.l	#6,sp

;
; Start to relocate game back to load address of trainer code.
;
; All comments from here on are by JPM/Pompey Pirates - much too
; technical coding here for me to understand !
;

	lea	packed(pc),a3	; start of packed file in a3

* a3 is pointing to start of depacked program

	move.l	2(a3),a0	; text segment
	add.l	6(a3),a0	; + data segment
	add.l	14(a3),a0	; + symbol table
	lea	28(a0),a0	; + header
	add.l	a3,a0	; + start of program
* a0 now points to relocation table
	move.l	8(a5),d0	; d0 points to TEXT
	lea	28(a3),a3	; a3 points to program
	move.l	a3,a6
	tst.l	(a0)	; zero 1st relocation?
	beq.s	done_reloc

	moveq	#0,d1
	add.l	(a0)+,a3	; + offset
relocate	add.l	d0,(a3)	; relocate it
add_no_reloc	move.b	(a0)+,d1	; next byte
	beq.s	done_reloc	; zero is end
	cmp.b	#1,d1	; 1 is add 254, but
	bne.s	not1	; don't relocate
	lea	254(a3),a3
	bra.s	add_no_reloc
not1	add.l	d1,a3	; + offset
	bra.s	relocate

done_reloc	lea	packed+2(pc),a2 ; past $601a
	move.l	(a2),12(a5)	  ; write real TEXT len
	add.l	(a2),d0	  ; TEXT len + TEXT addr
	move.l	d0,16(a5)	  ; write real DATA addr
	move.l	4(a2),20(a5)	  ; write real DATA len
	add.l	4(a2),d0	  ; + DATA len
	move.l	d0,24(a5)	  ; write real BSS addr
	move.l	8(a2),28(a5)	  ; write real BSS len

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
mover	move.l	12(a5),d0	; TEXT len
	add.l	20(a5),d0	; + DATA len
	lsr.l	#1,d0	; divide by 2
	addq.l	#1,d0	; one for luck
	move.l	8(a5),a4	; pointer to TEXT addr
	pea	(a4)	; run address
copydown	move.w	(a6)+,(a4)+
	subq.l	#1,d0
	bne.s	copydown

	ifne	clr_bss	; clear the BSS
	move.l	28(a5),d1
	add.l	#(packed-start)+28,d1
	lsr.l	#2,d1	; bug fixed...!
	addq.l	#1,d1
clrbss	move.l	d0,(a4)+
	subq.l	#1,d1
	bne.s	clrbss
	endc

; If you wish to modify part of your program file, but don't wish to repack
; it, you can put a piece of code like this at this point:
;	move.l	8(a5),a5	a5 now points to TEXT area of prog.
; now you can carry out modifications off (a5), etc. such as:
;	move.w	#$4e71,20(a5)
; or whatever you want!

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
; Routine used in fade routine to slow down fading
;

	ifne	fade_on
delay	moveq	#7,d7	; Delay used in fading colours
.1	move.w	#$25,-(a7)	; Wait for VBL
	trap	#14
	addq.l	#2,a7
	dbf	d7,.1
	rts

oldpal	ds.w	16

newpal	dc.w	$000
	dc.w	$111
	dc.w	$222
	dc.w	$777	; White med rez text
	dc.w	$444
	dc.w	$555
	dc.w	$666
	dc.w	$777
	ds.w	7	; 7 words of 0 bytes
	dc.w	$777	; White low rez text
	endc

;
; Text message & variables - Numbers below are columns on Low rez screen
;
;		 01234567890123456789012345678901234567890

text	dc.b	27,'E'
	dc.b	13,10,10,10,10,10,10
	dc.b	"  __     __   __ __   _____   __  __ __ ",13,10
	dc.b	" /  \   /  \ / | | \ /  _  | / | | |/ / ",13,10
	dc.b	" |   \_/   | | |_| | | |_| | | |_|   (  ",13,10
	dc.b	" |  |\_/|  | |_____| \____ | |     |\ | ",13,10
	dc.b	" |  |   |  |  _          | | \_____/| | ",13,10
	dc.b	" |  |   |  | / \_________/ /        | | ",13,10
	dc.b	" \__|   |__/ \____________/         |_/ ",13,10,10

	dc.b	"                           Art by ()rm ",13,10
	dc.b	13,10,10
	dc.b	"            Press any key ..........    ",13,10
	dc.b	0
	even

text2	dc.b	27,'E'
	dc.b	"+--------------------------------------+",13,10
	dc.b	"|                                      |",13,10
	dc.b	"|          Overscan Invaders           |",13,10
	dc.b	"|                                      |",13,10
	dc.b	"|         Trained by MUG U.K¿          |",13,10
	dc.b	"|                                      |",13,10
	dc.b	"+--------------------------------------+",13,10
	dc.b	"| This program is weird !  When packed |",13,10
	dc.b	"| its' title page appears OK, as soon  |",13,10
	dc.b	"| as it is in an unpacked state, there |",13,10
	dc.b	"| is a corrupt title page .....        |",13,10
	dc.b	"|                                      |",13,10
	dc.b	"| Not being fluent in 68000, I've got  |",13,10
	dc.b	"| no idea whatsoever why this occurs!  |",13,10
	dc.b	"+--------------------------------------+",13,10
	dc.b	10,10,10

	dc.b	"Do you want infinite lives ? (Y/N)",13,10,10
	dc.b	0
	even

;
; The game file goes here
;

packed	incbin	"invader3.prg"
endoffile
