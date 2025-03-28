




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

***********************************
*              POV 26             *
*              ------             *
* Written by                      *
*           MAC SYS DATA          *
*             28-6-90             *
***********************************
; Special menu with ISR driven scrolline

BUFFER_SIZE:	EQU	17*4
WIDTH:		EQU	25


**
** NOTE:	THIS MENU WAS WRITTEN FOR AUTORUN 4 SO IT WILL NOT P_EXEC
**	  	YOUR PROGRAM FROM HERE.
**		(that means it will not run your program from here!)
**		To make it work, put AUTORUN4.PRG in your AUTO folder
**		after this menu.
**

		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
clear_bss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss


		bsr	set_super

wait_for_drive	tst.w	$43e
		bne.s	wait_for_drive

		bsr	hide_cursor
		bsr	save_pal
		bsr	set_palette
		bsr	get_base
		move.l	#screen,d0
		clr.b	d0
		move.l	d0,new_base

		move.l	d0,a0		;screen_base
		bsr	set_low_rez

		bsr	set_for_border

*************************************************************************
* play RAMPAGE music (C) MSD 1989                                       *
* Other files needed;-                                                  *
*                     RAMPAGE.IMG into TUNE                             *
* Stolen from the GIGABYTE CREW in '88                                  *
*************************************************************************

	move.b	$484,old484
	move.b	#2,$484		;no sound from IKBD
	bsr	set_chip

; 0=normal tune
; 1=hi score?
	move.l	#1,D0
	bsr	tune

	bsr	transfer

		move.w	#$ffff,horiz_sync
main_loop	tst.w	horiz_sync
		bne	main_loop

		MOVE.W	#$FFFF,horiz_sync
		move.b	$fffc02,d0

		cmp.b	#01,d0		;escape
		beq	exit

		cmp.b	#$b,d0		;0 key
		bne.s	not_zero
		tst.w	zero_counter
		bne.s	aa
		eor.w	#$111,$ff8240
		eor.w	#$ffff,toggle
		move.w	#10,zero_counter
		bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#7,d0		;6 key
	bge	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484
	lea	$ffff8240.w,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)
	bsr	user_mode

	move.l	old_base,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp


exit:
	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484
	bsr	user_mode
	clr.w	-(sp)
	trap	#1



***************
* Subroutines *
***************
scroll	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on	move.l	line_ptr,a6
		cmp.b	#$7f,(a6)
		bne.s	no_delay
		add.l	#1,line_ptr
		move.w	#320,delay
		rts
delay		dc.w	0
no_delay	cmp.b	#$ff,(a6)
		bne	loop3
		lea	scroll_line,a6	;restart message
		move.l	a6,line_ptr

loop3		tst.w	scroll_number
		bne	loop2
		move.w	#WIDTH,scroll_number
		moveq	#0,d0
		move.b	(a6)+,d0
		move.l	a6,line_ptr
		sub.w	#32,d0
		mulu	#68,d0
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
		move.l	(a6),(a1)	;68 bytes each char

loop2		move.l	new_base,a6
		add.l	#32000+480,a6
		move.l	a6,a2
		add.w	#152,a2
		lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
		move.w	#17-1,d1
loop		roxl.w	2(a1)	;scroll
		roxl.w	(a1)	;letter
		move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
		and.w	#1,d0	;mask off lowest bit
		or.w	d0,(a2)	;put onto screen
		sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
		add.w	#4,a1	;increase buffer position
		add.w	#160,a2	;increase screen
		dbf	d1,loop

		move.w	#17-1,d0
loopy		roxl.w	152(a6)
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
		roxl.w	(a6)
		sub.w	d4,d4	;clear X flag to stop wrapping.
		add.w	#160,a6
		dbf	d0,loopy
		sub.w	#1,scroll_number
		rts

set_super	clr.l	-(sp)		;set supervisor mode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

user_mode	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

save_pal	lea	old_pal,a1
		lea	$ffff8240,a0
		move.w	#16-1,d0
save_p		move.w	(a0)+,(a1)+
		dbf	d0,save_p
		rts

restore_pal	lea	old_pal,a0
		bra.s	set_p

set_palette
	lea	pic+2,a0
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

set_med_rez	move.w	#1,-(sp)
		bra.s	set_rez

set_low_rez	clr.w	-(sp)
set_rez		move.l	a0,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts


set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#new_vbl,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


isr_off
	ORI.W	#$700,SR
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


set_chip:
	move.w	#5,D0
	clr.w	D1
	lea	$FF8800,A0
.loop:	move.b	D1,(A0)
	move.b	#0,2(A0)
	sub.w	#1,D0
	bne.s	.loop
	move.b	#7,$FF8800
	move.b	$ff8802,D2
	and.b	#$C0,D2
	or.b	d1,d2
	move.b	D2,$FF8802
	move.b	#8,$FF8800
	move.b	#0,$FF8802
	move.b	#9,$FF8800
	move.b	#0,$FF8802
	move.b	#10,$FF8800
	move.b	#0,$FF8802
	rts

transfer:
	lea	pic+34,a0
	move.l	a0,a2
	add.w	#16000,a0
	add.w	#16000,a2
	move.l	new_base,a1
	move.l	a1,a3
	add.w	#16000,a1
	add.w	#16000,a3
	move.w	#199,d7
.lines:	move.w	#20-1,d6
.words:	move.l	(a0)+,(a1)+
	move.l	-(a2),-(a3)
	move.w	#200,d0
.p	nop
	dbf	d0,.p
	dbf	d6,.words
	dbf	d7,.lines
	rts



*********
* ISRs  *
*********
new_vbl
	clr.b	$fffffa1b.w
	move.l	#horiz_isr,$120.W
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	d0-a6,-(sp)	;preserve regs
	move.w	pic+4,$ffff8242.w
	clr.w	horiz_sync
	bsr	tune+$106
	bsr	scroll
	bsr	scroll
	bsr	scroll
	movem.l	(sp)+,d0-a6
	rte


horiz_isr	;$120
		clr.b	$fffffa1b.w
		move.l	d0,-(sp)
		REPT	50
		nop
		ENDR
		moveq	#0,d0
.loop		cmp.b	$ffff8209.w,d0
		bne.s	.loop
		CLR.B	$FFFF820A.W
		REPT	22
		nop
		ENDR
		MOVE.B	#2,$FFFF820A.W
		move.l	a0,-(sp)
		lea	pal_table,a0
		move.w	#17-1,d0
col_loop	move.w	(a0)+,$ffff8242.w
		REPT 120
		nop
		ENDR
		dbf	d0,col_loop
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		rte
pal_table	dc.w	$123
		dc.w	$124,$125,$126,$127,$137,$237,$247,$347
		dc.w	$357,$457,$467,$567,$577,$677,$777,$fff
		rte

********
* Data *
********
scroll_number:	dc.w	16


ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a

line_ptr:	dc.l	scroll_line

scroll_line:
 DC.B "WELCOME TO P.O.V. 26        ALL CODING BY MAC SYS DATA,  THE "
 DC.B "GRAPHIX AND FONT ARE FROM OUR NEW ARTIST - PRETTY GOOD EH?    ALY IS STILL A "
 DC.B "MEMBER OF P.O.V. BUT CAN'T SUPPLY ENOUGH PICTURES TO MATCH MY PACKING SPEED. "
 DC.B "   THE NEW ARTISTS NAME "
 DC.B "IS RATHER LONG SO WE WILL CALL HIM OZ FOR SHORT (WITH ONE Z).  "
 DC.B "     WELL HERE IS A TOTALLY HALF MEG COMPATABLE DISC.  "
 DC.B "     THE ULTIMATE DEMO WAS A BOOT LOADING DEMO WITH ALL THE DATA STORED "
 DC.B "AS RAW DATA BUT NOT ANY LONGER!  HEY HI-TECH, I LIKE THE MESSAGE TO ALL "
 DC.B "HACKERS, IT CERTAINLY CAUGHT ME BY SURPRISE, CAN YOU USE THE SAME "
 DC.B "LOADER ON ALL YOUR DEMOS AS I RIPPED IT OFF IN UNDER 15 MINUTES.     IF "
 DC.B "OK END OF TEXT AS I'M RUNNING OUT OF DISC SPACE....     "
	dc.b	$ff,$ff
	even
font:	incbin	"font.dAT"
	even
tune:	Incbin "rampage.IMG"
	even
pic	incbin	"pov26.PI1"

filenames:	;filenames are 14 chars long.....
	dc.b	"ULTIMATE.MSD",0,0
	dc.b	"DECADE.FB",0,0,0,0,0
	dc.b	"FOFT7.MSD",0,0,0,0,0
	dc.b	"WIZARDS.MSD",0,0,0
	dc.b	"COPIER.POV",0,0,0,0

	even
	SECTION BSS
bssstart
old484		ds.w	1
horiz_sync	ds.w	1
old_base	ds.l	1
old_pal		ds.b	32
stack_save	ds.l	1
toggle		ds.w	1	;hertz toggle
old70		ds.l	1
old120		ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
	even
buffer		ds.b	BUFFER_SIZE

new_base	ds.l	1
	ds.b	256
screen	ds.b	32000+160*48
bssend