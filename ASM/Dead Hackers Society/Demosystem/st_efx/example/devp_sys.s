
; System code for the ST-Demoscreen online compo.
; Do not modify this file!
;
; Anders Eriksson
; ae@dhs.nu
;
; July 1, 2001

		section	text

		move.l	4(sp),a5			;address to basepage
		move.l	$0c(a5),d0			;length of text segment
		add.l	$14(a5),d0			;length of data segment
		add.l	$1c(a5),d0			;length of bss segment
		add.l	#$100,d0			;length of basepage
		add.l	#$1000,d0			;length of stackpointer
		move.l	a5,d1				;address to basepage
		add.l	d0,d1				;end of program
		and.l	#-2,d1				;make address even
		move.l	d1,sp				;new stackspace

		move.l	d0,-(sp)			;mshrink()
		move.l	a5,-(sp)			;
		move.w	d0,-(sp)			;
		move.w	#$4a,-(sp)			;
		trap	#1				;
		lea	12(sp),sp			;

		move.l	#64000+256,-(sp)		;malloc()
		move.w	#72,-(sp)			;screen memory
		trap	#1				;
		addq.l	#6,sp				;
		tst.l	d0				;
		beq.w	exit_nostram			;
		
		add.l	#256,d0				;init screens
		clr.b	d0				;even by 256 bytes
		move.l	d0,screen_adr			;
		add.l	#32000,d0			;
		move.l	d0,screen_adr2			;

		move.l	screen_adr,a0			;clear screens
		move.w	#64000/64-1,d7			;
clearscreen:	rept	16				;
		clr.l	(a0)+				;
		endr					;
		dbra	d7,clearscreen			;

		move.w	#2,-(sp)			;save phys
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_phys			;

		move.w	#3,-(sp)			;save log
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_log			;

		clr.l	-(sp)				;supervisor
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;


;-------------- Check machinetype via Cookiejar

		move.l	#"_VDO",d1			;cookie we want	
		move.l	$5a0.w,d0			;get address of cookie jar in d0
		beq.s	init_nojar			;If zero, there's no jar.
		move.l	d0,a0				;move the address of the jar to a0
init_search:	tst.l	(a0)				;is this jar entry the last one ?
		beq.s	init_nofind			;yes, the cookie was not found
		cmp.l	(a0),d1				;does this cookie match what we're looking for?
		beq.s	init_foundit			;yes, it does.
		addq.l	#8,a0				;advance to the next jar entry
		bra.s	init_search			;and start over
init_nofind:	moveq	#-1,d0				;a negative (-1) means cookie not found
		bra.s	init_cookieexit
init_nojar:	moveq	#-2,d0				;a negative (-2) means there's no jar
		bra.s	init_cookieexit
init_foundit:	moveq	#0,d0				;a null in d0 means the cookie was found.
init_cookieexit:

		tst.l	d0				;if not 0, st for sure
		bne.s	init_st				;
		cmp.l	#$00010000,4(a0)		;1=ste
		beq.s	init_ste			;
		cmp.l	#$00020000,4(a0)		;2=tt
		beq.s	init_tt				;
		cmp.l	#$00030000,4(a0)		;3=falcon
		beq.s	init_falc			;
		bra.s	init_st				;if nothing else, assume ST
init_ste:	move.w	#1,computer			;
		bra.s	init_st				;
init_tt:	move.w	#2,computer			;
init_st:	move.w	#4,-(sp)			;save resolution (st/tt)
		trap	#14				;
		addq.l	#2,sp				;
		move.w	d0,save_res			;
		move.w	#0,-(sp)			;set stlow (st/tt)
		move.l	#-1,-(sp)			;
		move.l	#-1,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea	12(sp),sp			;
		bra.w	init_video_done
init_falc:	move.w	#3,computer
		lea.l	save_f030video,a0
		move.l	$ffff8200.w,(a0)+		;vidhm
		move.w	$ffff820c.w,(a0)+		;vidl
		move.l	$ffff8282.w,(a0)+		;h-regs
		move.l	$ffff8286.w,(a0)+		;
		move.l	$ffff828a.w,(a0)+		;
		move.l	$ffff82a2.w,(a0)+		;v-regs
		move.l	$ffff82a6.w,(a0)+		;
		move.l	$ffff82aa.w,(a0)+		;
		move.w	$ffff82c0.w,(a0)+		;vco
		move.w	$ffff82c2.w,(a0)+		;c_s
		move.l	$ffff820e.w,(a0)+		;offset
		move.w	$ffff820a.w,(a0)+		;sync
		move.b  $ffff8256.w,(a0)+		;p_o
		clr.b   (a0)				;test of st(e) or falcon mode
		cmp.w   #$b0,$ffff8282.w		;hht kleiner $b0?
		sle     (a0)+				;flag setzen
		move.w	$ffff8266.w,(a0)+		;f_s
		move.w	$ffff8260.w,(a0)+		;st_s
		move.w	#$59,-(sp)			;check monitortype (falcon)
		trap	#14				;
		addq.l	#2,sp				;
		cmp.w	#1,d0				;if 1 = rgb
		beq.w	rgb50				;
		cmp.w	#3,d0				;if 3 = tv
		beq.w	rgb50				;otherwise assume vga (ignore mono..)
vga60:		move.l	#$170012,$ffff8282.w		;falcon 60Hz vga
		move.l	#$1020e,$ffff8286.w		;
		move.l	#$d0012,$ffff828a.w		;
		move.l	#$41903ff,$ffff82a2.w		;
		move.l	#$3f008d,$ffff82a6.w		;
		move.l	#$3ad0415,$ffff82aa.w		;
		move.w	#$200,$ffff820a.w		;
		move.w	#$186,$ffff82c0.w		;
		clr.w	$ffff8266.w			;
		clr.b	$ffff8260.w			;
		move.w	#$5,$ffff82c2.w			;
		move.w	#$50,$ffff8210.w		;
		bra.s	init_video_done
rgb50:		move.l	#$300027,$ffff8282.w		;falcon 50Hz rgb
		move.l	#$70229,$ffff8286.w		;
		move.l	#$1e002a,$ffff828a.w		;
		move.l	#$2710265,$ffff82a2.w		;
		move.l	#$2f0081,$ffff82a6.w		;
		move.l	#$211026b,$ffff82aa.w		;
		move.w	#$200,$ffff820a.w		;
		move.w	#$185,$ffff82c0.w		;
		clr.w	$ffff8266.w			;
		clr.b	$ffff8260.w			;
		clr.w	$ffff82c2.w			;
		move.w	#$50,$ffff8210.w		;
init_video_done:
		movem.l	$ffff8240.w,d0-d7		;save palette
		movem.l	d0-d7,save_pal			;

		lea.l	$ffff8240.w,a0			;black palette
		rept	8				;
		clr.l	(a0)+				;
		endr					;

		move.w	#-1,-(sp)			;set screen
		move.l	screen_adr,-(sp)		;
		move.l	#-1,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea.l	12(sp),sp			;

		move.b	$484.w,save_keymode		;save keyclick mode
		bclr	#0,$484				;keyclick off

		bsr.w	compo_init			;run effect init
		
		ifne	playmusic
		jsr	sndfile				;init music
		endc

		move.l	$70.w,save_vbl
		move.l	#vbl,$70.w

		move.l	$114.w,save_tc
		move.l	#timer_c,$114.w




; --------------------------------------------------------------
; ------------- Mainloop ---------------------------------------
; --------------------------------------------------------------


mainloop:	cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	nomain					;

		tst.w	vblflag
		beq.s	nomain

		jsr	compo_mainrout

		clr.w	vblflag

		cmp.b	#$1d,$fffffc02.w			;show cpuuse
		bne.s	nocpu					;
		move.w	$ffff8240.w,d0				;
		not.w	$ffff8240.w				;
		move.w	#100-1,d7				;
cpuuse:		nop						;
		dbra	d7,cpuuse				;
		move.w	d0,$ffff8240				;
nocpu:		

		move.l	screen_adr,d0				;swap screens
		move.l	screen_adr2,screen_adr			;
		move.l	d0,screen_adr2				;

nomain:		cmp.b	#$39,$fffffc02.w			;check for space
		beq.w	exit					;exit
		bra.s	mainloop				;



; --------------------------------------------------------------
; ------------- VBL 50/60Hz ------------------------------------
; --------------------------------------------------------------


vbl:		movem.l	d0-a6,-(sp)

		move.w	#1,vblflag

		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	novbl					;

		move.l	screen_adr,d0				;set screen
		move.b	d0,d1					;
		lsr.w   #8,d0					;
		move.b  d0,$ffff8203.w				;
		swap    d0					;
		move.b  d0,$ffff8201.w				;

		jsr	compo_vblrout

novbl:		movem.l	(sp)+,d0-a6
		rte


; --------------------------------------------------------------
; ------------- Timer-C 200Hz ----------------------------------
; --------------------------------------------------------------

timer_c:	movem.l	d0-a6,-(sp)

		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	notimer					;
		
		jsr	compo_timerrout

		ifne	playmusic
		subq.w	#1,music50hz				;play music at 50Hz
		bne.s	notimer					;
		move.w	#4,music50hz				;
		jsr	sndfile+8				;
		endc
		
notimer:	movem.l	(sp)+,d0-a6
		rte

		ifne	playmusic
music50hz:	dc.w	4
		endc


; --------------------------------------------------------------
; ------------- Exit -------------------------------------------
; --------------------------------------------------------------

exit:		move.l	save_vbl,$70.w
		move.l	save_tc,$114.w

		ifne	playmusic		
		jsr	sndfile+4				;stop music
		endc

		cmp.w	#3,computer
		beq.s	falcrestore
strestore:	move.w	save_res,-(sp)				;restore screenadr & resolution (st)
		move.l	save_phys,-(sp)				;
		move.l	save_log,-(sp)				;
		move.w	#5,-(sp)				;
		trap	#14					;
		lea.l	12(sp),sp				;
		bra.w	video_done				;

falcrestore:	clr.w   $ffff8266.w     		        ;falcon-shift clear
		lea.l	save_f030video,a0	
		move.l	(a0)+,$ffff8200.w			;videobase_address:h&m
		move.w	(a0)+,$ffff820c.w			;l
		move.l	(a0)+,$ffff8282.w			;h-regs
		move.l	(a0)+,$ffff8286.w			;
		move.l	(a0)+,$ffff828a.w			;
		move.l	(a0)+,$ffff82a2.w			;v-regs
		move.l	(a0)+,$ffff82a6.w			;
		move.l	(a0)+,$ffff82aa.w			;
		move.w	(a0)+,$ffff82c0.w			;vco
		move.w	(a0)+,$ffff82c2.w			;c_s
		move.l	(a0)+,$ffff820e.w			;offset
		move.w	(a0)+,$ffff820a.w			;sync
		move.b  (a0)+,$ffff8256.w			;p_o
		tst.b   (a0)+   				;st(e) comptaible mode?
	        bne.s   falcok	
		move.w  (a0),$ffff8266.w			;falcon-shift
		bra.s	video_done
falcok:		move.w  2(a0),$ffff8260.w			;st-shift
		lea.l	save_f030video,a0
		move.w	32(a0),$ffff82c2.w			;c_s
		move.l	34(a0),$ffff820e.w			;offset
video_done:

		movem.l	save_pal,d0-d7				;restore st palette
		movem.l	d0-d7,$ffff8240.w			;

		move.b	save_keymode,$484.w			;restore keyclick

		move.l	save_stack,-(sp)			;exit supervisor
		move.w	#32,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;

exit_nostram:	clr.w	-(sp)					;pterm()
		trap	#1					;



setpal:		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


; --------------------------------------------------------------
; ------------- Section DATA -----------------------------------
; --------------------------------------------------------------

		section	data

		ifne	playmusic
sndfile:	incbin	'force.snd'
		even
		endc



; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

		section	bss

vblflag:	ds.w	1
computer:	ds.w	1					;0=st 1=ste 2=tt 3=falc
screen_adr:	ds.l	1					;screen address 1
screen_adr2:	ds.l	1					;screen address 2
save_stack:	ds.l	1					;old stackpointer
save_phys:	ds.l	1					;old physbase
save_log:	ds.l	1					;old logbase
save_tc:	ds.l	1					;old timer-c
save_vbl:	ds.l	1					;old vbl
save_res:	ds.w	1					;old screen resolution
save_pal:	ds.l	8					;old colours
save_f030video:	ds.b	32+12+2					;old falcon video
save_keymode:	ds.b	1					;old keyklick status

		section	text
