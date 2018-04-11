
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

	clr.l	-(sp)			; supervisor mode
	move.w	#$20,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;
	move.l	d0,oldusp		; store old user stack pointer

	move.b $ffff8265,old8265
	move.b $ffff820f,old820f

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

	if enablehbl
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
	move.b	$fffffa13,old13
	move.b	$fffffa1b,old1b
	move.b	$fffffa21,old21
	endif

	move.w sr,-(sp)
	or.w #$0700,sr

	move.l	$70,oldvbl		; store old VBL
	move.l	#vbl,$70		; steal VBL

	if enablehbl
		move.b #0,$fffffa1b		; Switch off Timer B
		move.b #0,$fffffa09		; Disable all timers in IERB, including Timer A
		move.l $120,oldhbl		; save old hbl
		move.l	#hbl,$120			; insert own hbl
		bset #0,$fffffa07			; Enable Timer B
		bset #0,$fffffa13			; Mask Timer B to enable it
	;	move.b #50,$fffffa21	; Timer B data
	;	move.b #8,$fffffa1b		; Set Timer B to Event Count Mode

	;	or.b	#1,$fffffa07		; IERA bit 0: Timer B enabled
	;	move.b	#0,$fffffa09	; IERB: all timers disabled
	;	or.b	#1,$fffffa13		; Mask bit 0: timer b enabled
	;	move.b	#0,$fffffa1b	; timer b control empty
	;
	;	move.l $120,oldhbl
	;	move.l	#hbl,$120
	endif

	move.w (sp)+,sr

	move.l sp,startupsp
