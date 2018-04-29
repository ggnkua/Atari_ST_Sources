;
;	Timer C replayer for unpacked SNDH files
;       Special example for Frequent and Nerve/Ephidrena
;
;	gwEm 2005, 2006
;

R_FREQ	equ	200			; SNDH replay frequency here (200Hz in this example)
S_TUNE	equ	2			; SNDH sub-tune number

	section	text
;................................................................
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
	move.l  a5,-(sp)                ;
	move.w  d0,-(sp)                ;
	move.w  #$4a,-(sp)              ;
	trap    #1                  	;
	lea 	12(sp),sp               ;  

	clr.l	-(sp)			; supervisor mode
	move.w	#$20,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;
	move.l	d0,oldusp		; store old user stack pointer

	move.l	$114.w,oldtc		; store old timer C vector
	move.l	#timer_c,$114.w		; steal timer C

	moveq	#S_TUNE,d0		; select sub-tune 2
	bsr	MUSIC+0			; init music

	move.w	#7,-(sp)		; wait for a key
	trap	#1			;
	addq.l	#2,sp			;

	bsr	MUSIC+4			; de-init music

	move.l	oldtc,$114.w		; restore timer C

	move.l	oldusp(pc),-(sp)	; user mode
	move.w	#$20,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;

	clr.w   -(sp)                   ; pterm()
	move.w	#$4c,-(sp)		;
	trap    #1      		;

oldtc:	ds.l	1
oldusp:	ds.l	1


;................................................................
timer_c:sub.w	#R_FREQ,tccount		; you can use any replay rate here less than or equal to 200Hz
	bgt.s	.nocall			; dont call zak this time
	add.w	#200,tccount		; syntheses any freq from 200hz system tick

	move.w	sr,-(sp)		; store status word - system friendly, but not needed in a demo i guess
	move.w	#$2500,sr		; enable timer interrupts
	bsr 	MUSIC+8			; call music
	move.w	(sp)+,sr		; restore status word

.nocall	move.l  oldtc(pc),-(sp)		; go to old vector (system friendly ;) )
        rts

tccount:ds.w	200


;................................................................
MUSIC:	incbin	multsndh.snd		; SNDH file, non ice packed
