
; Small example to remove 16 pixels of left border on STe Lowres.
; Giving 336*200 16 colour resolution. Untested in medres.
;
; Untested with Mega STe and TT. Probably doesn't work with Falcon.
;
; Anders Eriksson
; ae@dhs.nu
;
; May 26, 2002
;
; Note: This prg doesn't alter resolution, run it from lowres.

		section	text
begin:

; --------------------------------------------------------------
;		reserve stackspace and leave back memory
; --------------------------------------------------------------

		move.l	4(sp),a5				;address to basepage
		move.l	$0c(a5),d0				;length of text segment
		add.l	$14(a5),d0				;length of data segment
		add.l	$1c(a5),d0				;length of bss segment
		add.l	#$1000+100,d0				;length of stackpointer+basepage
		move.l	a5,d1					;address to basepage
		add.l	d0,d1					;end of program
		and.l	#-2,d1					;make address even
		move.l	d1,sp					;new stackspace

		move.l	d0,-(sp)				;mshrink()
		move.l	a5,-(sp)				;
		clr.w	-(sp)					;
		move.w	#$4a,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;


; --------------------------------------------------------------
;		Save & remove, waitkey, restore
; --------------------------------------------------------------

		move.l	#save_and_install,d0			;save reg and open border
		bsr.w	supexec					;

		move.w	#7,-(sp)				;crawkin()
		trap	#1					;
		addq.l	#2,sp					;

		move.l	#restore,d0				;restore reg (close border)
		bsr.w	supexec

		clr.w	-(sp)					;pterm()
		trap	#1					;

; --------------------------------------------------------------
;		subroutines
; --------------------------------------------------------------

save_and_install:	
		move.w	$ffff8264.w,save_hscroll		;save reg
		move.w	#1,$ffff8264.w				;fix the overscan
		clr.b	$ffff8264.w				;
		rts

restore:	move.w	save_hscroll,$ffff8264.w		;restore reg
		rts

supexec:	move.l	d0,-(sp)				;supexec()
		move.w	#$26,-(sp)				;run subrout in supervisor
		trap	#14					;
		addq.l	#6,sp					;
		rts						;

		section	bss

save_hscroll:	ds.w	1		

		end
