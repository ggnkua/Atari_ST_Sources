
	move.l  4(sp),a5                ; address to basepage
	move.l  $0c(a5),d0              ; length of text segment
	add.l   $14(a5),d0              ; length of data segment
	add.l   $1c(a5),d0              ; length of bss segment
	add.l   #$1000,d0               ; length of stackpointer
	add.l   #$100,d0                ; length of basepage
	move.l  a5,d1                   ; address to basepage
	add.l   d0,d1                   ; end of program
	and.l   #-2,d1                  ; make address even
	move.l  d1,sp                   ; new stackspace

	move.l  d0,-(sp)                ; mshrink()
	move.l  a5,-(sp)
	move.w  d0,-(sp)
	move.w  #$4a,-(sp)
	trap    #1
	lea 	12(sp),sp

ignoremshrink:

;	clr.l	-(sp)			; supervisor mode
;	move.w	#$20,-(sp)		;
;	trap	#1			;
;	addq.l	#6,sp			;
;	move.l	d0,oldusp		; store old user stack pointer

	move.b $ffff8265,old8265
	move.b $ffff820f,old820f

this_is_ggntrap::
	move.l $8,-(sp)
	move.l #.ggntrap,$8
	move.b $ffff8e21,old8e21
.ggntrap:
	move.l (sp)+,$8

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez
	
	move #2,-(sp)		; get address of physical screen
	trap #14
	addq #2,sp
	move.l d0,physbase

	rept 0
		move.b $ffff8203,old8203
		move.b $ffff8201,old8201
		move.b $ffff820d,old820d
	endr
	
	movem.l $ffff8240,d0-d7
	movem.l d0-d7,oldpal

	move.b $484,old484 ; save key click
	bclr #0,$484 ; kill key click

	dc.w $a00a	; hide mouse pointer
	move.b #$12,$fffffc02 ; disable mouse reporting

	rept 0
		move.l $ffff8260,old8260		; save old screen rez
		move.l $ffff820a,old820a
	endr

	rept 0
		clr.b $ffff8260.w		; set lowres
		move.b #2,$ffff820a.w
	endr

	move.w #0,-(sp)				; set lowres
	move.l physbase,-(sp)
	move.l physbase,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	
	bset.b #1,$ffff820a

;	ifne HBL_ENABLE
;	move.b	$fffffa07,old07
;	move.b	$fffffa09,old09
;	move.b	$fffffa13,old13
;	move.b	$fffffa1b,old1b
;	move.b	$fffffa21,old21
;	endif
;
;	move.w sr,-(sp)
;	or.w #$0700,sr
;
;	move.l	$70,oldvbl		; store old VBL
;	move.l	#vbl,$70		; steal VBL
;
;	move.l $114,old114    ; Timer C
;  ifne TIMER_C_DISABLE_ON_STARTUP
;	move.l #timer_c_dummy,$114
;	endif
;
;	ifne HBL_ENABLE
;		move.b #0,$fffffa1b		; Switch off Timer B
;		move.b #0,$fffffa09		; Disable all timers in IERB, including Timer A
;		move.l $120,oldhbl		; save old hbl
;		move.l	#hbl,$120			; insert own hbl
;		bset #0,$fffffa07			; Enable Timer B
;		bset #0,$fffffa13			; Mask Timer B to enable it
;	;	move.b #50,$fffffa21	; Timer B data
;	;	move.b #8,$fffffa1b		; Set Timer B to Event Count Mode
;
;	;	or.b	#1,$fffffa07		; IERA bit 0: Timer B enabled
;	;	move.b	#0,$fffffa09	; IERB: all timers disabled
;	;	or.b	#1,$fffffa13		; Mask bit 0: timer b enabled
;	;	move.b	#0,$fffffa1b	; timer b control empty
;	;
;	;	move.l $120,oldhbl
;	;	move.l	#hbl,$120
;	endif
;
;	move.w (sp)+,sr


; From DHS' demosystem
;--------------	Save vectors, MFP and start the demosystem
		move.w	#$2700,sr			;Stop interrupts

		move.l	usp,a0				;USP
		move.l	a0,save_usp			;
		
		move.l	$68.w,save_hbl			;HBL
		move.l	$70.w,save_vbl			;VBL
		move.l	$134.w,save_timer_a		;Timer-A
		move.l	$120.w,save_timer_b		;Timer-B
		move.l	$114.w,save_timer_c		;Timer-C
		move.l	$110.w,save_timer_d		;Timer-D
		move.l	$118.w,save_acia		;ACIA

		lea	save_mfp,a0			;Restore vectors and mfp
		move.b	$fffffa01.w,(a0)+		;// datareg
		move.b	$fffffa03.w,(a0)+		;Active edge
		move.b	$fffffa05.w,(a0)+		;Data direction
		move.b	$fffffa07.w,(a0)+		;Interrupt enable A
		move.b	$fffffa13.w,(a0)+		;Interupt Mask A
		move.b	$fffffa09.w,(a0)+		;Interrupt enable B
		move.b	$fffffa15.w,(a0)+		;Interrupt mask B
		move.b	$fffffa17.w,(a0)+		;Automatic/software end of interupt
		move.b	$fffffa19.w,(a0)+		;Timer A control
		move.b	$fffffa1b.w,(a0)+		;Timer B control
		move.b	$fffffa1d.w,(a0)+		;Timer C & D control
		move.b	$fffffa27.w,(a0)+		;Sync character
		move.b	$fffffa29.w,(a0)+		;USART control
		move.b	$fffffa2b.w,(a0)+		;Receiver status
		move.b	$fffffa2d.w,(a0)+		;Transmitter status
		move.b	$fffffa2f.w,(a0)+		;USART data

		move.l	#hbl,$68.w 			;Set HBL
		move.l	#vbl,$70.w 			;Set VBL
;	ifeq	music_sndh_fx
		move.l	#timer_a,$134.w			;Set Timer-A
;	endif
		move.l	#timer_b,$120.w			;Set Timer-B
  if TIMER_C_DISABLE_ON_STARTUP
		move.l	#timer_c,$114.w			;Set Timer-C
  endif
		move.l	#timer_d,$110.w			;Set Timer-D
		move.l	#acia,$118.w			;Set ACIA

;	ifne	music_ymdigi8
;		move.l	#music_ymdigi8_timer,$68	;Set HBL to YM digi
;	else
;		move.l	#hbl,$68.w 			;Set HBL
;	endif


		clr.b	$fffffa07.w			;Interrupt enable A (Timer-A & B)
		clr.b	$fffffa13.w			;Interrupt mask A (Timer-A & B)
		clr.b	$fffffa09.w			;Interrupt enable B (Timer-C & D)
		clr.b	$fffffa15.w			;Interrupt mask B (Timer-C & D)

		clr.b	$fffffa19.w			;Timer-A control (stop)
		clr.b	$fffffa1b.w			;Timer-B control (stop)
		clr.b	$fffffa1d.w			;Timer-C & D control (stop)

		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		bset	#5,$fffffa07.w			;Interrupt enable A (Timer-A)
		bset	#5,$fffffa13.w			;Interrupt mask A

;	ifne	music_ymdigi8
;		move.w	#$2100,sr			;Enable interrupts with HBL for YM digi
;	else
		move.w	#$2300,sr			;Enable interrupts
;	endif


	move.l sp,startupsp
