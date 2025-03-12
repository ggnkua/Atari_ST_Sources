***************************
* POV 17		  *
***************************

BUFFER_SIZE:	EQU     42*18
WIDTH:	EQU     16
BASE:	EQU     $66000  ;put screen at $66000 when finally assembling
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

	bsr     set_super
wait_for_drive:
	tst.w   $43e
	bne.s   wait_for_drive

	bsr     hide_cursor
	bsr     save_pal
	bsr     set_palette
	bsr     get_base
	move.l  #BASE,a0	;screen_base
	bsr     set_low_rez
	bsr     clear_lower_border
	bsr     set_up_for_border

;the next two lines are to prevent a screen OFFSET on STE machines.
	clr.w   $ff8264 ;STE bit wise shift
	move.w  #$ff00,$ff820e

;************************************************************************
;*			       VIXEN				  *
;*			       -----				  *
;* Stolen by: MAC SYS DATA of P.O.V. in 1988 and again 12/6/89 18:08    *
;*      From: WAS (NOT WAS) disc 48				     *
;* Include files;-						      *
;*		 VIXEN.IMG					    *
;************************************************************************
	move.b	$484,old484
	move.b	#0,$484		;no keyclick

;*********************************************
;* There is more than one tune here....
;* 0=AUTOMATION
;* 1=WAS (NOT WAS) 48
;* 2=End of level jingle

	move.w	#0,d0
	jsr	tune+$4d2

	bsr     transfer

	move.w  #$ffff,horiz_sync
main_loop:
	tst.w   horiz_sync
	bne     main_loop
;	move.w  $ffff8240.w,-(sp)
;	move.w  #$070,$ffff8240.w
	bsr     scroll
	bsr     scroll
	bsr     scroll
	bsr     scroll
	bsr     show_buffer
;	move.w  (sp)+,$ffff8240.w
	MOVE.W  #$FFFF,horiz_sync
	move.b  $fffc02,d0
	cmp.b   #01,d0	  ;escape
	beq     exit

	cmp.b   #$b,d0	  ;0 key
	bne.s   not_zero
	tst.w   zero_counter
	bne.s   aa
	eor.w   #$111,pic+2
	eor.w	#$ffff,toggle
	move.w  #10,zero_counter
	bra     main_loop
zero_counter:   dc.w    0
not_zero:
	tst.w   zero_counter
	beq.s   car
aa:     sub.w   #1,zero_counter

car:    cmp.b   #2,d0	   ;1 key
	blt     main_loop
	cmp.b   #4,d0	   ;3 key
	bge     main_loop       

	move.l  d0,-(sp)
	bsr     isr_off
	move.l  old_base,a0     ;screen_base
	bsr     set_low_rez
	move.l  (sp)+,d0

	move.b	old484,$484
;key is in D0.L
	and.l   #$ff,d0
	lea     filenames,a6
	sub.b   #2,d0
	mulu    #14,d0
	add.w   d0,a6

	tst.w   toggle
	beq.s   hz50
	eor.b   #2,$ff820a
hz50:
	bsr     user_mode
	move.l	old_base,a0
	add.w	#199*160,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	bra.s	fin
exit:
	bsr     isr_off
	move.b	old484,$484
;reset rez
	move.l  old_base,a0
	bsr     set_med_rez
;	bsr     set_low_rez

	bsr     restore_pal
	bsr     show_cursor
	bsr     user_mode
fin:	clr.w   -(sp)
	move.w  #$4c,-(sp)
	trap    #1
	addq.l  #4,sp
	rts

***************************
* CUSTOM SUPPORT ROUTINES *
***************************

***************
* SUBROUTINES *
***************
scroll: move.l  line_ptr,a6
	cmp.b   #$ff,(a6)
	bne     loop3
	lea     scroll_line,a6  ;restart message
	move.l  a6,line_ptr
loop3:  
	tst.w   scroll_number
	bne     loop2
	move.w  #WIDTH,scroll_number
	clr.l   d0
	move.b  (a6)+,d0
	move.l  a6,line_ptr
	sub.w   #32,d0
	lsl.w   #5,d0   ;*32 (1 plane char set)
	lea     font,a6
	add.l   d0,a6   ;letter address is in a6
;transfer letter into buffer
; each line in buffer is 42 bytes long.
	lea     buffer+42,a1
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
	lea     buffer+42,a5    ;scroll buffer
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
	dbf     d0,loopy
	sub.w   #1,scroll_number
	rts

show_buffer:    ;puts scrolline buffer to screen
	lea     buffer,a0
	move.l  #BASE,a1
	add.w   #32000+320,a1
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
	add.w   #160,a1
	dbf     d7,.loop
	rts



*************************************
* INTERRUPT SERVICE ROUTINES (ISRs) *
*************************************
vert_isr:       ;$70
	CLR.B   $FFFF8260.W
	move.l	d0,-(sp)

	move.l	pic+2,d0
	move.l	d0,$FFFF8240.W
	move.w	pic+$14,d0
	move.w	d0,$ffff8252.w

	move.l  a0,d0
	move.l  pal_position,a0
	cmp.w   #$ffff,(a0)
	bne.s   no_colour_reset
	move.l  #pal_table,pal_position
no_colour_reset:
	move.l  d0,a0
	move.l (sp)+,d0
	MOVE.B  #49,counter     ;49/50 of a second

	MOVE.L  #horiz_isr,$120.W
	clr.w   horiz_sync

	movem.l d0-d7/a0-a6,-(sp)
	jsr     tune+$28
;flash the disc drive light
	move.b  #9,$ff8800
	move.b  $ff8800,d7
	cmp.b   #12,d7
	blt.s   no_flash
	move.b  #14,$ff8800
	bclr    #1,$ff8802
	movem.l (sp)+,d0-d7/a0-a6
	move.w	#$770,$ffff8252		;flash lights on pic.
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

horiz_isr:      ;$120
	move.b  #4,$fffffa21.w    ;4/50 of a second (a frame) makes it in the
	move.l  #go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b  #1,counter
	beq.s   extended_scan
	rte

extended_scan:
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
	CLR.B   $FFFF820A.W
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
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	MOVE.B  #2,$FFFF820A.W
f1:     MOVE.L  #L3DBD0,$120.W
	rte

L3DBD0  ;move.b #0,$ffff8260.w  ;(can be changed to get a med rez scroller)
	clr.b   $fffa1b
	movem.l d0/d1/a0,-(sp)
	move.l  pal_position,a0
	move.w  #40-1,d0
col_loop:
	move.w  (a0)+,d1
	cmp.w   #$ffff,d1
	bne.s   ad
	move.w  (a0)+,d1
ad:     move.w  d1,$ffff8242.w
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
	movem.l (sp)+,d0/d1/a0
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
	lea     $ff8800,a0
	move.l  #$8080000,(a0)
	move.l  #$9090000,(a0)
	move.l  #$a0a0000,(a0)
	rts


clear_lower_border:
	move.l  #BASE,a0
	add.l   #32000,a0
	move.w  #45-1,d0
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
	dbf     d0,clr_
	rts

set_super:
	clr.l   -(sp)	   ;set supervisor mode
	move.w  #32,-(sp)
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack_save
	rts

transfer:
	lea     pic+34,a0
	move.l  #BASE,a1
	move.w  #32000/4-1,d0
.loop:  move.l  (a0)+,(a1)+
	dbf     d0,.loop

	move.w  #2,d1	   ;do a pause
lo:     move.w  #65000,d0
halt:   nop
	dbf     d0,halt
	dbf     d1,lo

	rts

pause:  move.w  d0,-(sp)
	move.w  #1000,d0
pau:    nop
	dbf     d0,pau
	move.w  (sp)+,d0
	rts

user_mode:
	move.l  stack_save,-(sp)
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	rts

save_pal:
	lea     old_pal,a1
	lea     $ffff8240,a0
	move.w  #16-1,d0
save_p:
	move.w  (a0)+,(a1)+
	dbf     d0,save_p
	rts

restore_pal:
	lea     old_pal,a0
	bra.s   set_p

set_palette:
	lea     pic+2,a0
set_p:  lea     $ffff8240,a1
	move.w  #16-1,d0
set_pal:
	move.w  (a0)+,(a1)+
	dbf     d0,set_pal
	rts

get_base:
	move.w  #3,-(sp)
	trap    #14
	addq.l  #2,sp
	move.l  d0,old_base
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
	rts

hide_cursor:
	pea     di_mouse
	move.w  #$2-1,-(sp)
	move.w  #$19,-(sp)
	trap    #14
	addq.l  #8,sp
	rts

show_cursor:
	pea     ei_mouse
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
	dc.w    $700,$700,$710,$710,$720,$720,$730,$730
	dc.w    $740,$740,$750,$750,$760,$760,$770,$770
	dc.w    $670,$670,$570,$570,$470,$470,$370,$370
	dc.w    $270,$270,$170,$170,$070,$070,$071,$071
	dc.w    $072,$072,$073,$073,$074,$074,$075,$075
	dc.w    $076,$076,$077,$077,$067,$067,$057,$057
	dc.w    $047,$047,$037,$037,$027,$027,$017,$017
	dc.w    $007,$007,$106,$106,$205,$205,$304,$304
	dc.w    $403,$403,$502,$502,$601,$601
	dc.w    $ffff

	dc.w    $700,$700,$710,$710,$720,$720,$730,$730
	dc.w    $740,$740,$750,$750,$760,$760,$770,$770
	dc.w    $670,$670,$570,$570,$470,$470,$370,$370
	dc.w    $270,$270,$170,$170,$070,$070,$071,$071
	dc.w    $072,$072,$073,$073,$074,$074,$075,$075

stack_save:     dc.l    0
old70:  dc.l    0
old120: dc.l    0
olda07: dc.l    0
olda09: dc.b    0
olda17: dc.b    0
olda1b: dc.b    0
olda21: dc.b    0
old484:	dc.b	0
	even
horiz_sync:     dc.w    0
old_base:       dc.l    0
counter:	dc.w    0
toggle:		dc.w	0	;hertz toggle
scroll_number:  dc.w    16
old_pal:	ds.b    32
line_ptr:
	dc.l    scroll_line
buffer: dcb.b   0,BUFFER_SIZE

scroll_line:
 dc.b "   MAC SYS DATA PRESENTS -      PERSISTENCE OF VISION DISC 17.    "
 dc.b "CREDITS:   MENU CODED BY "
 dc.b "MAC SYS DATA,    GRAFIX BY DR.SYNE,  "
 dc.b "    MUSIC BY DAVE WHITTAKER, STOLEN FROM VIXEN.   "
 dc.b "MEMBERS OF P.O.V. ARE ;-     "
 dc.b "MAC SYS DATA,    BORIS,    DR.SYNE    AND ALY.     "
 dc.b "HI TO;-    ALAN R,  GEORGE,  BASHER,  NIEL OF COR BLIMEY AND "
 dc.b "TCB.             "
 DC.B "  --- IMPORTANT ---        FROM THE 21-4-90 PERSISTENCE OF VISION DISCS WILL "
 DC.B "BE AVAILABLE FROM 'THE DEMO CLUB' PD LIBRARY. THIS LIBRARY IS THE BEST "
 DC.B "FOR DEMOS, WHATEVER YOU DO DON'T GOTO 'PUBLIC DOMINATOR' "
 DC.B "BECAUSE THEY'RE A BAG OF SH*T!!! "
 DC.B "       THIS IS THE END OF THE SCROLLINE, PRESS A KEY TO START A DEMO "
 DC.B ".........."
 DC.B "                        "
 DC.B "YEP, I REALLY MEANT IT THIS TIME, NO MORE OF THE EXTENDED SCROLLING SO THERE.      "
 DC.B "                                                                                   "
	dc.b    $ff,$ff,$ff,$ff
	even

font:
	incbin  "med_font.dat"
	even
pic     incbin  "pov17.PI1"
tune:   incbin "VIXEN.IMG"
filenames:
	dc.b    "FOREIGN.POV",0,0,0
	dc.b    "z650.msd",0,0
	even
	dc.l	0
