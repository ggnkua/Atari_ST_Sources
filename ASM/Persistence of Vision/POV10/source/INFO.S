* INFO FILE FOR POV 10

WIDTH:		equ	16	;pixels wide for letters
BUFFER_SIZE:	equ	32	;one character

	move.l	A7,A5
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	D0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
	or.b	#$2,$ff820a	;go into 50Hz

	dc.w	$a00a		;hide mouse
	bsr	hide_cursor
	bsr	get_screen_base
;	bsr	get_old_palette
	bsr	set_new_palette
;	bsr	get_original_rez
	bsr	set_low_rez
	bsr	show_pic

;************************************************************************
;*                            WICKED                                    *
;*                            ------                                    *
;* Stolen by: MAC SYS DATA of P.O.V. 4/11/89 17:00                      *
;*      From: GUARDIANS OF LOGIK 13                                     *
;* Include files:-                                                      *
;*                 WICKED.IMG into TUNE                                 *
;************************************************************************
;	bra	bypass
	move.b	#2,$484		;off with keyclick/bell

	lea	tune,a0
	lea	$3c85e,a1
trans:	move.b	(a0)+,(a1)+
	cmp.l	#endoftune,a0
	blt.s	trans

	jsr	$3c85e
bypass:
	move.w	#$2700,sr
; Store original vector slots
	move.l	$120,hbc	;horiz blank counter timing vector
	move.l	$70,v_blank
	move.b	$FFFa09,a09
	move.b	$FFFa07,a07
	move.b	$FFFa13,a13
	and.b	#$DF,$FFFA09
	and.b	#$FE,$FFFA07
	move.l	#isr1,$120
	move.l	#isr2,$70
	or.b	#1,$FFFA07	;EI
	or.b	#1,$FFFA13	;EI
	move.w	#$2300,sr


main_loop:
	bsr	vsync
;	move.w	#$123,$ff8240
	bsr	scroll
	bsr	scroll
	bsr	scroll
; 	move.w	pic+2,$ff8240
	bsr	tst_key
	tst.l	d0
	beq.s	main_loop

	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	beq.s	main_loop
	
	bsr	isr_off		;ok now off with colours

;*** set up for exit ***
	move.l	4,a0
	jmp	(a0)
;	bsr	set_old_palette
;	bsr	set_med_rez
;	bsr	show_cursor
;	dc.w	$a009
;	bsr	set_user

;	clr.w	-(sp)
;	MOVE.W	#$4c,-(SP)	; RETURN TO GEM DESKTOP.
;	TRAP	#1
;ERR:	bra.s	ERR


isr1:	
	move.l	a5,-(sp)
	move.l	isr_data,a5
	move.w	(a5)+,$ff8242
;	move.w	(a5)+,$ff8240
	move.l	a5,isr_data
	move.l	(sp)+,a5
	move.b	#1,$FFFa21		;1 line of each colour.....
	move.b	#8,$FFFA1B		;HBC timer
	bclr	#0,$FFFA0F	;EI
	rte

isr2:	;$70
	lea	isr_data(pc),a5
	move.l	#b_line,(a5)
	JSR	$3c980

	tst.w	vsync_flag
	beq.s	flag_notset
	sub.w	#1,vsync_flag
flag_notset:
	move.b	#1,$FFFa21		;1 line of each colour.....
	move.b	#8,$FFFA1B		;HBC timer
	bclr	#0,$FFFA0F	;EI
	rte

vsync:	move.w	#1,vsync_flag
vsyn:	tst.w	vsync_flag
	bne.s	vsyn
	rts

***********************
* SUBROUTINES SECTION *
***********************

scroll:	tst.w	enable
	beq.s	ok
	sub.w	#1,enable
	rts
ok:	move.l	line_ptr,a6	;need a new letter?
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3:	cmp.b	#1,(a6)
	bne.s	move
	move.w	#110,enable
	move.b	(a6)+,d5
	move.l	a6,line_ptr
	rts
move:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	clr.w	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr

	sub.w	#32,d0
	lsl.w	#5,d0	;*32 (single plane char set)
bp:
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
	move.l	(a6),(a1)

loop2:	move.l	screen_base,a6
	add.l	#160*144,a6
	move.l	a6,a2
	add.w	#152,a2

	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loop:	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	add.w	#160,a2
	dbf	d1,loop

	move.w	#16-1,d0
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
	sub.w	#1,scroll_number
	rts

isr_off:
	move.w	#$2700,sr
	move.l	v_blank,$70
	and.b	#$DF,$FFFA09
	and.b	#$FE,$FFFA07
	move.l	hbc,$120
	move.b	a07,$FFFa07
	move.b	a09,$FFFa09
	move.b	a13,$fffa13
	move.w	#$2300,sr
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
	rts

	rts

tst_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

;get_key:
;	move.w	#7,-(sp)
;	trap	#1
;	addq.l	#2,sp
;	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
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

show_pic:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts


****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16
line_ptr:	dc.l	scroll_line
scroll_number:	dc.w	16
enable:		dc.w	0

di_mouse:
	dc.b	$12,$1a
	even
hbc:
	dc.l	0
v_blank:
	dc.l	0
a09:
	dc.l	0
a07:
	dc.l	0
a13:
	dc.l	0
	even
vsync_flag:
	dc.w	1
line_count:
	dc.w	0	;count of horizontal line down screen for ISR1
isr_data:
	dc.l	0
b_line:
	dcb.w	$000,75
	dc.w	$080,$010,$090,$020,$0a0,$030,$0b0,$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
	dc.w	$8f0,$1f0,$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0,$ff0
	dc.w	$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$f00
	dc.w	$708,$e01,$609,$d02,$50a,$c03,$40b,$b04,$30c,$a05,$20d,$906,$10e,$807,$00f
	dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
	dc.w	$8ff,$1ff,$9ff,$2ff,$aff,$3ff,$bff,$4ff,$cff,$5ff
	dcb.w	$000,120
	dc.w	0,0,0
	even
pic:	incbin	"g:\info.pi1"
buffer:	dcb.b	0,BUFFER_SIZE


scroll_line:
 dc.b "P.O.V. INFO SCROLLINE.................                    "
 DC.B "PERSISTENCE OF VISION IS NOW MADE UP OF THE FOLLOWING MEMBERS ;- "
 DC.B "         MAC SYS DATA  -  CHIEF PROGRAMMER/HACKER/PACKER/ARTIST            DR.SYNE - DISTRIBUTION            ALY - MAIN GRAPHICS"
 DC.B "            BORIS - SECOND PROGRAMMER/SOME DEVELOPMENT WORK.              WE ALL LIVE AROUND THE BLACKPOOL AREA BUT BORIS IS PRESENTLY AT MANCHESTER "
 DC.B "DOING SOME COMPUTER DEGREE.      ALY IS A STUDENT AT PRESTON DOING SOME DEGREE IN "
 DC.B "ELECTRONICS.           "
 DC.B "             NOW A LIST OF OUR DISCS ------        1: MICROMIX 1 & 2  ",1," 2: FUZZBOX DEMO   ",1,"3: TEX DEMO 1-3 +  ",1,"XXX INTERNATIONAL 1 ",1,"4: GHOSTBUSTERS DEMO ",1
 dc.b "    5: A-HA DEMO    ",1,"6: SPACE ACE DEMO,  STARWARS RAP,  BOUNCING BALL,  XXX INTERNATIONAL GLOBE DEMO,  FLYING BIRD  AND MANYBOINK        7: TO BE RELEASED   ",1
 dc.b "8: MEGABANG 1 + LIVING ON VIDEO   ",1,"9: ROBOMIX + BAT DEMO + FUJIBOINK                 "
 dc.b "        NOTE: IF YOU ARE USING AN STE THEN YOU WILL BE SEEING TWICE AS MANY COLOURS THAN AN STFM USER.           "
 DC.B "               THAT'S IT, NO MORE DISC SPACE.............  DISC 11 WILL BE RELEASED IN TWO WEEKS.                "
	dc.b	$ff,$ff,$ff,$ff
	even
font:
	dcb.b	0,30
	incbin	"g:\big_set.img"
	even
tune:	incbin	"wicked.img"
endoftune:


