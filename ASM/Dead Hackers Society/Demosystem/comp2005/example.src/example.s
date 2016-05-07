
		comment HEAD=%011


		section	text

;-------------- save and setup the system -------------
		jmp	init_program


;-------------- insert your init routines here ---------
user_inits:	move.l	screen_adr,a0			;copy pi1 image to workscreens
		move.l	screen_adr2,a1			;
		lea.l	picture+34,a2			;
		move.w	#32000/4-1,d7			;
.copy:		move.l	(a2)+,d0			;
		move.l	d0,(a0)+			;
		move.l	d0,(a1)+			;
		dbra	d7,.copy			;

		movem.l	picture+2,d0-d7			;set palette of pi1 picture
		movem.l	d0-d7,$ffff8240.w		;

		rts


;-------------- mainloop - use for all heavy routines
mainloop:	tst.w	cpu060				;check for 68060
		beq.s	.no060				;if available flush
		move.w  #0,-(sp)			;caches to make
		move.w  #3,-(sp)			;SMC chip players
		move.w  #160,-(sp)			;resonably happy
		trap    #14				;
		addq.l  #6,sp				;
.no060:							;

		tst.w	vblwait				;make sure mainloop 
		beq.s	.no				;doeasn't run >1 
		clr.w	vblwait				;times each VBL


		;insert code to run here


		move.l	screen_adr,d0			;set screen
		move.b	d0,d1				;
		lsr.w   #8,d0				;
		move.b  d0,$ffff8203.w			;
		swap    d0				;
		move.b  d0,$ffff8201.w			;

 		move.l	screen_adr,d0			;swap screens
		move.l	screen_adr2,screen_adr		;doublebuffer
		move.l	d0,screen_adr2			;


.no:		cmp.b	#$39,$fffffc02.w		;check for space
		beq.w	exit_program			;exit
		bra.w	mainloop





;-------------- VBL - use for syncs, music calling and such stuff
vbl:		movem.l	d0-a6,-(sp)			;save regs


		;insert code to run here


		jsr	player+8			;play SNDH


		addq.w	#1,vblwait			;add vbl counter

		movem.l	(sp)+,d0-a6			;restore regs
		rte					;
		
		
		
		







init_program:
;-------------- check program length and add mem for sp
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


;-------------- return unused memory to the os --------
		move.l	d0,-(sp)			;mshrink()
		move.l	a5,-(sp)			;
		move.w	d0,-(sp)			;
		move.w	#$4a,-(sp)			;
		trap	#1				;
		lea	12(sp),sp			;


;-------------- reserve memory for screens - fastram compatible!
		move.l	#64000+256,-(sp)		;malloc()
		move.w	#72,-(sp)			;screen memory
		trap	#1				;
		addq.l	#6,sp				;
		tst.l	d0				;
		beq.w	pterm				;


;-------------- setup screenpointers to screen_adr and screen_adr2		
		add.l	#256,d0				;init screens
		clr.b	d0				;even by 256 bytes
		move.l	d0,screen_adr			;

		add.l	#32000,d0			;
		move.l	d0,screen_adr2			;

		move.l	screen_adr,a0			;clear screens
		move.w	#64000/64-1,d7			;
.loop:		rept	16				;
		clr.l	(a0)+				;
		endr					;
		dbra	d7,.loop			;


;-------------- save old screen positions --------------
		move.w	#2,-(sp)			;save phys
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_phys			;

		move.w	#3,-(sp)			;save log
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_log			;


;-------------- enter supervisor mode ------------------
		clr.l	-(sp)				;supervisormode
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;


;-------------- Check graphics type via Cookiejar
		move.l	#"_VDO",d1			;_VDO cookie for video type	
		move.l	$5a0.w,d0			;
		beq.s	.nojar				;
		move.l	d0,a0				;
.search:	tst.l	(a0)				;
		beq.s	.nofind				;
		cmp.l	(a0),d1				;
		beq.s	.foundit			;
		addq.l	#8,a0				;
		bra.s	.search				;
.nofind:	moveq	#-1,d0				;
		bra.s	.cookieexit			;
.nojar:		moveq	#-2,d0				;
		bra.s	.cookieexit			;
.foundit:	moveq	#0,d0				;
.cookieexit:

;-------------- save and setup screens depending what found in the _VDO cookie
		tst.l	d0				;if not 0, st for sure
		bne.s	.st				;
		cmp.l	#$00010000,4(a0)		;1=ste
		beq.s	.ste				;
		cmp.l	#$00020000,4(a0)		;2=tt
		beq.s	.tt				;
		cmp.l	#$00030000,4(a0)		;3=falcon
		beq.s	.falc				;
		bra.s	.st				;if nothing else, assume ST
.ste:		move.w	#1,computer			;
		bra.s	.st				;
.tt:		move.w	#2,computer			;
.st:		move.w	#4,-(sp)			;save resolution (st/tt)
		trap	#14				;
		addq.l	#2,sp				;
		move.w	d0,save_res			;
		move.w	#0,-(sp)			;set stlow (st/tt)
		move.l	#-1,-(sp)			;
		move.l	#-1,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea	12(sp),sp			;
		bra.w	.video_done			;
.falc:		move.w	#3,computer			;
		lea.l	save_f030video,a0		;
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
		beq.w	.rgb				;
		cmp.w	#3,d0				;if 3 = tv
		beq.w	.rgb				;otherwise assume vga (ignore mono..)
.vga50:		move.l	#$170011,$ffff8282.w		;falcon 50Hz vga
		move.l	#$2020e,$ffff8286.w		;
		move.l	#$d0012,$ffff828a.w		;
		move.l	#$4eb04d1,$ffff82a2.w		;
		move.l	#$3f00f5,$ffff82a6.w		;
		move.l	#$41504e7,$ffff82aa.w		;
		move.w	#$200,$ffff820a.w		;
		move.w	#$186,$ffff82c0.w		;
		clr.w	$ffff8266.w			;
		clr.b	$ffff8260.w			;
		move.w	#$5,$ffff82c2.w			;
		move.w	#$50,$ffff8210.w		;
		bra.s	.video_done
.rgb:		move.l	#$300027,$ffff8282.w		;falcon 50Hz rgb
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
.video_done:


;-------------- save the old colour palette ------------
		movem.l	$ffff8240.w,d0-d7		;save palette
		movem.l	d0-d7,save_pal			;


;-------------- set all colours black-------------------
		lea.l	$ffff8240.w,a0			;black palette
		rept	8				;
		clr.l	(a0)+				;
		endr					;

;-------------- set screenpointer to reserved memory ---
		move.w	#-1,-(sp)			;set screen
		move.l	screen_adr,-(sp)		;
		move.l	#-1,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea.l	12(sp),sp			;

;-------------- save and turn off key clicks------------
		move.b	$484.w,save_keymode		;save keyclick
		bclr	#0,$484				;keyclick off


;-------------- check if we're using 68060 -------------
check_cpu:	lea.l	$05a0.w,a0			;cookiejar pointer
		tst.l	(a0)				;== 0 no cookiejar, st for sure
		beq.s	.done				;

		move.l	(a0),a0				;cookiejar address
		
.loop:		tst.l	(a0)				;== 0 cookiejar ended
		beq.s	.done				;
		cmp.l	#"_CPU",(a0)			;check for CPU cookie
		beq.s	.found_cookie			;found
		addq.l	#8,a0				;next cookie
		bra.s	.loop				;

.found_cookie:	cmp.l	#$0000003c,4(a0)		;check for 60 (68060)
		beq.s	.found060			;yippie!
		bra.s	.done				;

.found060:	move.w	#1,cpu060
.done:


;-------------- inititalise SNDH player ----------------						
		moveq.l	#0,d0				;
		jsr	player+0			;



;------------- run user inits --------------------------;
		bsr.w	user_inits			;


;-------------- setup VBL and then all inits are done --
		move.w	sr,d0				;store sr
		move.w	#$2700,sr			;stop all ints
		move.l	$070.w,save_vbl			;
		move.l	#vbl,$70.w			;install new vbl
		move.w	d0,sr				;restore sr

		jmp	mainloop





exit_program:

;-------------- restore VBL ---------------------------
		move.w	#$2700,sr			;all ints off
		move.l	save_vbl,$70			;restore vbi
		move.w	#$2300,sr			;all ints on


;-------------- de initialize SNDH player --------------
		jsr	player+4			;SNDH off


;-------------- silence! -------------------------------
		lea.l	$ffff8800.w,a0			;
		move.l	#$08000000,(a0)			;
		move.l	#$09000000,(a0)			;
		move.l	#$0a000000,(a0)			;


;-------------- restore video --------------------------
		cmp.w	#3,computer			;
		beq.s	.falc				;
.st:		move.w	save_res,-(sp)			;restore screenadr & resolution (st)
		move.l	save_phys,-(sp)			;
		move.l	save_log,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea.l	12(sp),sp			;
		bra.w	.video_done			;
.falc:		clr.w   $ffff8266.w     	        ;falcon-shift clear
		lea.l	save_f030video,a0	
		move.l	(a0)+,$ffff8200.w		;videobase_address:h&m
		move.w	(a0)+,$ffff820c.w		;l
		move.l	(a0)+,$ffff8282.w		;h-regs
		move.l	(a0)+,$ffff8286.w		;
		move.l	(a0)+,$ffff828a.w		;
		move.l	(a0)+,$ffff82a2.w		;v-regs
		move.l	(a0)+,$ffff82a6.w		;
		move.l	(a0)+,$ffff82aa.w		;
		move.w	(a0)+,$ffff82c0.w		;vco
		move.w	(a0)+,$ffff82c2.w		;c_s
		move.l	(a0)+,$ffff820e.w		;offset
		move.w	(a0)+,$ffff820a.w		;sync
		move.b  (a0)+,$ffff8256.w		;p_o
		tst.b   (a0)+   			;st(e) comptaible mode?
	        bne.s   .ok	
		move.w  (a0),$ffff8266.w		;falcon-shift
		bra.s	.video_done
.ok:		move.w  2(a0),$ffff8260.w		;st-shift
		lea.l	save_f030video,a0
		move.w	32(a0),$ffff82c2.w		;c_s
		move.l	34(a0),$ffff820e.w		;offset
.video_done:

;-------------- restore palette ------------------------
		movem.l	save_pal,d0-d7			;
		movem.l	d0-d7,$ffff8240.w		;


;-------------- restore keyclick -----------------------
		move.b	save_keymode,$484.w		;


;-------------- exit supervisor mode -------------------
		move.l	save_stack,-(sp)		;
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;


;-------------- terminate program ----------------------
pterm:		clr.w	-(sp)				;pterm()
		trap	#1				;








		section	data

player:		incbin	'gigatex.snd'
		even

picture:	incbin	'test.pi1'
		even

		section	bss

		even
cpu060:		ds.w	1
computer:	ds.w	1				;0=st 1=ste 2=tt 3=falc
vblwait:	ds.w	1				;for fx in less than 1vbl
screen_adr:	ds.l	1				;screen address 1
screen_adr2:	ds.l	1				;screen address 2
save_stack:	ds.l	1				;old stackpointer
save_phys:	ds.l	1				;old physbase
save_log:	ds.l	1				;old logbase
save_vbl:	ds.l	1				;old vbl
save_dta:	ds.l	1				;old dta address
save_res:	ds.w	1				;old screen resolution
save_pal:	ds.l	8				;old colours
save_f030video:	ds.b	32+12+2				;old falcon video
save_keymode:	ds.b	1				;old keyklick status
		even