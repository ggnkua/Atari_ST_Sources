		section	text
		
base_setup:

;-------------- Reserve stackspace and leave back unused memory

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


;-------------- Reserve ST-RAM for video buffers and clear screens

		move.l	#32000*2+256,-(sp)		;malloc()
		move.w	#72,-(sp)			;screen memory
		trap	#1				;
		addq.l	#6,sp				;
		tst.l	d0				;
		beq.w	exit_nostram			;
		
		add.l	#256,d0				;make screens
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

		move.w	#2,-(sp)			;save phys
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_phys			;

		move.w	#3,-(sp)			;save log
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_log			;


;-------------- Enter supervisor mode
		clr.l	-(sp)				;supervisor mode
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;


;-------------- Check machinetype via Cookiejar

		move.l	#"_VDO",d1			;cookie we want	
		move.l	$5a0.w,d0			;get address of cookie jar in d0
		beq.s	.nojar				;If zero, there's no jar.
		move.l	d0,a0				;move the address of the jar to a0
.search:	tst.l	(a0)				;is this jar entry the last one ?
		beq.s	.nofind				;yes, the cookie was not found
		cmp.l	(a0),d1				;does this cookie match what we're looking for?
		beq.s	.foundit			;yes, it does.
		addq.l	#8,a0				;advance to the next jar entry
		bra.s	.search				;and start over
.nofind:	moveq	#-1,d0				;a negative (-1) means cookie not found
		bra.s	.cookieexit
.nojar:		moveq	#-2,d0				;a negative (-2) means there's no jar
		bra.s	.cookieexit
.foundit:	moveq	#0,d0				;a null in d0 means the cookie was found.
.cookieexit:

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
		bra.w	.video_done
.falc:		move.w	#3,computer
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
		beq.w	.rgb				;
		cmp.w	#3,d0				;if 3 = tv
		beq.w	.rgb				;otherwise assume vga (ignore mono..)
.vga60:		move.l	#$170011,$ffff8282.w		;falcon 50Hz vga
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

		move.b	$484.w,save_keymode		;save keyclick
		bclr	#0,$484				;keyclick off

		bsr.w	inits				;run user inits before demo kicks off

		move.w	sr,d0				;store sr
		move.w	#$2700,sr			;stop all ints
		move.l	$070.w,save_vbl			;save old vbl
		move.l	#base_vbl,$70.w			;install new vbl
		move.w	d0,sr				;restore sr


;-------------- Setup done


base_mainloop:
		jsr	mainloop			;run user mainloop


		cmp.w	#3,computer			;if falcon
		beq.s	.falcon				;don't set screen here
		
		move.l	screen_adr,d0			;set screen
		move.b	d0,d1				;
		lsr.w   #8,d0				;
		move.b  d0,$ffff8203.w			;
		swap    d0				;
		move.b  d0,$ffff8201.w			;

.falcon:	move.l	screen_adr,d0			;swap screens
		move.l	screen_adr2,screen_adr		;
		move.l	d0,screen_adr2			;

		cmp.b	#$39,$fffffc02.w		;check for space
		bne.s	base_mainloop


base_exit:	jsr	exits				;run user exits

		move.w	#$2700,sr			;all ints off
		move.l	save_vbl,$70			;restore vbl
		move.w	#$2300,sr			;all ints on

		cmp.w	#3,computer
		beq.s	.falc
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

		movem.l	save_pal,d0-d7			;restore st palette
		movem.l	d0-d7,$ffff8240.w		;

		move.b	save_keymode,$484.w		;restore keyclick


		move.l	save_stack,-(sp)		;exit supervisor
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

		clr.w	-(sp)				;pterm()
		trap	#1				;


exit_nostram:
		move.l	#nostram_text,-(sp)		;cconws()
		move.w	#9,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

		move.w	#7,-(sp)			;crawcin()
		trap	#1				;
		addq.l	#2,sp				;
	
		clr.w	-(sp)				;pterm()
		trap	#1				;




base_vbl:	movem.l	d0-a6,-(sp)

		cmp.w	#3,computer			;if falcon
		bne.s	.st				;set screen 
		move.l	screen_adr2,d0			;
		move.b	d0,d1				;
		lsr.w   #8,d0				;
		move.b  d0,$ffff8203.w			;
		swap    d0				;
		move.b  d0,$ffff8201.w			;

.st:		jsr	vbl				;run user vbl

		move.l	sndh_vbl,a0			;run sndh vbl
		jsr	(a0)				;

		movem.l	(sp)+,d0-a6
		rte



; VBL SNDH-player

init_sndh:	move.l	sndh_adr,a0			;init sndhfile
		jsr	(a0)				;
		rts
		

play_sndh:	movem.l	d0-a6,-(sp)			
		move.l	sndh_adr,a0			;sndhfile
		jsr	8(a0)				;play
		movem.l	(sp)+,d0-a6
		rts


exit_sndh:	move.l	sndh_adr,a0			;deinit sndh
		jsr	4(a0)				;
		rts


dummy:		rts



		section	data

		even

nostram_text:	dc.b	"Sorry, you do not have enough",13,10
		dc.b	"free ST-RAM to run this demo.",13,1,0

		even

sndh_vbl:	dc.l	dummy

		section	bss
		
screen_adr:	ds.l	1				;screen address 1
screen_adr2:	ds.l	1				;screen address 2
sndh_adr:	ds.l	1				;address to SNDH-file
save_stack:	ds.l	1				;old stack
save_vbl:	ds.l	1				;old vbl
save_res:	ds.w	1				;old screen resolution
save_phys:	ds.l	1				;old physbase
save_log:	ds.l	1				;old logbase
save_pal:	ds.l	8				;old colours
save_f030video:	ds.b	32+12+2				;old falcon video
save_keymode:	ds.w	1				;old keyklick
computer:	ds.w	1				;0=st 1=ste 2=tt 3=falc

		even
		
		
		section	text
