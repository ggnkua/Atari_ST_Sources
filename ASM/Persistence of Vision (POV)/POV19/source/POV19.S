***************************
* POV 19		  *
***************************
	opt	o+,w-
BUFFER_SIZE:    EQU     42*18
WIDTH:	  EQU     16
BASE:	   EQU     $66000  ;put screen at $66000 when finally assembling
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
;*				CUSTODIAN				*
;*				---------				*
;* Stolen by: MAC SYS DATA of P.O.V. 27/06/89 23:15			*
;*      From: AUTOMATION disc 97					*
;* Include files:-							*
;*		 WAS97.IMG into TUNE					*
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION disc 97 - CUSTODIAN main tune
; 1=intro score table
; 2=title screen
; 3=enter name on high score.
; 4=Jingle
; 5=Jingle
	move.l	#3,D0
	jsr	tune+$6ca

	bsr     transfer

	move.w  #$ffff,horiz_sync
main_loop:
	tst.w   horiz_sync
	bne.s	main_loop
;	move.w  $ffff8240.w,-(sp)
;	move.w  #$070,$ffff8240.w
	bsr	print_garfield
	bsr     scroll
	bsr     scroll
	bsr     scroll
	bsr     scroll
	bsr     show_buffer
;	move.w  (sp)+,$ffff8240.w
	MOVE.W  #$FFFF,horiz_sync
	move.b  $fffc02,d0
;	cmp.b   #01,d0	  ;escape
;	beq     exit

	cmp.b   #$b,d0	  ;0 key
	bne.s   not_zero
	tst.w   zero_counter
	bne.s   aa
	eor.w   #$111,pic+2
	eor.w	#$ffff,toggle
	move.w  #10,zero_counter
	bra.s	main_loop
toggle:	dc.w	0
zero_counter:   dc.w    0
not_zero:
	tst.w   zero_counter
	beq.s   car
aa:     sub.w   #1,zero_counter

car:    cmp.b   #2,d0	   ;1 key
	blt	main_loop
	cmp.b   #6,d0	   ;5 key
	bge	main_loop       

	move.w	d0,-(sp)
	bsr     isr_off
	move.l  old_base,a0     ;screen_base
	bsr     set_low_rez
	move.w	(sp)+,d0
	
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
	lea	$ffff8240.w,a0
	clr.l	(a0)
	clr.l	4(a0)
	clr.l	8(a0)
	clr.l	12(a0)
	clr.l	16(a0)
	clr.l	20(a0)
	clr.l	24(a0)
	clr.l	28(a0)
; poke filename to screen
	move.l	old_base,a0
	add.w	#160*199,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	clr.w   $ff8264 ;STE bit wise shift
	move.w  #$ff00,$ff820e

	bsr	user_mode
	clr.w   -(sp)		;to AUTORUN in AUTO folder
	trap    #1

exit:	bsr     isr_off

;reset rez
	move.l  old_base,a0
	bsr     set_med_rez
;	bsr     set_low_rez

	bsr     restore_pal
	bsr     show_cursor
	bsr     user_mode
	clr.w   -(sp)
	move.w  #$4c,-(sp)
	trap    #1
	addq.l  #4,sp
	rts

***************************
* CUSTOM SUPPORT ROUTINES *
***************************
print_garfield:
	move.l	garfield_position,a0
	cmp.l	#$ffffffff,(a0)
	bne.s	no_reset
	lea	garfield_table,a0
	move.l	a0,garfield_position
no_reset:
	move.l	(a0)+,d6	;word offset on screen
	move.l	(a0)+,a2
	move.l	a0,garfield_position

	move.l	#BASE,a1
	add.w	d6,a1		;address of garfield

;now print a garfield
	move.w	#46-1,d0
.loop:	move.l	(a2)+,(a1)
	move.l	(a2)+,8(a1)
	move.l	(a2)+,16(a1)
	move.l	(a2)+,24(a1)
	move.l	(a2)+,32(a1)
	move.l	(a2)+,40(a1)
	move.l	(a2)+,48(a1)
	move.l	(a2)+,56(a1)
	move.l	(a2)+,64(a1)
	move.l	(a2)+,72(a1)
	move.l	(a2)+,80(a1)
	move.l	(a2)+,88(a1)
	move.l	(a2)+,96(a1)
	move.l	(a2)+,104(a1)
	move.l	(a2)+,112(a1)
	move.l	(a2)+,120(a1)
	move.l	(a2)+,128(a1)
	move.l	(a2)+,136(a1)
	add.w	#160,a1
	dbf	d0,.loop
	rts
	
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
	MOVEM.L D0-d7,-(A7)

	MOVEM.L pic+2,d0-d7
	MOVEM.L d0-d7,$FFFF8240.W

	clr.w   $ff8264 ;STE bit wise shift
	move.w  #$ff00,$ff820e

	move.l  a0,d0
	move.l  pal_position,a0
	cmp.w   #$ffff,(a0)
	bne.s   no_colour_reset
	move.l  #pal_table,pal_position
no_colour_reset:
	move.l  d0,a0
	MOVEM.L (sp)+,D0-d7
	MOVE.B  #49,counter     ;49/50 of a second

	MOVE.L  #horiz_isr,$120.W
	clr.w   horiz_sync

	movem.l d0-d7/a0-a6,-(sp)
	jsr	tune+$7f2


;flash the disc drive light
	move.b  #10,$ff8800
	move.b  $ff8800,d7
	cmp.b   #14,d7
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

horiz_isr:      ;$120
	move.b  #4,$fffffa21.w    ;4 lines per horizontal interrupt
	move.l  #go_border,$120.w
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
	nop
	CLR.B   $FFFF820A.W
	REPT	29
	nop
	ENDR
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
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack_save
	rts

transfer:
	lea	pic+34,a0
	move.l	a0,a2
	add.w	#32000,a2
	move.l	#BASE,a1
	move.l	a1,a3
	add.w	#32000,a3
	move.w	#199,d7
lines:	move.w	#20-1,d6
words:	move.l	(a0)+,(a1)+
	move.l	-(a2),-(a3)
	move.w	d0,-(sp)
	move.w	#100,d0
del:	nop
	dbf	d0,del
	move.w	(sp)+,d0
	dbf	d6,words
	dbf	d7,lines
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

scroll_number:  dc.w    16
old_pal:	ds.b    32

line_ptr:
	dc.l    scroll_line
scroll_line:
 dc.b "              MAC SYS DATA AND HIS MERRY MEN PRESENT -      "
 dc.b "PERSISTENCE OF VISION DISC 19.        "
 dc.b "MENU CODED BY "
 dc.b "MAC SYS DATA.       "
 dc.b "MUSIC STOLEN FROM CUSTODIAN BY NIEL OF COR BLIMEY.   "
 dc.b "    NOTE: THIS MENU WAS CODED BY M.S.D. IN JANUARY 1990, IT "
 dc.b "WAS THEN RIPPED OFF BY OBERJE' AND LEE-LEE AND PUT ON "
 dc.b "AUTOMATION 237.      "
 dc.b "        MEMBERS OF P.O.V. ARE ;-     "
 dc.b "MAC SYS DATA,    BORIS,    DR.SYNE    AND ALY.            "
 dc.b "HI TO;-    ALAN R.,  GEORGE,  STEWART,  VAPOUR,  NIEL OF COR BLIMEY,  "
 dc.b "TCB,  TNT-CREW,  SLIPSTREAM (AMIGA)  AND  ABE (MY NEW AMIGA CONTACT).     "
 dc.b "     THIS WEEK (18-5-90) I'VE COPIED ABOUT 70 AUTOMATION DISCS AND 20 "
 DC.B "ASSORTED DISCS FROM EUROPE. I AM NOW DISC LESS!          "
 dc.b "IN THE COARSE OF WRITING THIS MENU, I SWAPPED FROM GENST 2.07 TO 2.08.  "
 DC.B "I'VE HAD 2.08 FOR AGES BUT STOPPED USING IT BECAUSE I THOUGHT THERE WAS A "
 DC.B "BUG IN THE ASSEMBLE TO DISC ROUTINE AND ORG FUNCTION.   ANDY PENNELL "
 DC.B "HAS ADMITTED THE BUG IN WRITING TO DISC (IT FILLS THE DISC UP SOMETIMES AND "
 DC.B "ALSO CREATES FILES WITH THE SAME NAME WHICH MAKES MY HARD-DISC DRIVER "
 DC.B "GO HAYWIRE!).    WELL, TODAY I FOUND A MAJOR BUG!     THE "
 DC.B "DCB.B FUNCTION ON VERSION 2.08 DOES NOT DO AS IT IS SHOULD, IT JUST "
 DC.B "RESERVES THE MEMORY LIKE DS.B.      I SPENT HALF OF LAST NIGHT TRYING "
 DC.B "TO DISCOVER WHY THE SCROLLINE KEPT GETTING STRAY BITS OF DATA IN IT. "
 DC.B "  IT WAS MADE EVEN HARDER TO TRACK DOWN THE FAULT "
 DC.B "BECAUSE YOU CAN'T RUN THE MENU USING MONST BECAUSE I TAKE OVER THE VBL AND "
 DC.B "HBL INTERRUPT VECTORS FOR THE BORDER ROUTINE.    WELL I'VE FIXED IT NOW AND "
 DC.B "SO HERE IS A HINT, DON'T USE 2.08 'COS IT'S GOT MORE BUGS IN IT THAN THE "
 DC.B "NEW BT EXCHANGE SOFTWARE!                THE TIME IS 18:38 AND I'LL BE "
 DC.B "STARTING DISC 20 TONIGHT.   MY STFM IS NOW PACKING THE SNOWMAN DEMO FOR "
 DC.B "A FUTURE RELEASE, SO FAR IT'S DONE 12 PERCENT OF 600K!      IF YOU ARE INTERESTED, "
 DC.B "THIS MENU WAS WRITTEN ON A 1040STE USING DEVPAC 2 WITH THE AID OF DEGAS ELITE, "
 DC.B "AND A 45 MEG HARD DISC!     THE GARFIELD PIC ORIGINALLY CAME FROM AN EASTER "
 DC.B "EGG BOX, I DIGITIZED IT USING THE NEW-TEK GOLD DIGITIZER ON THE AMIGA (I HAVE "
 DC.B "A 1 MEG AMIGA AS WELL!), I TRANSFERED THE PICTURE FROM AMIGA TO STE VIA THE "
 DC.B "RS232 USING KERMIT.   THE PICTURE WAS THEN LOADED INTO DEGAS ELITE USING THE "
 DC.B "LOAD BLOCK FUNCTION AND FINALLY COLOURED IN. THE SAME METHOD WAS USED FOR THE "
 DC.B "GARFIELD LOGO.    I HAVE 4 MORE GARFIELD PICS AND ABOUT 3 OTHER ASSORTED PICS THAT "
 DC.B "NEED COLOURING IN BEFORE GOING ON MENUS.          THE HARDEST AND MOST TIME "
 DC.B "CONSUMING PART OF DOING THESE DISCS IS WRITING THE MENU CODE AND TESTING THE "
 DC.B "DISCS ON ALL MACHINES.   I STILL HAVE P.O.V. 16,17 AND 18 READY FOR RELEASE "
 DC.B "BUT THEY HAVE NOT BEEN TESTED BECAUSE MY 2 ST'S ARE BOTH 1 MEG (MY STE WILL "
 DC.B "SOON BE 4 MEG!!!!!)                        HAVE YOU SEEN THE OPPOSITION TO OUR "
 DC.B "DISCS?            THEY ARE WRITTEN BY STEW AND BASICALLY HAVE A LOAD OF CRAP "
 DC.B "ON THEM. I MUST, HOWEVER, CONGRATULATE HIM ON SOME 'NICE' MENUS, IT'S A "
 DC.B "PITY HE CAN'T PACK THE DATA FILES AS WELL AS THE PRG FILES.     IF YOU'RE "
 DC.B "READING THIS STEW, GET IN TOUCH AND I'LL SEND YOU MY FILE PACKING DISC AND "
 DC.B "INSTRUCTION SHEET ON HOW TO PACK!           HEY THE STFM IS UPTO 16 PERCENT - WOW! "
 DC.B "        HAVE YOU ALL SEEN THE LOSTBOYS MINDBOMB DEMO YET?        EVERYONE "
 DC.B "IS RAVING ABOUT IT WIPING THE FLOOR WITH THE CUDDLY DEMO, BUT I THINK IT'S "
 DC.B "PRETTY BAD, THERE ARE ONLY ABOUT 2 DECENT SCREENS ON IT.     HOW COME TCB DEMOS "
 DC.B "ALWAYS LOOK POLISHED AND COMPLETE?  THE LOST BOYS DEMO LOOKS LIKE A PROJECT "
 DC.B "FOR A GCSE.      COME ON BOYS, WRITE SOMETHING AMAZING WITH LOADS OF COLOURS, "
 DC.B "SPRITES AND A BLOODY GOOD TUNE.       OH YEA, I LIKE THE RED SECTOR DEMO, IT "
 DC.B "IS VERY CLOSE TO THE AMIGA VERSION.          THAT'S IT... BYE     "
 dc.b "       REMEMBER... IT'S NOT BIG AND IT'S NOT CLEVER TO ATTEMPT TO COPY "
 dc.b "THE STYLE OF P.O.V. (DID YOU HEAR THAT STEW?   IF YOU WANT TO COMPETE, "
 DC.B "THEN TRY PACKING ALL THE DATA FILES INSTEAD OF USING PAMPUK TO MAKE PROGRAMS "
 DC.B "SINGLE PARTED 'COS PAMPUK MAKES THINGS 1 MEG.          "
 DC.B "........................................."
 DC.B "                                            "
	dc.b    $ff,$ff,$ff,$ff
	even
garfield_position:
	dc.l	init_garfield_table
init_garfield_table:
	dc.l	8,garfield_logos+(0*(46*72))
	dc.l	8,garfield_logos+(1*(46*72))
	dc.l	8,garfield_logos+(2*(46*72))
	dc.l	8,garfield_logos+(3*(46*72))
	dc.l	8,garfield_logos+(4*(46*72))
	dc.l	8,garfield_logos+(5*(46*72))
	dc.l	8,garfield_logos+(6*(46*72))
	dc.l	8,garfield_logos+(7*(46*72))
	dc.l	8,garfield_logos+(8*(46*72))
	dc.l	8,garfield_logos+(9*(46*72))
	dc.l	8,garfield_logos+(10*(46*72))
	dc.l	8,garfield_logos+(11*(46*72))
	dc.l	8,garfield_logos+(12*(46*72))
	dc.l	8,garfield_logos+(13*(46*72))
	dc.l	8,garfield_logos+(14*(46*72))
	dc.l	8,garfield_logos+(15*(46*72))

garfield_table:
	dc.l	0,garfield_logos
	dc.l	0,garfield_logos+(46*72)
	dc.l	0,garfield_logos+(2*(46*72))
	dc.l	0,garfield_logos+(3*(46*72))
	dc.l	0,garfield_logos+(4*(46*72))
	dc.l	0,garfield_logos+(5*(46*72))
	dc.l	0,garfield_logos+(6*(46*72))
	dc.l	0,garfield_logos+(7*(46*72))
	dc.l	0,garfield_logos+(8*(46*72))
	dc.l	0,garfield_logos+(9*(46*72))
	dc.l	0,garfield_logos+(10*(46*72))
	dc.l	0,garfield_logos+(11*(46*72))
	dc.l	0,garfield_logos+(12*(46*72))
	dc.l	0,garfield_logos+(13*(46*72))
	dc.l	0,garfield_logos+(14*(46*72))

;now go right
	dc.l	0,garfield_logos+(15*(46*72))
	dc.l	0,garfield_logos+(14*(46*72))
	dc.l	0,garfield_logos+(13*(46*72))
	dc.l	0,garfield_logos+(12*(46*72))
	dc.l	0,garfield_logos+(11*(46*72))
	dc.l	0,garfield_logos+(10*(46*72))
	dc.l	0,garfield_logos+(9*(46*72))
	dc.l	0,garfield_logos+(8*(46*72))
	dc.l	0,garfield_logos+(7*(46*72))
	dc.l	0,garfield_logos+(6*(46*72))
	dc.l	0,garfield_logos+(5*(46*72))
	dc.l	0,garfield_logos+(4*(46*72))
	dc.l	0,garfield_logos+(3*(46*72))
	dc.l	0,garfield_logos+(2*(46*72))
	dc.l	0,garfield_logos+(46*72)
	dc.l	0,garfield_logos

	dc.l	8,garfield_logos+(15*(46*72))
	dc.l	8,garfield_logos+(14*(46*72))
	dc.l	8,garfield_logos+(13*(46*72))
	dc.l	8,garfield_logos+(12*(46*72))
	dc.l	8,garfield_logos+(11*(46*72))
	dc.l	8,garfield_logos+(10*(46*72))
	dc.l	8,garfield_logos+(9*(46*72))
	dc.l	8,garfield_logos+(8*(46*72))
	dc.l	8,garfield_logos+(7*(46*72))
	dc.l	8,garfield_logos+(6*(46*72))
	dc.l	8,garfield_logos+(5*(46*72))
	dc.l	8,garfield_logos+(4*(46*72))
	dc.l	8,garfield_logos+(3*(46*72))
	dc.l	8,garfield_logos+(2*(46*72))
	dc.l	8,garfield_logos+(1*(46*72))
	dc.l	8,garfield_logos

	dc.l	16,garfield_logos+(15*(46*72))
	dc.l	16,garfield_logos+(14*(46*72))
	dc.l	16,garfield_logos+(13*(46*72))
	dc.l	16,garfield_logos+(12*(46*72))
	dc.l	16,garfield_logos+(11*(46*72))
	dc.l	16,garfield_logos+(10*(46*72))
	dc.l	16,garfield_logos+(9*(46*72))
	dc.l	16,garfield_logos+(8*(46*72))
	dc.l	16,garfield_logos+(7*(46*72))
	dc.l	16,garfield_logos+(6*(46*72))
	dc.l	16,garfield_logos+(5*(46*72))
	dc.l	16,garfield_logos+(4*(46*72))
	dc.l	16,garfield_logos+(3*(46*72))
	dc.l	16,garfield_logos+(2*(46*72))
	dc.l	16,garfield_logos+(1*(46*72))
	dc.l	16,garfield_logos

	dc.l	24,garfield_logos+(15*(46*72))
	dc.l	24,garfield_logos+(14*(46*72))
	dc.l	24,garfield_logos+(13*(46*72))
	dc.l	24,garfield_logos+(12*(46*72))
	dc.l	24,garfield_logos+(11*(46*72))
	dc.l	24,garfield_logos+(10*(46*72))
	dc.l	24,garfield_logos+(9*(46*72))

; now go left
	dc.l	24,garfield_logos+(10*(46*72))
	dc.l	24,garfield_logos+(11*(46*72))
	dc.l	24,garfield_logos+(12*(46*72))
	dc.l	24,garfield_logos+(13*(46*72))
	dc.l	24,garfield_logos+(14*(46*72))
	dc.l	24,garfield_logos+(15*(46*72))

	dc.l	16,garfield_logos
	dc.l	16,garfield_logos+(1*(46*72))
	dc.l	16,garfield_logos+(2*(46*72))
	dc.l	16,garfield_logos+(3*(46*72))
	dc.l	16,garfield_logos+(4*(46*72))
	dc.l	16,garfield_logos+(5*(46*72))
	dc.l	16,garfield_logos+(6*(46*72))
	dc.l	16,garfield_logos+(7*(46*72))
	dc.l	16,garfield_logos+(8*(46*72))
	dc.l	16,garfield_logos+(9*(46*72))
	dc.l	16,garfield_logos+(10*(46*72))
	dc.l	16,garfield_logos+(11*(46*72))
	dc.l	16,garfield_logos+(12*(46*72))
	dc.l	16,garfield_logos+(13*(46*72))
	dc.l	16,garfield_logos+(14*(46*72))
	dc.l	16,garfield_logos+(15*(46*72))

	dc.l	8,garfield_logos+(0*(46*72))
	dc.l	8,garfield_logos+(1*(46*72))
	dc.l	8,garfield_logos+(2*(46*72))
	dc.l	8,garfield_logos+(3*(46*72))
	dc.l	8,garfield_logos+(4*(46*72))
	dc.l	8,garfield_logos+(5*(46*72))
	dc.l	8,garfield_logos+(6*(46*72))
	dc.l	8,garfield_logos+(7*(46*72))
	dc.l	8,garfield_logos+(8*(46*72))
	dc.l	8,garfield_logos+(9*(46*72))
	dc.l	8,garfield_logos+(10*(46*72))
	dc.l	8,garfield_logos+(11*(46*72))
	dc.l	8,garfield_logos+(12*(46*72))
	dc.l	8,garfield_logos+(13*(46*72))
	dc.l	8,garfield_logos+(14*(46*72))
	dc.l	8,garfield_logos+(15*(46*72))

	dc.l	$ffffffff,$ffffffff
garfield_logos:
	incbin	"logo1.dat"
	incbin	"logo2.dat"
	incbin	"logo3.dat"
	incbin	"logo4.dat"
	even
font:
	incbin  "med_font.dat"
	even
pic     incbin  "garfield.PI1"
tune:   incbin "was97.img"
	even
filenames:
	dc.b    "ATG.MSD",0,0,0,0,0,0,0
	dc.b    "TNT3",0,0,0,0,0,0,0,0,0,0
	dc.b    "TNT4",0,0,0,0,0,0,0,0,0,0
	dc.b    "NO_NAME",0,0,0,0,0,0,0
buffer: dcb.b   0,BUFFER_SIZE
