*****************************************************************
* Persistence Of Vision menu 12
* ----------------------------
*
* Written by MAC SYS DATA 23-1-90
*              Finished :
* Version 2 repacked SPHERES on 6/12/92
*****************************************************************
	opt	o+,w-

WIDTH		equ	16	;pixels wide for letters
BUFFER_SIZE	equ	128	;one character

begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start
	move.l	#bssend-bssstart,d0
	lea	bssstart,a0
.clear	clr.b	(a0)+
	sub.l	#1,d0
	bne.s	.clear

	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

		bsr	super_mode
		move.b	#$12,$fffffc02.w
		bsr	get_scr_base
		bsr	get_res
		bsr	save_palette
		bsr	low_res
		bsr	set_palette
		or.b	#$2,$ffff820a.w		;go into 50Hz


;************************************************************************
;*                            XENON 2                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 03/01/90 13:48                     *
;*      From: AUTOMATION disc 156                                       *
;* Include files:-                                                      *
;*                 AUTO156.IMG into TUNE                                *
;************************************************************************
		move.b	$484.w,old484
		move.b	#2,$484.w	;off with keyclick/bell


; There is only one tune in this code....

		moveq	#0,d0
		jsr	tune
		move.l	#tune+$e,$4d6.w	;use VBL to play tune

		bsr	show_picture
		bsr	clear_buffer

main_loop	bsr	vsync
;	move.w	#$123,$ffff8240.w
		bsr	printp
		bsr	printo
		bsr	printv
		bsr	scroll
		bsr	scroll
		bsr	scroll
; 	move.w	pic+2,$ffff8240.w
		bsr	check_key
		tst.l	d0
		beq.s	main_loop

		move.w	#$ff,-(sp)
		move.w	#6,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.l	d0
		beq.s	main_loop
	
	cmp.b	#$30,d0		;0 key
	bne.s	not_zero
	eor.b	#$2,$ff820a
	bra.s	main_loop
not_zero:
	cmp.b	#27,d0
	beq.s	ex
	cmp.b	#$31,d0		;1 key
	blt.s	main_loop
	cmp.b	#$36,d0		;6 key
	bge.s	main_loop	
	jsr	endmus

	jsr	clear_screen
	clr.w	$ffff8240.w
	move.w	#$FFF,$ffff825e.w
	move.b	old484,$484
	move.l	org_base,$44e.w

;key is in D0.L
	lea	filenames,a6
	sub.b	#$31,d0
	mulu	#14,d0
	add.w	d0,a6

	move.l	org_base,screen_base
	bsr	org_res
	lea	$200.w,a2
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a2)
	bsr	user_mode
	bra	exec

ex	jsr	endmus
	move.b	old484,$484.w
	bsr	org_res
	bsr	restore_palette
	move.b	#$8,$fffffc02.w
	bsr	user_mode

	clr.w	-(sp)
	trap	#1



***************
* Subroutines *
***************

scroll	move.l	line_ptr,a6	;need a new letter?
	cmp.b	#$ff,(a6)
	bne	.loop3
	lea	scroll_line,a6	;restart message
.loop3	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lsl.w	#7,d0	;*128
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6),(a1)

loop2:	move.l	screen_base,a6
	add.l	#32000-(17*160),a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling

	move.w	#16-1,d1
loop	roxl.w	(a1)
	move.w	(a1),d0
	and.w	#1,d0
	or.w	d0,(a2)

	roxl.w	2(a1)
	move.w	2(a1),d0
	and.w	#1,d0
	or.w	d0,2(a2)

	roxl.w	4(a1)
	move.w	4(a1),d0
	and.w	#1,d0
	or.w	d0,4(a2)

	roxl.w	6(a1)
	move.w	6(a1),d0
	and.w	#1,d0
	or.w	d0,6(a2)

	addq.l	#8,a1
	add.l	#160,a2
	dbf	d1,loop

	move.w	#4-1,d1		;4 planes of screen.
shift:	move.w	#16-1,d0
loopy:	roxl.w	152(a6)
	roxl.w	144(a6)
	roxl.w	136(a6)
	roxl.w	128(a6)
	roxl.w	120(a6)
	roxl.w	112(a6)
	roxl.w	104(a6)
	roxl.w	96(a6)
	roxl.w	88(a6)
	roxl.w	80(a6)
	roxl.w	72(a6)
	roxl.w	64(a6)
	roxl.w	56(a6)
	roxl.w	48(a6)
	roxl.w	40(a6)
	roxl.w	32(a6)
	roxl.w	24(a6)
	roxl.w	16(a6)
	roxl.w	8(a6)
	move.w	(a6),d7
	and.w	#$7fff,d7
	roxl.w	#1,d7
	move.w	d7,(a6)
	add.w	#160,a6
	dbf	d0,loopy
	sub.w	#160*16,a6
	add.w	#2,a6
	dbf	d1,shift
	sub.w	#1,scroll_number
	rts

; POV bouncy routine
printp:
	move.l	pdata,a0
	cmp.b	#$ff,(a0)
	bne.s	no_prst
	lea	ptable,a0
	move.l	a0,pdata
no_prst:
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,pdata
	clr.l	d1
	lea	images,a1
	bra.s	common_prt

printo:
	move.l	odata,a0
	cmp.b	#$ff,(a0)
	bne.s	no_orst
	lea	otable,a0
	move.l	a0,odata
no_orst:
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,odata
	move.l	#160*30,d1
	lea	images+(24*25),a1
	bra.s	common_prt

printv:
	move.l	vdata,a0
	cmp.b	#$ff,(a0)
	bne.s	no_vrst
	lea	vtable,a0
	move.l	a0,vdata
no_vrst:
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,vdata
	move.l	#160*60,d1
	lea	images+(24*50),a1

common_prt:
	move.l	screen_base,a0
	add.l	#8*16+(160*80),a0
	mulu	#24*75,d0
	add.l	d0,a1
	add.l	d1,a0		;offset for each letter
	bsr	print_image
	rts

print_image:
	move.w	#25-1,d7
.loop:	movem.l	(a1),d0/d1/d2/d3/d4/d5
	movem.l	d0/d1/d2/d3/d4/d5,(a0)
	add.w	#24,a1
	add.w	#160,a0
	dbf	d7,.loop
	rts

vsync:	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

clear_buffer	bsr	check_key
		tst.l	d0
		beq.s	.rts
		move.w	#$ff,-(sp)
		move.w	#6,-(sp)
		trap	#1
		addq.l	#4,sp
		bra.s	clear_buffer
.rts		rts

check_key	move.w	#11,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

show_picture	lea	pic+34,a0
		move.l	a0,a2
		add.w	#16000,a0
		add.w	#16000,a2
		move.l	screen_base,a1
		move.l	a1,a3
		add.w	#16000,a1
		add.w	#16000,a3
		move.w	#200-1,d7
lines		move.w	#20-1,d6
words		move.l	(a0)+,(a1)+
		move.l	-(a2),-(a3)
		bsr	delay
		dbf	d6,words
		dbf	d7,lines
		rts

delay		move.w	d0,-(sp)
		move.w	#100,d0
del		nop
		dbf	d0,del
		move.w	(sp)+,d0
		rts

endmus:	clr.l	$4d6
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
	rts

wait_for_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_scr_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,org_base

		move.l	#screen,d0
		clr.b	d0
		move.l	d0,screen_base
		rts

super_mode	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,save_stk
		rts

user_mode	move.l	save_stk,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

save_palette	movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette
		rts

restore_palette	movem.l	old_palette,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

set_palette	movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

get_res		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,old_rez
		rts

low_res		clr.w	d0
		bra.s	change_res
med_res		moveq	#1,d0
		bra.s	change_res
org_res		move.w	old_rez,d0
change_res	move.w	d0,-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts


clear_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	screen_base,a0
	move.w	#32000/4-1,d0
.loop:	clr.l	(a0)+
	dbf	d0,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts

pause:	move.l	d0,-(sp)
	move.w	#100,d0
pau:	bsr	vsync
	dbf	d0,pau
	move.l	(sp)+,d0
	rts

cls:	pea	cls_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
cls_mess
	dc.b	27,'E',0
	even
********
* Data *
********
scroll_number	dc.w	16
line_ptr	dc.l	scroll_line
	even

save_stk	dc.l	0



scroll_line:
 dc.b "PERSISTENCE OF VISION DISC 12 V2.     ORIGINALLY RELEASED 18/02/90  "
 dc.b "VERSION 2 (HALF MEG VERSION) RELEASED 6/12/92.    NOTE: I HAVE LEFT "
 dc.b "THE ORIGINAL SCROLL TEXT IN HERE SO DON'T EXPECT ANYTHING NEW.....  OH "
 dc.b "YEAH, THE DEMO CLUB DIED YEARS AGO, IF YOU WANT A POV CONTACT "
 DC.B "BART AT TOWER PD (SEE ST-FORMAT FOR THE ADDRESS).           "
 dc.b "ALL CODING/HACKING/PACKING BY MAC SYS DATA.     MUSIC RIPPED FROM XENON II BY MAC SYS DATA. "
 dc.b "     GREETS TO .. BASHER,  TCB,  NIEL OF COR BLIMEY,  VAPOUR,  GEORGE,  ALAN R.  AND  THE LOST BOYS.          "
 dc.b " I HAVE JUST RECEIVED 20 DISCS OF DEMOS FROM GEORGE MY NEW SUPPLIER, SO KEEP A LOOK OUT FOR A FLOOD OF "
 DC.B "P.O.V. DISCS REAL SOON.          YOU MAY BE INTERESTED TO KNOW THAT BORIS HAS STARTED WORK ON DISC 7!     YES "
 DC.B "MY CONSTANT SLAGGING HIM OFF HAS REPAID WITH HIM ACTUALLY DOING SOMETHING, ALL HE NEEDS NOW IS SOME "
 DC.B "DEMOS TO PUT ON IT.                   INFO:  DUE TO A RECENT CONTACT WE CAN NOW GIVE DETAILS OF A PD "
 DC.B "CLUB THAT DISTRIBUTES OUR DISCS, YOU CAN GET THEM FROM 'COMPUTER CONNECTIONS', THEY ADVERTISE IN "
 DC.B "ST USER.  -  HEY BRIAN, YOU'RE FAMOUS!!  THE CLUB HAS A SMALL COLLECTION OF DEMOS/UTILITIES AND GAMES WHICH "
 DC.B "GROWS BY THE HOUR, SO HAVE A LOOK IN ST USER FOR THE ADDRESS.        "
 dc.b "BYE...                                           "
 DC.B "      ..........> "
	dc.b	$ff
	even
pic	incbin	"pov12.pi1"


font	dc.w	0,0,0
	incbin	"pov11set.dat"


tune	incbin	"XENON2.img"
	even
filenames	dc.b	"STINGRAY.RUN",0,0
		dc.b	"TRANS.RUN",0,0,0,0,0
		dc.b	"SPHERES.MSD",0,0,0
		dc.b	"DOCII.MSD",0,0,0,0,0
		dc.b	"COPIER.POV",0,0,0,0

pdata		dc.l	ptable
odata		dc.l	otable
vdata		dc.l	vtable

images:		incbin	"pov.dat"

ptable:
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14

	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
;********************************************************
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,15,15,15,15,15,15

	dc.b	$ff,$ff
otable:
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14		;154
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dcb.b	0,154
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
;*************************************************************
	dc.b	15,15,15,15
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,15,15
	dc.b	$ff,$ff
vtable:
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dcb.b	0,154
	dcb.b	0,154
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14

	dc.b	15,15,14,13,11,9,7,4,1,0,1,4,7,9,11,13
	dc.b	14,13,11,9,7,4,1,0,1,4,7,9,11,12
	dc.b	13,12,11,9,7,4,1,0,1,4,7,9,11
	dc.b	12,11,9,7,4,1,0,1,4,7,9
	dc.b	11,10,9,7,4,1,0,1,4,7,9
	dc.b	10,9,8,6,3,0,3,6,8
	dc.b	9,8,7,5,3,0,3,5,7
	dc.b	8,7,6,4,2,0,2,4,6
	dc.b	7,6,5,3,1,0,1,3,5
	dc.b	6,5,4,2,0,2,4
	dc.b	5,4,3,1,0,1,3
	dc.b	4,3,2,0,2
	dc.b	3,2,0
	dc.b	2,1,0
	dc.b	1,0
	dcb.b	0,10
	dc.b	1,1,2,2,3,4,5,6,7,8,9,10,11,12,13,14
;***********************************************************
	dc.b	15,15,15,15,15,15,15,15
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b	$ff,$ff

	SECTION BSS
bssstart
old484		ds.w	1
org_base	ds.l	1
screen_base	ds.l	1
old_palette	ds.b	32
old_rez		ds.w	1


buffer		ds.b	BUFFER_SIZE

		ds.b	256
screen		ds.b	32000
bssend