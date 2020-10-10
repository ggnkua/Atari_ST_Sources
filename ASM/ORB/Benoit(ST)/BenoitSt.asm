*****************************************************************************
* Benoît
*
* a small 252 mandelbrot (including file header)
* for amiga ocs...
*
* ultra^orb 20150409
*
*****************************************************************************
release         equ     1
plane           equ     $1f00
planelen	equ	40*170
minIm           equ     -1
maxIm           equ     1
minRe           equ     -2
maxRe           equ     1
xSize           equ    	320
ySize           equ    	160

fixedmul	equ	$100
fixedshift	equ	8
screen		equ	end+1024
use4p		equ	0

;        section shortig, code_c
*****************************************************************************
; a0 = x
; a1 = y
; d1 = im
; d2 = re
; d3 = zi
; a6 = zr
; d5 = a
; d6 = b
; d7 = bits
start
	pea	prg(pc)
	move.w	#$26,-(a7)
	trap	#$e
prg:
	move	#$2700,sr
	
	clr	-(sp)
	lea	screen(pc),a5
	move.l  a5,-(sp)
	move.l  a5,-(sp)
	move.w  #5,-(sp)
	trap    #14
	

	move	#$8240,a6
        moveq	#$000,d0
setcol:
	if	use4p
	move	d0,d1
	move	d0,d2
	and	#$111,d1
	lsl	#3,d1	
	lsr	#1,d2
	and	#$777,d2
	or	d2,d1
        move	d1,(a6)+
	else
        move	d0,(a6)+
	endc
        add	#$110,d0
        cmp	#$1100,d0
        bne.s	setcol

        move	#minIm*fixedmul+$10,d1
        ;for y
	sub.l	a1,a1
	moveq	#$10,d7
yloop:

	move	#minRe*fixedmul+$60,d2
	;for x
	sub.l	a0,a0
xloop:

        ;zr = re
        move	d2,a6
        ;zi = im
        move	d1,d3

        ; for n
        moveq	#0,d4
nloop
        ; a=zr*zr;

        move	a6,d5
        muls	d5,d5
        asr.l	#fixedshift,d5

        ; b=zi*zi;
        move	d3,d0
        muls	d0,d0
        asr.l	#fixedshift,d0
        move	d0,d6
	add	d5,d0
	cmp	#$280,d0
	bgt.s	stop

	;Zi=2*Zr*Zi+Im;
	move	a6,d0
	add	d0,d0
	muls	d0,d3
        asr.l	#fixedshift,d3
	add	d1,d3

	;Zr=a-b+Re;
	sub	d6,d5
	add	d2,d5
	move	d5,a6
	addq	#1,d4
	cmp	#14,d4
	bne.s	nloop

stop:
	if	use4p
	lsr	#1,d4
	else
	lsr	#2,d4
	endc

	roxl	(a5)
	roxr	d4
	roxl	2(a5)
	roxr	d4
	roxl	4(a5)
	
	if	use4p
	roxr	d4
	roxl	6(a5)
	endc
	
	subq	#1,d7
	bne.s	nores
	moveq	#$10,d7
	addq.l	#8,a5
nores
        addq    #((maxRe-minRe)*fixedmul)/xSize,d2
	addq.w	#1,a0
	cmp	#xSize,a0
	bne.s	xloop
        addq    #((maxIm-minIm)*fixedmul)/ySize,d1

	addq	#1,a1
	cmp	#ySize,a1
	bne.s	yloop
mainloop:

;        if      release
        bra.s   mainloop
;        else
;	cmpi.b  #$39,$fc02.w
;	bne.s   mainloop
;        illegal
;        endc
end:

*****************************************************************************
        printt  "size:"
        if      release=1
        printv  *-start
        printv  *-start+26
        else
        printv  *-start-20
        printv  *-start-26
        endc
*****************************************************************************

        end