* ATARI FREAKS DEMO
* Code: Jace/STKnights 1993-2005


mfp	=	$fffffa00
iera	=	$07		
ierb	=	$09
isra	=	$0f
imra	=	$13
tbcr	=	$1b
tbdr	=	$21
tacr	=	$19
tadr	=	$1f
vector	=	$17


nbrl		equ 	152 *numbers of lines diplayed
Lg_depart	equ	26  *first line
Secondes	equ	10  *time between plasma changes

		comment HEAD=%011


		section	text

;-------------- save and setup the system -------------
		jmp	init_program


;-------------- insert your init routines here ---------
user_inits:
		move.l	screen_adr,a0			;copy pi1 image to workscreens
		move.l	screen_adr2,a1			;
		move.w	#160*200/4-1,d0
lg_desin:	clr.l	(a0)+
		clr.l	(a1)+
		dbra	d0,lg_desin

		move.l	screen_adr,a0			;copy pi1 image to workscreens
		move.l	screen_adr2,a1
		lea	160(a0),a0
		lea	160(a1),a1			;
		lea.l	logo+34,a2			;
		move.w	#(160*24)/4-1,d7			;
.copy:		move.l	(a2)+,d0			;
		move.l	d0,(a0)+			;
		move.l	d0,(a1)+			;
		dbra	d7,.copy			;

;		lea	logo+34+160*53,a2
;		move.l	screen_adr,a0			;copy pi1 image to workscreens
;		move.l	screen_adr2,a1			;
;		lea	160*176(a0),a0
;		lea	160*176(a1),a1
;		move.w	#160/4-1,d0
;lg_desin:	move.l	(a2),(a0)+
;		move.l	(a2)+,(a1)+
;		dbra	d0,lg_desin

		;movem.l	picture+2,d0-d7			;set palette of pi1 picture
		;movem.l	d0-d7,$ffff8240.w		;

;		move.w	#$012,fontes
		bsr	Prepare_couleurs 
		bsr	codage

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
		beq.s	.no060				;doeasn't run >1 
		clr.w	vblwait				;times each VBL


;	eor.w	#$123,$ffff8240.w
	bsr	Routine_plasma
;	bsr	Sctexte
;	eor.w	#$123,$ffff8240.w

	tst.w	decompt_effet
	beq.s	Mode_fade_plasma

	subq	#1,decompt_effet
	bne	passe

Mode_fade_plasma
	move.l	fade_plasma,d0
	add.l	d0,pt_fade
tst_plama:
	cmp.l	#Colorz-30*nbrl,pt_fade
	bne.s	passe1			

	move.w	nbrp,d0	
	addq	#1,d0
	and.w	#7,d0
	move.w	d0,nbrp
	lea	table_plasma,a0
	lsl.w	#2,d0
	move.l	(a0,d0.w),buffer_plasma

	neg.l	fade_plasma
	bra	passe
	
passe1
	cmp.l	#Colorz,pt_fade
	bne	passe
	neg.l	fade_plasma
	move.w	#50*Secondes,decompt_effet

passe
	
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
		add.l	d0,Scrolling1
		add.l	#32000,d0			;
		move.l	d0,screen_adr2			;
		add.l	d0,Scrolling2

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


;------------- run user inits --------------------------;
	bsr.w	user_inits			;


;-------------- setup VBL and then all inits are done --
	move	#$2700,sr
	bsr	Sauve
	move.w	#mfp,a0
	bclr	#4,ierb(a0)
	bclr	#5,ierb(a0)
	bclr	#3,vector(a0)
	clr.b	tbcr(a0)
	bset	#0,iera(a0)	; Timer B
	bset	#0,imra(a0)
	bsr	MUSIC			; init music
	move.l	#Vbl,$70.w
	move.l	#Timerb,$120.w
	move.b	#$12,$fffffc02.w
	stop	#$2300


	jmp	mainloop
 


SAUVE	LEA	SAUVE_ALL,A0
	LEA	$FFFFFA00.W,A1
	MOVE.B	7(A1),(A0)+
	MOVE.B	$9(A1),(A0)+
	MOVE.B	$13(A1),(A0)+
	MOVE.B	$15(A1),(A0)+
	MOVE.L	$70.W,(A0)+
	MOVE.L	$134.W,(A0)+
	MOVE.L	$120.W,(A0)+
	MOVEM.L	$FFFF8240.W,D0-D7
	MOVEM.L	D0-D7,(A0)
	RTS

Restaure
	LEA	$FFFFFA00.W,A1
	LEA	SAUVE_ALL,A0
	MOVE.B	(A0)+,$7(A1)
	MOVE.B	(A0)+,$9(A1)
	MOVE.B	(A0)+,$13(A1)
	MOVE.B	(A0)+,$15(A1)
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$134.W
	MOVE.L	(A0)+,$120.W
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	RTS

exit_program:

;-------------- restore VBL ---------------------------
		move.w	#$2700,sr			;all ints off
		bsr	MUSIC+$4		; de-init music
		bsr	Restaure
		move.b	#$8,$fffffc02.w
		move.w	#$2300,sr			;all ints on


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



;-------------- fading rout ----------------------

RGB1	dc.b	0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15


Fading
	move.w	d0,-(sp)
floop
	move.w	(a0),d1
	move.w	(a1)+,d2
 
	move.w	d1,d3
	and.w	#$f00,d3
	lsr.w	#8,d3
	move.b	RGB1(pc,d3.w),d3
	move.w	d2,d4
	and.w	#$f00,d4
	lsr.w	#8,d4
	move.b	RGB1(pc,d4.w),d4

	cmp.w	d3,d4
	beq.s	green
	bgt.s	.inc
	subq.w	#1,d3
	bra.s	green
.inc
	addq.w	#1,d3
green
	move.w	d1,d4
	and.w	#$f0,d4
	lsr.w	#4,d4
	move.b	RGB1(pc,d4.w),d4
	move.w	d2,d5
	and.w	#$f0,d5
	lsr.w	#4,d5
	move.b	RGB1(pc,d5.w),d5

	cmp.w	d4,d5
	beq.s	blue
	bgt.s	.inc
	subq.w	#1,d4
	bra.s	blue
.inc
	addq.w	#1,d4
blue
	and.w	#$f,d1
	move.b	RGB1(pc,d1.w),d1
	and.w	#$f,d2
	move.b	RGB1(pc,d2.w),d2

	cmp.w	d1,d2
	beq.s	.skip
	bgt.s	.inc
	subq.w	#1,d1
	bra.s	.skip
.inc
	addq.w	#1,d1
.skip
	move.b	RGB2(pc,d1.w),d1
	move.b	RGB2(pc,d3.w),d3
	move.b	RGB2(pc,d4.w),d4
	lsl.w	#8,d3
	add.w	d3,d1
	lsl.w	#4,d4
	add.w	d4,d1
	move.w	d1,(a0)+
	dbra	d0,floop
	
	move.w	(sp)+,d1
	moveq	#0,d0
.test
	move.w	-(a0),d2
	cmp.w	-(a1),d2
	beq.s	.skip2
	sne	d0
.skip2	dbra	d1,.test
	rts


RGB2	dc.b	0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15





;-------------- VBL rout ----------------------


vbl:		movem.l	d0-a6,-(sp)				;save regs

 		movem.l	logo+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		addq.w	#1,vblwait				;add vbl counter

		clr.b	(mfp+tbcr).w
		move.b	#Lg_depart-2,(mfp+tbdr).w
		move.l	#Init_timerb,$120.w
		move.b	#8,$fffffa1b.w
;		lea	COLORZ-32*4,A6
		move.l	pt_fade,a6
		move.l	a6,pt_color
		bsr	Sctexte
		bsr 	MUSIC+$8		; call music
		movem.l	(sp)+,d0-a6				;restore regs
		rte

;-------------- Init Timer B ----------------------

Init_timerb:
	movem.l	a0/a1/d0,-(sp)
	lea	(mfp+tbdr).w,a0
	move.w	#$2700,sr
	move.b	(a0),d0
Pas_ligne:
	cmp.b	(a0),d0
	beq.s	Pas_ligne
	rept	6
	nop
	endr
	move.w	#$125,$ffff8240.w
	move.l	pt_color,a1
offset	set	2
	rept	7
	;move.l	#$7770666,($FFFFF8240+offset).W
	MOVE.L	(a1)+,($FFFFF8240+offset).W
offset	set	offset+4
	endr
	MOVE.W	(a1)+,($FFFFF8240+offset).W
	;MOVE.W	#$444,($FFFFF8240+offset).W
	move.l	a1,pt_color
	clr.b	(mfp+tbcr).w
	move.b	#2,(mfp+tbdr).w
	move.l	#Timerb,$120.w
	move.b	#8,$fffffa1b.w
	move.b	(a0),d0
Pas_ligne2:
	cmp.b	(a0),d0
	beq.s	Pas_ligne2
	rept	6
	nop
	endr
	move.w	#$13,$ffff8240.w
	move.w	#$2300,sr
	movem.l	(sp)+,a0/a1/d0
	rte

;-------------- Timer B ----------------------

Timerb:
	move.l	a6,-(sp)
	move.l	pt_color,a6
offset	set	2
	rept	7
	MOVE.L	(a6)+,($FFFFF8240+offset).W
offset	set	offset+4
	endr
	MOVE.W	(a6)+,($FFFFF8240+offset).W
	move.l	a6,pt_color
	move.l	(sp)+,a6
	subq	#1,cmpt_timer
	bmi.s	Fin_timerb
	RTE
Fin_timerb:
	move.w	#(nbrl/2)-1,cmpt_timer
	move.w	#$2700,sr
	movem.l	a0/d0,-(sp)
	lea	(mfp+tbdr).w,a0
	move.b	(a0),d0
Pas_ligne_2:
	cmp.b	(a0),d0
	beq.s	Pas_ligne_2
	rept	6
	nop
	endr
	move.w	#$125,$ffff8240.w
	clr.b	(mfp+tbcr).w
	move.b	#30,(mfp+tbdr).w
	move.l	#Fake,$120.w
	move.b	#8,$fffffa1b.w
	move.b	(a0),d0
Pas_ligne2_2:
	cmp.b	(a0),d0
	beq.s	Pas_ligne2_2
	clr.b	(mfp+tbcr).w
	move.l	fontes,$ffff8240.w
	move.l	fontes+4,($ffff8240+4).w
	move.l	fontes+8,($ffff8240+8).w
	move.l	fontes+12,($ffff8240+12).w
	move.l	fontes+16,($ffff8240+16).w
	move.l	fontes+20,($ffff8240+20).w
	move.l	fontes+24,($ffff8240+24).w
	move.l	fontes+28,($ffff8240+28).w
	move.w	#$2300,sr
	movem.l	(sp)+,a0/d0
Fake	rte


;-------------- Plasma rout ----------------------
;it is just a four scroll of a pic with color cycling each 2 lines
;very simple...

Routine_plasma
	MOVE.L	PT_PLASMA,A5
	MOVE.L	screen_adr,a1
	add.l	#160*Lg_depart,a1
	lea	160*((nbrl/2)-1)(a1),a2
	lea	160*(nbrl/2)(a1),a3
	lea	160*(nbrl-1)(a1),a4

;using move because of interrupt lagging....

loopi
	MOVE.L	(A5)+,A0
	add.l	Buffer_plasma,a0
	MOVEM.L	(A0)+,D0-D7
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	d0,(a3)+
	move.l	d1,(a3)+
	move.l	d2,(a3)+
	move.l	d3,(a3)+
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	move.l	d2,(a4)+
	move.l	d3,(a4)+
	move.l	d4,(a4)+
	move.l	d5,(a4)+
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	MOVEM.L	(A0)+,D0-D7
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	d0,(a3)+
	move.l	d1,(a3)+
	move.l	d2,(a3)+
	move.l	d3,(a3)+
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	move.l	d2,(a4)+
	move.l	d3,(a4)+
	move.l	d4,(a4)+
	move.l	d5,(a4)+
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	MOVEM.L	(A0)+,D0-D7
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	d0,(a3)+
	move.l	d1,(a3)+
	move.l	d2,(a3)+
	move.l	d3,(a3)+
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	move.l	d2,(a4)+
	move.l	d3,(a4)+
	move.l	d4,(a4)+
	move.l	d5,(a4)+
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	MOVEM.L	(A0)+,D0-D7
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	d0,(a3)+
	move.l	d1,(a3)+
	move.l	d2,(a3)+
	move.l	d3,(a3)+
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	move.l	d2,(a4)+
	move.l	d3,(a4)+
	move.l	d4,(a4)+
	move.l	d5,(a4)+
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	MOVEM.L	(A0)+,D0-D7
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	d0,(a3)+
	move.l	d1,(a3)+
	move.l	d2,(a3)+
	move.l	d3,(a3)+
	move.l	d4,(a3)+
	move.l	d5,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	move.l	d2,(a4)+
	move.l	d3,(a4)+
	move.l	d4,(a4)+
	move.l	d5,(a4)+
	move.l	d6,(a4)+
	move.l	d7,(a4)+
	lea	-160*2(a2),a2
	lea	-160*2(a4),a4
	subq	#1,nbrb
	bne	loopi
	move.w	#nbrl/4,nbrb

	ADD.L	#4,PT_PLASMA
	CMP.L	#FIN_ANIM,PT_PLASMA
	BMI.S	OK_PLAS
	MOVE.L	#ANIM_P,PT_PLASMA
OK_PLAS
	RTS

nbrb	dc.w	nbrl/4

;-------------- color stuff ----------------------

Prepare_couleurs
	lea	COULEUR,a2
	Lea	COLORZ-15*2,A1
	MOVE.W	#(nbrl/2+1)*2,D0
LINES	MOVE.L	A2,A0
	REPT	15
	MOVE.W	(A0)+,(A1)+
	ENDR
	ADD.W	#2,A2
	CMP.L	#FIN_COULEUR,A2
	BNE.S	OK_B
	LEA	COULEUR,A2
OK_B	DBRA	D0,LINES

	lea	colorz-(nbrl*30),a3
	lea	colorz-15*2,a2
_fade1
	moveq	#14,d0
	move.l	a2,a0
	move.l	a3,a1
	bsr	Fading
	sub.l	#15*2,a2

	movem.l	(a0),d1-d7
	movem.l	d1-d7,(a2)
	move.w	7*4(a0),7*4(a2)
	tst.w	d0
	bne.s	_fade1

	rts

;-------------- scrolltext rout ----------------------

SCTEXTE
	SUBQ.W	#1,decompt
	BNE	SCROL
	MOVE.W	#5,decompt
	MOVEA.L	PTEXTE,A0
LOOPI2	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	BPL.S	SCTEXT
	LEA	TEXTE,A0
	BRA.S	LOOPI2
SCTEXT
	MOVE.L	A0,ptexte
	LEA	FONTES+32,A0
	MULU	#20*20,D1
	ADD.L	D1,A0
	LEA	PTFONTES,A1
	MOVE.L	A0,(A1)
SCROL	MOVE.L	SCROLLING2,A4
	MOVE.L	SCROLLING1,A3
	MOVE.L	A4,SCROLLING1
	MOVE.L	A3,SCROLLING2
	MOVE.L	A3,PT_LIGNE
	REPT	20
	MOVEM.L	8(A4),D0-D5/A0-A3
	MOVEM.L	D0-D5/A0-A3,(A4)
	MOVEM.L	48(A4),D0-D5/A0-A3
	MOVEM.L	D0-D5/A0-A3,40(A4)
	MOVEM.L	88(A4),D0-D5/A0-A2
	MOVEM.L	D0-D5/A0-A2,80(A4)
	MOVEM.L	124(A4),D0-D5/A0-A2
	MOVEM.L	D0-D5/A0-A2,116(A4)
	MOVE.L	PT_LIGNE,A3
	MOVEP.L	$99(A3),D0
	MOVEP.L	D0,$98(A4)
	MOVE.L	PTFONTES,A2
	MOVE.L	(A2)+,D0
	MOVEP.L	D0,$99(A4)
	MOVE.L	A2,PTFONTES
	ADD.L	#160,PT_LIGNE
	LEA	160(A4),A4
	ENDR
	RTS
CODAGE	LEA	TEXTE,A0
	LEA	TABLECODES,A1
CODE	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	SUBI.B	#$20,D0
	MOVE.B	(A1,D0.W),(A0)+
	TST.B	(A0)
	BNE.S	CODE
	MOVE.B	#$FF,(A0)+
	RTS




		section	data
;Music	incbin	"maxy\outrun_b.snd"
Music	incbin	"broken2.snd"
	even
pt_fade	dc.l	Colorz
fade_plasma	dc.l	-30
pt_color	dc.l	COLORZ
cmpt_timer	dc.w	(nbrl/2)-1
POINTEUR	DC.L	COULEUR
COULEUR	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$761,$752,$743,$734,$725,$716,$707
	dc.w	$617,$527,$437,$347,$257,$167,$077
	dc.w	$176,$275,$374,$473,$572,$671,$770
	dc.w	$771,$772,$773,$774,$775,$776,$777
	dc.w	$766,$755,$744,$733,$722,$711,$700
	dc.w	$701,$702,$703,$704,$705,$706,$707
	dc.w	$716,$725,$734,$743,$752,$761,$770
	dc.w	$670,$570,$470,$370,$270,$170,$070
	dc.w	$160,$250,$340,$430,$520,$610
FIN_COULEUR
	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$761,$752,$743,$734,$725,$716,$707
	dc.w	$617,$527,$437,$347,$257,$167,$077
	dc.w	$176,$275,$374,$473,$572,$671,$770
	dc.w	$771,$772,$773,$774,$775,$776,$777
	dc.w	$766,$755,$744,$733,$722,$711,$700
	dc.w	$701,$702,$703,$704,$705,$706,$707
	dc.w	$716,$725,$734,$743,$752,$761,$770
	dc.w	$670,$570,$470,$370,$270,$170,$070
	dc.w	$160,$250,$340,$430,$520,$610

	dcb.w	15*(nbrl+1),$13
COLORZ	DS.B	32*(nbrl+1)

PT_PLASMA	DC.L	ANIM_P
ANIM_P
LINE_IMG	SET	160
	REPT	nbrl-4
	DC.L	0+LINE_IMG
LINE_IMG	SET	LINE_IMG+160
	ENDR
	REPT	nbrl-4
	DC.L	0+LINE_IMG
LINE_IMG	SET	LINE_IMG-160
	ENDR
FIN_ANIM
	REPT	nbrl/4
	DC.L	0+LINE_IMG
LINE_IMG	SET	LINE_IMG+160
	ENDR
	dcb.l	100,0
;player:	incbin	'gigatex.snd'
		even
nbrp		dc.w	0
decompt_effet	dc.w	50*Secondes
Buffer_plasma	dc.l	buffer
table_plasma	dc.l	buffer
		dc.l	buffer+32066*1
		dc.l	buffer+32066*2
		dc.l	buffer+32066*3
		dc.l	buffer+32066*4
		dc.l	buffer+32066*5
		dc.l	buffer+32066*6
		dc.l	buffer+32066*7
		dc.l	buffer+32066*8
pic_plasma	incbin	tampon68.pi1	;74,70,68,66,64,62,61,55,50,53,33,14
buffer	EQU	pic_plasma+34
		incbin	tampon64.pi1
		incbin	tampon61.pi1
		incbin	tampon50.pi1
		incbin	tampon62.pi1
		incbin	tampon33.pi1
		incbin	tampon14.pi1
		incbin	tampon74.pi1
		even
PT_LIGNE	DC.L	0
PTEXTE	DC.L	TEXTE
Scrolling1	dc.l	160*180
Scrolling2	dc.l	160*180

	EVEN
DECOMPT	DC.W	1
PTFONTES	DC.L	FONTES+35*4*16
FONTES
	INCBIN	REMIXUP.BIT
;	INCBIN	PIG_MIX.BIT
	ds.b	16*20
TABLECODES
	DC.B	26       espace
	DC.B	28       !
	DC.B	26       "
	DC.B	26       # non
	DC.B	26       $ non
	DC.B	26       % non
	DC.B	26       & non
	DC.B	26	 '
	DC.B	26       (
	DC.B	26       )
	DC.B	26       * non
	DC.B	26       + non
	DC.B	26       ,
	DC.B	26       -
	DC.B	30       .
	DC.B	26       / non
	DC.B	31,32,33,34,35,36,37,38,39,40
	DC.B	29       :
	DC.B	26       ;
	DC.B	26       < non
	DC.B	26       = non
	DC.B	26       > non
	DC.B	27       ?
	DC.B	26       @ non
	DC.B	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25	A-Z
	DC.B	26
	EVEN
TEXTE
;here are the fonts available...

	;dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ ?!:.0123456789 ",0
	dc.b	"                  HI AND WELCOME TO THIS FILLING INTRO BY ATARI FREAKS! THIS INTRO WAS AT FIRST AN ELITE INTRO. MARCER DECIDED TO SEND IT FOR THE COMPO. "
	DC.B	"I .JACE. THOUGHT IT WAS NOT ENOUGHT GOOD TO BE INCLUDED SO I DECIDED TO JOIN MORE PLASMA EFFECTS. "
	DC.B	"FOR INFORMATION THESE ARE THE UNUSED PLASMAS FROM THE COLORZ DEMO IN 1993... "
	DC.B	"SOME CREDITS NOW : SUPER COOL MUSIC BY MARCER AND BRILL "
	DC.B	"LOGO BY CREM THE CREMEUX. THIS OLD FONT BY DIEU... MEGA HI TO ALL ATARIS FANS ARROUND AND ESPECIALLY TO EVL FOR THIS COMPO!  STAY ATARI!  LET'S WRAAAAAAAAAP!      "
	DC.B	0
	EVEN
l	set	0	;pour debug...
	rept	48
	dc.b	l
l	set	l+1
	endr
	EVEN
Logo	incbin	logoht.bit
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
Sauve_all	ds.l	16
		even
	end


