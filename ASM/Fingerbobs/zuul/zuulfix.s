;========================================================================
;
; The Fingerbobs LOGO Demo V2.0
;
; Written for ZUUL's NTM Demo by Oberje'.
;
; V2.0 (C)1992  22/3/91
;
; This source code released to the world on 7th Aug 1992, via
; STatic BBS ( 0224 648277 )
;
; Please feel free to muck around with this as you like. But
; if you use any of it credit me, it's only polite.
;
; Features..
;
; o No Top-Bottom Borders ( Griff's mega 'Any-ST' code! )  	
; o 34 'Multi-scrolls', as supposed to just 15
;   and as an added bonus these actually work!             	
; o Wibbly Logo ( No CHANGE! ) A fast as I can make it just now.
; o Scrolls. Two of the buggers now. One at top, and one at 
;   bottom. Cut from 25 high to 23 high.		        		
; o Music ( No CHANGE ). Well you just can't improve it!
;
; The commenting in this code is quite adequate amd for the most part
; is also accurate.
;
; 20/8/97 AjB. Fixed with Code to build a non border kill version.
;	       Works better under the PaCifiST emulator!
;
; This optional version is cut as follows
;
; o Only 25 8-Bit scrolls
; o 2 Scrollers as before - positioning changed
; o Recommend music off - seems buggered, wrks most times but not all :)
; o Wibbly logo - position changed
;
;========================================================================

TIMING		equ	0	; Timing bars ON-OFF ( Debug )
STEP		equ	0	; Keystepping ON-OFF ( Debug )
DESK		equ	1	; Desktop Version ON-OFF
PDS		equ	0	; PDS ON-OFF
MUSIC_ON	equ	1	; Music ON-OFF

KILLBORDER	equ	0	; Top/Bottom Border Death


;
; Set positions of screen element, no of scrolls etc..
;
	IFNE KILLBORDER
scroll0pos	EQU	30	; 30
scroll1pos	EQU	223	; 223
logopos		EQU	83	; 83
screenhi	EQU	272	; 272
	ELSE
scroll0pos	EQU	10	; 10
scroll1pos	EQU	167	; 167
logopos		EQU	41	; 43
screenhi	EQU	200	; 200
	ENDC


addition	equ	$21

timing_bar	macro		; Use : 'timing_bar' 700 for red 
	IFNE	TIMING
	move.w	#$\1,$ffff8240.w
	ENDC
	endm

	IFNE	PDS
	org	$19000
	opt	d+
	opt	p+
	ENDC


;
; This is just test rubbish ( Tidy up! )
;
go	IFNE	DESK
	clr	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_stack
	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_res
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,old_screen
	clr	-(a7)
	pea	-1
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_palette
	ENDC

begin:
	move.l	#my_stack,a7

	movem.l	blank_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w

	IFNE	MUSIC_ON
	jsr	music_init		; Music init
	ENDC
	jsr	convert_message	; Scroller inits
	jsr	init_scroller
	jsr	restart_put_pos
	jsr	preshift_biglogo	; Init Wibble
	jsr	init_texts		; Init Multi-scroll

	;=======Start Interrupts======ie. border kills & rasters
	jsr	interrupts

loop	jsr	next_screen
	move.l	$466.w,d0
vsync	cmp.l	$466.w,d0
	beq.s	vsync

	timing_bar	700
	jsr	show_top		; Draw top scroller
	timing_bar	070
	jsr	show			; Do Logo
	timing_bar	500
	jsr	show_bottom		; Draw Bottom Scoller
	timing_bar	007
	jsr	deal_with_wibble	; Do texts
	timing_bar	200
	jsr	do_scroller		; Do Scroller(s)
	timing_bar	770
	IFNE	MUSIC_ON
	jsr	music_vbl		; Do music
	ENDC
	timing_bar	777		; Reset bars

	IFNE	STEP
wait_key
	btst #0,$fffffc00.w		; For debugging
	beq.s wait_key
	ENDC
		
	move.b $fffffc02.w,d0
	cmp.b #$39,d0
	bne.s	loop
	
	jsr	restore		; Restore interrupts
	
exit	IFNE	MUSIC_ON
	jsr	music_deinit
	ENDC

	IFNE	DESK
	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	old_stack,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_stack
	move.w	old_res,-(a7)
	move.l	old_screen,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	clr	-(a7)
	trap	#1
	ENDC
	IFNE	PDS
	trap	#0
	;move.w	#$2700,sr
	;jmp	$148.w
	ENDC
		
	rts
	
blank_palette	dc.l	0,0,0,0,0,0,0,0

	IFNE	DESK
old_palette	ds.w	16
old_res		ds.w	1
old_screen	ds.l	1
old_stack	ds.l	1
	ENDC

	ds.l	50
my_stack	ds.l	1

;---------------------------------------
;
; Wibbly Multi-scroller code
;
; I can't remember how this works, I think I wrote it
; when I was drunk!
;
;---------------------------------------
	;========Init texts===========
init_texts:
	move.l	#s_start,d0
	add.l	#512,d0
	move.b	#0,d0
	move.l	d0,screen_start
	move.l	d0,screen_pt
	add.l	#screenhi*$a0,d0
	move.l	d0,screen_end
	move.l	#wave_data,wave_pointer
	jsr	create_text_buffer

	move.l	screen_start,a0
	moveq	#0,d1
	move.l	#((screenhi*2*$a0)/4)-1,d0
.clear	move.l	d1,(a0)+
	dbf	d0,.clear
	rts

create_text_buffer
	lea message,a0
	lea repeat_message,a1
	moveq #39,d0
.loop	move.b (a0)+,(a1)+
	dbf d0,.loop		; Copy message

	move.l #text_length,d0	; Create 0 offset buffer
	move.l d0,d2
	asr.l #1,d0
	subq.l #1,d0
	
	lea message,a0
	lea scroll_buffer,a1
	lea char_set,a2
create_loop
	lea (a1),a4
	
	moveq	#0,d1
	move.b (a0)+,d1		; get char
	asl.w	#3,d1
	lea (a2,d1.w),a3
	rept	7
	move.b (a3)+,(a4)
	add.l d2,a4
	endr

	lea 1(a1),a4
	moveq #0,d1
	move.b (a0)+,d1		; get char
	asl.l	#3,d1
	lea (a2,d1.w),a3
	rept	7
	move.b (a3)+,(a4)
	add.l d2,a4
	endr

	lea 2(a1),a1
	
	dbf d0,create_loop

; Now create preshift copies 1-15

	lea	scroll_buffer,a0
	lea	(a0),a6
	moveq	#15-1,d4
.preshift
	lea	(a6),a0
	lea	text_length*7(a0),a1
	move.w	#(text_length*7)-1,d7
.copy_loop
	move.b	(a0)+,(a1)+
	dbf	d7,.copy_loop		; Copy
	
	move.w #7-1,d5
.line_loop
	lea text_length(a0),a0
	move.l #text_length,d6
	asr.l #1,d6
	subq.l #1,d6
.loop	roxl.w -(a0)
	dbf d6,.loop
	lea text_length(a0),a0
	dbf	d5,.line_loop

	lea	text_length*7(a6),a6
	dbf	d4,.preshift
	
	rts

screen_pt	dc.l	0

next_screen
	move.l	screen_pt,d0
	cmp.l	screen_end,d0
	bne.s	.over
	move.l	screen_start,d0
.over
	add.l	#8*$a0,d0
	move.l	d0,screen_pt
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	rts
	
value	ds.w	1

wave_pointer	ds.l	1

wave_data:	INCBIN SWIB.DAT

repeat_wave
	move.l	#wave_data,wave_pointer
	add.w	#addition,x_coord		; Inc X-coord
	move.w	x_coord,d0			; Deal with wrap
	cmp.w	#(text_length-40)*8,d0
	ble.s	.over
	sub.w	#(text_length-40)*8,d0
	move.w	d0,x_coord
.over
get_wave_data
	move.l	wave_pointer,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	bmi.s	repeat_wave
	move.l	a0,wave_pointer
	move.w	d0,value
	rts

deal_with_wibble
	bsr	get_wave_data
	moveq	#0,d0
	moveq	#0,d1
	move.w	x_coord,d0
	add.w	value,d0
	cmp.w	#(text_length-40)*8,d0
	ble.s	.over
	sub.w	#(text_length-40)*8,d0
.over
	move.w	d0,d1		; DUP
	and.w	#$f,d0		; X pre
	mulu	#text_length*7,d0
	asr.w	#4,d1		
	asl.w	#1,d1		
;	andi.w	#$f0,d1
;	asr.w	#3,d1
	lea	scroll_buffer,a5
	add.l	d1,a5
	add.l	d0,a5
	move.l	screen_pt,a4
	sub.l	#(8*$a0)-6,a4
	move.l	a4,a6
	add.l	#screenhi*$a0,a6
	jsr	draw_buffer
	rts

draw_buffer
	;
	; Assume,
	; 
	; a5=addr of scroll data
	; a4=addr to draw to
	; a6=other addr to draw to
	;
x	set 0
	rept	7
	movem.w (a5),d0-d7/a0-a3
	move.w d0,0*8+x(a4)
	move.w d1,1*8+x(a4)
	move.w d2,2*8+x(a4)
	move.w d3,3*8+x(a4)
	move.w d4,4*8+x(a4)
	move.w d5,5*8+x(a4)
	move.w d6,6*8+x(a4)
	move.w d7,7*8+x(a4)
	move.w a0,8*8+x(a4)
	move.w a1,9*8+x(a4)
	move.w a2,10*8+x(a4)
	move.w a3,11*8+x(a4)
	move.w d0,0*8+x(a6)
	move.w d1,1*8+x(a6)
	move.w d2,2*8+x(a6)
	move.w d3,3*8+x(a6)
	move.w d4,4*8+x(a6)
	move.w d5,5*8+x(a6)
	move.w d6,6*8+x(a6)
	move.w d7,7*8+x(a6)
	move.w a0,8*8+x(a6)
	move.w a1,9*8+x(a6)
	move.w a2,10*8+x(a6)
	move.w a3,11*8+x(a6)
	lea	24(a5),a5
	movem.w (a5),d0-d7
	move.w d0,12*8+x(a4)
	move.w d1,13*8+x(a4)
	move.w d2,14*8+x(a4)
	move.w d3,15*8+x(a4)
	move.w d4,16*8+x(a4)
	move.w d5,17*8+x(a4)
	move.w d6,18*8+x(a4)
	move.w d7,19*8+x(a4)
	move.w d0,12*8+x(a6)
	move.w d1,13*8+x(a6)
	move.w d2,14*8+x(a6)
	move.w d3,15*8+x(a6)
	move.w d4,16*8+x(a6)
	move.w d5,17*8+x(a6)
	move.w d6,18*8+x(a6)
	move.w d7,19*8+x(a6)
x	set $a0+x
	lea text_length-24(a5),a5
	endr

	; Cleanup!
MYARSE	EQU	0
	IFNE	MYARSE
	moveq	#0,d0
	move.w	d0,0*8+x(a4)
	move.w  d0,1*8+x(a4)
	move.w	d0,2*8+x(a4)
	move.w  d0,3*8+x(a4)
	move.w	d0,4*8+x(a4)
	move.w  d0,5*8+x(a4)
	move.w	d0,6*8+x(a4)
	move.w  d0,7*8+x(a4)
	move.w	d0,8*8+x(a4)
	move.w  d0,9*8+x(a4)
	move.w	d0,10*8+x(a4)
	move.w  d0,11*8+x(a4)
	move.w  d0,12*8+x(a4)
	move.w  d0,13*8+x(a4)
	move.w  d0,14*8+x(a4)
	move.w  d0,15*8+x(a4)
	move.w  d0,16*8+x(a4)
	move.w  d0,17*8+x(a4)
	move.w  d0,18*8+x(a4)
	move.w  d0,19*8+x(a4)
	move.w	d0,0*8+x(a6)
	move.w  d0,1*8+x(a6)
	move.w	d0,2*8+x(a6)
	move.w  d0,3*8+x(a6)
	move.w	d0,4*8+x(a6)
	move.w  d0,5*8+x(a6)
	move.w	d0,6*8+x(a6)
	move.w  d0,7*8+x(a6)
	move.w	d0,8*8+x(a6)
	move.w  d0,9*8+x(a6)
	move.w	d0,10*8+x(a6)
	move.w  d0,11*8+x(a6)
	move.w  d0,12*8+x(a6)
	move.w  d0,13*8+x(a6)
	move.w  d0,14*8+x(a6)
	move.w  d0,15*8+x(a6)
	move.w  d0,16*8+x(a6)
	move.w  d0,17*8+x(a6)
	move.w  d0,18*8+x(a6)
	move.w  d0,19*8+x(a6)
	ENDC

	rts

char_set:   INCBIN FRENCH.FNT

;
; 116 characters long
;
message
 dc.b "                                        "
 dc.b "HELLO JUNKIE, SWEETHEART,  LISTEN NOW, THIS IS YOUR CAPTAIN CALLING:...........YOUR CAPTAIN IS DEAD.    "
; dc.b "THIS IS THE WIBBLY MESSAGE IN THE BACKGROUND.   IT SHOULD "
; dc.b "BE QUITE SEXY BUT OF COURSE I MAKE NO GUARANTEES........  "
repeat_message
 dc.b 0
 ds.b 39
 
text_length	equ	repeat_message-message+40
buffer_size	equ	text_length*7*16

 even

x_coord	dc.w	0	

	even
 
scroll_buffer
 ds.b	buffer_size	; 
scroll_done

screen_start	ds.l	1
screen_end	ds.l	1

 
;--------------------------------------------------
;
;  Border Kill code & rasters
;
;--------------------------------------------------
* BOTH BORDER GET RIDDER.
* By Martin Griffiths (C) AUG 1989
* Using timer A for top border.
* updated MARCH 1990 - bottom bord made STE compatable.
*                    - Top border done with STOP to get 8 cycle sync.

interrupts	
	LEA old_mfp(PC),A0
	MOVE.B $FFFFFA07.W,(A0)+
	MOVE.B $FFFFFA09.W,(A0)+
	MOVE.B $FFFFFA13.W,(A0)+
	MOVE.B $FFFFFA15.W,(A0)+
	MOVE.B $FFFFFA19.W,(A0)+
	MOVE.B $FFFFFA1B.W,(A0)+
	MOVE.B $FFFFFA1F.W,(A0)+
	MOVE.B $FFFFFA21.W,(A0)+
	MOVE.L $68.W,(A0)+
	MOVE.L $70.W,(A0)+
	MOVE.L $120.W,(A0)+
	MOVE.L $134.W,(A0)+
	
	CLR.B $FFFFFA1B.W
	CLR.B $FFFFFA19.W
	MOVE.B #$21,$FFFFFA07.W
	CLR.B $FFFFFA09.W
	MOVE.B #$21,$FFFFFA13.W
	CLR.B $FFFFFA15.w
	BCLR.B #3,$FFFFFA17.W	;Auto-end-of-Interrupts
	MOVE.L #topbord,$134.W	; Timer A? cant remember - DOH!
	MOVE.L #hbl_1,$120.W
	MOVE.L #my_vbl,$70.W
	MOVE #$2300,SR
	rts

restore	MOVE #$2700,SR
	LEA old_mfp(PC),A0
	MOVE.B (A0)+,$FFFFFA07.W
	MOVE.B (A0)+,$FFFFFA09.W
	MOVE.B (A0)+,$FFFFFA13.W
	MOVE.B (A0)+,$FFFFFA15.W
	MOVE.B (A0)+,$FFFFFA19.W
	MOVE.B (A0)+,$FFFFFA1B.W
	MOVE.B (A0)+,$FFFFFA1F.W
	MOVE.B (A0)+,$FFFFFA21.W
	MOVE.L (A0)+,$68.W
	MOVE.L (A0)+,$70.W
	MOVE.L (A0)+,$120.W
	MOVE.L (A0)+,$134.W
	BSET.B #3,$FFFFFA17.W
	MOVE #$2300,SR
	rts
		
my_vbl	;movem.l	d0-d7/a0-a6,-(A7)
	;jmp	mainloop		; PDS in-line xfer shell
vbl_99	;movem.l	(a7)+,d0-d7/a0-a6
	CLR.B $FFFFFA19.W
	addq.l #1,$466.w	; Bump frame counter
	MOVE.B #100,$FFFFFA1F.W
	MOVE.B #4,$FFFFFA19.W
	CLR.B $FFFFFA1B.W

	IFNE KILLBORDER
	move.l #hb1,$120.w
	ELSE
	move.l #hb6,$120.w
	ENDC

	;;MOVE.B #228,$FFFFFA21.W	; 228 lines from top for bottom border kill
	MOVE.B #8,$FFFFFA21.W	
	MOVE.B #8,$FFFFFA1B.W
	MOVE.L #phbl,$68.W
	ADDQ #1,vbl_timer
	move.l a0,-(a7)
;	lea $ffff8240.w,a0
;	move.l #$00000111,(a0)+
;	move.l #$02220333,(a0)+
;	move.l #$04440555,(a0)+
;	move.l #$06660777,(a0)+
;	move.l #$04140111,(a0)+ <---------
;	move.l #$02220333,(a0)+
;	move.l #$04440555,(a0)+
;	move.l #$06660777,(a0)+
	lea $ffff8240.w,a0
	move.l #$00000001,(a0)+
	move.l #$01120223,(a0)+
	move.l #$0ccd0dde,(a0)+
	move.l #$0eef0f00,(a0)+
	move.l #$04140001,(a0)+ <---------
	move.l #$01120223,(a0)+
	move.l #$0ccd0dde,(a0)+
	move.l #$0eef0f00,(a0)+
	move.l (a7)+,a0
	RTE

topbord:
	MOVE #$2100,sr
	STOP #$2100
	CLR.B $FFFFFA19.W
	IFNE KILLBORDER
	rept 78
	DC.W $4e71
	endr	
	CLR.B $FFFF820A.W
	rept 18	
	DC.W $4E71
	endr
	MOVE.B #2,$FFFF820A.W
	ENDC
	RTE

phbl	RTE

do_hb	macro
	move.w	#$\1,$ffff8250.w
	move.l	#\2,$120.w
	rte
	endm

hb1	do_hb	513,hb2
hb2	do_hb	602,hb3
hb3	do_hb	612,hb4
hb4	do_hb	622,hb5
hb5	do_hb	532,hb6
hb6	do_hb	542,hb7
hb7	do_hb	453,hb8
hb8	do_hb	344,hb9
hb9	do_hb	245,hb10
hb10	move.l a0,usp
	lea $ffff8240.w,a0
	move.l #$00000c00,(a0)+
	move.l #$0ed10fff,(a0)+
	lea	8(a0),a0
	move.l #$03440c00,(a0)+ <---------
	move.l #$0ed10fff,(a0)
	move.l #hb11,$120.w
	move.l usp,a0
	rte
hb11	do_hb	453,hb12
hb12	do_hb	542,hb13
hb13	do_hb	532,hb14
hb14	do_hb	622,hb15
hb15	do_hb	612,hb16
hb16	do_hb	602,hb17
hb17	do_hb	513,hb18
hb18	do_hb	414,hb19
hb19	do_hb	513,hb20
hb20	do_hb	602,hb21
hb21	do_hb	612,hb22
hb22	do_hb	622,hb23
hb23	do_hb	532,hb24
hb24	do_hb	542,hb25

	IFNE KILLBORDER
hb25	do_hb	453,hb26
	ELSE
hb25    move.l a0,usp
	lea $ffff8240.w,a0
	move.l #$00000001,(a0)+
	move.l #$01120223,(a0)+
	move.l #$0ccd0dde,(a0)+
	move.l #$0eef0f00,(a0)+
	move.l #$04530001,(a0)+ <---------
	move.l #$01120223,(a0)+
	move.l #$0ccd0dde,(a0)+
	move.l #$0eef0f00,(a0)+
	move.l #hb26,$120.w
	move.l usp,a0
	rte
	ENDC

hb26	do_hb	344,hb27

	IFNE KILLBORDER
hb27	move.l a0,usp
;	lea $ffff8240.w,a0
;	move.l #$00000111,(a0)+
;	move.l #$02220333,(a0)+
;	move.l #$04440555,(a0)+
;	move.l #$06660777,(a0)+
;	move.l #$02450111,(a0)+ <-----
;	move.l #$02220333,(a0)+
;	move.l #$04440555,(a0)+
;	move.l #$06660777,(a0)
	lea $ffff8240.w,a0
	move.l #$00000001,(a0)+
	move.l #$01120223,(a0)+
	move.l #$0ccd0dde,(a0)+
	move.l #$0eef0f00,(a0)+
	move.l #$02450001,(a0)+ <---------
	move.l #$01120223,(a0)+
	move.l #$0ccd0dde,(a0)+
	move.l #$0eef0f00,(a0)+
	move.l #hb28,$120.w
	move.l usp,a0
	rte
	ELSE
hb27	do_hb	245,hb28
	ENDC

hb28	move.w #$344,$ffff8250.w
	move.b #0,$fffffa1b.w
	move.l #hbl_1,$120.w
	move.b #4,$fffffa21.w
	move.b #8,$fffffa1b.w
	rte

hbl_1:
	IFNE KILLBORDER
	MOVE D0,-(SP)
	rept 32	
	DC.W $4e71
	endr
	CLR D0
.syncb	MOVE.B $ffff8209.w,D0
	NEG.B D0
	ADD.B #64+128,D0
	LSL.B D0,D0
	MOVE #18,D0
.wait	DBF D0,.wait		;101 nops!
	MOVE.B #0,$FF820A
	rept 12	
	DC.W $4E71
	endr
	MOVE.B #2,$FF820A
	MOVE.w (SP)+,D0
	ENDC
	move.b #0,$fffffa1b.w
	move.l #hb29,$120.w
	move.b #4,$fffffa21.w
	move.b #8,$fffffa1b.w
	RTE

hb29	move.w #$453,$ffff8250.w
	move.b #0,$fffffa1b.w
	move.l #hb30,$120.w
	move.b #8,$fffffa21.w
	move.b #8,$fffffa1b.w

hb30	do_hb	542,hb31
hb31	do_hb	532,hb32
hb32	do_hb	622,hb33
hb33	do_hb	612,hb_end

hb_end	move.b #0,$fffffa1b.w
	rte
	
vbl_timer	DS.W 1
old_mfp		DS.L 7

;--------------------------------------------------------------
;
; LOGO WIBBLE CODE
;
;--------------------------------------------------------------

preshift_biglogo
	lea	logo,a0
	lea	output,a1
	move.l	a0,a2
	move.l	a1,a3
	moveq	#16-1,d7
.loop
	bsr	doshift
	lea	11040(a2),a0
	lea	11040(a3),a1
	move.l	a0,a2
	move.l	a1,a3
	dbf	d7,.loop
	rts
	
doshift move.l	#115-1,d0
dsloop
	rept	24
	move.l	(a0)+,(a1)+
	endr
	lea	-96(a1),a1
	roxr	0*4(a0)
	roxr	1*4(a0)
	roxr	2*4(a0)
	roxr	3*4(a0)
	roxr	4*4(a0)
	roxr	5*4(a0)
	roxr	6*4(a0)
	roxr	7*4(a0)
	roxr	8*4(a0)
	roxr	9*4(a0)
	roxr	10*4(a0)
	roxr	11*4(a0)
	roxr	12*4(a0)
	roxr	13*4(a0)
	roxr	14*4(a0)
	roxr	15*4(a0)
	roxr	16*4(a0)
	roxr	17*4(a0)
	roxr	18*4(a0)
	roxr	19*4(a0)
	roxr	20*4(a0)
	roxr	21*4(a0)
	roxr	22*4(a0)
	roxr	23*4(a0)
	roxr	2+0*4(a0)
	roxr	2+1*4(a0)
	roxr	2+2*4(a0)
	roxr	2+3*4(a0)
	roxr	2+4*4(a0)
	roxr	2+5*4(a0)
	roxr	2+6*4(a0)
	roxr	2+7*4(a0)
	roxr	2+8*4(a0)
	roxr	2+9*4(a0)
	roxr	2+10*4(a0)
	roxr	2+11*4(a0)
	roxr	2+12*4(a0)
	roxr	2+13*4(a0)
	roxr	2+14*4(a0)
	roxr	2+15*4(a0)
	roxr	2+16*4(a0)
	roxr	2+17*4(a0)
	roxr	2+18*4(a0)
	roxr	2+19*4(a0)
	roxr	2+20*4(a0)
	roxr	2+21*4(a0)
	roxr	2+22*4(a0)
	roxr	2+23*4(a0)
	lea	96(a1),a1
	dbf	d0,dsloop
	rts

show	bsr	create_linelist
	bsr	remove_logo_shite
	bsr	doshow2
	rts

at_list	dc.l	plain_list
	
try_again
	move.l	#plain_list,at_list
create_linelist
	move.l	at_list,a5
	add.l	#2,a5           
	cmp.l	#list_point,a5
	bge.s	try_again
	move.l	a5,at_list
	move.l	a5,a2
	
	lea	linelist,a0	; line list
	lea	shift_table,a1	; Addrs' of pre-shifted data
	*lea	plain_list,a2	; 'sine' list
	move.l	#0,d7		; Line offset
	move.w	#115-1,d0	
.loop
	moveq	#0,d1
	move.b	(a2)+,d1	; Get value ( 0-64 ) 32 = centre
	move.l	d1,d2		; Save
	andi.w	#%1111,d1	; Find pre-shift no.
	asl.w	#2,d1		; x4
	move.l	(a1,d1.w),d3	; Get addr of pre-shift data relevant
	add.l	d7,d3		; Add line offset
	andi.w	#%110000,d2	;
	asr.w	#2,d2		; Get word offset value
	add.l	d2,d3		; Add to pre-shift
	move.l	d3,(a0)+	; OUTPUT value
	add.l	#96,d7
	dbf	d0,.loop
	rts

plain_list:	
	INCBIN WIBBLE.TAB
list_point:
	INCBIN WIBBLE.TAB

	EVEN
	
shift_table	
	dc.l	output+14*11040+4
	dc.l	output+13*11040+4
	dc.l	output+12*11040+4
	dc.l	output+11*11040+4
	dc.l	output+10*11040+4
	dc.l	output+9*11040+4
	dc.l	output+8*11040+4
	dc.l	output+7*11040+4
	dc.l	output+6*11040+4
	dc.l	output+5*11040+4
	dc.l	output+4*11040+4
	dc.l	output+3*11040+4
	dc.l	output+2*11040+4
	dc.l	output+1*11040+4
	dc.l	output+0*11040+4
	dc.l	logo+4

linelist	ds.l	120

remove_logo_shite
	;
	; Rub out 8 lines at top left, because of 'multi-scroll'
	; effect
	;
	move.l	screen_pt,a5
	adda.l	#(logopos-8)*$a0,a5
	moveq	#0,d0
x	set	0
	rept	8
	move.l	d0,x+0*8(a5)
	move.l	d0,x+1*8(a5)
	move.l	d0,x+2*8(a5)
	move.l	d0,x+3*8(a5)
	move.l	d0,x+4*8(a5)
	move.l	d0,x+5*8(a5)
	move.l	d0,x+6*8(a5)
	move.l	d0,x+7*8(a5)
	move.l	d0,x+8*8(a5)
	move.l	d0,x+9*8(a5)
	move.l	d0,x+10*8(a5)
	move.l	d0,x+11*8(a5)
	move.l	d0,x+12*8(a5)
	move.l	d0,x+13*8(a5)
	move.l	d0,x+14*8(a5)
	move.l	d0,x+15*8(a5)
	move.l	d0,x+16*8(a5)
	move.l	d0,x+17*8(a5)
	move.l	d0,x+18*8(a5)
	move.l	d0,x+19*8(a5)
x	set	$a0+x
	endr
	
	;
	; Rub-out bottom 8 lines, cause of rubbish
	; carried over from screen wrap
	;
	move.l	screen_pt,a5
	adda.l	#(screenhi-8)*$a0,a5
	moveq	#0,d0
x	set	0
	rept	8
	move.l	d0,x+0*8(a5)
	move.w	d0,x+0*8+4(a5)
	move.l	d0,x+1*8(a5)
	move.w	d0,x+1*8+4(a5)
	move.l	d0,x+2*8(a5)
	move.w	d0,x+2*8+4(a5)
	move.l	d0,x+3*8(a5)
	move.w	d0,x+3*8+4(a5)
	move.l	d0,x+4*8(a5)
	move.w	d0,x+4*8+4(a5)
	move.l	d0,x+5*8(a5)
	move.w	d0,x+5*8+4(a5)
	move.l	d0,x+6*8(a5)
	move.w	d0,x+6*8+4(a5)
	move.l	d0,x+7*8(a5)
	move.w	d0,x+7*8+4(a5)
	move.l	d0,x+8*8(a5)
	move.w	d0,x+8*8+4(a5)
	move.l	d0,x+9*8(a5)
	move.w	d0,x+9*8+4(a5)
	move.l	d0,x+10*8(a5)
	move.w	d0,x+10*8+4(a5)
	move.l	d0,x+11*8(a5)
	move.w	d0,x+11*8+4(a5)
	move.l	d0,x+12*8(a5)
	move.w	d0,x+12*8+4(a5)
	move.l	d0,x+13*8(a5)
	move.w	d0,x+13*8+4(a5)
	move.l	d0,x+14*8(a5)
	move.w	d0,x+14*8+4(a5)
	move.l	d0,x+15*8(a5)
	move.w	d0,x+15*8+4(a5)
	move.l	d0,x+16*8(a5)
	move.w	d0,x+16*8+4(a5)
	move.l	d0,x+17*8(a5)
	move.w	d0,x+17*8+4(a5)
	move.l	d0,x+18*8(a5)
	move.w	d0,x+18*8+4(a5)
	move.l	d0,x+19*8(a5)
	move.w	d0,x+19*8+4(a5)
x	set	$a0+x
	endr
	rts
	
;
; Faster show rout.
;
doshow2	
	move.l	screen_pt,a5
	adda.l	#logopos*$a0,a5
	lea	linelist,a4
count	set	0
	rept	114
	move.l	(a4)+,a6	; NL
	movem.l	(a6)+,d0-d7/a0-a3
	move.l	d0,count+0*8(a5)	;1
	move.l	d1,count+1*8(a5)	;2
	move.l	d2,count+2*8(a5)	;3
	move.l	d3,count+3*8(a5)	;4
	move.l	d4,count+4*8(a5)	;5
	move.l	d5,count+5*8(a5)	;6
	move.l	d6,count+6*8(a5)	;7
	move.l	d7,count+7*8(a5)	;8
	move.l	a0,count+8*8(a5)	;9
	move.l	a1,count+9*8(a5)	;10
	move.l	a2,count+10*8(a5)	;11
	move.l	a3,count+11*8(a5)	;12
	movem.l	(a6)+,d0-d7	
	move.l	d0,count+12*8(a5)	;13
	move.l	d1,count+13*8(a5)	;14
	move.l	d2,count+14*8(a5)	;15
	move.l	d3,count+15*8(a5)	;16
	move.l	d4,count+16*8(a5)	;17
	move.l	d5,count+17*8(a5)	;18
	move.l	d6,count+18*8(a5)	;19
	move.l	d7,count+19*8(a5)	;20
count	set	20*8+count
	endr    
	rts	

	
;--------------------------------------------------------------
;       ================SCROLLER CODE=============
;--------------------------------------------------------------
	;
	;
clear_scroller_shite
	move.l	screen_pt,a1
	move.l	a1,a2
	add.l	#(scroll1pos-8)*$a0,a1
	add.l	#(scroll0pos-8)*$a0,a2
	moveq	#0,d0

;	rept	80*2
;	move.l	d0,(a1)+	
;	move.w	d0,(a1)+	
;	lea	2(a1),a1
;	move.l	d0,(a2)+	
;	move.w	d0,(a2)+	
;	lea	2(a2),a2
;	endr

x	set	0
	rept	80*2
	move.l	d0,x(a1)
	move.w	d0,x+4(a1)
	move.l	d0,x(a2)
	move.w	d0,x+4(a2)
x	set	8+x
	endr

	rts

show_top	
	jsr	clear_scroller_shite
	move.l	print_buffer,a0
	move.l	screen_pt,a1
	move.l	a1,a2
	add.l	#scroll0pos*$a0,a1
	bsr	show_buffer
	rts
show_bottom
	move.l	print_buffer,a0
	move.l	screen_pt,a1
	move.l	a1,a2
	add.l	#scroll1pos*$a0,a1
	bsr	show_buffer
	rts
show_buffer
x	set	0	
	rept	23
	movem.l	(a0)+,d0-d7/a3
	move.l	d0,0+x(a1)
	move.l	d2,10+x(a1)
	move.w	d1,8+x(a1)
	swap	d1
	move.w	d1,4+x(a1)
x	set	x+16
	move.l	d3,0+x(a1)
	move.l	d5,10+x(a1)
	move.w	d4,8+x(a1)
	swap	d4
	move.w	d4,4+x(a1)
x	set	x+16
	move.l	d6,0+x(a1)
	move.l	a3,10+x(a1)
	move.w	d7,8+x(a1)
	swap	d7
	move.w	d7,4+x(a1)
x	set	x+16
	movem.l	(a0)+,d0-d7/a3	;**************
	move.l	d0,0+x(a1)
	move.l	d2,10+x(a1)
	move.w	d1,8+x(a1)
	swap	d1
	move.w	d1,4+x(a1)
x	set	x+16
	move.l	d3,0+x(a1)
	move.l	d5,10+x(a1)
	move.w	d4,8+x(a1)
	swap	d4
	move.w	d4,4+x(a1)
x	set	x+16
	move.l	d6,0+x(a1)
	move.l	a3,10+x(a1)
	move.w	d7,8+x(a1)
	swap	d7
	move.w	d7,4+x(a1)
x	set	x+16
	movem.l	(a0)+,d0-d7/a3	;**************
	move.l	d0,0+x(a1)
	move.l	d2,10+x(a1)
	move.w	d1,8+x(a1)
	swap	d1
	move.w	d1,4+x(a1)
x	set	x+16
	move.l	d3,0+x(a1)
	move.l	d5,10+x(a1)
	move.w	d4,8+x(a1)
	swap	d4
	move.w	d4,4+x(a1)
x	set	x+16
	move.l	d6,0+x(a1)
	move.l	a3,10+x(a1)
	move.w	d7,8+x(a1)
	swap	d7
	move.w	d7,4+x(a1)
x	set	x+16
	movem.l	(a0)+,d0-d2	;**************
	move.l	d0,0+x(a1)
	move.l	d2,10+x(a1)
	move.w	d1,8+x(a1)
	swap	d1
	move.w	d1,4+x(a1)
x	set	x+16
	lea	120(a0),a0
	endr
	rts

scroll_pos_table
 dc.w 20*6,0*6,21*6,1*6,22*6,2*6,23*6,3*6,24*6,4*6,25*6,5*6,26*6,6*6,27*6,7*6,28*6,8*6,29*6,9*6
 dc.w 30*6,10*6,31*6,11*6,32*6,12*6,33*6,13*6,34*6,14*6,35*6,15*6,36*6,16*6,37*6,17*6,38*6,18*6,39*6,19*6,-1

scroll_put_pointer	dc.l	scroll_pos_table

restart_put_pos
	move.l	#scroll_pos_table,scroll_put_pointer
get_put_pos
	move.l	scroll_put_pointer,a0
	move.w	(a0)+,d0
	bmi.s	restart_put_pos
	move.w	d0,put_pos_1
	move.w	(a0)+,d0
	move.w	d0,put_pos_2
	move.l	a0,scroll_put_pointer
	rts
	
put_pos_1	ds.w	1
put_pos_2	ds.w	1

;--------------------------------------------------------------------------
; Letter handler
;--------------------------------------------------------------------------
restart_letter
	move.l	#s_message,here	;Start of scrolltext
get_letter
	move.l	here,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	restart_letter
	move.l	a0,here
	cmpi.b	#99,d0	
	beq	do_space
	subi.b	#32,d0	
	mulu	#26*12,d0	
	lea	charset,a0
	lea	(a0,d0.w),a0
	move.l	a0,letter_at	
	rts
do_space
	move.l	#space,letter_at
	rts
;--------------------------------------------------------------------------
; Init scroll variables
;--------------------------------------------------------------------------
init_scroller 
	move.l	#s_message,here	;Start of scrolltext
	move.l	#rout_1,do_scroller+2
	bsr	get_letter
	rts
;--------------------------------------------------------------------------
; Scroll routine entry point.....
;--------------------------------------------------------------------------
do_scroller	JMP	rout_1
rout_1	
	moveq	#0,d0
	moveq	#0,d1
	move.w	put_pos_1,d0
	move.w	put_pos_2,d1

	lea	buffer_1,a0
	lea	(a0),a3
	add.l	d0,a0
	add.l	d1,a3
	lea	buffer_2,a2
	add.l	d0,a2
	move.l	letter_at,a1
	rept	23
	move.b	0(a1),1(a0)
	move.b	2(a1),3(a0)
	move.b	4(a1),5(a0)
	move.b	1(a2),(a0)
	move.b	3(a2),2(a0)
	move.b	5(a2),4(a0)

	move.b	0(a1),1(a3)
	move.b	2(a1),3(a3)
	move.b	4(a1),5(a3)
	move.b	1(a2),(a3)
	move.b	3(a2),2(a3)
	move.b	5(a2),4(a3)
	lea	20*6*2(a0),a0
	lea	20*6*2(a3),a3
	lea	12(a1),a1
	lea	20*6*2(a2),a2
	endr	

	bsr	get_put_pos

	lea	buffer_2,a0
	add.l	d0,a0
	move.l	a0,print_buffer

	move.l	#rout_2,do_scroller+2
	rts
rout_2	
	moveq	#0,d0
	move.w	put_pos_2,d0
	lea	buffer_1,a0
	add.l	d0,a0
	move.l	a0,print_buffer

	moveq	#0,d0
	moveq	#0,d1
	move.w	put_pos_1,d1
	move.w	put_pos_2,d0

	lea	buffer_2,a0
	lea	(a0),a3
	add.l	d0,a0
	add.l	d1,a3
	move.l	letter_at,a1
	rept	23
	move.w	0(a1),0(a0)
	move.w	2(a1),2(a0)
	move.w	4(a1),4(a0)

	move.w	0(a1),0(a3)
	move.w	2(a1),2(a3)
	move.w	4(a1),4(a3)
	lea	12(a1),a1
	lea	20*6*2(a0),a0
	lea	20*6*2(a3),a3
	endr	

	move.l	#rout_3,do_scroller+2
	rts
rout_3	
	moveq	#0,d0
	moveq	#0,d1
	move.w	put_pos_1,d0
	move.w	put_pos_2,d1

	lea	buffer_1,a0
	lea	(a0),a3
	add.l	d0,a0
	add.l	d1,a3
	lea	buffer_2,a2
	add.l	d0,a2
	move.l	letter_at,a1
	rept	23
	move.b	6(a1),1(a0)
	move.b	8(a1),3(a0)
	move.b	10(a1),5(a0)
	move.b	1(a2),(a0)
	move.b	3(a2),2(a0)
	move.b	5(a2),4(a0)

	move.b	6(a1),1(a3)
	move.b	8(a1),3(a3)
	move.b	10(a1),5(a3)
	move.b	1(a2),(a3)
	move.b	3(a2),2(a3)
	move.b	5(a2),4(a3)
	lea	20*6*2(a0),a0
	lea	20*6*2(a3),a3
	lea	12(a1),a1
	lea	20*6*2(a2),a2
	endr	
	
	bsr	get_put_pos

	lea	buffer_2,a0
	add.l	d0,a0
	move.l	a0,print_buffer

	move.l	#rout_4,do_scroller+2
	rts
rout_4	
	moveq	#0,d0
	move.w	put_pos_2,d0

	lea	buffer_1,a0
	add.l	d0,a0
	move.l	a0,print_buffer

	moveq	#0,d0
	moveq	#0,d1
	move.w	put_pos_1,d1
	move.w	put_pos_2,d0

	lea	buffer_2,a0
	lea	(a0),a3
	add.l	d0,a0
	add.l	d1,a3
	move.l	letter_at,a1
	rept	23
	move.w	6(a1),0(a0)
	move.w	8(a1),2(a0)
	move.w	10(a1),4(a0)

	move.w	6(a1),0(a3)
	move.w	8(a1),2(a3)
	move.w	10(a1),4(a3)
	lea	12(a1),a1
	lea	20*6*2(a0),a0
	lea	20*6*2(a3),a3
	endr	

	bsr	get_letter
	
	move.l	#rout_1,do_scroller+2
	rts

print_buffer	dc.l	buffer_1

convert_message		; Convert messaage to ref. correct symbols etc...
	lea	s_message,a0
	lea	.chars,a1
.loop	moveq	#0,d0	; 99 - Blank, others -32 give actual pix data offsets
	move.b	(a0),d0
	beq.s	.end
	move.b	(a1,d0.w),d0
	move.b	d0,(a0)+
	bra.s	.loop
.end	rts
.chars	dc.b	99
	dc.b	99,99,99,99,99,99,99,99,99,99
	dc.b	99,99,99,99,99,99,99,99,99,99	
	dc.b	99,99,99,99,99,99,99,99,99,99
	dc.b	99,99,58,72,79,80,99,99,78,73
	dc.b	74,79,99,75,76,77,80,62,63,64
	dc.b	65,66,67,68,69,70,71,60,61,99
	dc.b	99,99,59,79,32,33,34,35,36,37
	dc.b	38,39,40,41,42,43,44,45,46,47
	dc.b	48,49,50,51,52,53,54,55,56,57,99

s_message	
 dc.b "            "
 dc.b " EVENING LADIES AND GENTLEMEN..........AND NOW AGAINST OUR BETTER"
 dc.b " JUDGEMENT AND ALSO AGAINST THE EXPRESS WISHES OF HER MAJESTY THE "
 dc.b "QUEEN OF ENGLAND, WE PRESENT TO YOU..................."
 dc.b "  THE SCROLLTEXT............   "
 dc.b "          BUT FIRST WE MUST UNCOVER THE DISPICABLE SCOUNDRELS WHO "
 DC.B "ARE TO BLAME FOR THIS CRIME AGAINST HUMANITY.             "
 DC.B "       THEY ARE...........            OBERJE : CHARGED WITH CODING THIS "
 DC.B "SCREEN AND WILLFULLY WRITING SOME SCROLLTEXT            "
 DC.B "      PIXAR : CHARGED WITH DRAWING THE LOVELY GRAPHICS AND WRITING "
 DC.B "SCROLLTEXT.                 COUNT ZERO ( ELECTRONIC IMAGES ) : CHARGED "
 DC.B "WITH CODING THE FAB-N-FUNKY-GET-UP-AND-BOOGIE MUSIC.          "
 DC.B "           ALL SUGGESTIONS FOR SUITABLE PUNISHMENTS ON A POSTCARD PLEASE. "
 DC.B " SEND YOUR ""THEY DESERVE IT"" SUGGESTIONS TO.......         "
 DC.B "            SOMEONE WHO GIVES A SHIT, SOMEWHERE, NOT HERE, POSTCODE.       "
 DC.B "           AND NOW......TAKE IT AWAY PIXAR............."
 dc.b "            "
 dc.b "    YO SCROLLMONSTERS!          THIS IS PIXAR WELCOMING YOU TO YET ANOTHER"
 dc.b " ROLLIN' SCROLLINE FROM THE BOYZ WITH THE NOIZE - THE FINGERBOBS.        "
 dc.b "      ONCE AGAIN OBERJE HAS PADLOCKED THE NESCAFE AND CHAINED ME TO THE "
 dc.b "KEYBOARD TO ENTERTAIN YOU FOLKS OUT THERE IN COUCH-POTATO-LAND. "
 dc.b "     THINGS TO LOOK FORWARD (AND GO OOOER THAT SOUNDS GOOD) TO IN THIS "
 dc.b "SCROLLER INCLUDING THE FABULOUS WIN A FINGERBOBS CUSTOM YUGO "
 dc.b "COMPETITION,    PIXARS TOP 10 ALL TIME BEST LIGHTBULB JOKES AND OF" 
 dc.b " COURSE THE COMPULSORY GREETS BIT TO PEOPLE I KNOW AND TO TOTAL "
 dc.b "STRANGERS THAT I CAN ONLY PRETEND TO KNOW.        BUT FIRST A GENERAL" 
 dc.b " WORD ABOUT THE SERIOUS SCROLLTEXT BOREDOM PROBLEM.................I'VE CHECKED "
 dc.b "OUT THE COMPETITION AND I'VE GOT TO SAY I WASN'T VERY IMPRESSED; "
 dc.b "THE BULK OF THE SCROLLERS OUT THERE ARE VERY DULL, REPETITIOUS "
 dc.b "AND REPETITIOUS.     BORING SCROLLERS REALLY SUCK EGGS SO THAT'S WHY "
 dc.b "THE FINGERBOBS HAVE LAUNCHED AN ACTION GROUP TO SORT THIS SORRY "
 dc.b "PROBLEM OUT.        IT'S CALLED SIMPLY, 'WORKING AGAINST SCROLLTEXT THAT "
 dc.b "EVERYBODY DETESTS'.        NOW WE'VE BEEN W.A.S.T.E.D. FOR SOME TIME NOW "
 dc.b "AND I THINK THAT COMES ACROSS IN THIS PARTICULAR SCROLLER. THIS "
 dc.b "IS NOT HOWEVER A LONE CRUSADE, SO HANDS UP ALL THOSE WHO WANT TO "
 dc.b "BE W.A.S.T.E.D.? .................. THAT MANY EH?    WELL THAT'S VERY ENCOURAGING "
 dc.b "AS YOU ARE NO DOUBT AWARE,       THE FINGERBOBS ARE ALWAYS TRYING TO "
 dc.b "GET YOU, 'SCROLL TEXT OFFERING NEW EXCITING DEVELOPMENTS'. TO "
 dc.b "THIS END WE'VE SPENT THE LAST COUPLE OF MONTHS GETTING "
 dc.b "S.T.O.N.E.D. AND W.A.S.T.E.D. JUST TO BRING YOU, THE VIEWER, THE "
 dc.b "BEST IN WELL FUNKY SCROLLINES.            YES BOB BUDDIES, IT'S ALL THANKS "
 dc.b "TO THE DUDES WITH THE GOODS,      OBERJE AND THE CAPED CRUSADER THAT "
 dc.b "THIS LITTLE BABY IS SCROLLING ITS WAY THROUGH YOUR 68000 RIGHT "
 dc.b "HERE AND NOW. PLEASE WAIT . . . . . . . . . . . . . . . . . . . . . . THANK YOU. "
 dc.b ". . . WHILE WE ENDEAVOUR AT ALL TIMES TO BRING YOU SCROLLTEXT "
 dc.b "THAT THROWS THE RULE BOOK OUT OF THE WINDOW, SCROLLTEXT THAT "
 dc.b "BREAKS NEW GROUND, WE ARE ALWAYS CAREFUL TO ENSURE THAT IT IS "
 dc.b "        1) FREE OF ANY HARMFUL BACKWARDS MESSAGES (EXCEPT MAYBE 'YENOM FO "
 dc.b "STOL SBOBREGNIF DNES' OR 'GNOS ECIN A SI NOITULOS EDICIUS') ....   "
 dc.b "        2) ENVIRONMENTALLY FRIENDLY  (IE. IT WON'T HANG YOUR ST). ...."
 dc.b "        3) FREE OF C.F.C.S  (COMPLETE F..KING CRAP) ....          4) FULLY "
 dc.b "RECYCLED  (IF YOU READ MY 1ST SCROLLER YOU'LL KNOW WHAT I MEAN). "
 dc.b "....          5) DOLPHIN FRIENDLY  (FLIPPER'S A BIG FAN) .... AND FINALLY "
 dc.b "        6) GREEN  (THIS ONE REALLY DEPENDS ON THE RASTERS. IF YOU LOOK AT THE SCREEN YOU WILL SEE THAT THIS SCREEN IS SLIGHTLY GREEN........BUT NOT A LOT!).            YES DUDES, "
 dc.b "EVERY WORD IS SCRUTINIZED AT FINGERBOBS CENTRAL TO ENSURE YOUR "
 dc.b "ABSOLUTE SAFETY AND ENJOYMENT. SHOULD THIS PRODUCT REACH YOU IN "
 dc.b "AN UNSAFE OR UNENJOYABLE STATE THEN IT IS PROBABLE THAT YOU HAVE "
 dc.b "OBTAINED AN  INFERIOR PRETEND VERSION. ANY PROBLEMS WITH THIS "
 dc.b "PRODUCT SHOULD BE ADDRESSED TO FINGERBOBS GLOBAL COMMAND CENTRE, "
 dc.b "(CONSUMER SERVICES DIVISION), UNIT 10, 1ST FLOOR, 138 HUTCHEON "
 dc.b "ST, ABERDEEN, SCOTLAND, AB2 3RX, UK. ............... DUE TO THE "
 dc.b "OVERWHELMING RESPONSE TO OUR SPOT THE BALL COMPETITION IN THE "
 dc.b "LAST SCROLLER THOSE NICE PEOPLE AT FINGERBOBS ARE OFFERING YOU "
 dc.b "THE CHANCE TO WIN ONE OF ONE BRAND NEW H REGISTERED FINGERBOBS "
 dc.b "CUSTOM DESIGNED YUGOS. YES, THE YUGO IS STATE OF THE ART HARDWARE "
 dc.b "AT THE CUTTING EDGE OF YUGOSLAVIAN CAR TECHNOLOGY! ITS MANY "
 dc.b "FEATURES INCLUDE........ WINDOWS (FOR ALL ROUND VISIBILITY),        WHEELS (FOR "
 dc.b "EASY MOVEMENT) AND.........  SIGNALS (FITTED FOR NON-CONTINENTAL DRIVERS "
 dc.b "ONLY).          ALL YOU HAVE TO DO TO HAVE A CHANCE OF WINNING YOUR DREAM "
 dc.b "YUGO IS ANSWER THESE 3 SIMPLE QUESTIONS -           Q1. IF OBERJE ON THE "
 dc.b "PLANET FINGERBOB STARTS OUT IN HIS SPACESHIP AT 20 MPH, AND HIS "
 dc.b "SPEED DOUBLES EVERY 3.2 SECONDS,         (A) HOW LONG WILL IT BE BEFORE "
 dc.b "HE EXCEEDS THE SPEED OF LIGHT?         (B) HOW LONG WILL IT BE BEFORE "
 dc.b "GALACTIC PATROL PICKS UP THE PIECES OF HIS SPACESHIP?-           Q2. "
 dc.b "IF THE CAPED CRUSADER WRECKS HIS CAR EVERY WEEK, AND EACH WEEK HE "
 dc.b "BREAKS TWICE AS MANY BONES AS BEFORE,         (A) HOW LONG WILL IT BE "
 dc.b "BEFORE HE BREAKS EVERY BONE IN HIS BODY?          (B) HOW LONG WILL IT BE "
 dc.b "BEFORE THEY CUT OFF HIS INSURANCE?          (C) WHERE DOES HE GET A NEW "
 dc.b "CAR EVERY WEEK?   -          Q3. IF PIXAR DRINKS ONE BEER THE FIRST HOUR, "
 dc.b "FOUR BEERS THE NEXT HOUR, NINE BEERS THE NEXT, ETC., AND HE "
 dc.b "STACKS THE CANS IN A PYRAMID,         (A) HOW SOON WILL PIXAR'S PYRAMID "
 dc.b "BE LARGER THAN KING TUT'S?          (B) WHEN WILL IT FALL ON HIM?         (C) "
 dc.b "WILL HE NOTICE?            - SO THERE ARE THE QUESTIONS, AND WE'LL NEED "
 dc.b "YOUR ANSWERS ON A POSTCARD, TO ARRIVE BY THE END OF THE "
 dc.b "SCROLLTEXT.           BUT NEXT, AS PROMISED (ISN'T CONTINUITY A WONDERFUL "
 dc.b "THING) THE LIGHTBULB JOKES. FROM 'LIGHTBULB JOKE U LIKE' AND "
 dc.b "'LIGHTBULB JOKES R US' (THANX POL) I GIVE YOU MY TOP 10 FAVOURITE "
 dc.b "ALL TIME LIGHTBULB JOKES, IN NO PARTICULAR ORDER.....         (1)  Q. HOW "
 dc.b "MANY PROGRAMMERS DOES IT TAKE TO SCREW IN A LIGHTBULB?	   A. "
 dc.b "NONE. THAT'S A HARDWARE PROBLEM.       (2)  Q. HOW MANY FOLK SINGERS "
 dc.b "DOES IT TAKE TO SCREW IN A LIGHTBULB?        A. TWO. ONE TO CHANGE "
 dc.b "THE BULB, AND ONE TO WRITE A SONG ABOUT HOW GOOD THE OLD LIGHT "
 dc.b "BULB WAS.          (3)  Q. HOW MANY SURREALISTS DOES IT TAKE TO CHANGE A "
 dc.b "LIGHTBULB?        A. TWO. ONE TO HOLD THE GIRAFFE, AND THE OTHER TO "
 dc.b "FILL THE BATHTUB WITH BRIGHTLY COLOURED MACHINE TOOLS.      (4)  Q. "
 dc.b "HOW MANY IBM TYPES DOES IT TAKE TO CHANGE A LIGHTBULB?      A. 100. "
 dc.b "TEN TO DO IT, AND 90 TO WRITE DOCUMENT NUMBER GC75004389-0001, "
 dc.b "MULTITASKING INCANDESCENT SOURCE SYSTEM FACILITY, OF WHICH 10% OF "
 dc.b "THE PAGES STATE ONLY 'THIS PAGE INTENTIONALLY LEFT BLANK' AND 20% "
 dc.b "OF THE DEFINITIONS ARE OF THE FORM 'A ...... CONSISTS OF "
 dc.b "SEQUENCES OF NON-BLANK CHARACTERS SEPERATED BY BLANKS'.       (5)  Q. "
 dc.b "HOW MANY THOUGHT POLICE DOES IT TAKE TO SCREW IN A LIGHTBULB? "
 dc.b "      A. NONE. THERE NEVER WAS ANY LIGHTBULB.       (6)  Q. HOW MANY FLIES "
 dc.b "DOES IT TAKE TO SCREW IN A LIGHTBULB?      A. TWO. BUT IT'S VERY "
 dc.b "UNCOMFORTABLE.       (7)  Q. HOW MANY PROLOG PROGRAMMERS DOES IT TAKE "
 dc.b "TO SCREW IN A LIGHTBULB?      A. NO.       (8)  Q. HOW MANY JOURNALISTS "
 dc.b "DOES IT TAKE TO SCREW IN A LIGHTBULB?      A. THREE. ONE TO REPORT "
 dc.b "IT AS AN INSPIRED GOVERNMENT PROGRAMME TO BRING LIGHT TO THE "
 dc.b "PEOPLE. ONE TO REPORT IT AS A DIABOLICAL GOVERNMENT PLOT TO "
 dc.b "DEPRIVE THE POOR OF DARKNESS, AND ONE TO WIN A PULITZER PRIZE FOR "
 dc.b "REPORTING THAT THE ELECTRIC COMPANY HIRED A LIGHTBULB-ASSASSIN TO "
 dc.b "BREAK THE BULB IN THE FIRST PLACE.       (9) Q.HOW MANY GALACTIC HITCHHIKERS "
 dc.b "DOES IT TAKE TO CHANGE A LIGHTBULB?       A. 42.       (10)  Q. HOW MANY "
 dc.b "EXISTENTIALISTS DOES IT TAKE TO SCREW IN A LIGHTBULB?      A. TWO. "
 dc.b "ONE TO SCREW IT IN AND ONE TO OBSERVE HOW THE LIGHTBULB ITSELF "
 dc.b "SYMBOLIZES A SINGLE INCANDESCENT BEACON OF SUBJECTIVE REALITY IN "
 dc.b "A NETHERWORLD OF ENDLESS ABSURDITY REACHING OUT TOWARD A MAUDLIN "
 dc.b "COSMOS OF NOTHINGNESS............... THERE YOU HAVE EM, AND THANX TO "
 dc.b "UNDERCOVER ELEPHANT FOR THOSE."
 
 DC.B "                  YIPPEEE.  OB-E-POOS BACK AT THE KEYBOARD! "
 DC.B "       AS YOU MAY HAVE HEARD FROM PIX-E-BABES, THE FINGERBOBS "
 DC.B " ( THATS US! ) HAVE BEEN PUTING QUITE A LOT OF EFFORT INTO "
 DC.B "THIS   W.A.S.T.E.D   AND   S.T.O.N.E.D   BUSINESS.    IN FACT SPURRED ON "
 DC.B "BY THE INITIAL SUCCESS OF THE W.A.S.T.E.D SCROLLTEXT WRITING "
 DC.B "PROGRAMME, I EMBARKED ON A SCIENTIFIC STUDY OF MY OWN.   "
 DC.B "  MY EXPERIMENTS INVOLVED MEASURING PERFORMANCE AGAINST LEVEL"
 DC.B " OF ALCOHOL ABUSE.          THE RESULTS, I THINK YOU WILL AGREE ARE "
 DC.B "QUITE INTERESTING.....................HERE THEY ARE.........."
 DC.B " ( ALL SCORES ARE GIVEN THUS.... -10 : DEATH       0 - VERY BAD      5 - NORMAL      10 - VERY GOOD      MORE - F..KING AMAZING!     )"
 DC.B "        SUBJECT : OBERJE'                 AGE : 20          "
 DC.B "       ZERO ALCOHOL RATING :  PERFORMANCE - 5         "
 DC.B "   ONE GLASS SOUTHERN COMFORT OR 1 BEER : PERFORMANCE - 6       "
 DC.B "   TWO GLASSES SOUTHERN COMFORT : PERFORMANCE - 8      "
 DC.B "   THREE GLASSES SOUTHERN COMFORT : PERFORMANCE - 6      "
 DC.B "   FOUR GLASSES SOUTHERN COMFORT : PERFORMANCE - 3      "
 DC.B "   F..K IT THE WHOLE BOTTLE : PERFORMANCE -  -10 ( NOT MUCH "
 DC.B "ABOVE PASSING OUT, OR SPEAKING SHITE IN A CORNER FOR TWO HOURS! )"
 DC.B "              AS A CONTROL EXPERIMENT I TRIED ANOTHER INEBRIATING"
 DC.B " COMPOUND........           "
 DC.B "   ZERO FOREIGN SUBSTANCE : PERFORMANCE - 6        "
 DC.B "   ONE JOINT : PERFORMANCE - 8        "
 DC.B "   TWO JOINT : PERFORMANCE - 10       "
 DC.B "   THREE JOINT : PERFORMANCE - HEY WHO CARES BABE!     "
 DC.B "   MORE : PERFORMANCE - DON'T ASK!          "
 DC.B "         AS YOU CAN SEE THE RESULTS PROVE CONCLUSIVLY THAT"
 DC.B " ALCOHOL IS GOOD FOR YOU IN MODERATION. AND IN EXCESS ITS BLOODY "
 DC.B "GOOD ALSO!           IF ANY OTHER PROGRAMMERS OUT THERE WOULD CARE TO "
 DC.B "REPEAT MY EXPERIMENTS FOR THEMSELVES, PLEASE LET ME KNOW IF YOUR "
 DC.B "RESULTS DEVIATE SIGNIFICANTLY FROM MINE.          "
 DC.B "           I WAS KINDA HOPING THAT THIS WOULD BE A REALLY "
 DC.B "LONG SCROLLTEXT, BUT I CAN SEE ALREADY THAT IT IS NOT VERY LONG " 
 DC.B "AT ALL! BOO HOO!     MAYBE IF I AM LUCKY THIS SCROLLER HAS STILL "
 DC.B "CAUSED YOU TO SUFFER FROM 'SCROLLERS-HEAD'.   THIS IS A LITTLE "
 DC.B "TALKED ABOUT CONDITION WHICH YOU HAVE PROBABLY ALL EXPERIENCED"
 DC.B " BEFORE.   NOW, DON'T BE SHY.   THE ONLY WAY TO CLEAR THE AIR, "
 DC.B "IS TO TALK ABOUT IT.............REPEAT AFTER ME.      "
 DC.B " (EMOTIONAL VOICE - TEARS WOULD BE NICE TOO!) ""MY NAME IS (INSERT NAME), AND I SUFFER"
 DC.B " FROM 'SCROLLER-HEAD'. "".          "
 DC.B " YES, EVEN I SUFFERED FROM SCROLLER HEAD ONCE.  IT HAPPED "
 DC.B "ONE SUNDAY AFTERNOOM. THE PREVIOUS DAY I HAD BEEN TO A LOCAL "
 DC.B "P.D. LIBRARY AND HAD AQUIRED A RATHER SPIFFING DEMO BY THE "
 DC.B "EXCEPTIONS CALLED THE B.I.G. DEMO.   SOMEWHERE NEAR THE START "
 DC.B "OF THE SCROLLER THE AUTHORS PROMISED TO REVEAL THE SECRET OF "
 DC.B "BORDER REMOVAL...........BUT, AT THE END OF THE SCROLLTEXT.   "
 DC.B " CURIOUS AS EVER, I SAT MYSELF DOWN AND BEGAN TO READ....."
 DC.B "                 HALF AN HOUR PASSED, I FELT FINE.......... "
 DC.B "              ANOTHER HALF-HOUR PASSED, I FELT A LITTLE STIFF, BUT BASICALLY OK........"
 DC.B "                ANOTHER HALF-HOUR PASSED AND MY MOTHER MADE ME SOME COFFEE"
 DC.B " AND ADVISED ME THAT IT WAS A LOVELY DAY OUTSIDE, PERHAPS I "
 DC.B "SHOULD GET AT LEAST ONE LUNGFULL OF AIR EVERY YEAR OR SO - I IGNORED HER....."
 DC.B "              FINALLY THE END OF THE SCROLLER ARRIVED, I HAD LEARNED ALL "
 DC.B "THERE WAS ABOUT EVERYTHING T.E.X. HAD EVER SEEN DONE READ-ABOUT SMELT "
 DC.B "PUNCHED KICKED SNOGGED. IT WAS ALL IN THERE, AND I HAD READ IT ALL......"
 DC.B "   THEN I TRIED TO STAND UP.......... THE ROOM KEPT SCROLLING.........."
 DC.B "       I TRIED TO SIT DOWN AGAIN........... THE ROOM LURCHED AGAIN......."
 DC.B "  I LOOKED AT MY HAND    -    IT WAS DIST-ING!        I SPUN ROUND IN VAIN "
 DC.B "LOOKING FOR SOMETHING THAT DIDN'T SCROLL OR DISTORT. I FOUND SOMETHING. "
 DC.B " OUTSIDE MY WINDOW I SAW A BLOODY BIG HOUSE THAT STOOD STILL.........."
 DC.B " THE 'SCROLLER-HEAD' FIT PASSED..........          "
 DC.B "      I WENT OUT INTO THE SUN AND DID NOT TOUCH MY COMPUTER FOR ALMOST "
 DC.B " 3 DAYS.         "
 DC.B " I ADVISE YOU, AFTER YOU HAVE WATCHED ALL OF THIS ZUUL'S FABBO NTM DEMO, "
 DC.B " BUGGER OFF OUTSIDE AND ENJOY YOURSELF........SUMMER DON'T LAST FOREVER. "
 DC.B "                     "
 DC.B " I HAVE RUN OUT OF THINGS TO SAY, SO AS A LAST RESORT HERE COME SOME "
 DC.B "GREETINGS............          "
 DC.B "LOVE AND KISSES TO...........            "
 DC.B "   ALL MY FELLOW INNER CIRCLE MEMBERS - LOVELY PEOPLE, ALL OF THEM!,     "
 DC.B "          MY BEST PALS AT RIPPED OFF - STICK AND BILBO,              JAKE AT "
 DC.B "CALEDONIA P.D.L - ARE YOU STILL PROVIDING A FAST EFFICIENT FRIENDLY "
 DC.B "COMPETENT SERVICE?,          FM - YES ONE DAY I WILL ACTUALLY SEND YOU A DISK! "
 DC.B "          ZUUL - OF COURSE!,               ST CONNEXION AND VANTAGE,          HEMOROIDS AND SINK,             PIPS AND DNT CREW - "
 DC.B "KEEP CODING THOSE GROOVY BOOTSECTORS!,              TSB AND IKI - I HOPE YOU FIND "
 DC.B "A NAME SOON!,          N.A.T.O. AND CHARON,          DEFBOY,          THE PUBLIC ENEMY ("
 DC.B " OF THE SYNDICATE ) AND BAT - NICE CD'S!,      "
 DC.B "          ROB AT THE BOMB SQUAD - KEEP CODING YOUR DEMO!,            LEELEE,           "
 DC.B "   MOB OF AUTOMATION - HELLO, I HAVE WRITTEN YOU A REPLY, I JUST 'AINT"
 DC.B " SENT IT YET!,           THE LOST BOYS AND SAMMY JOE,              JOHN AT THE DEMO CLUB,   "
 DC.B "   ROX AT ELECTRIC BLUE - I HAVEN'T STOLEN YOUR DISKS, I JUST CAN NEVER "
 DC.B "BE BOTHERED TO SEND THEM BACK! I WILL TRY!, "
 DC.B "           A BIG HELLO THOSE I HAVE FORGOTTEN! - SORRY!    "
 DC.B "    ALSO A WARM WAVE OF THE HAND TO        TEX, THE CAREBEARS, THE OTHER "
 DC.B "TRUELY LEGENDARY GROUPS ON THE ST.........            "
 DC.B "            AND OF COURSE I MUST ALSO GREET THE OTHER GROUPS IN THIS "
 DC.B "DEMO...............I DONT KNOW WHO YOU ALL ARE, BUT HELLO ANYWAY!        "
 DC.B "ADDITIONALLY I SEND SOME REGARDS TO KEITH AND STEWART - GOOD LUCK WITH CODING THOSE GAME(S).     "
 DC.B " AND ALSO A HELLO TO MY COLLEGE BUDDIES.............. A BIG BITCHIN' YO! TO.........."
 DC.B "  FLASH! - HOWS THE EAR?           HAXTY-BABES - MASTER OF BEER DRINKING AND VIDEO WATCHING!          "
 DC.B "       SOMMERVI - DID I EVER SEND YOU THOSE FONTS, I CAN'T REMEMBER!          "
 DC.B " GRAHME SUPREME OVERLORD OF THE UNIVERSE - WHATS WITH THE HAIR DUDE! BEFORE IT WAS A CREW CUT, "
 DC.B " ONE SANDWICH YEAR LATER AND IT RIVALS MINE IN LENGTH!            "
 DC.B "    AND WHILE I'M AT IT, I MOST DEFINATELY DON'T GREET GONZO - FUCK OFF YOU BORING LITTLE CUNT!        "
 DC.B "                                  "
 DC.B "     SORRY, BUT IT IS TIME TO WRAP........................             "
 DC.B 0

	even

charset	INCBIN 32_3.fnt	;Le Font!
space	ds.b	26*12	

here		ds.l	1
letter_at	ds.l	1
buffer_1	ds.b	26*6*20*2
buffer_2	ds.b	26*6*20*2
	
	
;===========================================================================	
;
; Tune : Snake from AWESOME
; By Tim Wright & Count Zero
;	
		IFNE	MUSIC_ON
		
music	INCBIN awe.mus

music_init	moveq	#1,d0
		bra	music

music_deinit	moveq	#0,d0
		bra	music

music_vbl	equ	music+6
		
		rts
		
		ENDC
;
;
;===========================================================================	

logo	INCBIN biglogo.dat
output	equ	*
s_start	equ	*+(11040*16)


   

;--------------------------------------------------------------
;			END
;--------------------------------------------------------------
   
   
	END BEGIN

