;
;	VBL replayer for unpacked SNDH files
;       Special example for Tobe and Gloky/MJJ
;
;	Depending on your tune - all timers now free ;)
;
;	gwEm 2005, 2006
;

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

	move.l	$70.w,oldvbl		; store old VBL
	move.l	#vbl,$70.w		; steal VBL

	bsr	MUSIC+0			; init music

	move.w	#7,-(sp)		; wait for a key
	trap	#1			;
	addq.l	#2,sp			;

	bsr	MUSIC+4			; de-init music

	move.l	oldvbl,$70.w		; restore VBL

	move.l	oldusp(pc),-(sp)	; user mode
	move.w	#$20,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;

	clr.w   -(sp)                   ; pterm()
	move.w	#$4c,-(sp)		;
	trap    #1      		;

;................................................................
vbl:	bsr 	MUSIC+8			; call music
        move.l  oldvbl(pc),-(sp)	; go to old vector (system friendly ;) )
        rts

oldvbl:	ds.l	1
oldusp:	ds.l	1

;................................................................
MUSIC:	incbin	test_ste.snd		; SNDH file to include (this one needs 50Hz replay)
