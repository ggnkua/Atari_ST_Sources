*
* POV Dot Scroller & Soundtracker MENU
*

VBL_ISR		equ	$70
MAX_COLUMNS	equ	128
vsync_flag	equ	$200
fade_done	equ	$202


	move.l	sp,oldsp
	lea	new_stack,sp
	pea	Prog(pc)
	move.w	#$26,-(sp)	Call SUPERVISOR routine.
	trap	#14
	addq.l	#6,sp
term
	move.l	oldsp,sp
	clr.w	-(sp)
	trap	#1

oldsp:	dc.l	0

Prog
	clr.l	$24.w
	bra.s	over
	dc.b	"   PISS OFF LAMER, GO WRITE YOUR OWN STUFF  "
	even
over
	move.b	#$12,$fffffc02.w
	move.l	$44e.w,scr_now
	jsr	black_palette
	jsr	vsync
	move.l	$118.w,kbd_bak
	move.l	#new_kbd,$118.w
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	jsr	show_logo
	move.w	#-1,fade_done
	bsr	InitSystem		start up exceptions etc

	bsr	startsong		Initialise song

	jsr	wait_for_fade
	move.l	#vbl_isr_2,VBL_ISR
	move.w	#-1,fade_done
	jsr	wait_for_fade

	jsr	set_up
	jsr	set_screen
	jsr	show_pic
	move.l	#vbl_isr_3,VBL_ISR
	move.w	#-1,fade_done
	jsr	wait_for_fade
	move.l	#vblankint,VBL_ISR

.loop
	jsr	vsync2
;	clr.w	$ffff8240.w
	jsr	set_screen
	jsr	scroller
	jsr	clear_dots
	jsr	show_dots
;	move.w	#$007,$ffff8240.w

	move.w	key,d0
	jsr	change_hz
	cmp.w	#$c53,d0
	beq	reset

;;;	cmp.b	#1,d0		;esc
;;;	beq.s	exit

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	.loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run
	lsr.w	#4,d1
	and.w	#$fff0,d1

***** Boris' cock up here so I'l have to fix it!!!!
	move.w	d1,-(sp)		;save key number

	jsr	black_palette
exit
	jsr	vsync2
	clr.b	$ffff8260.w		; Med res.
	move.l	$44e,d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)

	bsr.w	RestoreSystem
	move.l	kbd_bak,$118.w

	jsr	stop_tune
	tst.w	hz_col
	beq.s	.skip
	clr.b	$ffff820a.w
.skip	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.end
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.skip
.end
*********** NOW POKE FILENAME INTO $200 (fixing Boris' cock ups!!)*****
	lea	filenames,a0
	lea	$200.w,a1
	add.w	d1,a0
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

	move.b	#$08,$fffffc02.w
	rts	return from Super call to Prog


reset
	move.l	$4.w,-(sp)
	rts


;Constant Offsets from start of DRIVER.BIN
_Install equ	$0000		sets up timer A  vector & installs
_DeInstall equ	$0004		restores old vectors etc
_Start	equ	$0008		start playing tune (_SongAddr,_VoiceAddr)
_Stop	equ	$000C		stop playing current tune
_Restart equ	$0010		restart playing current tune
_SongAddr equ	$002C	.l	holds address of song
_VoiceAddr equ	$0030	.l	holds address of 20-voice kit
_IRQmask equ	$0038	.w	holds normal IRQ mask to write to MFP


installq			;grab vectors, init soundchip, etc
	lea	sing_s(pc),a6		get sing-routine start address

	lea	song1_s,a5
	lea	sing_s(pc),a6
	move.l	a5,_SongAddr(a6)	inform system of where song is

	move.w	#$0040,_IRQmask(a6)	ie just keyboard.
	jmp	_Install(a6)

deinstallq			;restore vectors, deinit soundchip, etc
	lea	sing_s(pc),a6
	jmp	_DeInstall(a6)

startsong			;start singing song1
	lea	song1_s,a5
singsong
	lea	sing_s(pc),a6
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s,a5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	jmp	_Start(a6)		let's go!

stopsong
	lea	sing_s(pc),a6
	jmp	_Stop(a6)		stop!

restartsong
	;should have started (& stopped) a song before calling this!
	;but the program double-checks anyway
	lea	sing_s(pc),a6
	jmp	_Restart(a6)		restart!



;System startup & shutdown code

vec	MACRO
	lea	\2.w,a1
	lea	\1,a2
	move.w	a1,(a0)+
	move.l	(a1),(a0)+
	move.l	a2,(a1)
	ENDM

unvec	MACRO
	move.w	(a0)+,a1
	move.l	(a0)+,(a1)
	ENDM


InitSystem
	move.w	#$2700,SR
	lea	savearea(pc),a0
	vec	vbl_isr_1,VBL_ISR
	vec	timerAint,$110
	move.w	#-1,(a0)
	bclr	#3,$fffffa17.w		set AEI mode
	bsr	savemfp			remember settings of mfp

	bsr.w	installq		install quartet driver

	;now disable midi ACIA interrupts so that keyboard is sole source	
	move.b	#$00,$fffffc04.w	midi acia control reg (no irqs)
	move.b	$fffffc04.w,d0		clear any passing midi irq
	move.b	$fffffc06.w,d0		and anything in receive buffer

	move.w	#$2300,SR		Don't leave the old vbl in unless you want
*					Crashes left right and centre
	rts


RestoreSystem
	move.w	#$2700,SR

	bsr.w	deinstallq		deinstall quartet driver

	bsr	loadmfp			get default bits
	lea	savearea(pc),a0
	sub.l	a1,a1
unstacklp
	unvec
	tst.w	(a0)
	bpl.s	unstacklp
	bset	#3,$fffffa17.w		set SEI mode

	move.w	#$2300,SR
	rts


vblankint
	clr.w	$200.w
	rte

timerAint
	rte


IERA	equ	$07
IERB	equ	$09
IPRA	equ	$0B
IPRB	equ	$0D
ISRA	equ	$0F
ISRB	equ	$11
IMRA	equ	$13
IMRB	equ	$15
VECTR	equ	$17
TACR	equ	$19
TADR	equ	$1F
TCDCR	equ	$1d
TDDR	equ	$25

ISRVEC	equ	$110

savemfp	lea	mfpdata(pc),a1
	move.b	IERA+$fffffa00.w,(a1)
	move.b	IERB+$fffffa00.w,1(a1)
	move.b	IMRA+$fffffa00.w,2(a1)
	move.b	IMRB+$fffffa00.w,3(a1)
	move.b	TADR+$fffffa00.w,4(a1)
	move.b	TACR+$fffffa00.w,5(a1)
	move.b	VECTR+$fffffa00.w,6(a1)
	rts

loadmfp	move.b	mfpdata+6(pc),VECTR+$fffffa00.w
	move.b	mfpdata+5(pc),TACR+$fffffa00.w
	move.b	mfpdata+4(pc),TADR+$fffffa00.w
	move.b	mfpdata+3(pc),IMRB+$fffffa00.w
	move.b	mfpdata+2(pc),IMRA+$fffffa00.w
	move.b	mfpdata+1(pc),IERB+$fffffa00.w
	move.b	mfpdata+0(pc),IERA+$fffffa00.w
	rts


mfpdata	dcb.b	16,0

savearea ds.w	$100		ST's vectors go here

	ds.l	1200
new_stack	ds.l	1

sing_s
	include	volpro8.s
	even

song1_s	incbin	rsi.mod
	even
voice_s	
	ds.b	32*800


	opt	o+,w+,ow2-,ow3-,p-


vsync2
	move.w	#-1,vsync_flag
.loop	tst.w	vsync_flag
	bne.s	.loop
	rts


wait_for_fade
	tst.w	fade_done
	bne.s	wait_for_fade
	rts


vbl_isr_1
	clr.w	vsync_flag
	addq.w	#1,clock
	movem.l	d0-d5/a0-a1,-(sp)
	lea	presents+2,a0
	bsr.s	fade_in
	movem.l	(sp)+,d0-d5/a0-a1
	rte

vbl_isr_2
	clr.w	vsync_flag
	addq.w	#1,clock
	movem.l	d0-d5/a0-a1,-(sp)
	bsr	fade_out
	movem.l	(sp)+,d0-d5/a0-a1
	rte

vbl_isr_3
	clr.w	vsync_flag
	addq.w	#1,clock
	movem.l	d0-d5/a0-a1,-(sp)
	lea	picture+2,a0
	bsr.s	fade_in
	movem.l	(sp)+,d0-d5/a0-a1
	rte


fade_in
	move.w	clock,d0
	and.w	#3,d0
	bne.s	.end
	lea	$ffff8240.w,a1
	moveq	#0,d5
	moveq	#15,d0
.loop
	move.w	(a0)+,d1
	move.w	(a1),d2
	and.w	#$777,d2
.red
	move.w	d1,d3
	move.w	d2,d4
	and.w	#$700,d3
	and.w	#$700,d4
	cmp.w	d3,d4
	beq.s	.green
	add.w	#$100,d2
	moveq	#-1,d5
.green
	move.w	d1,d3
	move.w	d2,d4
	and.w	#$070,d3
	and.w	#$070,d4
	cmp.w	d3,d4
	beq.s	.blue
	add.w	#$010,d2
	moveq	#-1,d5
.blue
	move.w	d1,d3
	move.w	d2,d4
	and.w	#$007,d3
	and.w	#$007,d4
	cmp.w	d3,d4
	beq.s	.cont
	addq.w	#$001,d2
	moveq	#-1,d5
.cont	move.w	d2,(a1)+
	dbf	d0,.loop
	tst.w	d5
	bne.s	.end
	clr.w	fade_done
.end	rts

fade_out
	move.w	clock,d0
	and.w	#3,d0
	bne.s	.end
	lea	$ffff8240.w,a0
	moveq	#0,d5
	moveq	#15,d0
.loop
	move.w	(a0),d1
.red
	move.w	d1,d2
	and.w	#$700,d2
	beq.s	.green
	sub.w	#$100,d1
	moveq	#-1,d5
.green
	move.w	d1,d2
	and.w	#$070,d2
	beq.s	.blue
	sub.w	#$010,d1
	moveq	#-1,d5
.blue
	move.w	d1,d2
	and.w	#$007,d2
	beq.s	.cont
	subq.w	#$001,d1
	moveq	#-1,d5
.cont	and.w	#$777,d1
	move.w	d1,(a0)+
	dbf	d0,.loop
	tst.w	d5
	bne.s	.end
	clr.w	fade_done
.end	rts


show_logo
	lea	presents+34,a0
	move.l	$44e.w,a1
	move.w	#(32000/4)-1,d0
.loop
	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts


clear_dots
	move.l	scr_now,a0
	addq.w	#6,a0
	lea	dot_pos,a1
	add.w	path_type,a1
	moveq	#0,d0
	REPT	146
	movem.w	(a1)+,d1-d7
	move.w	d0,(a0,d1)
	move.w	d0,(a0,d2)
	move.w	d0,(a0,d3)
	move.w	d0,(a0,d4)
	move.w	d0,(a0,d5)
	move.w	d0,(a0,d6)
	move.w	d0,(a0,d7)
	ENDR
	REPT	2
	move.w	(a1)+,d1
	move.w	d0,(a0,d1)
	ENDR
	rts


plot	MACRO
	tst.b	(a2)+
	beq.s	*+6
	or.w	\1,(a0,\2)
	ENDM

show_dots
	move.l	scr_now,a0
	addq.w	#6,a0
	lea	dot_pos,a1
	add.w	path_type,a1
	lea	(MAX_COLUMNS*8*2)(a1),a3
	lea	buffer,a2
	bsr	.do_it
.do_it
	REPT	MAX_COLUMNS
	movem.w	(a3)+,d0-d3
	movem.w	(a1)+,d4-d7
	plot	d0,d4
	plot	d1,d5
	plot	d2,d6
	plot	d3,d7
	ENDR
	rts


scroller
	lea	font,a1
	lea	buffer,a5
	move.l	text_ptr,a4
	move.l	a4,a3
	move.w	char_off,d7
	move.w	d7,d0
	lsl.w	#3,d0
	sub.w	d0,a5
	moveq	#((MAX_COLUMNS+8)/8)-1,d1
.loop
	moveq	#0,d0
	move.b	(a3)+,d0
	bpl.s	.skip
	and.w	#$f,d0
	mulu	#(MAX_COLUMNS*8*4),d0
	move.w	d0,path_type
	bra.s	.loop
.skip
	move.l	a1,a0
	lsl.w	#6,d0
	add.w	d0,a0
	REPT	(2*8)
	move.l	(a0)+,(a5)+
	ENDR
	dbf	d1,.loop
	move.w	char_off,d7
	addq.w	#1,d7
	and.w	#7,d7
	move.w	d7,char_off
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.cont
	addq.w	#1,a4
.cont
	cmp.l	#(end_text-20),a4
	blt.s	.end
	lea	text_start,a4
.end	move.l	a4,text_ptr
	rts


show_pic
	move.l	scr_now,a0
	move.l	a0,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,a1
	lea	picture+34,a2
	move.w	#(32000/4)-1,d0
.loop	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d0,.loop
	rts


change_hz
	tst.w	clock
	bne.s	.end
	cmp.b	#$0b,d0
	beq.s	.ok
	cmp.b	#$70,d0
	beq.s	.ok
	rts
.ok	eor.w	#$002,hz_col
	move.w	hz_col,$ffff8240.w
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts


set_up
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#(160*200),d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts


set_palette
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

black_palette
	lea	$ffff8240.w,a0
	REPT	8
	clr.l	(a0)+
	ENDR
	rts


vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


new_kbd
	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte


stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


font		incbin	"CHUNKY.FNT"

path_type	dc.w	0
dot_pos
	incbin	"NAFF.PTH"		;#0
	incbin	"CIRCLE.PTH"		;#1
	incbin	"UPLEFT.PTH"		;#2
	incbin	"PERSPECT.PTH"		;#3
	incbin	"CIRCLE2.PTH"		;#4 UNREADABLE
	incbin	"COSINE.PTH"		;#5 UNREADABLE
	incbin	"SINE.PTH"		;#6 UNREADABLE
	incbin	"SINE2.PTH"		;#7
		ds.b	(7*8)
buffer		dcb.b	(MAX_COLUMNS+8)*8,0

char_off	dc.w	0
text_ptr	dc.l	text_start
text_start
	incbin	"SCROLLER.TXT"
end_text
	even

presents	incbin	"PREDLOGO.PI1"
picture		incbin	"ROX_8COL.PI1"

demo_keys
	dc.b	0, $02	;key 1
	dc.b	1, $03
	dc.b	2, $04
	dc.b	3, $05
	dc.b	4, $06
	dc.b	5, $07
	dc.b	6, $08
	dc.b	7, $09
	dc.b	8, $0A	;key 9


	dc.b	0, $6d	;keypad 1
	dc.b	1, $6e
	dc.b	2, $6f
	dc.b	3, $6a
	dc.b	4, $6b
	dc.b	5, $6c
	dc.b	6, $67
	dc.b	7, $68
	dc.b	8, $69	;keypad 9
	dc.b	-1, -1
filenames
	dc.b	"$$FILENAME.EXT",0,0
	dc.b	"GIGASTAR.PRG",0,0,0,0
	dc.b	"BALLOON.PRG",0,0,0,0,0
	dc.b	"24HOUR.PRG",0,0,0,0,0,0
	dc.b	"WEIRD.PRG",0,0,0,0,0,0,0
	dc.b	"FUN.PRG",0,0,0,0,0,0,0,0,0
	dc.b	"FIRSTDEM.PRG",0,0,0,0
	dc.b	"WOLFDEMO.PRG",0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0
	even

clock		ds.w	1

key		ds.w	1

hz_col		ds.w	1

kbd_bak		ds.l	1

scr_xor		ds.l	1
scr_now		ds.l	1

		ds.b	256
screens		ds.b	(160*200*2)
finish	even
