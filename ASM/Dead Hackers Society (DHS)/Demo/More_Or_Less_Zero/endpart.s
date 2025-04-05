;    ___      ___      ___   
;   /\  \    /\__\    /\  \  
;  /::\  \  /:/__/_  /::\  \ 
; /:/\:\__\/::\/\__\/\:\:\__\
; \:\/:/  /\/\::/  /\:\:\/__/
;  \::/  /   /:/  /  \::/  / 
;   \/__/    \/__/    \/__/  
;
;    DEAD HACKERS SOCIETY
;
; Atari ST/e synclock demosystem v0.3
; January 6, 2008
;
; endpart.s
; 
; Anders Eriksson
; ae@dhs.nu
;

; MORE OR LESS ZERO - ENDPART
; Atari STe-demo 2008 (?)


;scr_w:		equ	230			;linewidth of fullscreen
;scr_h:		equ	280			;max lines visible

hatari:		equ	0			;Hatari specific codepath (bug workarounds)
hatari_speedup:	equ	0			;Hatari specific speedup during init

music_sndh:	equ	0			;Play a sndh music file
music_ym:	equ	0			;Play an ym-music file (YM3 only)
music_dma:	equ	0			;Play a DMA-sample sequence (STe only)
music_mod:	equ	1			;Play a ProTracker module (STe only)

init_green:	equ	0			;1=runtime init sets bg green when done

		opt	p=68000
		output .tos

		section	text

begin:		include	'sys/fullinit.s'		;setup demosystem

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM MAINLOOP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainloop:	tst.l	vbl_counter
		beq.s	mainloop
		clr.l	vbl_counter

		move.l	a0,-(sp)
		move.l	main_routine,a0
		jsr	(a0)
		move.l	(sp)+,a0
	
		cmp.b	#$39,$fffffc02.w		;space?
		bne.s	mainloop
		move.l	#endpart_end,part_position
		bra.s	mainloop
		include	'sys/fullexit.s'		;exit demosystem

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM VBL
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbl:
		clr.b	$fffffa19.w			;timer-a setup
		move.b	timera_delay+3,$fffffa1f.w	;
		move.b	timera_div+3,$fffffa19.w	;

		movem.l	d0-a6,-(sp)

		move.l	endpart_scr1,d0		;set screen
		add.l	endpart_scrollofs,d0
		add.l	#160,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		movem.l	endpart_setpal,d0-d7
		movem.l	d0-d7,$ffff8240.w


		ifne	music_ym
		jsr	music_ym_play
		endc
		
		ifne	music_sndh
		jsr	music_sndh_play
		endc

		ifne	music_dma
		jsr	music_dma_play
		endc

		ifne	music_mod
		jsr	protracker_vbl
		endc

		move.l	vbl_routine,a0
		jsr	(a0)


;		Micro demopart sequencer
		move.l	part_position,a0
		subq.l	#1,(a0)+
		bne.s	.no_switch
		add.l	#24,part_position
.no_switch:	move.l	(a0)+,timera_delay
		move.l	(a0)+,timera_div
		move.l	(a0)+,vbl_routine
		move.l	(a0)+,timera_routine
		move.l	(a0)+,main_routine

		addq.l	#1,vbl_counter
		addq.l	#1,global_vbl
		movem.l	(sp)+,d0-a6
		rte

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM HBL (PLACEHOLDER)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hbl:		rte

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM TIMER A
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timer_a:	movem.l	d0-a6,-(sp)
		move.l	timera_routine,a0
		jsr	(a0)
		movem.l	(sp)+,d0-a6
		rte

timer_a_dummy:	clr.b	$fffffa19.w			;stop ta
		rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		MISC COMMON ROUTINES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dummy:		rts


clear_screens:	move.l	screen_adr_base,a0
		moveq.l	#0,d0
		move.w	#128*1024/8-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

black_pal:	movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.black:		dcb.w	16,$0000

white_pal:	movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.black:		dcb.w	16,$0fff


syncfix:	move.l	global_vbl,.vbls

.wait_first:	move.l	.vbls,d0			;vsync
		cmp.l	global_vbl,d0
		bge.s	.wait_first

		ifeq	hatari
		move.b	#1,$ffff8260.w			;medres
		endc

		move.l	global_vbl,.vbls
		add.l	#2,.vbls			;n

.more:		move.l	global_vbl,d0			;vsync n times
		cmp.l	.vbls,d0
		ble.s	.more

		ifeq	hatari
		move.b	#0,$ffff8260.w			;lowres
		endc
		rts
.vbls:		dc.l	0


lmc1992:	move.w	#%11111111111,$ffff8924.w	;set microwire mask
		move.w	d0,$ffff8922.w
.waitstart	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		beq.s	.waitstart
.waitend	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire 
		bne.s	.waitend
		rts


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM INCLUDES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		ifne	hatari_speedup
		include	'hatari/hatari.s'
		endc

		ifne	music_sndh
		include	'music/sndh.s'
		endc

		ifne	music_ym
		include	'music/ym.s'
		endc
		
		ifne	music_dma
		include	'music/dma.s'
		endc

		ifne	music_mod
		include	'music/pt_src50.s'
		endc

		include	'sys/fade.s'

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER INIT LIST
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initlist:
		ifne	music_mod
		jsr	protracker_init
		endc

		jsr	endpart_init

		rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER CODE
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dotsanim:	equ	0
endpar:		equ	1

endpart_init:	move.l	screen_adr_base,d0	;init two screen buffers, each being 400 lines (for scroller wrapping)
		move.l	d0,endpart_scr1
		add.l	#1024*64,d0		
		move.l	d0,endpart_scr2
		rts

endpart_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	dotsanim
		jsr	dotsanim_init
		jsr	dotsanim_runtime_init
		endc

		ifne	endpar
		jsr	endpart_par_init
		endc

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

endpart_fadein:
		bsr.w	endpart_main

		subq.w	#1,.wait
		bne.s	.no
		move.w	#5,.wait
		
		lea.l	endpart_setpal,a0
		lea.l	endpart_pal,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	5

endpart_fadeout:
		bsr.w	endpart_main

		lea.l	endpart_setpal,a0
		lea.l	endpart_blackpal,a1
		jsr	component_fade
		
		rts

endpart_vbl:

		ifne	dotsanim
		move.l	endpart_scr2,d0
		add.l	endpart_scrollofs,d0
		add.l	#6,d0
		move.l	d0,dotsanim_scr
		jsr	dotsanim_vbl
		endc



		move.l	endpart_scr1,d0
		move.l	endpart_scr2,endpart_scr1
		move.l	d0,endpart_scr2

		not.w	.wait
		bne.s	.no
		cmp.l	#160*200,endpart_scrollofs
		blt.s	.add
		move.l	#160,endpart_scrollofs
		rts
.add:		add.l	#160,endpart_scrollofs
.no:		rts

.wait:		dc.w	0

endpart_main:	
		;move.w	#$0100,$ffff8240.w
		;dcb.w	124,$4e71
		;clr.w	$ffff8240.w
		
		bsr.w	endpart_scroller

		ifne	dotsanim
		jsr	dotsanim_main
		endc


		ifne	endpar
		bsr.w	endpart_par
		endc

		;move.w	#$0020,$ffff8240.w
		;dcb.w	124,$4e71
		;clr.w	$ffff8240.w

		rts

endpart_timer_a:	
		rts

endpart_scroller:
		move.l	endpart_scr1,a0
		add.l	endpart_scrollofs,a0
		lea.l	32000(a0),a1

		lea.l	endpart_text,a2
		add.l	endpart_textofs,a2		
		lea.l	endpart_chartab,a3

		lea.l	endpart_font,a4
		add.l	endpart_fontofs,a4

		cmp.l	#6*15,endpart_fontofs
		ble.w	.normal
		rept	20
		clr.l	(a0)+
		clr.w	(a0)+
		clr.l	(a1)+
		clr.w	(a1)+
		addq.l	#2,a0
		addq.l	#2,a1
		endr

		bra.s	.continue
.normal:		
		move.w	#20-1,d7
.char:
		moveq.l	#0,d0
		move.b	(a2)+,d0
		add.w	d0,d0
		move.w	(a3,d0.w),d0

		move.l	(a4,d0.w),d5
		move.w	4(a4,d0.w),d6
		move.l	d5,(a0)
		move.w	d6,4(a0)
		move.l	d5,(a1)
		move.w	d6,4(a1)

		addq.l	#8,a0
		addq.l	#8,a1
		dbra	d7,.char

.continue:
		not.w	.wait
		bne.s	.no
		cmp.l	#6*22,endpart_fontofs
		blt.s	.add
		clr.l	endpart_fontofs
		tst.l	(a2)
		beq.s	.wrap
		add.l	#20,endpart_textofs
		rts
.wrap:		clr.l	endpart_textofs
.add:		addq.l	#6,endpart_fontofs
.no:		rts
.wait:		dc.w	0


		ifne	endpar
endpart_par_init:
		lea.l	endpart_par_gfx,a0
		move.w	#200-1,d7
.clr:
		rept	10
		clr.l	(a0)+
		endr
		dbra	d7,.clr

		lea.l	endpart_par_gfx+40*200,a0
		lea.l	40*800(a0),a1
		lea.l	endpart_bg,a2
		move.w	#800-1,d7
.y:
		rept	10
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		endr
		dbra	d7,.y
		rts
endpart_par:
		move.l	endpart_scr1,a0
		lea.l	160(a0),a0
		add.l	endpart_scrollofs,a0
		addq.l	#6,a0
		lea.l	endpart_par_gfx,a1
		add.l	.ofs,a1

		move.w	#200-1,d7
.y:

q:		set	0
		rept	20
		move.w	(a1)+,q(a0)
q:		set	q+8
		endr
		lea.l	160(a0),a0
		dbra	d7,.y

		cmp.l	#40*1000,.ofs
		blt.s	.add
		move.l	#40*200,.ofs
		bra.s	.ok
.add:		add.l	#40,.ofs
.ok:		rts
.ofs:		dc.l	0
		endc

		section	data

endpart_textofs:
		dc.l	0	;20*350	;0
endpart_scrollofs:
		dc.l	0
endpart_fontofs:
		dc.l	0
endpart_chartab:
		dcb.w	32,$0000
q:		set	0
		rept	80
		dc.w	96*q
q:		set	q+1
		endr

			;01234567890123456789
endpart_text:
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "


		dc.b	" MORE OR LESS ZERO  "
		dc.b	"                    "
		dc.b	"        BY          "
		dc.b	"                    "
		dc.b	"DEAD HACKERS SOCIETY"
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"  RELEASED AT THE   "
		dc.b	"ALTERNATIVE PARTY'08"
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"FIRST SOME TECHNICAL"
		dc.b	"NOTES ABOUT THE DEMO"
		dc.b	"--------------------"
		dc.b	"ALL EFFECTS AND PICS"
		dc.b	"USE SYNCHRONIZED    "
		dc.b	"CODE IN SOME FORM.  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"ALL FULLSCREEN FX   "
		dc.b	"RUN IN FULL FRAME   "
		dc.b	"RATE (ONE VBL).     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"THE PARTIAL         "
		dc.b	"FULLSCREENS RUN     "
		dc.b	"COMBINED AT ONE VBL "
		dc.b	"AND MULTIPLE VBLS.  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"WE'RE USING THE FULL"
		dc.b	"OVERSCAN RESOLUTION "
		dc.b	"OF 416 PIXELS PER   "
		dc.b	"LINE AND 274 SCANS. "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"THE OVERSCAN ROUT   "
		dc.b	"IS A SIMPLIFIED AND "
		dc.b	"FASTER METHOD WHICH "
		dc.b	"WE BELIVE HAVE NOT  "
		dc.b	"BEEN USED BEFORE.   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"THE SPECTRUM 4096   "
		dc.b	"DISPLAYER USES AN   "
		dc.b	"EXTENDED RESOLUTION "
		dc.b	"OF 320 X 273 PIXELS "
		dc.b	"SIMILAR TO THE OLD  "
		dc.b	"SPX FORMAT INVENTED "
		dc.b	"BY ELECTRONIC IMAGES"
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"OK, ENOUGH OF TECH- "
		dc.b	"BABBLE AND ON TO    "
		dc.b	"SOME CRAP BABBLE    "
		dc.b	"INSTEAD...          "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"FOR YEARS WE HAVE   "
		dc.b	"BEEN THINKING ABOUT "
		dc.b	"CODING SOME STE     "
		dc.b	"SPECIFIC EFFECTS    "
		dc.b	"THAT COULDN'T BE    "
		dc.b	"MADE ON AN ST.      "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"WE DIDN'T CARE IF   "
		dc.b	"THE EFFECTS WERE NEW"
		dc.b	"OR OLD, WE JUST HAD "
		dc.b	"OUR MINDS SET TO    "
		dc.b	"SPANK THE STE HARD- "
		dc.b	"WARE A BIT!         "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"SOME OF THE EFFECTS "
		dc.b	"ARE CERTAINLY DOABLE"
		dc.b	"A PLAIN ST, BUT SOME"
		dc.b	"OF THEM NOT.        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"WE'RE PRETTY SURE   "
		dc.b	"THAT THERE WILL BE  "
		dc.b	"COMPLAINTS ABOUT US "
		dc.b	"USING TWO MEGS OF   "
		dc.b	"MEMORY.             "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"WE COULD MAKE THIS  "
		dc.b	"IN ONE MEG IF WE USE"
		dc.b	"CHIP MUSIC AND SPLIT"
		dc.b	"THE DEMO INTO MORE  "
		dc.b	"PARTS.              "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"BUT THE POINT OF THE"
		dc.b	"DEMO WAS ABOUT USING"
		dc.b	"THE STE HARDWARE SO "
		dc.b	"WE RATHER MADE IT IN"
		dc.b	"TWO MEGS THAN BADLY "
		dc.b	"CRIPPLE IT .        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"OK, ENOUGH BULLSHIT "
		dc.b	"FROM ME (EVIL), HERE"
		dc.b	"ARE THE CREDITS!    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"PICS........GIZMO'FR"
		dc.b	"MAINZIK..........505"
		dc.b	"ENDZIK......TOODELOO"
		dc.b	"ENDFONT......CYCLONE"
		dc.b	"MODPLAYER......LANCE"
		dc.b	"PACKER...........RAY"
		dc.b	"CODE...........GIZMO"
		dc.b	"CODE............EVIL"
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"BIG THANKS TO THE   "
		dc.b	"NICE PEOPLE WHO     "
		dc.b	"HELPED OUT WITH THE "
		dc.b	"DEMO:               "
		dc.b	"                    "
		dc.b	"GIZMO / FARBRAUSCH  "
		dc.b	"--------------------"
		dc.b	"FOR HIS AMAZING     "
		dc.b	"FULLSCREEN AND      "
		dc.b	"SPECTRUM 4096 PICS! "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"505 / PARADOX       "
		dc.b	"--------------------"
		dc.b	"FOR THE MAIN MUSIC  "
		dc.b	"WHICH WE GOT IN A   "
		dc.b	"STATE OF PANIC WHEN "
		dc.b	"ALL OTHER OPTIONS   "
		dc.b	"WERE SLIM. THANKS   "
		dc.b	"FOR SAVING THE DEMO "
		dc.b	"NILS!!              "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"CYCLONE / X-TROLL   "
		dc.b	"--------------------"
		dc.b	"FOR PAINTING THIS   "
		dc.b	"ENDPART FONT IN A   "
		dc.b	"BIG HURRY!          "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"AND FINALLY THIS    "
		dc.b	"ENDPART MUSIC WAS   "
		dc.b	"COMPOSED BY TOODELOO"
		dc.b	"                    "
		dc.b	"              R.I.P."
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"ALRIGHT, HOW ABOUT  "
		dc.b	"GREETINGS?          "
		dc.b	"                    "
		dc.b	"WERE YOU TOO SLOW TO"
		dc.b	"READ THEM IN THE    "
		dc.b	"DEMO?               "
		dc.b	"                    "
		dc.b	"YEAH SO WERE WE..   "
		dc.b	"                    "
		dc.b	"IN FACT THE GREETING"
		dc.b	"AND CREDIT SCREENS  "
		dc.b	"ARE ONLY IN THE DEMO"
		dc.b	"TO COVER UP FOR SOME"
		dc.b	"LENGTHY PRECALS..   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"ANYWAY HERE IS THE  "
		dc.b	"HUGE GREETINGS LIST!"
		dc.b	"(RANDOM ORDER)      "
		dc.b	"--------------------"
		dc.b	"RESERVOIR GODS      "
		dc.b	"KUA PRODUCTIONS     "
		dc.b	"EVOLUTION           "
		dc.b	"T.O.Y.S.            "
		dc.b	".TSCC.              "
		dc.b	"PARADOX             "
		dc.b	"MYSTIC BYTES        "
		dc.b	"AGGRESSION          "
		dc.b	"CHECKPOINT          "
		dc.b	"NOCREW              "
		dc.b	"ORB                 "
		dc.b	"CREATORS            "
		dc.b	"RAVE NETWORK OVERSC."
		dc.b	"X-TROLL             "
		dc.b	"DUNE                "
		dc.b	"REZ                 "
		dc.b	"ESCAPE              "
		dc.b	"EPHIDRENA           "
		dc.b	"MJJ PROD            "
		dc.b	"MR.STYCKX           "
		dc.b	"OXYGENE             "
		dc.b	"LINEOUT             "
		dc.b	"SATANTRONIC         "
		dc.b	"DEKADENCE           "
		dc.b	"THE BLACK LOTUS     "
		dc.b	"SECTOR ONE          "
		dc.b	"LAZER               "
		dc.b	"D-BUG               "
		dc.b	"TRIO                "
		dc.b	"CHRISTOS            "
		dc.b	"BUZZ                "
		dc.b	"AIDS                "
		dc.b	"ST KNIGHTS          "
		dc.b	"KNEZZEN             "
		dc.b	"ATEBIT              "
		dc.b	"SCARAB              "
		dc.b	"CREAM               "
		dc.b	"NEXT                "
		dc.b	"CEREBRAL VORTEX     "
		dc.b	"PARADIZE            "
		dc.b	"TORMENT             "
		dc.b	"ATIPYK DEVELOPMENT  "
		dc.b	"ORION               "
		dc.b	"NATURE              "
		dc.b	"NO EXTRA            "
		dc.b	"OXYRON              "
		dc.b	"T.A.O.S.            "
		dc.b	"STAX                "
		dc.b	"TRILOBIT            "
		dc.b	"ALIVE TEAM          "
		dc.b	"ULTRA CREW          "
		dc.b	"TCE DESIGN          "
		dc.b	"C.P.U.              "
		dc.b	"WAMMA               "
		dc.b	"PSYCHO HACKING FORCE"
		dc.b	"RIBBON              "
		dc.b	"THE REMOVERS        "
		dc.b	"YM ROCKERZ          "
		dc.b	"FARBRAUSCH          "
		dc.b	"TOS CREW            "
		dc.b	"YESCREW             "
		dc.b	"SCUM OF THE EARTH   "
		dc.b	"NEW BEAT            "
		dc.b	"DARK ANGEL          "
		dc.b	"T.N.G.              "
		dc.b	"SAGE                "
		dc.b	"IMPONANCE           "
		dc.b	"                    "
		dc.b	"AND ALL THE PEOPLE  "
		dc.b	"AT THE ALTERNATIVE  "
		dc.b	"PARTY 2008!         "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"OK BACK TO THE CRAP "
		dc.b	"TALKING..           "
		dc.b	"                    "
		dc.b	"THE WORK ON THE DEMO"
		dc.b	"BEGAN (AS SO OFTEN) "
		dc.b	"WITH A NEW DEMO-    "
		dc.b	"SEQUENCER.          "
		dc.b	"                    "
		dc.b	"THIS TIME WE HAD TO "
		dc.b	"SUPPORT FULLSCREENS,"
		dc.b	"SPECTRUM 4096 PICS, "
		dc.b	"AND PLASMA STYLE    "
		dc.b	"EFFECTS.            "
		dc.b	"                    "
		dc.b	"IT WAS EASIER TO DO "
		dc.b	"A COMPLETE RE-WRITE "
		dc.b	"THAN TO ADAPT THE   "
		dc.b	"OLD ONE.            "
		dc.b	"                    "
		dc.b	"IN THE END I THINK  "
		dc.b	"IT GOT QUITE SMOOTH "
		dc.b	"TO WORK WITH AND    "
		dc.b	"DOING A MULTI-PART  "
		dc.b	"ISN'T THAT DIFFERENT"
		dc.b	"FROM BEFORE.        "
		dc.b	"                    "
		dc.b	"WE'LL PROBABLY MAKE "
		dc.b	"THE DEMO-SYSTEM OPEN"
		dc.b	"SOURCE IN A WHILE.  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"AS YOU READ EARLIER "
		dc.b	"THIS DEMO USES A NEW"
		dc.b	"FASTER WAY OF DOING "
		dc.b	"OVERSCAN.           "
		dc.b	"                    "
		dc.b	"BUT IN FACT IT'S    "
		dc.b	"ONLY A SLIGHT DIFF- "
		dc.b	"ERENCE COMPARED TO  "
		dc.b	"THE TRADITIONAL     "
		dc.b	"ROUTINES.           "
		dc.b	"                    "
		dc.b	"BASICLY AT THE END  "
		dc.b	"OF EACH SCANLINE    "
		dc.b	"WE DON'T DO THE     "
		dc.b	"STABILIZER THING.   "
		dc.b	"                    "
		dc.b	"IT SAVES A BUNCH OF "
		dc.b	"CYCLES. THE DOWNSIDE"
		dc.b	"IS THAT IT ONLY     "
		dc.b	"WORKS ON THE STE-   "
		dc.b	"SHIFTERS.           "
		dc.b	"                    "
		dc.b	"THE OVERSCAN LINE   "
		dc.b	"GETS A NICE, EVEN   "
		dc.b	"224 BYTE LINEWIDTH  "
		dc.b	"COMPARED TO THE 230 "
		dc.b	"BYTES OF A NORMAL   "
		dc.b	"OVERSCAN ROUTINE.   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"IF YOU WANT SOURCES "
		dc.b	"JUST MAIL US!       "
		dc.b	"                    "
		dc.b	"-> AE@DHS.NU        "
		dc.b	"-> GIZMO@DHS.NU     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"THE WORK ON THE DEMO"
		dc.b	"HAVE BEEN GOING ON  "
		dc.b	"FOR AN UNUSUALLY    "
		dc.b	"LONG TIME. WE'RE    "
		dc.b	"USED TO FIX A DEMO  "
		dc.b	"IN A COUPLE OF      "
		dc.b	"MONTHS.             "
		dc.b	"                    "
		dc.b	"THIS TIME HOWEVER,  "
		dc.b	"IT TOOK NINE MONTHS."
		dc.b	"                    "
		dc.b	"WE BLAME WORK AND   "
		dc.b	"OTHER CRAPPY THINGS "
		dc.b	"FOR THE DELAYS!     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"IT'S TIME TO WRAP   "
		dc.b	"THIS UP AND FINISH  "
		dc.b	"THE DEMO.           "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"THANKS FOR WATCHING "
		dc.b	"AND READING THE LONG"
		dc.b	"AND BORING TEXT.    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"SEE YOU NEXT TIME!  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"DEAD HACKERS SOCIETY"
		dc.b	"    OCTOBER 2008    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "

		dc.l	0

		even

endpart_font:	incbin	'endfont.3pl'
		even

		ifne	endpar
endpart_bg:	incbin	'endbg.1pl'
		even
		endc

endpart_blackpal:	dcb.w	16,$0000
endpart_setpal:		dcb.w	16,$0000
endpart_pal:		dc.w	$0000,$0776,$0752,$0532,$0421,$0310,$0200,$0000
			dc.w	$0888,$0776,$0752,$0532,$0421,$0310,$0200,$0000

		ifne	dotsanim
		include	'dotsanim/dotsanim.s'
		endc

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		LIST OF DEMOPARTS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		section	data

;format
;dc.l vbls,ta_delay,ta_div,vbl,ta,main

partlist:
		dc.l	200,99,4,dummy,timer_a_dummy,endpart_runtime_init
		dc.l	150,99,4,endpart_vbl,endpart_timer_a,endpart_fadein
		dc.l	-1,99,4,endpart_vbl,endpart_timer_a,endpart_main
endpart_end:	dc.l	150,99,4,endpart_vbl,endpart_timer_a,endpart_fadeout

		dc.l	-1,100,4,dummy,dummy,exit

;		Do not shift order of these variables
part_position:	dc.l	partlist
timera_delay:	dc.l	0
timera_div:	dc.l	0
vbl_routine:	dc.l	dummy
timera_routine:	dc.l	dummy
main_routine:	dc.l	dummy
vbl_counter:	dc.l	0
global_vbl:	dc.l	0

empty:			dcb.b	160*32+256,$00
empty_adr:		dc.l	0

		section	bss

endpart_scr1:	ds.l	1
endpart_scr2:	ds.l	1

		ifne	endpar
endpart_par_gfx:		ds.b	40*1800
		endc

		section	text

