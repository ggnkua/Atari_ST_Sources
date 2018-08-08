export _interupt
export linkin
export Sclock
export gdrout
export dummyfn
export inint

import stik
import engine
import vbl_hook
super

data

text

stksve:	ds.l		1		; stack save
savesuper:	ds.l	1

			ds.l	1024	;huge stack
mmstack:	ds.l	1
insurance:	ds.l 40
gdrout:	ds.w	1
oldgvec:	ds.l	1
inint:	ds.w	1
clkval:	ds.l	1
saveregs: ds.l	16

; I'm probably setting these up wrong for the Pure C assembler, :)

vblsem		equ	$452
nvbls		equ	$454
vblqueue	equ	$456
hz200		equ	$4BA

	dc.l	'XBRA'
	dc.l	'STIK'	;change your id as you want for xbra protocol
oldvec:	dc.l		0					; Place for old vector
gdcount:
	move.l	usp,a0
	btst	#5,(sp)
	beq.s	.usermode
	move.l	sp,a0	;supervisor
	addq.l	#6,sp	;6 for 68000 & 68010
	tst.w	$59e.w	;long stack frames ?
	beq.s	.usermode
	addq.l	#2,sp	;8 for 68020+
.usermode:
	move.w	(a0),gdrout	;save gemdos function number called

;insert what you want to do else here...
;don't forget to save used register if they are in these
;ranges: d2-d6 & a2-a6 (d2 & a2 not needed normally, just a security :)
;use an illegal to make the debugger stop there

	movea.l	oldgvec(pc),a0
	jmp	(a0)	;go back to normal gemdos processing


;You could get away with just putting address of stik() into the 
;vbl list however this way you can see if the routine is working.
_interupt:
		tas			inint
		beq			cont
		move.w		#$ABAC,gdrout
		bra			xit
cont:	movem.l		d0-d7/a0-a7,saveregs

;changing stack is not recommended inside an interrupt
;it can be dangerous if that interrupt happened during
;another one... unless it's the main one for the whole
;program. 
		move.l		#mmstack,sp

;uncomment the following 2 lines to enable gemdos catching
		move.l		$84.w,oldgvec
		move.l		#gdcount,$84.w

		move.l		hz200.w,clkval
		jsr			stik


;uncomment that line if you have enabled gemdos catching
		move.l		oldgvec,$84.w

		movem.l		saveregs,d0-d7/a0-a7
		clr.w		inint
xit:	rts								;and exit...

linkin:
		movem.l		d2-d7/a2-a6,-(sp)	;Stack everything
		clr.w		gdrout		
		clr.l		-(sp)				;Go Super()
		move.w		#$20,-(sp)
		trap		#1
		addq.l		#6,sp
		move.l		d0,savesuper		;save stack

		move.w		#0,vblsem.w			;Stop the deferred VBL list from being called.
		move.w		nvbls.w,d1			;Get number of slots
		subq.w		#2,d1				;GEM uses slot 1 so we forget it, -1 for a dbra loop		
		move.l		vblqueue.w,a0		;get address of queue in a0
		lea			4(a0),a0			;Skip the GEM slot
lop:	tst.l		(a0)+
		beq.s		femp				;found a null slot jump to fill it
		dbra		d1,lop
		moveq		#1,d0				;Can't install interupt exit.
		move.w		#1,vblsem.w

		move.l		savesuper,-(sp)
		move.w		#$20,-(sp)
		trap		#1
		addq.l		#6,sp
		movem.l		(sp)+,d2-d7/a2-a6			;replace regies.		
		rts
		
femp:	lea			-4(a0),a0			;Get address of free slot
		move.l		a0,vbl_hook			; Save address of space
		move.l		#_interupt,(a0)		;Plonk our routine in.
		move.w		#1,vblsem.w
		moveq		#0,d0
		
		move.l		savesuper,-(sp)
		move.w		#$20,-(sp)
		trap		#1
		addq.l		#6,sp
		movem.l		(sp)+,d2-d7/a2-a6			;replace regies.		
		rts

;Sclock - same as clock() except designed to be called from interrupt
Sclock:	move.l		clkval,d0
		rts

dummyfn: rts
