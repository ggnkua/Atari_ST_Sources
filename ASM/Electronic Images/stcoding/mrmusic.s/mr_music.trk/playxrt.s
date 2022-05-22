;
; Example player for version 2 of Mr Music (40% at 11Khz).
;
; Programmed by The Phantom of Electronic Images.
;
; Mr Music is programmed by The Phantom and Griff of Electronic Images.
;
; Please note that Mr Music uses register D7 and USP so therefore you must
; be in supervisor mode when playing the music.
;
;

	clr.l	-(sp)			; Set supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,oldsp		; Store old stack pointer.

	move.w	#$2700,sr		; No interrupts.
	lea	oldmfp(pc),a0		; Start storing MFP variables.
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.l	$70.w,(a0)+	
	move.b  #0,$fffffa07.w		; Stop all interrupts.
	move.b	#0,$fffffa09.w	
	move.b  #0,$fffffa13.w
	move.b	#0,$fffffa15.w
	move.l	#vbl,$70.w		; Install our VBL.

	move.l	#tune,rotfile+24	; Give Mr music the tune address.
	move.l	#vceset,rotfile+28 	; Give it voice set address.
	move.l	#notetab,rotfile+32	; And spare 32768 bytes for tables.
	bsr	rotfile			; Now initialise & start music.

	move.w	#$2300,sr		; Enable interrupts

key:	cmpi.b	#57,$fffffc02.w		; Wait for space bar to be pressed.
	bne.s	key

out:	move.w	#$2700,sr		; Stop interrupts.
	bsr	rotfile+8		; Stop Mr Music & de-initialise.
	lea	oldmfp(pc),a0		; Now start restoring MFP.
	move.b	(a0)+,$fffffa07.w 
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	(a0)+,$70.w

flush:	btst.b	#0,$fffffc00.w		; Flush out keyboard buffer.
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done:

	move.w	#$2300,sr		; Enable interrupts.

	move.l	oldsp(pc),-(sp)		; Restore old stack pointer & mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)			; End program.
	trap	#1


;
; Our VBL.  Please note that the music driver should roughly be called at
; the same point every frame.  It can tolerate differences when it was
; last called to about +-3% or so (to a 50th of a second).  This isn't
; important, but I thought you ought to know just in case!
;
vbl:	eor.w	#$777,$ffff8240.w
	bsr	rotfile+12		; Call Mr Music.
	eor.w	#$777,$ffff8240.w
	rte

oldsp:	ds.l	1
oldmfp:	ds.l	5

rotfile:
	incbin	mr_music.xrt

tune:	incbin	cocktail.sng
vceset:	incbin	cocktail.eit

; 32768 spare bytes for note tables from here.
notetab:
