;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ BLITTER ROUTINES                             ~
;~ START: 28.01.96      LAST UPDATE: 12.02.96   ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~ BLITTER REGISTERS ~~~~~~~~~~~~~~~~~~~~~~~~~~
BLITTER	equ $ffff8a00
Halftone 	equ $0
Srcincx	equ $20
Srcincy	equ $22
Srcaddr	equ $24
Endmask1	equ $28
Endmask2	equ $2a
Endmask3	equ $2c
Destincx	equ $2e
Destincy	equ $30
Destaddr	equ $32
Countx	equ $36
County	equ $38
Hop	equ $3a
Op	equ $3b
Linenum	equ $3c
Smudge	equ $5
Hog	equ $6
Busy	equ $7
Skew	equ $3d
nfsr	equ $6
fxsr	equ $7


BLITTER_CLR_32KB:
	;bra BB
ClearScreen:
					lea.l $FFFF8A28.w,A1
					move.l #$FFFFFFFF,(A1)+
					move.l #$FFFF0002,(A1)+
					addq.w #2,A1
					move.l a0,(A1)+
					move.l #$3E800001,(A1)+
					move.l #$0000C000,(A1)
					rts


BB:	lea BLITTER.w,a1

.WAIT_BLITTER
	btst #Busy,Linenum(a1)
	nop
	bne.s .WAIT_BLITTER
	move.w #80,Countx(a1)
	move.w #$C8,County(a1)
	move.w #0,Srcincx(a1)
	move.w #0,Srcincy(a1)
	move.l #CLR_WORD,Srcaddr(a1)
	move.w #$ffff,Endmask1(a1)
	move.w #$ffff,Endmask2(a1)
	move.w #$ffff,Endmask3(a1)
	move.w #2,Destincx(a1)
	move.w #0,Destincy(a1)
	move.l a0,Destaddr(a1)
	move.b #0,Skew(a1)
	move.b #0,Hop(a1)
	move.b #0,Op(a1)
	move.b #192,Linenum(a1)
	;bset #Hog,Linenum(a1)
	;bset #Busy,Linenum(a1) ;trigger chip
	rts
	
INIT_FILL_LINE:
	lea BLITTER.w,a6
.WAIT_BLITTER:
	btst #Busy,Linenum(a6)
	nop
	bne.s .WAIT_BLITTER
	move.w #80,Countx(a6)
	move.w #1,County(a6)
	move.w #8,Destincx(a6)
	move.w #$ffff,Endmask2(a6)
	move.b #0,Skew(a6)
	move.b #0,Hop(a6)
	bset #Hog,Linenum(a6)
	rts
		

CLR_WORD:	dc.w 0	
