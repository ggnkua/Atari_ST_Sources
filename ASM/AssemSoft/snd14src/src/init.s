;
; SNDH testprogram
; 
; January 4, 2000
; Anders Eriksson / Odd Skancke
; ae@dhs.nu         ozk@atari.org
; 
; init.s

		section	text

		move.l	4(sp),a5				;address to basepage

		move.l	a5,d0					;basepage address
		add.l	#129,d0					;offset to commandline
		move.l	d0,filename			

		move.l	$0c(a5),d0				;length of text segment
		add.l	$14(a5),d0				;length of data segment
		add.l	$1c(a5),d0				;length of bss segment
		add.l	#$1000,d0				;length of stackpointer
		add.l	#$100,d0				;length of basepage
		move.l	a5,d1					;address to basepage
		add.l	d0,d1					;end of program
		and.l	#-2,d1					;make address even
		move.l	d1,sp					;new stackspace

		move.l	d0,-(sp)				;mshrink()
		move.l	a5,-(sp)				;
		move.w	d0,-(sp)				;
		move.w	#$4a,-(sp)				;
		trap	#1					;
		lea	12(sp),sp				;

		move.w	#$2f,-(sp)				;fgetdta() save old dta address
		trap	#1					;
		addq.l	#2,-(sp)				;
		move.l	d0,save_dta				;

		move.l	#dta,-(sp)				;fsetdta() set new dta buffer
		move.w	#$1a,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;

		move.w	#1,-(sp)				;Pdomain()
		move.w	#$119,-(sp)				;enter mint domain
		trap	#1					;
		addq.l	#4,sp					;
		clr.b	MiNT_domain
		tst.l	d0
		bmi.s	no_mntd
		st.b	MiNT_domain
no_mntd:
		move.l	#title_text,-(sp)			;cconw()
		move.w	#9,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;

