
; screen # by The Fate of ULM (c) 1989 and for all eternity...

demo:	equ 10			;demo =  0 => assemble for demo
				;demo <> 0 => assemble for devpack
test:	equ 10

	ifne demo

;please leave all section indications unchanged...
;simple loader to get into supervisor-mode
;this part can be removed when started from bootsector
go:
	move.l	y-x+$10000,d0		;length
	move.l	$80000-(y-x+$10000),d0	;memory left on ST with half-a-meg

	pea	start
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

start:
	move	sr,in_oldsr
	move	#$2700,sr

	move.b	$ffff8260.w,in_oldres
	bsr	waitvbl
	move.b	#0,$ffff8260.w

	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,in_oldpal
	movem.l black,d0-d7
	movem.l d0-d7,$ffff8240.w

	lea	$ffff8201.w,a0
	movep.w 0(a0),d0
	move.w	d0,in_screenad

	move.b	#26,$fffffc02.w
	bsr	waitvbl
	move.b	#18,$fffffc02.w

	bsr	in_psginit

	move.l	$0604.w,in_old604
	move.l	sp,$0604.w
	move	usp,a0
	move.l	a0,in_oldusp
	move.l	sp,in_oldsp
	move.l	$0600.w,in_old600
	move.l	#back,$0600.w
;here we go... to the real screen...
	jmp	screen
back:
	move.l	in_old600,$0600.w
	move.l	in_old604,$0604.w
	movea.l in_oldusp,a0
	move	a0,usp
	movea.l in_oldsp,sp

	movem.l black,d0-d7
	movem.l d0-d7,$ffff8240.w

	move.b	#2,$ffff820a.w
	bsr	waitvbl
	move.b	#0,$ffff820a.w
	bsr	waitvbl
	move.b	#2,$ffff820a.w

	movem.l in_oldpal,d0-d7
	movem.l d0-d7,$ffff8240.w

	move.b	in_oldres,$ffff8260.w
	lea	$ffff8201.w,a0
	move.w	in_screenad,d0
	movep.w d0,0(a0)

	bsr.s	in_psginit

	bsr	waitvbl
	move.b	#20,$fffffc02.w
	bsr	waitvbl
	move.b	#8,$fffffc02.w

	move	in_oldsr,sr

	rts

in_psginit:
	lea	in_psginittab,a0
in_nextinit:
	move.b	(a0)+,d0
	cmp.b	#$ff,d0
	beq.s	in_initend
	move.b	(a0)+,d1
	move.b	d0,$ffff8800.w
	move.b	d1,$ffff8802.w
	bra.s	in_nextinit
in_initend:
	rts

in_psginittab:
	dc.b	0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0
	dc.b	7,$7f,8,7,9,7,10,7,$ff,0
	even

in_screenad:	ds.w	1
in_oldpal:	ds.l	16
in_oldres:	ds.w	1
in_old600:	ds.l	1
in_old604:	ds.l	1
in_oldsr:	ds.w	1
in_oldsp:	ds.l	1
in_oldusp:	ds.l	1
	endc

;
; systemadresses: $600.w = return address (see exit)
;		  $604.w = stackpointer (copy to sp if needed
;					  ex. move.l $604.w,sp)
;
; from here on, no stackpointer is present, if you need one, just
; get the address of space for stack in $604.w (see also sys. $604.w)
;
; you can use all registers, even usp (move an,usp or move usp,an)
;
; sr is set to $2700 and must (!!!!) be $2700 when returning to main menu
;
; waitvbl can be used to wait for the end of the displayed(!!!!) screen
;	normal mode and overscan (with opened lowr border...)
; waitvbl uses d0-d1/a0
;

;this part is the real screen...

	ifeq demo
	org $010000
	endc

x:
screen:
	lea	bss_start,a0
	lea	bss_end,a1
	movem.l black,d1-d7/a2-a6
clear_loop:
	movem.l d1-d7/a2-a6,(a0)
	movem.l d1-d7/a2-a6,12*4(a0)
	movem.l d1-d7/a2-a6,24*4(a0)
	lea	36*4(a0),a0
	cmpa.l	a0,a1
	bpl.s	clear_loop

	move.l	#screenmem,d0
	add.l	#255,d0
	and.l	#$ffff00,d0
	move.l	d0,screenad1
	ror.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w d0,0(a0)

	move.l	screenad1,a6
	movem.l	black,d1-a2
	movem.l	d1-a2,(a6)
	movem.l	d1-a2,40(a6)
	movem.l	d1-a2,80(a6)
	movem.l	d1-a2,120(a6)
	lea	160(a6),a6
	lea	graphic,a5
	movem.l	(a5),d1-d2
	movem.l	(a5),d3-d4
	movem.l	(a5),d5-d6
	movem.l	(a5),d7-a0
	movem.l	(a5),a1-a2
	move.w	#290,d0
graphiccop:
	movem.l	d1-a2,(a6)
	movem.l	d1-a2,40(a6)
	movem.l	d1-a2,80(a6)
	movem.l	d1-a2,120(a6)
	movem.l	d1-a2,160(a6)
	movem.l	d1-a2,200(a6)
	lea	230(a6),a6
	dbra	d0,graphiccop

	lea	farbtab,a0
	lea	hsin,a1
	moveq	#0,d1
	move.w	#599,d0
fill_loop:
	move.b	(a1)+,d1
	move.w	d1,(a0)+
	cmp.l	#hsinend,a1
	bne.s	fill_ok
	lea	hsin,a1
fill_ok:
	dbf	d0,fill_loop
	move.l	a1,aktinhsin

	movea.l $0604.w,sp

testl:
	bsr	waitvbl

	lea	$ffff8209.w,a0
	moveq	#0,d0
	moveq	#20,d2
sync2:
	move.b	(a0),d0
	beq.s	sync2
	sub.w	d0,d2
	lsl.l	d2,d2

	bsr	waitvbl

	move.w	#1500,d0
wait_border:
	dbf	d0,wait_border

	dcb	$4e71,188+6

loop:
	lea	$ffff8260.w,sp
	move.b  #0,$ffff820a.w
	lea	coltab,a2
codmodvsin equ *+2
	add.w	#0,a2
	lea	farbtab,a1
	move.b  #2,$ffff820a.w

codmodhsin equ *+2
	add.w	#0,a1
	btst	#6,$fffffa0d.w
	bne	exit

	lea	$ffff8209.w,a0
	moveq	#0,d0
	moveq	#30,d2
sync:
	move.b	(a0),d0
	beq.s	sync
	sub.w	d0,d2
	lsl.l	d2,d2

	dcb	$4e71,24+24+1
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5

	moveq	#48,d0
lo0001:
	dcb	$4e71,5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,46+24
	lea	32(a2),a2
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo0001

	dcb	$4e71,4

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,46+24
	lea	32(a2),a2
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,1

	move.w	#110+50,d0
lo0004:
	dcb	$4e71,5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,46+24
	lea	32(a2),a2
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo0004

	dcb	$4e71,4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,59-11+24
	move.w	(a1)+,d2
	movem.l	32(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	lea	64(a2),a2
	dcb	$4e71,10
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	move.b	#2,$ffff820a.w

	dcb	$4e71,44+24
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	$4e71,2
	moveq	#13,d0
lo0002:
	dcb	$4e71,5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,46+24
	lea	32(a2),a2
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo0002

	dcb	$4e71,4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,48+24
	move.w	(a1)+,d2
	movem.l	32(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	lea	64(a2),a2
	dcb	$4e71,10
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	move.b	#2,$ffff820a.w

	dcb	$4e71,44+24
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	$4e71,2
	moveq	#43,d0
lo0003:
	dcb	$4e71,5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l d2-d5,$ffff8250.w
	move.b	#2,(sp)
	move.b	#0,(sp)
	dcb	$4e71,46+24
	lea	32(a2),a2
	move.w	(a1)+,d2
	movem.l	0(a2,d2.w),d2-d5
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo0003

	dcb	$4e71,4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.w	#137,d0
wait_border3:
	dcb	$4e71,32
	dbf	d0,wait_border3

	dcb	$4e71,25

	move.w	pointdist,d0
	move.w	d0,d1
	addq.w	#4,d0
	cmp.w	#300*4,d0
	bne.s	pointdis_ok
	moveq	#0,d0
pointdis_ok:
	move.w	d0,pointdist
	move.w	d0,codmodhsin

	moveq	#0,d0
	move.l	aktinhsin,a0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	cmp.l	#hsinend+2,a0
	bne.s	hsin_ok
	lea	hsin,a0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	bra.s	hsin_nok
hsin_ok:
	dcb	$4e71,11
hsin_nok:
	move.l	a0,aktinhsin
	lea	farbtab,a0
	add.w	d1,a0
	move.l	d0,(a0)
	move.l	d0,1200(a0)

	move.l	aktinvsin,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmp.l	#vsinend+4,a0
	bne.s	vsin_ok
	lea	vsin,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	bra.s	vsin_nok
vsin_ok:
	dcb	$4e71,10
vsin_nok:
	move.w	d0,codmodvsin
	move.l	a0,aktinvsin
	add.w	d1,codmodhsin

	move.l	$604.w,sp

	move.w	#1911,$ffff8240.w
	move.w	#$00,$ffff8240.w

	dcb	$4e71,16

	bra	loop

exit:
	movea.l $0600.w,a0
	jmp	(a0)

waitvbl:
	move.b	$ffff8203.w,d0
	lsl.w	#8,d0
	lea	$ffff8207.w,a0
no_vbl:
	movep.w 0(a0),d1
	cmp.w	d0,d1
	bne.s	no_vbl
	rts

;here starts the data section

black:
		dc.l	0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0
graphic:
		dc.l	%01010101010101010011001100110011
		dc.l	%00001111000011111111111111111111
pal:
		dc.w	$000,$221,$332,$443,$554,$665,$110,$020
hsin:
	incbin	'c:\includes\hsin.bin'
hsinend:
aktinvsin:
		dc.l	vsin
vsin:
	incbin	'c:\includes\vsin.bin'
vsinend:

coltab:
	incbin	'c:\includes\coltab.bin'
	incbin	'c:\includes\coltab.bin'
	incbin	'c:\includes\coltab.bin'
	incbin	'c:\includes\coltab.bin'
	incbin	'c:\includes\coltab.bin'
	incbin	'c:\includes\coltab.bin'

;end of data section

		section	bss
;please leave all section indications unchanged...
bss_start:			;here starts the bss

stack:		ds.l	1
screenad1:	ds.l	1
pointdist:	ds.w	1
aktinhsin:	ds.l	1
farbtab:	ds.l	600

screenmem:
		ds.l	$2000
		ds.l	$2000
		ds.l	$500
bss_end:			;here ends the bss
y:
	end

