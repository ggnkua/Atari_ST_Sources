* Muzak-driver for PSG-Tracker tunes by Illegal Exception/S.O.T.E.
* Written entirely in Devpac Developer v2.23...
* ...muzak ripped using MonST v2.05+!
* Change the constant "digi" to toggle digisound or normal!
* F1	=	Toggle ON/OFF Channel A
* F2	=	Toggle ON/OFF Channel B
* F3	=	Toggle ON/OFF Channel C
* F10	=	Exit player...

	OPT	D+,C+,X+

*** Muzak-rout vars. ***
no_of_tunes	EQU	5
tune_no		EQU	4	; Start-tune! 0 to 4 to change tune...
digi		EQU	1	; 0 = 2.0-tunes, 1 = 2.0DD (DIGI-tjofr„s serru!)
sys_flg		EQU	0	; 1 = Use system
blink_tjofr„s	EQU	1	; 1 = blink-tjofr„s l„ge...

	dc	$a00a
	bsr	SUPER1
	bsr	S_ADD
	lea	text_tjofr„s,a0
	bsr	PRINT_L
	bsr	MUZAK

cycle_l	clr	test
demo_l	addq	#1,test
	tst.b	vsync
	beq.s	demo_l
	sf	vsync
	IFNE	sys_flg
	movem.l	d0-a6,-(sp)
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-a6
	ENDC

	bsr	INTERRUPT

	move.b	$fffffc02.w,d0
	cmp.b	key,d0
	beq	f10
	move.b	d0,key

	IFNE	blink_tjofr„s
f1	cmp.b	#$3b,$fffffc02.w
	bne.s	f2
	bchg	#0,vol_flg
	beq.s	clr_A
	move	#$4E71,ch_A
	bra.s	f2
clr_A	move	#$7000,ch_A
f2	cmp.b	#$3c,$fffffc02.w
	bne.s	f3
	bchg	#1,vol_flg
	beq.s	clr_B
	move	#$4E71,ch_B
	bra.s	f3
clr_B	move	#$7200,ch_B
f3	cmp.b	#$3d,$fffffc02.w
	bne.s	left
	bchg	#2,vol_flg
	beq.s	clr_C
	move	#$4E71,ch_C
	bra.s	left
clr_C	move	#$7400,ch_C
	ENDC
left	cmp.b	#$4b,$fffffc02.w
	bne.s	right
	subq	#1,curr_tune
	bpl.s	cont_l
	move	#0,curr_tune
cont_l	bsr	NEW_TUNE
right	cmp.b	#$4d,$fffffc02.w
	bne.s	f10
	addq	#1,curr_tune
	cmp	#no_of_tunes,curr_tune
	blo.s	cont_r
	move	#no_of_tunes-1,curr_tune
cont_r	bsr	NEW_TUNE
f10	cmp.b	#$44,$fffffc02.w
	bne	cycle_l

	move	#$2700,sr
	clr.l	$4d2.w
	bsr	RESET_ADD
	bsr	CLR_SOUND

	move.l	s_super(pc),-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap	#1


PRINT_L	pea	(a0)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts


CLR_SOUND
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move.l	#$707ff00,$ffff8800.w
	move.l	#$e0efe00,$ffff8800.w
	rts
	

SUPER1	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	s_super(pc),a0
	move.l	d0,(a0)
	rts


S_ADD	lea	s_buff(pc),a0
	move.l	$120.w,(a0)+
	move.l	$70.w,(a0)+
	move	sr,(a0)+
	move	$484.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	rts


RESET_ADD
	lea	s_buff(pc),a0
	move.l	(a0)+,$120.w
	move.l	(a0)+,$70.w
	move	(a0)+,sr
	move	(a0)+,$484.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts


NEW_TUNE
	move	sr,-(sp)
	move	#$2700,sr

	move	curr_tune,d0
	lsl	#2,d0
	lea	muz_tab,a0
	move.l	(a0,d0.w),a6
	IFNE	digi
	lea	samples,a4
	ENDC
	bsr	replay

	move	#$2300,sr
	move	(sp)+,sr
	rts


MUZAK	bclr	#0,$484.w
	move.l	#$777,$ffff8240.w
	move.b	$ffff8260.w,d0
	and	#3,d0
	cmp	#2,d0
	bne.s	lo_res
	st	muz_var
lo_res
	IFEQ	sys_flg
	move	#$2700,sr
	move.l	#VBL,$70.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move	#$2300,sr
	ENDC

	bsr	NEW_TUNE
	rts


INTERRUPT
	movem.l	d0-a5,-(sp)
	tst.b	muz_var

	beq.s	not_70Hz
	lea	muz_counter(pc),a0
	subq	#1,(a0)
	bne.s	not_70Hz
	move	#4,(a0)
	bra	exit_muz_int
not_70Hz
	IFEQ	digi
	jsr	replay+$EC
	ELSE
	jsr	replay+$1A6
	ENDC

	IFNE	blink_tjofr„s
	move.b	#$8,$ffff8800.w
	move.b	$ffff8800.w,d0
ch_A	nop
	move.b	d0,$ffff8802.w
	move.b	#$9,$ffff8800.w
	move.b	$ffff8800.w,d1
ch_B	nop
	move.b	d1,$ffff8802.w
	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d2
ch_C	nop
	move.b	d2,$ffff8802.w
	and	#$f,d0
	and	#$f,d1
	and	#$f,d2
	moveq	#0,d4
	moveq	#0,d5
	cmp.b	#14,d0
	blo.s	clr_led
	bra.s	set_led
clr_led	moveq	#2,d4
set_led	cmp.b	#14,d1
	blo.s	clr_led2
	bra.s	set_led2
clr_led2
	moveq	#4,d5
set_led2
	lsr	#1,d0
	mulu	#$110,d1
	mulu	#$100,d2
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d3
	and.b	#$f8,d3
	or.b	d4,d3
	or.b	d5,d3
	move.b	d3,$ffff8802.w	
	move	d0,$ffff8240.w
	move	d2,$ffff8244.w
	move	d1,$ffff8246.w
	ENDC
exit_muz_int
	movem.l	(sp)+,d0-a5
	rts

VBL	st	vsync
	rte

s_super		dc.l	0
s_buff		ds.b	46
curr_tune	dc	tune_no
muz_counter	dc	4
test		ds	1
vsync		ds.b	1
muz_var		ds.b	1
vol_flg		ds.b	1
key		ds.b	1
	EVEN
text_tjofr„s
	dc.b	27,'E'
	dc.b	'Yo freax!                                |',13,10
	dc.b	'Illegal Exception of Scum Of The Earth   |         F1  = Toggle Channel A',13,10 
	dc.b	'presents the MEGAGREAT muzax from the    |         F2  = Toggle Channel B',13,10
	dc.b	'PSG-Tracker Demo 2 made by Chronicle...  |         F3  = Toggle Channel C',13,10
	dc.b	'Hey Guyer of Chronicle! I hope you don',$27,'t |',13,10
	dc.b	'feel angry about me ripping this but it  |         F10 = Exit rout...',13,10
	dc.b	'was so damned good that I couldn',$27,'t leave |',13,10
	dc.b	'it unripped!!! BTW, I',$27,'ll send U some of  |',13,10
	dc.b	'my latest warez soon...                  |',13,10
	dc.b	'O.K. Folx! That',$27,'s it and look out for    |',13,10
	dc.b	'"Too Much Month At The End Of The Money" | Left Arrow  = Decrease MUZAK-counter',13,10
	dc.b	'demo which hopefully will be released in | Right Arrow = Increase MUZAK-counter',13,10
	dc.b	'february... (A bit imaginative!)         |',13,10
	dc.b	'---------------------------------------------------------------------------------',13
	dc.b	'Helloes to:',13,10
	dc.b	'ARMADA (Or is it still UNC&Aggression?)  LYNX (Hi Headhunter, how is the war?)   ',13
	dc.b	'CHRONICLE (Fab muzax!!!)                 OMEGA (Megademo?)                       ',13
	dc.b	'DELTA 4CE (Hello there Daniel!)          SYNC (Hi 7an! Hey RedFox: "vinkelslip"?)',13
	dc.b	'ELECTRA (Hi Jesper!)                     SYNDICATE (Hi Zaphod B. and Ogge!)      ',13
	dc.b	'ELECTRONIC IMAGES (Seeya on Mega-Leif!)  TCB (Inga nya tjofr„ser AN Cool?)       ',13
	dc.b	'FUTURE MINDS (Hi Skyline!)               UNIT 17 (Sorry about the cockup TKT...) ',13
	dc.b	'LIGHT (Hi Maverick! Hope 2 C U on MLC!)  U (Hope you will enjoy these tunes!)    ',13,10
	dc.b	'V†r Julgurka har rymt med Gnufisken...  ',13,10
	dc.b	0
	EVEN
muz_tab		dc.l	tune01,tune02,tune03,tune04,tune05
	IFEQ	digi
replay		INCBIN	PSG2_0.ROT
music
tune01		INCBIN 	JAPANESE.MUS
tune02		INCBIN 	DESPAIR.MUS
tune03		INCBIN 	HEROES.MUS
tune04		INCBIN 	DOZEN.MUS
tune05		INCBIN 	NOWAYOUT.MUS
	ELSE
replay		INCBIN	PSG2_0DD.ROT
music
tune01		INCBIN 	WALKMAN.MUS
tune02		INCBIN 	BOMBSQUA.MUS
tune03		INCBIN 	THE_CAVE.MUS
tune04		INCBIN 	REZONATI.MUS
tune05		INCBIN 	NOWAYOU2.MUS
samples		INCBIN	SUFFER.SND
	ENDC

	END
