*-------------------------------------------------------------------------*
* Routine to unpack a degas elite screen - ( *.PC? )      Copyright 1991
*							    The Highlander.
*-------------------------------------------------------------------------*
* Call with	a0 :- Pointing to picture file data to be uncompressed
* 		a1 :- Palette data output. 32 bytes.
*		a2 :- 32000 byte Screen data dump.
*-------------------------------------------------------------------------*


UNPACK_DEGAS:
		addq.l	#2,a0		; skip resolution flag.
		move.l	(a0)+,(a1)+	; copy over palette.
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

; now the picture area to be uncompressed.

; 0 <= n <= 127		;	n>=0 and n<=127 then no rept for n+1
; -127 <= n <= -1	;	n>=-127 and n<=-1 then rept for -n+1
; n = -128 		;	no operation.

		move.w	#199,d7	; scan lines
.UNCOMP0:	moveq.w	#3,d6
.UNCOMP1:	lea	_DEGASBUFF(PC),a3
.UNCOMP2:	move.b	(a0)+,d0
		ext.w	d0
		cmp.b	#-128,d0		; ignore.
		beq.s	.UNCOMP2
		cmp.b	#-1,d0
		ble.s	.REPT
.LOOP1:		move.b	(a0)+,(a3)+		; no repeat.
		dbra	d0,.LOOP1
		cmp.l	#_DEGASBUFF+40,a3
		blt.s	.UNCOMP2
		bra.s	.DUMP_SCANLINE
.REPT:		neg.w	d0
		move.b	(a0)+,d1
.LOOP2:		move.b	d1,(a3)+		; repeat.
		dbra	d0,.LOOP2
		cmp.l	#_DEGASBUFF+40,a3
		blt.s	.UNCOMP2

.DUMP_SCANLINE:	lea	_DEGASBUFF(PC),a3	; dump completed 
		move.l	a2,a6			; uncompressed scan line
		REPT	20			; plane too screen.
		move.w	(a3)+,(a2)+
		addq.l	#6,a2
		ENDR
		lea.l	2(a6),a2
		dbra	d6,.UNCOMP1
		lea.l	152(a2),a2
		dbra	d7,.UNCOMP0
		rts

_DEGASBUFF:	ds.b	40		