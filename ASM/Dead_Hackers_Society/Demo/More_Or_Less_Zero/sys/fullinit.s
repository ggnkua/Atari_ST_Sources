; Atari ST/e synclock demosystem
; January 9, 2008
;
; fullinit.s

		section	text
init:

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


		move.l	#256*256*2+256,-(sp)		;malloc() about 284*2 overscan lines dividable by 256
		move.w	#72,-(sp)			;screen memory
		trap	#1				;
		addq.l	#6,sp				;
		tst.l	d0				;
		beq.w	exit_nostram			;
		add.l	#256,d0				;init screen
		clr.b	d0				;even by 256 bytes
		move.l	d0,screen_adr			;screen 1
		move.l	d0,screen_adr_base		;
		add.l	#256*256,d0			;
		move.l	d0,screen_adr2			;screen 2


		move.w	#2,-(sp)			;save phys
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_phys			;

		move.w	#3,-(sp)			;save log
		trap	#14				;
		addq.l	#2,sp				;
		move.l	d0,save_log			;

		move.w	#4,-(sp)			;save resolution
		trap	#14				;
		addq.l	#2,sp				;
		move.w	d0,save_res			;

		move.w	#0,-(sp)			;set stlow
		move.l	#-1,-(sp)			;
		move.l	#-1,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea	12(sp),sp			;

		

		clr.l	-(sp)				;supervisor mode
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;

		jsr	clear_screens		

		movem.l	$ffff8240.w,d0-d7		;save palette
		movem.l	d0-d7,save_pal			;

		jsr	black_pal

		
		move.w	#-1,-(sp)			;set screen
		move.l	screen_adr,-(sp)		;
		move.l	screen_adr,-(sp)		;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea.l	12(sp),sp			;

		move.b	$484.w,save_keymode		;save keyclick
		bclr	#0,$484				;keyclick off


;-------------- User + system inits
		ifne	hatari_speedup
		jsr	hatari_max
		endc

		move.l	#empty+256,d0
		clr.b	d0
		move.l	d0,empty_adr

		ifne	music_sndh
		jsr	music_sndh_init
		endc
		
		ifne	music_ym
		jsr	music_ym_init
		endc
		
		ifne	music_dma
		jsr	music_dma_init
		endc

		ifne	hatari_speedup
		jsr	hatari_min
		endc


		jsr	initlist			;run user inits




;--------------	Start demosystem
		move.w	sr,-(sp)
		move.w	#$2700,sr			;stop interrupts

		lea.l	save_buffer,a0			;save vectors and mfp
		move.l	$68.w,(a0)+			;hbl
		move.l	$70.w,(a0)+			;vbl
		move.l	$120.w,(a0)+			;timer b
		move.l	$134.w,(a0)+			;timer a
		move.b	$fffffa07.w,(a0)+		;mfp
		move.b	$fffffa09.w,(a0)+		;
		move.b	$fffffa13.w,(a0)+		;
		move.b	$fffffa15.w,(a0)+		;
		move.b	$fffffa17.w,(a0)+		;
		move.b	$fffffa19.w,(a0)+		;
		move.b	$fffffa1f.w,(a0)+		;

		move.l	#hbl,$68.w 			;new hbl
		move.l	#vbl,$70.w 			;new vbl
		move.l	#timer_a,$134.w			;new timer a
		move.b	#$20,$fffffa07.w		;enable timer a
		move.b	#$20,$fffffa13.w		;
		clr.b	$fffffa09.w			;stop interrupts
		clr.b	$fffffa15.w			;
		bclr	#3,$fffffa17.w			;automatic end of interrupt
		clr.b	$fffffa19.w			;stop timer a

		move.w	(sp)+,sr
