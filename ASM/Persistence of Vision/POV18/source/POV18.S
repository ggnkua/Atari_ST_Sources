*************************
* POV 18		*
*************************

BUFFER_SIZE:    EQU	42*18
WIDTH:		EQU	16
BASE:		EQU	$66000  ;put screen at $66000 when finally assembling
					;for 512K machines.
start:
	move.l  sp,a5
	move.l  4(a5),a5
	move.l  $C(a5),d0
	add.l   $14(a5),d0
	add.l   $1C(a5),d0
	add.l   #$100,d0
	move.l  d0,-(sp)
	move.l  a5,-(sp)
	move.w  d0,-(sp)
	move.w  #$4a,-(sp)
	trap    #1
	add.l   #12,sp	  ;okay that's it memory free & allocated

	bsr	set_super
	clr.l	$24	;disable MONST2 and so prevent hacking
wait_for_drive:
	tst.w   $43e
	bne.s   wait_for_drive
	clr.w	$444	;no verify

	bsr	hide_cursor
	bsr	save_pal
	bsr	get_base
	move.l  #BASE,a0	;screen_base
	bsr	set_low_rez
	bsr	set_palette
	bsr	clear_lower_border
	bsr	set_up_for_border
;the next two lines are to prevent a screen OFFSET on STE machines.
	clr.w   $ff8264 ;STE bit wise shift
	move.w  #$ff00,$ff820e

;************************************************************************
;*				BMX SIMULATOR				*
;*				-------------				*
;* Stolen by: MAC SYS DATA of P.O.V. 17/06/89 11:10			*
;*	From: AUTOMATION disc 72					*
;* Include files:-							*
;*		   WAS72.IMG into TUNE					*
;************************************************************************
	move.b	$484,old484
	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION disc 72
; 1=Jingle
; 2=Jingle
	move.l	#0,D0
	jsr	tune+$c

	bsr	transfer
	bsr	show_pov
	bsr	show_hertz

	move.w  #$ffff,horiz_sync
main_loop:
	tst.w   horiz_sync
	bne	main_loop
;	move.w  $ffff8240.w,-(sp)
;	move.w  #$070,$ffff8240.w
	bsr	show_pov
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	show_buffer
;	move.w  (sp)+,$ffff8240.w
	MOVE.W  #$FFFF,horiz_sync
	move.b  $fffc02,d0
;	cmp.b   #01,d0	  ;escape
;	beq	exit

	cmp.b   #$b,d0	  ;0 key
	bne.s   not_zero
	tst.w   zero_counter
	bne.s   aa
	eor.w   #$111,pic+2
	eor.w	#$ffff,toggle
	bsr.s	show_hertz
	move.w  #10,zero_counter
	bra	main_loop

show_hertz:
	tst.w	toggle
	bne.s	not_50
	pea	in50
	bra.s	print
not_50:	pea	in60
print:	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

zero_counter:   dc.w    0
not_zero:
	tst.w   zero_counter
	beq.s   car
aa:	sub.w   #1,zero_counter

car:    cmp.b   #2,d0	   ;1 key
	blt	main_loop
	cmp.b   #6,d0	   ;5 key
	bge	main_loop	 

	move.l  d0,-(sp)
	bsr	isr_off
	move.l  old_base,a0	;screen_base
	bsr	set_low_rez
	move.l  (sp)+,d0

	move.b	old484,$484
;key is in D0.L
	and.l   #$ff,d0
	lea	filenames,a6
	sub.b   #2,d0
	mulu    #14,d0
	add.w   d0,a6

	tst.w   toggle
	beq.s   hz50
	eor.b   #2,$ff820a
hz50:
	bsr	black_pal
; poke filename to screen
	move.l	old_base,a0
	add.w	#160*199,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	bsr	user_mode
	clr.w   -(sp)		;to AUTORUN in AUTO folder
	move.w  #$4c,-(sp)
	trap    #1
	addq.l  #4,sp

exit:	bsr	isr_off
	move.b	old484,$484
;reset rez
	move.l  old_base,a0
	bsr	set_med_rez

	bsr	restore_pal
	bsr	show_cursor
	bsr	user_mode
	clr.w   -(sp)
	move.w  #$4c,-(sp)
	trap    #1
	addq.l  #4,sp
	rts

***************************
* CUSTOM SUPPORT ROUTINES *
***************************
show_pov:
	move.l	pov_position,a0
	cmp.b	#$ff,(a0)
	bne.s	no_reset
	lea	best_table,a0
	move.l	a0,pov_position
no_reset:
	move.b	(a0)+,d0
	move.l	a0,pov_position
	and.l	#$ff,d0
	mulu	#65*40,d0
	lea	pov_logos,a0
	add.l	d0,a0
;now print best thingy
	move.l	#BASE,a1
	move.w	#65-1,d7
.loop:
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/a2/a3/a4
	movem.l	d0-d6/a2/a3/a4,(a1)
	add.w	#40,a0
	add.w	#160,a1
	dbf	d7,.loop
	rts


***************
* SUBROUTINES *
***************
scroll:	tst.w	halt
	beq	do_more
	sub.w	#1,halt
	rts
do_more:
	move.l  line_ptr,a6
	cmp.b   #$ff,(a6)
	bne	loop3
	lea	scroll_line,a6  ;restart message
	move.l  a6,line_ptr
loop3:  
	cmp.b	#$7e,(a6)	;is pause?
	bne.s	no_pause
	move.b	(a6)+,d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	and.w	#$ff,d0
	move.w	d0,halt
	rts

no_pause:
	cmp.b	#$7f,(a6)
	bne.s	no_spacing_change
	move.b	(a6)+,d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	and.w	#$ff,d0
	mulu	#160,d0
	move.w	d0,line_spacing
	rts

no_spacing_change:
	tst.w   scroll_number
	bne	loop2
	move.w  #WIDTH,scroll_number
	move.b  (a6)+,d0
	and.l	#$ff,d0
	move.l  a6,line_ptr
	sub.w   #32,d0
	lsl.w   #5,d0   ;*32 (1 plane char set)
	lea	font,a6
	add.l   d0,a6   ;letter address is in a6
;transfer letter into buffer
; each line in buffer is 42 bytes long.
	lea	buffer+42,a1
	move.w  (a6)+,40(a1)
	move.w  (a6)+,82(a1)
	move.w  (a6)+,124(a1)
	move.w  (a6)+,166(a1)
	move.w  (a6)+,208(a1)
	move.w  (a6)+,250(a1)
	move.w  (a6)+,292(a1)
	move.w  (a6)+,334(a1)
	move.w  (a6)+,376(a1)
	move.w  (a6)+,418(a1)
	move.w  (a6)+,460(a1)
	move.w  (a6)+,502(a1)
	move.w  (a6)+,544(a1)
	move.w  (a6)+,586(a1)
	move.w  (a6)+,628(a1)
	move.w  (a6),670(a1)    ;32 bytes per char

loop2:
	lea	buffer+42,a5    ;scroll buffer
	move.w  #16-1,d0
loopy:
	roxl    40(a5)
	roxl    38(a5)
	roxl    36(a5)
	roxl    34(a5)
	roxl    32(a5)
	roxl    30(a5)
	roxl    28(a5)
	roxl    26(a5)
	roxl    24(a5)
	roxl    22(a5)
	roxl    20(a5)
	roxl    18(a5)
	roxl    16(a5)
	roxl    14(a5)
	roxl    12(a5)
	roxl    10(a5)
	roxl    8(a5)
	roxl    6(a5)
	roxl    4(a5)
	roxl    2(a5)
	roxl    (a5)

	add.w   #42,a5
	dbf	d0,loopy
	sub.w   #1,scroll_number
	rts

show_buffer:    ;puts scrolline buffer to screen
	lea	buffer,a0
	move.l  #BASE,a1
	add.w   #32000+320,a1
	move.w	line_spacing,d2
	move.w  #16-1,d7
.loop:
	move.w  (a0)+,(a1)
	move.w  (a0)+,8(a1)
	move.w  (a0)+,16(a1)
	move.w  (a0)+,24(a1)
	move.w  (a0)+,32(a1)
	move.w  (a0)+,40(a1)
	move.w  (a0)+,48(a1)
	move.w  (a0)+,56(a1)
	move.w  (a0)+,64(a1)
	move.w  (a0)+,72(a1)
	move.w  (a0)+,80(a1)
	move.w  (a0)+,88(a1)
	move.w  (a0)+,96(a1)
	move.w  (a0)+,104(a1)
	move.w  (a0)+,112(a1)
	move.w  (a0)+,120(a1)
	move.w  (a0)+,128(a1)
	move.w  (a0)+,136(a1)
	move.w  (a0)+,144(a1)
	move.w  (a0)+,152(a1)
	add.w   #2,a0
	add.w   d2,a1
	dbf	d7,.loop
	rts


*************************************
* INTERRUPT SERVICE ROUTINES (ISRs) *
*************************************
vert_isr:	 ;$70
	CLR.B   $FFFF8260.W
	MOVEM.L D0-d7,-(A7)

	MOVEM.L pic+2(PC),d0-d7
	MOVEM.L d0-d7,$FFFF8240.W

	move.l  a0,d0
	move.l  pal_position,a0
	cmp.w   #$ffff,(a0)
	bne.s   no_colour_reset
	move.l  #pal_table,pal_position
no_colour_reset:
	move.l  d0,a0
	MOVEM.L (sp)+,D0-d7
	MOVE.B  #49,counter	;49/50 of a second

	MOVE.L  #horiz_isr,$120.W
	clr.w   horiz_sync

	movem.l d0-d7/a0-a6,-(sp)
	jsr	tune+$102
;flash the disc drive light
	move.b  #10,$ff8800
	move.b  $ff8800,d7
	cmp.b   #15,d7
	blt.s   no_flash
	move.b  #14,$ff8800
	bclr    #1,$ff8802
	movem.l (sp)+,d0-d7/a0-a6
	MOVE.B  #8,$FFFFFA1B.W
	MOVE.B  #3,$FFFFFA21.W
	rte
no_flash:
	move.b  #14,$ff8800
	or.b    #%00000010,$ff8802
	movem.l (sp)+,d0-d7/a0-a6
	MOVE.B  #8,$FFFFFA1B.W
	MOVE.B  #3,$FFFFFA21.W
	rte

horiz_isr:	;$120
	move.b  #4,$fffffa21.w    ;4/50 of a second (a frame) makes it in the
	move.l  #go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b  #1,counter
	beq.s   extended_scan
	rte

extended_scan:
	REPT	99
	nop
	ENDR
	CLR.B   $FFFF820A.W
	REPT	31
	nop
	ENDR
	MOVE.B  #2,$FFFF820A.W
f1:	MOVE.L  #L3DBD0,$120.W
	rte

L3DBD0  ;move.b #0,$ffff8260.w  ;(can be changed to get a med rez scroller)
	clr.b   $fffa1b
	movem.l d0/a0,-(sp)
	move.l  pal_position,a0
	move.w  #40-1,d0
col_loop:
	cmp.w   #$ffff,(a0)
	bne.s   ad
	move.w  (a0)+,$1000
ad:     move.w  (a0)+,$ffff8242.w
	nop
	nop
	nop
	nop     ;10
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;20
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;30
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;40
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;50
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;60
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;70
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;80
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;90
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;100
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop     ;110
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dbf     d0,col_loop
	movem.l (sp)+,d0/a0
	add.l   #2,pal_position
	bclr    #0,$fffa0f
	rte

********************
* SERVICE ROUTINES *
********************

set_up_for_border:
	ori.w   #$700,sr
	move.l  $70,old70
	move.l  $120,old120
	move.b  $fffffa07,olda07
	move.b  $fffffa09,olda09
	move.b  $fffffa17,olda17
	move.b  $fffffa1b,olda1b
	move.b  $fffffa21,olda21

	MOVE.L  #vert_isr,$70.W
	MOVE.L  #horiz_isr,$120.W

	MOVE.B  #1,$FFFFFA07.W
	CLR.B   $FFFFFA09.W
	BCLR    #0,$FFFFFA0F.W
	BSET    #0,$FFFFFA13.W
	BCLR    #3,$FFFFFA17.W
	CLR.B   $FFFFFA1B.W
	CLR.B   $FFFFFA21.W
	MOVE.W  #$2300,SR
	rts

isr_off:
	ORI.W   #$700,SR
	CLR.B   $FFFF8260.W
	move.l  old120,$120
	move.l  old70,$70

	MOVE.B  olda07,$FFFFFA07
	MOVE.B  olda09,$FFFFFA09
	MOVE.B  olda17,$FFFFFA17
	move.b  olda1b,$fffffa1b
	move.b  olda21,$fffffa21

	MOVE.W  #$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l  #$8080000,(a0)
	move.l  #$9090000,(a0)
	move.l  #$a0a0000,(a0)
	rts


clear_lower_border:
	move.l  #BASE,a0
	add.l   #32000,a0
	move.w  #47-1,d0
clr_:   clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	clr.l   (a0)+
	dbf	d0,clr_
	rts

set_super:
	clr.l   -(sp)	   ;set supervisor mode
	move.w  #32,-(sp)
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack_save
	rts

transfer:
	lea	pic+34,a0
	move.l  #BASE,a1
	move.w  #32000/4-1,d0
.loop:  move.l  (a0)+,(a1)+
	dbf	d0,.loop
	rts

pause:  move.w  d0,-(sp)
	move.w  #1000,d0
pau:    nop
	dbf	d0,pau
	move.w  (sp)+,d0
	rts

user_mode:
	move.l  stack_save,-(sp)
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240,a0
	move.w  #16-1,d0
save_p:
	move.w  (a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s   set_p

set_palette:
	lea	pic+2,a0
set_p:  lea	$ffff8240,a1
	move.w  #16-1,d0
set_pal:
	move.w  (a0)+,(a1)+
	dbf	d0,set_pal
	rts

black_pal:
	lea	$ffff8240.w,a0
	move.w	#8-1,d0
.loop:	clr.l	(a0)+
	dbf	d0,.loop
	rts

get_base:
	move.w  #3,-(sp)
	trap    #14
	addq.l  #2,sp
	move.l  d0,old_base
	clr.l	$24	;disable MONST2 and so prevent hacking
	rts

set_med_rez:
	move.w  #1,-(sp)
	bra.s   set_rez

set_low_rez:
	clr.w   -(sp)
set_rez:
	move.l  a0,-(sp)
	move.l  a0,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp
	clr.l	$24	;disable MONST2 and so prevent hacking
	rts

hide_cursor:
	pea	di_mouse
	move.w  #$2-1,-(sp)
	move.w  #$19,-(sp)
	trap    #14
	addq.l  #8,sp
	clr.l	$24	;disable MONST2 and so prevent hacking
	rts

show_cursor:
	pea	ei_mouse
	move.w  #$2-1,-(sp)
	move.w  #$19,-(sp)
	trap    #14
	addq.l  #8,sp
	rts
ei_mouse:
	dc.b    $14,8
	even
di_mouse:
	dc.b    $12,$1a
	even

	ds.l    40

********
* Data *
********
	section data
pal_position:   dc.l    pal_table
pal_table:
	dc.w    $f00,$780,$f10,$790,$f20,$7A0,$f30,$7B0
	dc.w    $f40,$7C0,$f50,$7D0,$f60,$7E0,$f70,$7F0
	dc.w    $eF0,$670,$dF0,$570,$cF0,$470,$bF0,$370
	dc.w    $aF0,$270,$9F0,$170,$8F0,$070,$0F1,$078
	dc.w    $0F2,$079,$0F3,$07A,$0F4,$07B,$0F5,$07C
	dc.w    $0F6,$07D,$0F7,$07E,$0E7,$06F,$0D7,$05F
	dc.w    $0C7,$04F,$0B7,$03F,$0A7,$02F,$097,$01F
	dc.w    $087,$00F,$806,$10E,$905,$20D,$A04,$30C
	dc.w    $B03,$40B,$C02,$50A,$D01,$609
	dc.w    $ffff
	dc.w    $f00,$780,$f10,$790,$f20,$7A0,$f30,$7B0
	dc.w    $f40,$7C0,$f50,$7D0,$f60,$7E0,$f70,$7F0
	dc.w    $eF0,$670,$dF0,$570,$cF0,$470,$bF0,$370
	dc.w    $aF0,$270,$9F0,$170,$8F0,$070,$0F1,$071
	dc.w    $0F2,$072,$0F3,$073,$0F4,$074,$0F5,$075


stack_save:	dc.l    0
old70:  dc.l    0
old120: dc.l    0
olda07: dc.l    0
olda09: dc.b    0
olda17: dc.b    0
olda1b: dc.b    0
olda21: dc.b    0
old484:	dc.b	0
toggle:	dc.w	0	;50 hertz
	even
horiz_sync:	dc.w    0
old_base:	 dc.l    0
counter:	dc.w    0

halt:	dc.w	0	;used to stop scrolline
line_spacing:	dc.w	160
scroll_number:  dc.w    16
old_pal:	ds.b    32
line_ptr:
	dc.l    scroll_line
buffer: dcb.b   0,BUFFER_SIZE

scroll_line:
 dc.b "   MAC SYS DATA AND HIS MOTELY CREW PRESENTS -                     ",$7f,2
 dc.b "DEMO COMPILATION 18  ",$7e,200,"                     ",$7f,1
 dc.b "CREDITS:   MENU CODED BY "
 dc.b "MAC SYS DATA,    GRAFIX BY MAC SYS DATA AND PETE LYON (STOLEN FROM "
 dc.b "AIRBALL) MUSIC STOLEN FROM BMX SIMULATOR BY MAC SYS DATA.          "
 dc.b "I THINK THIS IS ONE OF THE BEST MENUS I'VE WRITTEN, "
 dc.b "PROBABLY DUE TO THE GRAFIX FROM AIRBALL BEING AMAZING AND THE COLOURS "
 dc.b "IN THE BORDER LOOK PRETTY GOOD (EVEN BETTER IF YOU'RE USING AN STE!). "
 dc.b "         NOTE: FROM THE 21-4-90 ALL P.O.V. DISCS ARE AVAILABLE FROM "
 dc.b "                    ",$7f,2
 dc.b " 'THE DEMO CLUB'   ",$7e,255,"                     ",$7f,1
 dc.b " WE CHOSE THIS PD LIBRARY BECAUSE IT IS VERY FAST "
 dc.b "AND CAN SUPPLY US WITH ALL THE NEWEST DEMOS.             "
 dc.b "***** HOLD IT *****  ",$7e,200,"HAS ANYBODY GOT AN AMIGA OUT THERE?   "
 dc.b "  IF YOU HAVE, THEN GET HOLD OF THE WATCHMEN DEMO, ON THE DISC THERE "
 dc.b "IS 7 DEMOS.      HAVE A LOOK AT THE HURRICANE DEMO WITH KEY F4.       "
 dc.b " DO YOU RECOGNIZE THE TUNE?      READ THE SCROLL.        MUSIC BY - MAD MAX "
 DC.B "OF TEX!         ALL THE TIME WE BELEIVED MAD MAX WAS AN ST ONLY FREAK BUT NOW "
 DC.B "I'VE HEARD HIM ON AN AMIGA!       I MUST SAY THAT HE HAS DONE A GREAT JOB OF "
 DC.B "MAKING BOTH MACHINES SOUND ALMOST THE SAME HOWEVER THE AMIGA HAS THE EDGE DUE "
 DC.B "TO IT'S SYNTH CHIP BUT THE ST'S YAMAHA CHIP IS NOT FAR BEHIND.       THE SYNTH "
 DC.B "ROUTINE BY MAD MAX ON THE ST 'AMIGA DEMO' IS AMAZINGLY CLOSE TO THE AMIGA'S "
 dc.b "SOUND CAPACITY.           OK, COMING TO A SCREEN NEAR YOU SOON - "
 DC.B "TLT,   TNT DEMO 1,   ALF,   SNOWMAN,   STE ACID DEMO,   ST CONNEXION SOUND TRACKER,   "
 DC.B "MICROMIX 3 AND MANY, MANY MORE....        IF YOU'VE GOT AN STE THEN YOU MUST GET "
 DC.B "A COPY OF P.O.V. 20 'COS IT WILL CONTIAN THE FIRST EVER PACKED STE ONLY DEMO FROM THE "
 DC.B "OVERLANDERS.      I'VE ALSO BEEN BUSY DOING SOME STE ONLY CODE AND THAT SHOULD BE "
 DC.B "READY REAL SOON..            HAVE YOU ALL GOT THE 'MINDBOMB' DEMO?       IF YOU HAVE "
 DC.B "THEN CHECK OUT THE FIRST OF THE THREE DOORS IN THE CENTRE OF THE PLAY-AREA, IT'S BY "
 DC.B "THE FOREIGN GROUP THINGY.   IF YOU LEAVE IF FOR ABOUT 5 MINUTES IT CRASHES!      GOOD "
 DC.B "ONE LOST BOYS, KEEP UP THE GOOD WORK!               TODAYS DATE IS 31-5-90, THIS "
 DC.B "PIECE OF TEXT IS AN ADDITION TO THE DISC BECAUSE I'VE JUST HAD TO DO A BUG FIX ON "
 DC.B "THIS MENU!!!!      I'VE JUST RELEASED DISCS 16 AND 17 YESTERDAY AND I'LL FINISH THIS "
 DC.B "AND 19 TONIGHT.    WHEN I WENT TO STUART'S HOUSE LAST NIGHT TO TEST THE DISCS, I TOOK "
 DC.B "ALL MY AMIGA SOFTWARE. SOME OF THE DEMOS DO NOT WORK ON MY A500 BUT THEY DID ON HIS "
 DC.B "EVEN THOUGH WE HAVE THE SAME KICKSTART (ROM) AND WORKBENCH VERSION!  I THINK MY AGNES "
 DC.B "CHIP IS SHAGGED, OR THE COPPER IS A BIT WONKY.   ONE ANSWER MAY BE THAT I'VE GOT THE NEW "
 DC.B "FATTER AGNES WITH EXTENDED SPRITE ROUTINES AND BETTER MEMORY MANAGEMENT.    THE WEIRD THING "
 DC.B "IS THAT ALL THE GAMES WORK BUT SOME DEMOS GO INTO SELF DESTRUCT MODE.              "
 DC.B " HEY WOW, THE TUNES ON THE MAHONEY AND KAKTUS DEMO 2 ARE EXCELLENT (THEY ARE PLAYING IN THE "
 DC.B "BACKGROUND - CAN YOU HERE THEM?)    SPEAKING OF TUNES, ON DISC 21 (I THINK), THERE IS THE "
 DC.B "ST CONNEXION SOUND-TRACKER, THIS PIECE OF CODE IS PRETTY GOOD AND BRINGS YOU SOUNDS THAT ARE "
 DC.B "NEAR AS DAMN IT AS GOOD AS THE AMIGAS.    I'LL ALSO RELEASE THE TCB SOUND-TRACKER DEMO SOON ("
 DC.B "MAYBE ON DISC 23).      ON SOME FUTURE P.O.V. DISCS I WILL BE PUTTING A FEW DIGITIZED PICS "
 DC.B "BECAUSE I'VE GOT A VIDEO DIGITIZER FOR MY AMIGA.   I GET THE PICTURE ON THE AMIGA IN 16 COLOURS, "
 DC.B "DO A RS232 TRANSFER USING KERMIT SO THAT THE PICTURE IS ON THE ST, LOAD DEGAS ELITE AND USE THE "
 DC.B "LOAD BLOCK FUNCTION.   THE PICTURE IS THEN COLOURED IN BY ME AND STUCK ON A MENU,  THE GARFIELD "
 DC.B "PICTURE ON P.O.V. 19 WAS DONE THIS WAY.           IT'S NOW 9 PM AND MY MATE 'STRANGE ANDY' THE "
 DC.B "POSTMAN SHOULD BE HERE SOON TO HAVE A DRINKING SESSION. I'VE GOT PLENTY OF CANS AND A LITTLE "
 DC.B "BIT OF WHAT WAS A VERY LARGE BAR OF CHOCOLATE.        OH DEAR, I'VE JUST SCOFFED THE LAST "
 DC.B "PIECE OF CHOCOLATE - OOPS.                I AM GETTING BORED WITH THIS SCROLL TEXT, I WISH I "
 DC.B "COULD THINK OF SOMETHING TO WRITE......................................................."
 DC.B "..................... .......... ....... . . . . .  .   .   .    .    .     HERE WE GO, A "
 DC.B "NEW SUBJECT....   THE DELIRIUS DEMO   ...     DID YOU KNOW THAT ALL THE DEMOS ARE SEPERATE "
 DC.B "FILES?   IF YOU LOOK AT THE DIRECTORY, YOU WILL SEE A LOAD OF FOLDERS, BUT THEY ARE NOT FOLDERS!  "
 DC.B "WHAT THE PROGRAMMERS HAVE DONE IS TO ALTER THE FILES ATTRIBUTES SO THE DESKTOP THINKS THEY ARE FOLDERS! "
 DC.B "   IF YOU USE MONST2 AND LOAD THE FILES YOU WILL SEE THAT THEY ARE ALSO PACKED WITH AUTOMATION 2.3R. "
 DC.B "I SPENT ABOUT ONE HOUR DE-PACKING THESE FILES AND PUTTING THEM ON MY HARD DISC, THE TOTAL LENGTH OF "
 DC.B "UN-PACKED DATA IS ABOUT 3.6 MEG! I CAN NOW SUPPLY YOU WITH ANY SCREEN FROM THE DEMO SO YOU CAN STEAL "
 DC.B "THE GRAPHICS/FONTS/CODE, ETC...                 JOKE TIME:   WHAT GOES PLINK, PLINK FIZZ?     "
 DC.B "ANSWER:  TWO BABIES IN AN ACID BATH!            WELL WHAT DID YOU EXPECT, A JIMMY TARBUCK JOKE?     "
 DC.B "        WELL I THINK THAT THIS SCROLLER HAS GONE ON FOR FAR TOO SERIOUSLY LONG BY HALF?     SO WITHOUT "
 DC.B "FURTHER ADO I'LL SAY GOODBYE AND GOOD LUCK....                 "
 DC.B "                                            "
	dc.b    $ff,$ff,$ff,$ff
	even
in50:	dc.b	27,'Y86',"50 Hertz PAL ",0
	even
in60:	dc.b	27,'Y86',"60 Hertz NTSC",0
	even
font:
	incbin  "med_font.dat"
	even
pic	incbin  "pov18.PI1"
tune:   incbin	"WAS72.img"
pov_logos:
	incbin	"pova.dat"
	incbin	"povb.dat"
pov_position:	dc.l	best_table
best_table:
	dc.b	0
	dc.b	1
	dc.b	2
	dc.b	3
	dc.b	4,5,6,7,8,9,10,11,12,13,14,15,16
	dc.b	17
	dc.b	18
	dc.b	19
	dc.b	20
	dc.b	21
	dc.b	20
	dc.b	19
	dc.b	18
	dc.b	17,16,15,14,13,12,11,10,9,8,7,6,5

	dc.b	4
	dc.b	3
	dc.b	2
	dc.b	1
	dc.b	$ff,$ff

filenames:
	dc.b    "TNT.MSD",0,0,0,0,0,0,0
	dc.b    "FTB2.MSD",0,0,0,0,0,0
	dc.b    "HOLBURN.MSD",0,0,0
	dc.b    "FILLER.POV",0,0,0,0
