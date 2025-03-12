*************************************************************************
*			PERSISTENCE OF VISION 143			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:	? from Just Buggin'					*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
* Date:		21/2/94							*
*									*
*									*
*			½ Persistence Of Vision 1994			*
*									*
*************************************************************************
*
* PCS 48/4096 picture menu with single plane scroller
*
*
*
yes=1
no=0
YES=yes
NO=no


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=NO	;YES to remove escape to assembler code
		;NO to keep it on

		opt	o+,w-

		ifeq	AUTORUN4
begin		bra	start
		ds.b	100
ustack		ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec		pea	blank
		pea	blank
		pea	$200
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	.reset		;always reset on return from prog
		move.w	#$26,-(sp)
		trap	#14
.reset		move.l	4.w,-(sp)
		rts

blank		dc.l	0

*******************************************************************
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		ENDC


		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
		lsr.w	#2,d0
clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		clr.l	-(a7)		;set supervisor
		move.w	#$20,-(a7)
		trap	#1
		addq.w	#6,a7
		move.l	d0,stack_save

		moveq	#1,d0
		jsr	music

		move.b	#$12,$fffffc02.w

		move.l	#screen_space1,d0
		clr.b	d0
		move.l	d0,screen1

		move.l	#screen_space2,d0
		clr.b	d0
		move.l	d0,screen2

		move.l	#pal1,pal_pos1
		move.l	#pal2,pal_pos2

		bsr	check_keys

**** Sort pic
		move.l	#pic,pic_pos
		move.l	#picend-pic,d0	;pic length
		addq.l	#4,d0
		andi.b	#$fe,d0		;make length even length
		move.l	d0,pic_length

		bsr	save_old
		bsr	save_isr

		movea.l	pic_pos,a0
		bsr	sort_pics

		move	#$2700,sr
		move.l	screen2,d0
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		pea	main_vbl
		move.l	(a7)+,$70.w
		move	#$2300,sr


main_loop
		move.w	#1,vbl_count
.sync		tst.w	vbl_count
		bne.s	.sync

		jsr	music+4
		bsr	scroll

;		move.w	#$123,$ffff8240.w

		move.w	key,d0

		ifeq	FINAL
		cmp.w	#1,d0		;ESC
		beq	assem
		ENDC

		cmp.w	#11,d0		;0 keyboard
		beq	zero

		cmp.w	#$70,d0		;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR

exit		move	#$2700,sr
		pea	init_vbl	;make boring vbl rout.
		move.l	(a7)+,$70.w
		move	#$2300,sr

		bsr	black_out
		bsr	isr_off
		bsr	restore_old
		bsr	check_keys

		moveq	#0,d0
		jsr	music

		bsr	check_keys

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50

		move.l	stack_save,-(sp)
		move.w	#$20,-(a7)
		trap	#1
		addq.w	#6,a7

		ifeq	AUTORUN4
		bra	exec
		ELSE
		pea	$4c0000		;exit
		trap	#1
		ENDC

 
assem		move	#$2700,sr
		pea	init_vbl	;make boring vbl rout.
		move.l	(a7)+,$70.w
		move	#$2300,sr

		bsr	black_out
		bsr	isr_off
		bsr	restore_old
		bsr	check_keys
		moveq	#0,d0
		jsr	music

		bsr	check_keys

		move.b	#8,$fffffc02.w

		clr.w	-(a7)		;set keyboard shift/alt/cntl off
		move.w	#$b,-(a7)
		trap	#$d
		addq.l	#4,a7

		move.w	#$20,-(a7)
		trap	#1
		addq.w	#6,a7

		pea	$4c0000		;exit
		trap	#1

zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.l	#$00030003,hertz_toggle
		eor.l	#$00030003,hertz_toggle2
		eor.l	#$00030003,hertz_toggle3
		eor.l	#$00030003,hertz_toggle4
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop


reset		move.l	4.w,-(sp)
		rts



scroll		lea	font,a5
		move.l	screen2,a2
		lea	(160*201)+6(a2),a2

		move.l	text_ptr,a4
		move.l	a4,a3
		move.w	char_off,d6
		moveq	#0,d2
		moveq	#40-1,d1
.loop		move.w	(a3),d0
		bpl.s	.cont
		lea	text_start,a3
		move.w	(a3),d0
.cont		move.l	a5,a0
		add.w	d6,d0
		add.w	d0,a0
.column
OFF		set	0
		REPT	16
		move.b	(a0)+,OFF(a2)
OFF		set	OFF+160
		ENDR
		dbf	d1,.not_end
		add.w	#16,char_off
		and.w	#(16*3),char_off
		bne.s	.end
		addq.w	#2,a4
		tst.w	(a4)
		bpl.s	.end
		lea	text_start,a4
.end		move.l	a4,text_ptr
		rts
.not_end	addq.w	#1,a2
		tst.w	d2
		beq.s	.next
		addq.w	#6,a2
.next		not.w	d2
		add.w	#16,d6
		and.w	#(16*3),d6
		bne.s	.column
		addq.w	#2,a3
		bra	.loop


save_old	movem.l	$ffff8240.w,d0-d7	;keep all old colours
		movem.l	d0-d7,old_pal

		move.w	#4,-(a7)
		trap	#$e
		addq.w	#2,a7
		move.w	d0,old_rez

		move.w	#2,-(a7)
		trap	#$e
		addq.w	#2,a7
		move.l	d0,old_scrn_base

		move.w	#$25,-(a7)		;sync
		trap	#$e
		addq.w	#2,a7
		move.w	#0,-(a7)		;low rez NOW!
		pea	$ffffffff.w
		pea	$ffffffff.w
		move.w	#5,-(a7)
		trap	#$e
		adda.w	#$c,a7

		bsr	black_out
		movea.l	screen1,a0
		bsr	clear_screen
		movea.l	screen2,a0
		bsr	clear_screen
		rts

restore_old	bsr	black_out
		movea.l	screen1,a0
		bsr	clear_screen
		movea.l	screen2,a0
		bsr	clear_screen
		move.w	#$25,-(a7)
		trap	#$e
		addq.w	#2,a7
		move.w	old_rez,-(a7)
		move.l	old_scrn_base,-(a7)
		move.l	old_scrn_base,-(a7)
		move.w	#5,-(a7)
		trap	#$e
		adda.w	#$c,a7

		lea	old_pal,a0
		lea	$ffff8240.w,a1
		moveq	#7,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		rts


sort_pics	lea	6(a0),a1	;pic addr is in A0
		movea.l	a0,a6

		movea.l	screen1,a0
		bsr.s	depack_pic

		movea.l	pal_pos1,a0
		bsr	depack_pals

		bsr	show_pic
		bsr	create_pals
		rts

depack_pic	moveq	#0,d6
		move.w	#$28,d2
		move.w	#$c8,d3
		moveq	#5,d4
		move.b	(a1)+,d7
		lsl.w	#8,d7
		move.b	(a1)+,d7
.depack_pic1	moveq	#0,d0
		subq.w	#1,d7
		bmi.s	.depack_pic7
		move.b	(a1)+,d0
		bmi.s	.depack_pic8
		beq.s	.depack_pic2
		cmp.b	#1,d0
		beq.s	.depack_pic9
		bra.s	.depack_pic3
.depack_pic2	move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
.depack_pic3	subq.w	#1,d0
		move.b	(a1)+,d1
.depack_pic4	move.b	d1,0(a0,d6.w)
		addq.w	#1,d6
		andi.w	#1,d6
		bne.s	.depack_pic5
		addq.w	#8,a0
.depack_pic5	subq.w	#1,d2
		bne.s	.depack_pic6
		moveq	#$28,d2
		subq.w	#1,d3
		bne.s	.depack_pic6
		move.w	#$c8,d3
		lea	-31998(a0),a0
		subq.w	#1,d4
		beq.s	.depack_pic7
.depack_pic6	dbf	d0,.depack_pic4
		bra.s	.depack_pic1
.depack_pic7	rts
.depack_pic8	neg.b	d0
		bra.s	.depack_pic10
.depack_pic9	move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
.depack_pic10	subq.w	#1,d0
.depack_pic11	move.b	(a1)+,d1
		move.b	d1,0(a0,d6.w)
		addq.w	#1,d6
		andi.w	#1,d6
		bne.s	.depack_pic12
		addq.w	#8,a0
.depack_pic12	subq.w	#1,d2
		bne.s	.depack_pic13
		moveq	#$28,d2
		subq.w	#1,d3
		bne.s	.depack_pic13
		move.w	#$c8,d3
		lea	-31998(a0),a0
		subq.w	#1,d4
		beq.s	.depack_pic7
.depack_pic13	dbf	d0,.depack_pic11
		bra	.depack_pic1

depack_pals	move.b	(a1)+,d7
		lsl.w	#8,d7
		move.b	(a1)+,d7
.depack_pal1	moveq	#0,d0
		subq.w	#1,d7
		bmi.s	.depack_pal5
		move.b	(a1)+,d0
		bmi.s	.depack_pal6
		beq.s	.depack_pal2
		cmp.b	#1,d0
		beq.s	.depack_pal7
		bra.s	.depack_pal3
.depack_pal2	move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
.depack_pal3	subq.w	#1,d0
		move.b	(a1)+,d1
		lsl.w	#8,d1
		move.b	(a1)+,d1
.depack_pal4	move.w	d1,(a0)+
		dbf	d0,.depack_pal4
		bra.s	.depack_pal1
.depack_pal5	rts
.depack_pal6	neg.b	d0
		bra.s	.depack_pal8
.depack_pal7	move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
.depack_pal8	subq.w	#1,d0
.depack_pal9	move.b	(a1)+,d1
		lsl.w	#8,d1
		move.b	(a1)+,d1
		move.w	d1,(a0)+
		dbf	d0,.depack_pal9
		bra.s	.depack_pal1

show_pic	movem.l	d0-a6,-(a7)
		movea.l	screen1,a0
		movea.l	screen2,a1
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,d1
		eor.l	d1,(a1)+
		dbf	d0,.loop
		movem.l	(a7)+,d0-a6

		movea.l	screen1,a0
		lea	32000(a0),a0
		movea.l	screen2,a1
		lea	32000(a1),a1
		lea	pattern+34,a2
		move.w	#(160*42)/4-1,d0
.loop2		move.l	(a2),(a0)+
		move.l	(a2)+,(a1)+
		dbf	d0,.loop2
		rts

create_pals	movem.l	a0-a6/d0-d7,-(a7)
		movea.l	pal_pos1,a0
		movea.l	pal_pos2,a1
		move.w	#19136/2-1,d0
.loop		move.w	(a0)+,d1
		eor.w	d1,(a1)+
		dbf	d0,.loop
		movem.l	(a7)+,a0-a6/d0-d7
		rts

main_vbl	movem.l	a0-a1/d0,-(a7)
		move.b	#$34,hblank_count
		clr.w	$ffff8240.w
		move.l	#hblank_main,$68.w
		move	#$2100,sr
		move.l	screen1,d0
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w

		move.l	screen1,d0
		move.l	screen2,screen1
		move.l	d0,screen2
		move.l	pal_pos2,d0
		move.l	pal_pos1,pal_pos2
		move.l	d0,pal_pos1
		movea.l	pal_pos1,a0
		addq.w	#2,a0
		lea	$ffff8242.w,a1
		move.w	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		lea	hblank_count,a0
.wait		tst.b	(a0)
		bne.s	.wait
		move	#$2300,sr
.purge_key	btst	#0,$fffffc00.w
		beq.s	.key_clear
		move.b	$fffffc02.w,d0
		bra.s	.purge_key
.key_clear	clr.w	vbl_count
		tst.w	hertz_delay
		beq.s	.ok
		sub.w	#1,hertz_delay
.ok		movem.l	(a7)+,a0-a1/d0
		rte

hblank_count	dc.b	0
		even

hblank_main	subq.b	#1,hblank_count
		ble.s	.do_hblank
		rte
.do_hblank	move	#$2700,sr		;ISR off

		lea	vbl_stack_save,a6	;save stack position
		move.l	a7,(a6)

		lea	$ffff8209.w,a6
		moveq	#0,d0
		moveq	#$40,d7
.not_yet	move.b	(a6),d0
		beq.s	.not_yet
		sub.w	d0,d7		;sync in
		lsl.w	d7,d0

		movea.l	pal_pos1(pc),a7
		lea	32(a7),a7

		move.w	#$f,d0
.loop		dbf	d0,.loop
		nop
		nop

		rept	199
		movem.l	(a7)+,a0-a6/d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	a0-a6,$ffff8240.w
		move.l	(a7)+,$ffff825c.w
		lea	$ffff8240.w,a0
		move.l	(a7)+,(a0)+
		move.l	(a7)+,(a0)+
		move.l	(a7)+,(a0)+
		move.l	(a7)+,(a0)+
		move.l	(a7)+,(a0)+
		move.l	(a7)+,(a0)+
		move.l	(a7)+,(a0)+
		move.w	#0,$ffff8240.w
		move.l	(a7)+,(a0)+
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		endr

		move.l	#$000,$ffff8240.w	;scroller colour
hertz_toggle	equ	*-6

		move.l	d0,-(sp)
		move.b	#0,$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.l	(sp)+,d0

		move.l	#0,$ffff8244.w
hertz_toggle2	equ	*-6
		move.l	#0,$ffff8248.w
hertz_toggle3	equ	*-6
		move.l	#0,$ffff824c.w
hertz_toggle4	equ	*-6
		move.l	#$0310041,$ffff8250.w
		move.l	#$0510062,$ffff8254.w
		move.l	#$0730074,$ffff8258.w
		move.l	#$0750276,$ffff825c.w

		movea.l	#0,a7
vbl_stack_save	equ	*-4
		pea	null_hblank
		move.l	(a7)+,$68.w
		move.b	#$23,(a7)
null_hblank	rte


new_kbd		movem.l	d0,-(sp)
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		movem.l	(sp)+,d0
		rte


save_isr	lea	storage,a0
		move	usp,a1
		move.l	a1,(a0)+
		move.l	$68.w,(a0)+
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$134.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa1f.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		move.b	$fffffa19.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$ffff820a.w,(a0)+
		move	#$2700,sr
		pea	init_vbl
		move.l	(a7)+,$70.w
		move.l	#new_kbd,$118.w
		move.b	#0,$fffffa07.w
		move.b	#$40,$fffffa09.w
		move	#$2300,sr
		rts

isr_off		move	#$2700,sr
		lea	storage,a0
		movea.l	(a0)+,a1
		move	a1,usp
		move.l	(a0)+,$68.w
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$134.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa1f.w
		move.b	(a0)+,$fffffa21.w
		move.b	(a0)+,$fffffa19.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$ffff820a.w
		move	#$2300,sr
		rts

init_vbl	move.l	a0,-(a7)
		lea	vbl_count,a0
		tst.w	(a0)
		ble.s	.no_dec
		subq.w	#1,(a0)
.no_dec		movea.l	(a7)+,a0
		rte

check_keys	movem.l	a0-a6/d0-d7,-(a7)
		bsr.s	purge_kbd
.loop		move.w	#$b,-(a7)	;check status of keyboard input
		trap	#1
		addq.w	#2,a7
		tst.l	d0		;was there a key??
		beq.s	.no_key		;NO
		move.w	#7,-(a7)	;yeah get key
		trap	#1
		addq.w	#2,a7
		bra.s	.loop		;go check again for another key
.no_key		movem.l	(a7)+,a0-a6/d0-d7
		rts

purge_kbd	move.w	d7,-(a7)	;check to see if a key is down.
.get		btst	#0,$fffffc00.w
		beq.s	.no_key
		move.b	$fffffc02.w,d7
		bra.s	.get
.no_key		move.w	(a7)+,d7
		rts

black_out	moveq	#7,d7
		lea	$ffff8240.w,a0
.loop		clr.l	(a0)+
		dbf	d7,.loop
		rts

clear_screen	move.w	#32000/4-1,d0
.loop		clr.l	(a0)+
		dbf	d0,.loop
		rts

		data
pic_pos		dc.l	0
pic_length	dc.l	0

pal_pos1	dc.l	0

pal_pos2	dc.l	0

screen1	dc.l	0
screen2	dc.l	0


music		incbin	"backbitc.acf"

pattern		incbin	pattern.pi1

font		incbin	"BORIS.FNT"

char_off	dc.w	0
text_ptr	dc.l	text_start
text_start	incbin	"SCROLLER.TXT"


	even

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
;	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
;	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"sc7.pov",0
	even
exec2	dc.b	"fanatic1",0
	even
exec3	dc.b	"tsc_99",0
	even
exec4	dc.b	"dune",0
	even
exec5	dc.b	"copier.pov",0
	even
exec6	dc.b	"filename.ext",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even
exec9	dc.b	"filename.ext",0
	even



pic	incbin	visitor.pcs
picend



	section bss
bssstart
old_scrn_base	ds.l	1

vbl_count	ds.w	1

old_pal		ds.b	32

old_rez		ds.w	1

key		ds.w	1

hertz_delay	ds.w	1

stack_save	ds.l	1

storage		ds.b	40


		ds.b	256
screen_space1	ds.b	32000
		ds.b	160*48

screen_space2	ds.b	32000
		ds.b	160*48

	even
pal1	ds.b	19232
pal2	ds.b	19232

bssend