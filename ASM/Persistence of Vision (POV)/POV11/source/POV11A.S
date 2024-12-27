*****************************************************************
* Persistence Of Vision menu 11
* ----------------------------
*
* Written by MAC SYS DATA 15-1-90 23:00 on my 1040 STE (new today)
*              Finished :
*****************************************************************

WIDTH:		equ	16	;pixels wide for letters
BUFFER_SIZE:	equ	128	;one character
NO_LINES:	equ	16
ROLLER_LENGTH:	equ	41
go:
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	super_mode
	dc.w	$a00a
	bsr	get_scr_base
	bsr	get_res
	bsr	save_palette
	bsr	low_res
	or.b	#$2,$ff820a	;go into 50Hz

wait_for_drive:
	tst.w	$43e
	bne.s	wait_for_drive

	bsr	hide_mouse

	clr.w	-(sp)
	move.w	#14,-(sp)
	trap	#14
	addq.l	#4,sp
	move.l	d0,a0
	move.w	#1,4(a0)
	bsr	set_palette
	bsr	clear_screen
	move.w	#$006,$ffff8240.w

	move.l	screen_base,a0
	move.l	a0,horiz_tab

	move.l	#ripple_table,position
	move.l	#roller,roller_position

;************************************************************************
;*                          GOLDRUNNER II                               *
;*                          -------------                               *
;* Stolen by: MAC SYS DATA of P.O.V. 08/01/90 22:30                     *
;*      From: AUTOMATION disc 152                                       *
;* Include files:-                                                      *
;*                 AUTO152.IMG into TUNE                                *
;************************************************************************
	move.b	$484,old484
	move.b	#0,$484		;off with keyclick/bell
	move.l	#isr,$4d2	;use VBL to play tune

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION disc 152
; 1=tune 0 @ half speed
; 2=tune 2

	move.l	#2,D0
	jsr	tune

clr_k:
	bsr	check_key
	tst.l	d0
	beq.s	starter
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	bra.s	clr_k

starter:
	bsr	print_credits
	move.l	#0,D0
	jsr	tune
	bsr	set_palette
	jsr	set_screen

	bsr	show_picture
clr_buf:
	bsr	check_key
	tst.l	d0
	beq.s	main_loop
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	bra.s	clr_buf

main_loop:
	bsr	vsync
;	move.w	#$123,$ff8240
	bsr	ripple_up
	bsr	roll
	bsr	scroll
	bsr	scroll
	bsr	scroll
; 	move.w	pic+2,$ff8240
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
;	cmp.b	#27,d0
; 	beq.s	ex
	cmp.b	#$31,d0		;1 key
	blt.s	main_loop
	cmp.b	#$36,d0		;6 key
	bge.s	main_loop	
	jsr	endmus

;key is in D0.L
	lea	filenames,a6
	sub.b	#$31,d0
	cmp.b	#2,d0
	beq	mb
	cmp.b	#3,d0
	beq.s	ex
	mulu	#14,d0
	add.w	d0,a6

	bsr	fade
	bsr	user_mode

runaddr:
	pea	go
	pea	go
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
ert:
	move.w	#1,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bne.s	do
	bsr	super_mode
do:	move.l	4,a0
	jmp	(a0)

ex:
	jsr	endmus
	move.b	old484,$484

	bsr	restore_palette
	bsr	org_res
	bsr	show_mouse
	dc.w	$a009
	bsr	user_mode

	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp

mb:	jmp	mb2
***************
* Subroutines *
***************

scroll:	move.l	line_ptr,a6	;need a new letter?
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
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
	add.l	#32000-(16*160),a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling

	move.w	#16-1,d1
loop:	roxl.w	(a1)
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

ripple_up:
	move.l	screen_base,a1
	add.w	#56,a1
	add.w	#4*160,a1

	clr.w	line_count
	move.l	position,a0
	add.w	#1,a0
	move.l	a0,position
	cmp.b	#$ff,16(a0)
	move.l	a0,temp

	move.w	#NO_LINES-1,d7
ripple_loop:
	move.l	temp,a0
	move.b	(a0)+,d1
	move.l	a0,temp
	and.l	#$ff,d1
	cmp.b	#$ff,d1
	bne.s	no_reset_ripple
	move.l	#rrt,position
	move.l	position,temp
no_reset_ripple:
	move.w	line_count,d2
	add.w	#1,line_count
	mulu	#56,d2
	mulu	#56*16,d1
	lea	logo,a0
	add.w	d1,a0	;address of ripple
	add.w	d2,a0
	bsr	print_grafic
	dbf	d7,ripple_loop
	rts

print_grafic:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.w	#160-56,a1
	rts

roll:	move.l	screen_base,a6
	add.w	#160*140,a6
	add.w	#56,a6
	move.l	roller_position,a5
	cmp.l	#roller_end,a5
	bne.s	no_roller_rst
	move.l	#r_restart,roller_position
no_roller_rst:
	lea	table,a4
	move.w	#ROLLER_LENGTH-1,d7
.loop:	move.w	(a4)+,d0
	add.w	d0,a5
	move.l	(a5),(a6)	;roller is 16 pixels wide
	move.l	4(a5),4(a6)
	move.l	8(a5),8(a6)
	move.l	12(a5),12(a6)
	move.l	16(a5),16(a6)
	move.l	20(a5),20(a6)
	move.l	24(a5),24(a6)
	move.l	28(a5),28(a6)
	move.l	32(a5),32(a6)
	move.l	36(a5),36(a6)
	move.l	40(a5),40(a6)
	move.l	44(a5),44(a6)

	add.l	#160,a6
	dbf	d7,.loop
	add.l	#48,roller_position
	rts


vsync:	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

check_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

show_picture:
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
setup:	move.l	(a0)+,(a1)+
	dbf	d0,setup
	rts

wait_for_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_scr_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

super_mode:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	rts

user_mode:
	move.l	save_stk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_palette:
	lea	$ff8240,a0
	lea	old_palette,a1
	bra.s	change_palette

restore_palette:
	lea	old_palette,a0
	lea	$ff8240,a1
	bra.s	change_palette

set_palette:
	lea	pic+2,a0
	lea	$ff8240,a1

change_palette:
	moveq	#15,d0
change_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,change_pal
	rts

get_res:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,old_rez
	rts

low_res:
	clr.w	d0
	bra.s	change_res
med_res:
	moveq	#1,d0
	bra.s	change_res
org_res:
	move.w	old_rez,d0
change_res:
	move.w	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

hide_mouse:
	pea	di_mouse
	move.w	#2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_mouse:
	pea	ei_mouse
	move.w	#2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

print_credits:
	lea	credits_mess,a6
p_c:	bsr	check_key
	tst.l	d0
	bne.s	fin_pc
	tst.b	(a6)
	bne.s	pc2
fin_pc:	rts
pc2:	clr.l	d0
	move.b	(a6)+,d0
	cmp.b	#13,d0
	bgt.s	not_cr
	beq.s	cr
	cmp.b	#10,d0
	beq.s	sync
	cmp.b	#11,d0	;home
	beq.s	home
	cmp.b	#12,d0	;cls & home
	beq.s	clear_s
	bra.s	p_c
sync:	jsr	pause
	bra.s	p_c
home:	
	move.l	screen_base,a0
	clr.l	vertical_tab
	move.l	a0,horiz_tab
	bra.s	p_c
clear_s:
	bsr.s	clear_screen
	bra.s	p_c
cr:	add.l	#18*160,vertical_tab
	move.l	screen_base,a0
	move.l	a0,horiz_tab
	bra.s	p_c
not_cr:
	lea	font+6,a0
	sub.b	#32,d0
	mulu	#16*8,d0
	add.w	d0,a0
	bsr	print_letter
	add.l	#8,horiz_tab
	bra	p_c

print_letter:
	jsr	vsync
	move.l	horiz_tab,a1
	add.l	vertical_tab,a1
	move.w	#16-1,d0
.loop:	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	add.w	#160,a1
	dbf	d0,.loop
	rts

clear_screen:
	move.l	screen_base,a0
	clr.l	vertical_tab
	move.l	a0,horiz_tab
	move.w	#32000/4-1,d0
.loop:	clr.l	(a0)+
	dbf	d0,.loop
	rts

pause:	move.l	d0,-(sp)
	move.w	#100,d0
pau:	bsr	vsync
	dbf	d0,pau
	move.l	(sp)+,d0
	rts

set_screen:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

isr:	movem.l	d0-d7/a0-a6,-(sp)
	jsr	tune+$10a
	movem.l	(sp)+,d0-d7/a0-a6
	rts

endmus:	clr.l	$4D2
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
	rts

fade:	move.w	#$114,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$003,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$002,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$001,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$000,$ffff8240.w
cls:	pea	cls_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
cls_mess:
	dc.b	27,'E',0,0

********
* Data *
********
scroll_number:	dc.w	16
di_mouse:
	dc.b	$12,$1a
	even
ei_mouse:
	dc.b	$14,8
	even
line_ptr:	dc.l	scroll_line
	even
old_palette:
	ds.b	32
old_rez:
	dc.w	0

buffer:	dcb.b	0,BUFFER_SIZE

	even
screen_base:
	dc.l	0

	ds.l	25
save_stk:
	dc.l	0
	even

position:	dc.l	0
temp:		dc.l	0
line_count:	dc.w	0
roller_position:	dc.l	0

scroll_line:
 dc.b "WELCOME TO P.O.V. DISC 11.     RELEASED 7/2/90          "
 dc.b "P.O.V. ARE . . . .          "
 dc.b "MAC SYS DATA        BORIS        DR.SYNE"
 DC.B "        AND ALY              "
 dc.b "HELLO TO THE FOLLOWING ...       "
 dc.b "AUTOMATION, "
 dc.b "THE BLADERUNNERS, "
 dc.b "THE UNION, "
 dc.b "ALAN.R, "
 dc.b "GEORGE, "
 dc.b "TCB, "
 DC.B "BASHER, "
 DC.B "THE LOST BOYS "
 DC.B "AND "
 dc.b "THE REPLICANTS.           "
 dc.b "TODAYS DATE IS 15/1/90 AND I'M WRITTING THIS ON MY NEW 1040 STE.   "
 DC.B "I PICKED IT UP JUST 6 HOURS AGO AND IT'S GOING GREAT, I'VE HAD A "
 DC.B "GO AT THE HARWARE SCROLLING AND IT WORKS (SORT OF)!  UNFORTUNATELY "
 dc.b "BECAUSE THE STE ISN'T OFFICIALLY LAUNCHED UNTIL MARCH, I DID NOT "
 DC.B "RECEIVE THE SPECIAL CONTROL PANEL TO DEFINE THE PALETTE FROM 4096 "
 DC.B "COLOURS (BAH, HUMBUG)   BUT DON'T PANIC BECAUSE I'VE FIGURED OUT HOW THE COLOURS "
 dc.b "ARE STORED SO LOOK OUT FOR SOME STE ONLY SCREENS FROM P.O.V. REAL SOON  (HAVE A LOOK AT THE INFO FILE ON P.O.V. 10)! "
 dc.b "              IF YOU WISH TO CONTACT ANY MEMBER OF PERSISTENCE OF VISION, THEN GET DO SO VIA THE FOLLOWING SYSTEM ....... "
 DC.B "   GET ONTO THE NATIONAL 'JANET' SYSTEM AVAILABLE AT MOST POLYTECHNICS.   THE USER ID IS :- MOFFAT[AS      SITE:- LANCS P.P2.   "
 DC.B "THE MESSAGE WILL GO VIA LANCASHIRE POLYTECHNIC AT PRESTON AND WILL APPEAR ON ALY'S ACCOUNT.  WE WILL TRY TO ANSWER ALL "
 DC.B "MESSAGES, IF THERE IS A SPECIAL DEMO YOU WISH TO SEE ON A P.O.V. MENU THEN PLEASE TELL US, ALSO TELL US WHERE WE CAN GET A COPY. "
 DC.B "             WELL THE @ IS GETTING "
 DC.B "ON, SO I BETTER GET ON WITH DISC 12.                NOTE: STE OWNERS PLEASE LOOK AT THE DIRECTORY OF THIS DISC, THERE IS A SMALL "
 dc.b "DEMO FILE FOR YOU TO LOOK AT.           "
 DC.B "    WRAP IT-                                           "
	dc.b	$ff,$ff,$ff,$ff
	even
horiz_tab:	dc.l	0
vertical_tab:	dc.l	0
credits_mess:
	dc.b	10
	dc.b	13,13,13
	dc.b	"     PERSISTENCE",13
	dc.b	"         OF",13
	dc.b	"       VISION",13,10,12

	dc.b	13,13,13,13
	dc.b	"      PRESENTS",10,12

	dc.b	13,13,13
	dc.b	"        DEMO",13
	dc.b	"     COMPILATION",13,13
	dc.b	"      DISC 11",10,12

	dc.b	"      CREDITS",13
	dc.b	"      -------",13,13
	dc.b	"    PROGRAMMING:",13
	dc.b	"    MAC SYS DATA",13,13,10

	dc.b	"      ARTWORK:",13
	dc.b	"        ALY",10,13,13

	dc.b	"   DISTRIBUTION:",13
	dc.b	"      DR.SYNE",10,12

	dc.b	"  FURTHER CREDITS",13
	dc.b	"  ---------------",13,13
	dc.b	"   NO ADDITIONAL",13
	dc.b	"  PROGRAMMING BY:",13,13
	dc.b	"       BORIS",13,13,10
	dc.b	"ALL HACKS AND PACKS",13
	dc.b	"        BY:",13
	dc.b	"    MAC SYS DATA",13
	dc.b	10,12
	dc.b	0
	even
old484:	dc.w	0
pic:	incbin	"pov11.pi1"
	even

font:	dc.w	0,0,0
	incbin	"pov11set.dat"
	even

tune:	incbin	"GRUNNER.MUS"
logo:	incbin	"shift_11.dat"

ripple_table
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8

	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
rrt:	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8

	dc.b	7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0
	dc.b	1,1,2,2,3,3,4,4,5,5,6,6
	dc.b	7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0

	dc.b	1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11
	dc.b	12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11
	dc.b	10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

	dc.b	0,0,0,1,1,1,2,2,2,3,3,3,4,4,4
	dc.b	5,5,5,6,6,6,7,7,7,8,8,8,9,9,9
	dc.b	10,10,10,11,11,11,12,12,12,13,13,13
	dc.b	14,14,14,15,15,15,14,14,14,13,13,13
	dc.b	12,12,12,11,11,11,10,10,10,9,9,9
	dc.b	8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1

	dc.b	1,1,1,1,1
	dc.b	2,2,2,2,2
	dc.b	3,3,3,3,3
	dc.b	4,4,4,4,4
	dc.b	5,5,5,5,5
	dc.b	6,6,6,6,6
	dc.b	7,7,7,7,7
	dc.b	8,8,8,8,8
	dc.b	9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b	14,14,13,13,12,12,11,11,10,10
	dc.b	9,9,9,9,9
	dc.b	10,10,10,10,10
	dc.b	11,11,11,11,11
	dc.b	12,12,12,12,12
	dc.b	13,13,13,13,13
	dc.b	14,14,14,14,14
	dc.b	15,15,15,15,15
	dc.b	14,14,14,14,14
	dc.b	13,13,13,13,13
	dc.b	12,12,12,12,12
	dc.b	11,11,11,11,11
	dc.b	10,10,10,10,10
	dc.b	9,9,9,9,9
	dc.b	8,8,8,8,8
	dc.b	7,7,7,7,7
	dc.b	6,6,6,6,6
	dc.b	5,5,5,5,5
	dc.b	4,4,4,4,4
	dc.b	3,3,3,3,3
	dc.b	2,2,2,2,2
	dc.b	1,1,1,1,1

	dc.b	0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4
	dc.b	5,5,5,5,6,6,6,6,6,7,7,7,7
	dc.b	8,8,8,9,9,9,10,10,11,11,10,10,9,9,8,8,7,7,6,6,7,8,9,10,11,10,9
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	9,10,12,14,15,14,12,10,8,6,4,2,0
	dc.b	1,1,2,2,3,3,4,4,5,6,7,8,9,10,12,14,13,13,13,12,12,12,11,11,11
	dc.b	10,10,10,9,9,9

	dc.b	8,8,7,5,3,1,3,5,7,9,11,13,15
	dc.b	13,11,9,7,5,3,1,3,5,7,9,11,13,15

	dc.b	8,8,7,5,3,1,3,5,7,9,11,13,15
	dc.b	13,11,9,7,5,3,1,3,5,7,9,11,13,15

	dc.b	14,14,13,13,12,12,11,10,9,8,9,10,11,11,10,10,9,9

	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8

	dc.b	6,6,5,5,4,4,3,3,5,7,9,11,13,15,13,11,9,7,5,3,2,2,1,1,0,0
	dc.b	1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13
	dc.b	14,14,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9
	dc.b	8,8,8,8,8,8,8,8
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dc.b	15,13,11,9

	dc.b	8,7,6,5,4,3,2,1,0,0,0,1,1,1,2,2,2,3,3,3,4,4,4
	dc.b	5,6,7,8,9,10,9,8,9
	dc.b	10,10,10,11,12,13,12,11,11,11,12,12,12,13,13,13
	dc.b	14,15,14,14,14,15,15,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
 dc.b 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
 dc.b 1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,3,2,1,2,3,4,5,6,6,6,7,7,7,8,8,8,9,10,11,10,9,8,7,6,7,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,14,13,12,11,10,8,6,4,3,2,2,1,1,1,0,0,0
 dc.b 1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,3,2,1,2,3,4,5,6,6,6,7,7,7,8,8,8,9,10,11,10,9,8,7,6,7,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,14,13,12,11,10,8,6,4,3,2,2,1,1,1,0,0,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	14,12,10,8,6,4,2,0,2,4,6,8,10,12,14,13,13,12,12,11,10,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8


	dc.b	$ff,$ff
	even
roller:	dcb.w	0,(48*200)
r_restart:
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1

	incbin	"roller.dat"
roller_end:
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	0,$8000,$8000,$8000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	even
table:
	dc.w	48+48+48+48
	dc.w	48+48+48+48
	dc.w	48+48+48
	dc.w	48+48
	dc.w	48+48
	dc.w	48+48
	dc.w	48
	dc.w	48+48
	dc.w	48
	dc.w	48
	dc.w	48+48
	dcb.w	48,21
	dc.w	48+48
	dc.w	48
	dc.w	48
	dc.w	48+48
	dc.w	48
	dc.w	48+48
	dc.w	48+48+48
	dc.w	48+48+48+48
	dc.w	48+48+48+48
filenames:
	dc.b	"FULLSCRN.MSD",0,0
	dc.b	"OUTRUN.PRG",0,0,0,0
	dc.b	"filename.ext",0,0	;Megabang 2
	dc.b	"filename.ext",0,0	;junk demo
	dc.b	"wave.xxx",0,0,0,0,0,0,0
	even
mb2:
****************************************************************
*                   TRAP 1 interception routine                *
*                   ---------------------------                *
*                                                              *
* Written by MAC SYS DATA  JAN '90                             *
* Version 2.1                                                  *
****************************************************************
	move.w	#0,$ffff8240.w
	pea	mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	jsr	cls

	lea	do_jmp+2,a0
	move.l	$84,(a0)
	lea	new_trap1(pc),a0
	lea	$9000,a1
loopa:	move.b	(a0)+,(a1)+
	cmp.l	#laddr,a0
	blt.s	loopa

	move.l	#$9000,$84

	bra	loader

new_trap1:
	movem.l	d0-d7/a0-a6,$9000-100
	move.l	sp,a1
	addq.l	#6,a1
	move.w	(sp),d0
	btst	#13,d0
	bne.s	in_user

	move.l	USP,a1

in_user:
	cmp.w	#$3f,(a1)	;F_READ call.
	bne	go_jmp

	lea	store_sr(pc),a0
	move.w	(sp)+,(a0)+	;store SR
	move.l	(sp)+,(a0)	;and PC for return address

; simulate the load routine by putting all the bits back on the stack
; at the correct position.
	lea	$c(a1),a3
	move.l	-(a3),-(sp)	;address to load at
	move.l	-(a3),-(sp)	;number of bytes
	move.l	-(a3),-(sp)	;file handle and $3f for f_read

	pea	trap1_return(pc);push our return address to stack.
	move.w	#$2300,-(sp)	;put the SR back on the stack.

;return saved registers here........
go_jmp:	movem.l	$9000-100,d0-d7/a0-a6
do_jmp:	jmp	0		;and jump to ROM


; the read routine will return to here now... (depack)
trap1_return:
	movem.l	d0-d7/a0-a6,$9000-100

	lea	bytes_loaded(pc),a3
	move.l	d0,(a3)		;store number of bytes read

	move.l	8(sp),a1	;get where to load
	move.l	4(sp),a2	;how much to load
	add.l	#$c,sp

	move.l	a1,a3
	add.l	d0,a1	;get end of file?
	sub.w	#4,a1	;back up 4 bytes to start of ident long-word

	move.b	(a1),d1		;1st letter
	rol.l	#8,d1
	move.b	1(a1),d1	;2nd
	rol.l	#8,d1
	move.b	2(a1),d1	;3rd
	rol.l	#8,d1
	move.b	3(a1),d1	;4th
	cmp.l	#"MSD!",d1	;check ident long-word (if LSD pack then LSD!)
	bne.s	exit_trap1	;not packed	       (if JEK pack then JEK!)
;						       (if POV pack then MSD!)
; a0 must point to end of compacted code
; a1 must point to destination
	move.l	a1,a0
	move.l	a3,a1

	bsr	depak

exit_trap1:
	movem.l	$9000-100,d0-d7/a0-a6
	lea	bytes_loaded(pc),a0
	move.l	(a0),d0			; no. bytes loaded.
	lea	store_sr(pc),a0
	move.w	(a0)+,sr
	move.l	(a0),-(sp)
	rts

bytes_loaded:	dc.l	0

store_sr:	dc.w	0
store_pc:	dc.l	0

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
	blt.s 	l1
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

	even
laddr:	dc.l	0

loader:
	lea	load(pc),a0
	move.l	#$60000,a1
move:	move.b	(a0)+,(a1)+
	cmp.l	#codeend,a0
	blt.s	move
	jmp	$60000

load:	clr.w	-(sp)
	move.l	#filename,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	d0,d7
	move.l	#$10000,-(sp)
	move.l	#56320,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

start:	lea	patch(pc),a0
	move.l	#$100c6,a1
shif:	move.b	(a0)+,(a1)+
	cmp.l	#$1010c,a1
	blt.s	shif

	jmp	$10000

patch:	clr.w	-(sp)
	move.l	#sample,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	add.l	#8,sp
	move.l	d0,d7

	move.l	#$103a2,-(sp)
	move.l	#312321,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	jmp	$1010c
	
sample:	dc.b	"BANG.2",0
	dc.b	0,0
	even
filename:
	dc.b	"MEGA.",0
	even
codeend:

	even
mess:	dc.b	27,'E'
 dc.b	"        MEGABANG 2 - THE SEQUEL",13,10
 dc.b	"        -----------------------",13,10,10
 dc.b	"          Hacked and Packed by",13,10,10
 dc.b	"              MAC SYS DATA",13,10,10
 dc.b	"                10/1/90",13,10,10,10
 dc.b	"This demo was a bootsector loader, so I",13,10
 dc.b	"had to hack the loader, make the data",13,10
 dc.b	"into files then write a loader. Dead",13,10
 dc.b	"easy when you know how!",13,10,10
 dc.b	"Okay all you other demo packers, lets",13,10
 dc.b	"see what you're made of, try to hack",13,10
 dc.b	"and pack this one, and no stealing my",13,10
 dc.b	"hack of it.",13,10,10
 dc.b	"Be warned, you won't be using PAMPUK!",13,10,10
 dc.b	"        PRESS A KEY TO CONTINUE.",13,10,0
