




;-------------------------------------------------------------------------;
;       The following source code and art have been released by           ;
;       PERSISTENCE OF VISION for use by others for NON-Profit            ;
;   making purposes only. The code is supplied as is and no claim can     ;
;    be made against PERSISTENCE OF VISION for loses incured through      ;
;                    the use and/or missuse of it.                        ;
;                                                                         ;
;          All soundtracks are copyright of the original authors          ;
;-------------------------------------------------------------------------;
;
;                       This code was released on
;                         Persistence Of Vision
;                      Official Source Code Disc 1

******** POV 3 **********************
	opt	x+

	move.l	$4(a7),a5
	move.l	#$100,-(a7)
	move.l	a5,-(a7)
	move.l	#$4a0000,-(a7)
	trap	#1
	add.l	#12,sp
init:	equ	$A000		;A-LINE variables
hide_m:	equ	init+10
show_m:	equ	init+9

	dc.w	init
	dc.w	hide_m	;hide mouse
	
;set 68000 to supervisor mode
	clr.l	-(sp)		;Set super stack equal
	move.w	#32,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,STKSV	;save old supervisor stack value

	lea	$ff8240,a0
	move.w	#15,d0
clr_col	clr.w	(a0)+
	dbf	d0,clr_col

	MOVE.W	#3,-(SP)	GET SCREEN BASE
	TRAP	#14
	ADDQ.W	#2,SP
	MOVE.L	D0,SCR_ADD

	lea	PALETTE,A0
	move.W	#15,d0
	move.l	#$FF8240,A1
set_col:
	MOVE.W	(A0)+,(A1)+
	dbra	D0,set_col

	clr.w	-(SP)		;set rez
	move.l	SCR_ADD,D0
	MOVE.L	D0,-(SP)
	MOVE.L	D0,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.l	#12,SP

	lea 	eop(pc),a0	;end of compressed code
	move.l	SCR_ADD,a1	;destination
	bsr 	depak


;************************************************************************
;* QUADRALIEN tune by Dave Whittaker                                    *
;* Stolen by Mac Sys Data (M.S.D.) from the game 9/5/89 19:00           *
;* Include file;-                                                       *
;*               QUAD.IMG into TUNE                                     *
;************************************************************************
	clr.b 	$484		;no keyclick
	clr.l	d0		;2 tunes  0 or 1
	jsr	TUNE
	move.l	#TUNE+14,$4d2	;set ISR using V_VLANK table
	
START:	lea	MESS,A6
SCROLL:	move.b	(A6)+,D0
	cmp.b	#$FF,D0
	bne.s	OK
	cmp.b	#$FF,(A6)
	beq.s	START
OK:	and.l	#$FF,D0
	sub.b	#32,D0		;rid ourselves of ASCII chains
	mulu	#8,D0		;calc character offset
	lea	FONT,A1
	add.w	D0,A1
	lea	BUFFER,A2
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+

TEST:	tst.w	SYNC
	bne.s	DEC
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#2,SYNC
DEC:	sub.w	#1,SYNC
W_KEY:	move.l	#$600ff,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	D0
	bne.s	WAIT
CONT:	clr.l	D0
	lea	BUFFER,A5
	move.l	SCR_ADD,A0
	add.w	#160*189,A0
	moveq.l	#7,D7
LINES:	move.l	A0,-(sp)
	adda.l	#152,A0
	move.b	(A5),D1
	lsl.b	#1,D1
	move.b	D1,(A5)+
	moveq.l	#20-1,D6	;40 characters across scrn
COLUMN:	move.w	(A0),D1
	roxl.w	#1,D1		;scroll 2 chars at a time
	move.w	D1,(A0)
	move.w	D1,2(A0)
	move.w	D1,4(A0)
	move.w	D1,6(A0)
	subq.l	#8,A0	;move back a byte for next position on scrn
	dbf	D6,COLUMN
	movea.l	(sp)+,A0
	adda.l	#160,A0	;drop down a line
	dbra	D7,LINES
	addq.w	#1,D5
	andi.w	#7,D5	;test the buffer to see if empty?
	bne	TEST
	bra	SCROLL

;	Now wait for a sign from the user.
WAIT:	swap	d0
	cmp.b	#1,d0
	beq	esc
	blt.s	CONT
	cmp.b	#5,d0
	bgt.s	CONT
	bsr	endmus
	and.l	#$ff,d0
	sub.b	#2,d0
	move.l	d0,d7
	lea	fnames,a0
	mulu	#12,d7
	add.l	d7,a0

	move.l	a0,-(sp)
	clr.w	-(SP)		;set rez
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.l	#12,SP
	move.l	(sp)+,a0
	cmp.l	#xxx,a0
	bne.s	exe
	pea	xxxmes
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
;a0 points to f_name
exe	pea	laddr
	pea	laddr
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	tst.l	d0
ok	beq.s	ok
	bra.s	err
esc
	bsr.s	endmus
err
	dc.w	show_m	;show mouse

;set 68000 to user mode from supervisor
	move.l	STKSV,-(sp)	;recover old supervisor stack
	move.w	#32,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack

	MOVE.W	#$4c,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
endmus:	clr.l	$4d2
	lea	$FF8800,A0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	#$2,$484	
	rts
depak:	move.w	$ff8240,-(sp)
	move.l	-(a0),d1
	move.l	-(a0),d5
	move.l 	a1,a2
	adda.l 	d1,a2
	move.l 	-(a0),d0
	eor.l 	d0,d5
l1:	lsr.l 	#1,d0
	bne.s 	l2
	bsr 	l16
l2:	bcs.s 	l9
	moveq 	#8,d1
	moveq 	#1,d3
	lsr.l 	#1,d0
	bne.s 	l3
	bsr 	l16
l3:	bcs.s 	l11
	moveq 	#3,d1
	clr.w 	d4
l4:	bsr 	l17
	move.w 	d2,d3
	add.w 	d4,d3
l5:	moveq 	#7,d1
l6:	lsr.l 	#1,d0
	bne.s 	l7
	bsr 	l16
l7:	roxl.l 	#1,d2
	dbf 	d1,l6
	move.b 	d2,-(a2)
	dbf 	d3,l5
	bra.s 	l13
l8:	moveq 	#8,d1
	moveq 	#8,d4
	bra.s 	l4
l9:	moveq 	#2,d1
	bsr 	l17
	cmpi.b 	#2,d2
	blt.s 	l10
	cmpi.b 	#3,d2
	beq.s 	l8
	moveq 	#8,d1
	bsr.s 	l17
	move.w 	d2,d3
	move.w 	#12,d1
	bra.s 	l11
l10:	move.w 	#9,d1
	add.w 	d2,d1
	addq.w 	#2,d2
	move.w 	d2,d3
l11:	bsr.s 	l17
l12:	subq.w 	#1,a2
	move.b 	0(a2,d2.w),(a2)
	dbf 	d3,l12
l13:	move.w	d0,$ff8240
	cmpa.l 	a2,a1
	blt 	l1
	tst.l 	d5
	bne.s 	l14
fin	move.w	(sp)+,$ff8240
	rts
l14:	nop
l15:	moveq 	#1,d0
	rts
l16:	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
	rts
l17:	subq.w 	#1,d1
	clr.w	 d2
l18:	lsr.l 	#1,d0
	bne.s	 l19
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w	d0,$ff8240
	move.b 	#$10,ccr
	roxr.l 	#1,d0
l19:	roxl.l 	#1,d2
	dbf 	d1,l18
	rts

EVEN
STKSV:		dc.l	0
SCR_ADD:	dc.L	0
SYNC:		DC.W	0	;SYNC for vertical scrn update
	EVEN
PALETTE: DC.W      $000,$610,$620,$630,$744,$640,$750,$770
	 DC.W	   $555,$012,$023,$134,$245,$356,$467,$777
MESS:	dc.b	"WELCOME TO THE P.O.V. MENU 3.               "
	DC.B	" <<< INFO >>>       THE TUNE WAS RIPPED OUT OF QUADRALIEN BY M.S.D.,  "
	DC.B	"THE GRAFIX WERE DRAWN BY M.S.D.       THE CODING "
	DC.B	"WAS DONE BY M.S.D. (WHO ELSE IS THERE?)              "
	dc.b	"NOTE:- THIS DISC WAS RELEASED ON 26/5/89 00:24 FOR ALL YOU SINGLE "
	DC.B	"SIDED DISC DRIVE OWNERS.        THE DISC IS FORMATTED 80 TRACKS, 9 SECTORS "
	DC.B	"AND SINGLE SIDED.                    "
	dc.b	"  SCROLL TEXT HAS BEEN REMOVED FOR THIS VERSION.        "
	DC.B	"        THAT'S ALL FOR NOW.     BYE, BYE.          "
	DC.B	"                                      >> >> >>  ",$FF,$FF
xxxmes	dc.b	27,'E'
	dc.b	"        P.O.V. DECOMPRESSOR V1.3",13,10,10
	dc.b	"        XXX INTERNATIONAL DEMO 1",13,10,10,10
	dc.b	"     RE-COMPRESSED BY MAC SYS DATA",13,10,10,10,10,0
BUFFER:	ds.w	8
FONT:	ds.b	8
	incbin	"WAS_SET.IMG'
	even
TUNE:	incbin	"QUAD.IMG"	;load QUAD.IMG here
	EVEN
	incbin	"GARF.PIC"
eop
fnames	dc.b	'TEX_1.POV',0,0,0
	dc.b	'TEX_2.POV',0,0,0
	dc.b	'TEX_3.POV',0,0,0
xxx	dc.b	"XXX_DEM.POV",0
laddr
	EVEN