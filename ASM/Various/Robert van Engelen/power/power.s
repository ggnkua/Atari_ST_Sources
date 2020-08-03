;	High power calculator in MC68000 code
;	Written by Robert van Engelen, 20-08-1989
;
;	This might not be the healthiest (nor fastest) piece of code
;	you've ever seen, but the author does not have an ST. And the
;	program WORKS.

	opt d+

numsiz: equ             80000           The buffer size
power2: equ             256000		The power

	lea		numend-1,a0	Load end address of buffer
        move.b          #1,(a0)		Start at 1

        move.l          #power2,d0	Put power counter in D0
        move.l          #0,d2		

double: move.l          d2,d1		
        lea             numend,a0
	movea.l		a0,a1
        andi.b          #0,ccr
digloop:abcd		-(a1),-(a0)	Add binary decimal
        dbra            d1,digloop
        bcc.s           noofl		Overflow?
        move.b          #1,-(a0)
        addq.l          #1,d2
noofl:	bsr.s		wrtast		Write counter
        subq.l          #1,d0		Decrease counter
        bne             double

putloop:move.b          (a0)+,d0	Write number on printer
        move.b          d0,d1
        lsr.b           #4,d0
        addi.b          #48,d0
	bsr.s           prtchr		Output D0
	beq.s		quit		Error? Then quit
        andi.b          #$F,d1
        move.b          d1,d0
        addi.b          #48,d0
        bsr.s           prtchr
	beq.s		quit
        dbra            d2,putloop
	move.b		#13,d0		End reached...cr+lf
	bsr.s		prtchr
	move.b		#10,d0
	bsr.s		prtchr
quit:	bsr		wrtfil		Write file of buffer
   	move.w          #1,-(sp)	Wait for key
	trap 		#1
	addq.l		#2,sp
	rts

prtchr: movem.l         d0-d7/a0-a6,-(sp)
        move.w          d0,-(sp)
        move.w          #5,-(sp)	Character to printer
        trap            #1
        addq.l          #4,sp
        tst.w           d0
        movem.l         (sp)+,d0-d7/a0-a6
        rts

wrtast: movem.l         a0-a6/d0-d7,-(sp)
        lea		buffur,a0	Cursor home buffer
	move.l		a0,-(sp)
	move.w		#9,-(sp)
	trap 		#1
	addq.l 		#6,sp
	movem.l		(sp)+,d0-d7/a0-a6
	movem.l		d0-d7/a0-a6,-(sp)
	divu		#10000,d0	Hex->decimal conversion
	swap		d0
	move.l		d0,d1
	clr.w		d0
	swap		d0
	bsr.s		outint		Output four figures
	move.w		d1,d0
	bsr.s		outint		Output other four figures
	movem.l         (sp)+,a0-a6/d0-d7
	rts

outint:	movem.l		d0-d7/a0-a6,-(sp)
	bsr.s		repl
	lea		buffer,a0
	move.l		a0,-(sp)
	move.w		#9,-(sp)
	trap		#1
	addq.l		#6,sp
	movem.l		(sp)+,d0-d7/a0-a6
	rts

repl:	lea		buffer,a0
	move.l		#'0000',(a0)+
reploop:divu		#10,d0
	swap		d0
	addi.b		#48,d0
	move.b		d0,-(a0)
	clr.w		d0
	swap		d0
	tst.w		d0
	bne		reploop
	rts

wrtfil  movem.l		d0-d7/a0-a6,-(sp)
	move.w		#0,-(sp)
	move.l		#filenam,-(sp)
	move.w		#$3c,-(sp	Create
	trap		#1
	addq.l		#8,sp

	move.w		d0,handle

	move.l		#number,-(sp)
	move.l		#numsiz,-(sp)
	move.w		handle,-(sp)
	move.w		#$40,-(sp)	Write whole buffer
	trap		#1
	add.l		#12,sp

	move.w		handle,-(sp)
	move.w		#$3e,-(sp)	Close
	trap 		#1
	addq.l		#4,sp

	movem.l		(sp)+,d0-d7/a0-a6
	rts

	even

buffur: dc.b            27,'H',0,0

	even

buffer:	ds.b		4

	even

bufend:	dc.b		0

	even

number: ds.b            numsiz

	even

numend: ds.b            0

	even

filenam:dc.b		'power.img',0

	even

handle  dc.w		0

        end
