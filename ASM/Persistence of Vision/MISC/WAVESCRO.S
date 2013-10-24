clear_scroll	move.w	wave_flip,d0
		and.w	#7,d0
		move.l	old_wave_pointer,a1
		add.w	d0,a1
		move.l	(a1),a1
		move.w	#40-1,d0
		moveq	#0,d2
		move.w	d2,d3
		move.w	d2,d4
scroll_loop	move.l	screen_base,a0
		move.w	(a1)+,d1
		add.w	#4,a0
		move.l	a0,a2
		add.w	d1,a0
		lea	(31-5)*160(a0),a3
		REPT	5
		move.b	d3,(a0,d2.w)
		move.b	d3,(a3,d2.w)
		lea	160(a0),a0
		lea	160(a3),a3
		ENDR

		not.w	d4
		bpl.s	.word
		addq.w	#1,d2
		bra.s	.la
.word		addq.w	#7,d2
.la		move.l	a2,a0
		dbf	d0,scroll_loop

scroll		move.l	screen_base,a1
		add.w	#4,a1
		cmp.l	#waves_end,wave_pointer
		blt.s	.no_reset
		move.l	#waves,wave_pointer
.no_reset	move.l	wave_pointer,a6

		move.l	old_wave_pointer,a5
		move.w	wave_flip,d4
		and.w	#7,d4
		move.l	a6,(a5,d4.w)

		lea	font_offsets,a2
		move.l	scroll_pointer,a3
		move.l	a3,a5

		moveq	#0,d4
		moveq	#40,d5
		move.w	char_offset,d6
next_char	move.b	(a5),d2		;get a letter
		sub.b	#32,d2		;rid of ASCII
		ext.w	d2

		moveq	#0,d0
		move.l	#font,a0
		move.b	(a2,d2),d0
		mulu	#(31*4),d0
		add.w	d0,a0
		move.w	d6,d0
		mulu	#31,d0		;char depth 31 deep
		add.w	d0,a0

.column		moveq	#0,d1
		move.w	(a6)+,d1
		move.l	a1,-(sp)
		add.w	d1,a1
OFF		set	0
		REPT	31
		move.b	(a0)+,OFF(a1)
OFF		set	OFF+160
		ENDR

		move.l	(sp)+,a1

		subq.w	#1,d5
		beq.s	.finish

		addq.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if D4=0 then do next word
		addq.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d6		;character offset
		and.w	#3,d6
		bne	.column

		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	next_char

.finish		addq.w	#1,char_offset
		and.w	#3,char_offset
		bne.s	.end
		addq.w	#1,a3
		tst.b	(a3)
		bpl.s	.end
		lea	scroll_text,a3
.end		move.l	a3,scroll_pointer
		addq.l	#4,wave_pointer
		add.w	#4,wave_flip
		rts






scroll_pointer	dc.l	init_scroll_text

init_scroll_text

scroll_text
 dc.b "                 HELLO DUDES, WELCOME TO ANOTHER EXCELLENT DEMO STARING ERIK "
 DC.B "PLANKTON.   YOU MAY HAVE NOTICED THAT I'VE BEEN JOINED BY ANOTHER "
 DC.B "CODER ON THIS DEMO, HIS NAME IS BLIND BASTARD.      IF YOU WANT "
 DC.B "TO KNOW WHY HE'S CALLED THAT WELL, HE SPENT SO MUCH TIME "
 DC.B "WANKING OVER MY FIRST DEMO THAT HE HAD TO SEE AN OPTICIAN FOR HIS "
 DC.B "EYE SIGHT     (AND A DOCTOR FOR THE BLISTERS ON HIS PALMS!!!)      "
 DC.B "      IT'S BEEN A LONG TIME SINCE MY FIRST DEMO, IT WENT DOWN "
 DC.B "SO WELL THAT I FELT I HAD TO WRITE ANOTHER.      THE SAMPLING "
 DC.B "AND SOME GRAFIX WERE DONE BY ME (ERIK), OTHER GRAFIX WERE BY OZYMANDIAS "
 DC.B "OF 'PERSISTENCE OF VISION'.   I MUST SEND MEGA THANKS TO "
 DC.B "MAC SYS DATA FOR ALL HIS HELP ON THE CODING,    BORIS FOR THE "
 DC.B "PACKING TECHNIQUE AND HELPING PUT IT ALL TOGETHER    AND   OZYMANDIAS FOR "
 DC.B "HIS MEGA GRAFIX.         I THINK "
 DC.B "THAT IS ENOUGH BOTTOM LICKING FOR NOW!       "
 DC.B "THERE ARE OTHER GREETING AND CREDITS ELSE WHERE IN THIS DEMO SO "
 DC.B "I WON'T DO ANY MORE.        WELL AFTER 16 YEARS OF GROWING UP "
 DC.B "I FINALLY FIGURED OUT THAT GIRLS ARE WEIRD...     I MEAN, JUST "
 DC.B "'CAUSE I GOT A LITTLE DRUNK AND JUMPED ON ONE DIDN'T MEAN SHE "
 DC.B "HAD TO SMASH MY FACE IN DID IT?     OH, I FEEL ILL.        "
 DC.B "WHY CAN'T THEY MAKE BEER THAT DOESN'T MAKE YOUR HEAD HURT "
 DC.B "IN THE MORNING?     I WAS TOLD TO DRINK A PINT OF WATER "
 DC.B "BEFORE I WENT TO BED BUT I COULDN'T FUCKIN' FIND A PINT GLASS "
 DC.B "IN THE HOUSE SO I DRANK ABOUT 4 MOUTH FULLS THEN SPEWED UP IN THE "
 DC.B "SINK...   URRGGGHH  CARROTS!                 I DON'T KNOW "
 DC.B "WHAT MACHINE YOU'RE USING BUT IF YOU HAVE AN STFM THEN YOU "
 DC.B "WILL BE WATCHING THE SCREEN WITH LOADS OF RASTERS.   IF YOU "
 DC.B "ARE USING AN STE THEN YOU'LL BE WATCHING THE 25KHZ TRACKER "
 DC.B "SCREEN.    THE MODULE CAME FROM THE AMIGA AND IS PLAYED BACK "
 DC.B "USING AUDIO SCULPTURE CODE.    PERSONALLY I LIKE THE "
 DC.B "RASTER DEMO THE BEST SO YOU BETTER RUSH ROUND TO A FRIENDS HOUSE "
 DC.B "WHO HAS THE OPPOSITE MACHINE TOO YOURS AND SEE WHAT YOU'RE MISSING. "
 DC.B "           WELL I HAVEN'T GOT A LOT MORE TO SAY SO YOU'D "
 DC.B "BETTER PRESS THE SPACE BAR AND LOAD THE REST...     BYE.                          "
 DC.B "                                                                  "
 dc.b $ff
	even
char_offset	dc.w	0
font	dcb.b	31*4,0
		incbin	e:\menucode.pov\plankton\1plane.fnt
	even
wave_flip	dc.w	0
old_wave_pointer
	dc.l	old_wave_1
old_wave_1	dc.l	waves
old_wave_2	dc.l	waves
wave_pointer	dc.l	waves
waves		incbin	e:\menucode.pov\plankton\sine1.dat
waves_end	incbin	e:\menucode.pov\plankton\sine1.dat
		even


font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,00,00,00,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	50,00,00,00,00,00,00,00,00,48,00,00,00,00,00,49,00,00




screen_base	dc.l	0