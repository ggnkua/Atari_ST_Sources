* EXEC HEADER FOR EXEC FILES PACKED WITH ATOMIC PACKER v3.5
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
* Clearbss can be turned off using NO to save a couple of bytes if your
* packed program has no BSS area.

no	equ	0
yes	equ	1

low_res	equ	no	; Force Low Resolution 
text_on	equ	yes	; Print Text
wait_on	equ	yes	; Wait for key
pre_reg	equ	no	; Preserve registers
clr_bss	equ	yes	; Clear BSS segment (see above)
flash	equ	yes	; Flash depack colours
fade_on	equ	yes	; Fade Colours In/Out (Low res)

	opt	o+

start
	ifne	pre_reg
	movem.l	d0-d7/a0-a6,start-128
	endc
	move.l	4(sp),a5		base page address
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)

	ifne	low_res		; Low resolution
	clr.w	-(sp)
	pea	-1
	pea	-1
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

wait	ifne	wait_on		; Wait for keypress
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

	ifne	flash		; Store border colour
	lea	store(pc),a0
	move.w	$ff8240,(a0)
	endc

	lea	packedfile,a0	; go past ATOM header


;----------------------------------------------------	
* UNPACK source SPACKER 2.0/FIREHAWKS	* SUPERVISER Mode (Flash)
* ---------------------------------------------------------------
* In	a0: ^ source buffer
* Out	d0: original length or 0 if not SP20 packed
* ===============================================================

depack	movem.l	d1-a6,-(sp)
	clr.l	-(sp)
	cmp.l	#'SP20',(a0)+
	bne.s	sp2_05
	tst.w	(a0)
	bne.s	sp2_05
	move.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(sp)
	tst.w	d5
	beq.s	sp2_01
	swap	d5
	btst	#1,$FFFF8260.W
	bne.s	sp2_01
	lea	$FFFF8240.W,a5
	move.w	(a5),d5
	swap	d5
sp2_01:	lea	64(a0),a1
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a1
	move.l	a1,a3
	move.l	sp,a6
	moveq	#79,d0
sp2_02:	move.b	-(a3),-(a6)
	dbf	d0,sp2_02
	exg.l	a6,sp
	bsr.s	sp2_06
	lea	-80(a1),a3
	move.l	(a6),d0
sp2_03:	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	sp2_03
	exg.l	a6,sp
	moveq	#79,d0
sp2_04:	move.b	(a6)+,(a3)+
	dbf	d0,sp2_04
sp2_05:	movem.l	(sp)+,d0-a6
	rts	
sp2_06:	moveq	#0,d6
	moveq	#1,d7
	lea	sp2_38(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
sp2_07:	add.l	d0,d0
	bne.s	sp2_08
	jsr	(a3)
sp2_08:	bcs.s	sp2_24
	move.b	-(a0),d1
	bra.s	sp2_13
sp2_09:	moveq	#2,d2
	bsr.s	sp2_16
	move.l	d6,d1
	bset	d2,d1
	bra.s	sp2_13
sp2_10:	add.l	d0,d0
	bne.s	sp2_11
	jsr	(a3)
sp2_11:	bcs	sp2_33
	moveq	#3,d2
	bsr.s	sp2_16
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	sp2_12
	not.w	d2
sp2_12:	move.b	(a1),d1
	add.w	d2,d1
sp2_13:	move.b	d1,-(a1)
	clr.w	(a5)
sp2_14: cmp.l	a1,a2
	bne.s	sp2_07
	swap	d5
	move.w	d5,(a5)
	rts
sp2_15:	move.l	d7,d2
sp2_16:	move.l	d6,d1
sp2_17:	add.l	d0,d0
	bne.s	sp2_18
	jsr	(a3)
sp2_18:	addx	d1,d1

	ifne	flash		;flash
	not.w	$ffff8240.w
	not.w	$ffff8240.w
	endc

	dbf	d2,sp2_17
sp2_19:	move.l	d1,d2
	rts
sp2_20:	bsr.s	sp2_15
sp2_21:	beq.s	sp2_22
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	sp2_19
sp2_22:	add.w	d7,d2
	add.w	d2,d2
sp2_23:	add.w	d2,d2
	sub.w	d7,d2
	bra.s	sp2_17
sp2_24:	add.l	d0,d0
	bne.s	sp2_25
	jsr	(a3)
sp2_25:	bcs.s	sp2_27
	add.l	d0,d0
	bne.s	sp2_26
	jsr	(a3)
sp2_26:	bcs.s	sp2_10
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	sp2_36
sp2_27:	add.l	d0,d0
	bne.s	sp2_28
	jsr	(a3)
sp2_28:	bcs.s	sp2_29
	bsr.s	sp2_15
	beq.s	sp2_13
	moveq	#1,d3
	bra.s	sp2_35
sp2_29:	add.l	d0,d0
	bne.s	sp2_30
	jsr	(a3)
sp2_30:	bcs	sp2_09
	add.l	d0,d0
	bne.s	sp2_31
	jsr	(a3)
sp2_31:	bcs.s	sp2_32
	bsr.s	sp2_15
	beq.s	sp2_12
	moveq	#2,d3
	bra.s	sp2_35
sp2_32:	moveq	#3,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_33:	bsr.s	sp2_15
	beq.s	sp2_34
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	sp2_23
	move.l	d2,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_34:	bsr.s	sp2_20
	not.l	d1
	move.l	d2,d3
	bra.s	sp2_36
sp2_35:	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	sp2_21
sp2_36:	move.l	a1,a4
	addq.l	#2,a4
	add.l	d1,a4
	add.l	d3,a4
	move.b	-(a4),-(a1)
sp2_37:	move.b	-(a4),-(a1)
	dbf	d3,sp2_37
	move.w	d5,(a5)
	bra	sp2_14
sp2_38:	move.w	a0,d4
	btst	d6,d4
	bne.s	sp2_39
	move.l	-(a0),d0
	addx.l	d0,d0
	rts
sp2_39:	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts
;----------------------------------------------------
sort_it_out

	ifne	flash
	move.w	store(pc),$ff8240
	endc

	trap	#1		; user mode
	addq.l	#6,sp

	lea	packedfile,a3	; start of packed file in a3

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

done_reloc	lea	packedfile+2(pc),a2	past $601a
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
	add.l	#(packedfile-start)+28,d1
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
; Text Message goes here
;
	ifne	flash
store	ds.w	1
	endc

	ifne	text_on
text	dc.b	27,'E'
		dc.b	27,'f',1
		dc.b	27,'Y',32+04,32+((40-(line1end-line1))/2)

line1:
	dc.b	"ADRENALIN U.K. OF T.B.A. PRESENTS"
line1end:

		dc.b	27,'f',2
		dc.b	27,'Y',32+08,32+((40-(line2end-line2))/2)
line2:
	dc.b	"CENTIPEDE"
line2end:
		dc.b	27,'f',3
		dc.b	27,'Y',32+12,32+((40-(line3end-line3))/2)
line3:
	dc.b	"DEPACKED AND RE-PACKED BY MOOKIE"
line3end:
		dc.b	27,'f',4
		dc.b	27,'Y',32+16,32+((40-(line4end-line4))/2)
line4:
	dc.b	"I LOOK AT YOU THEN AT ME"
line4end:
		dc.b	27,'f',5
		dc.b	27,'Y',32+17,32+((40-(line5end-line5))/2)
line5:
	dc.b	"THERE IS NO DIFFERENCE I CAN SEE"
line5end:
		dc.b	27,'f',6
		dc.b	27,'Y',32+19,32+((40-(line6end-line6))/2)
line6:
	dc.b	"D.R.I. 'EQUAL PEOPLE'"
line6end:
		dc.b	27,'f',7
		dc.b	27,'Y',32+23,32+((40-(line7end-line7))/2)
line7:
	dc.b	"PRESS ANY KEY TO CONTINUE."
line7end:
	dc.b	0	
	endc
;
; the packed exec file goes here
;
packedfile	incbin	"kid_gp.dat"
endoffile		even