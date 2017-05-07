
; screen # by The Fate of ULM (c) 1989 and for all eternity...

demo:	equ 10			;demo =  0 => assemble for demo
				;demo <> 0 => assemble for devpack
test:	equ 10

	ifne demo

;please leave all section indications unchanged...
;simple loader to get into supervisor-mode
;this part can be removed when started from bootsector
x:
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

	move.b	#18,$fffffc02.w
	bsr	waitvbl
	move.b	#26,$fffffc02.w

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

	lea	graphic,a6
	movem.l (a6),d1-d2
	movem.l (a6),d3-d4
	movem.l (a6),d5-d6
	movem.l (a6),d7-a0
	movem.l (a6),a1-a2
	movea.l screenad1,a6
	lea	160(a6),a6
	move.w	#299,d0
graphiccop:
	movem.l d1-a2,(a6)
	movem.l d1-a2,40(a6)
	movem.l d1-a2,80(a6)
	movem.l d1-a2,120(a6)
	movem.l d1-a2,160(a6)
	movem.l d1-a2,200(a6)
	lea	230(a6),a6
	dbra	d0,graphiccop

	movem.l pal,d0-d3
	movem.l d0-d3,$ffff8240+4*4.w

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

	dcb	$4e71,196

loop:
	move.b  #0,$ffff820a.w
	dcb	$4e71,8
	move.b  #2,$ffff820a.w

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

	dcb	$4e71,79
	move.w	#210,d0
lo0001:
	dcb	$4e71,6
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,87
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dbf	d0,lo0001

	dcb	$4e71,5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,87
	move.b	#0,$ffff820a.w
	dcb	$4e71,12
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	dcb	$4e71,83
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	$4e71,2
	moveq	#13,d0
lo0002:
	dcb	$4e71,6
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,87
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dbf	d0,lo0002

	dcb	$4e71,5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,87
	move.b	#0,$ffff820a.w
	dcb	$4e71,12
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	dcb	$4e71,83
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	$4e71,2
	moveq	#43,d0
lo0003:
	dcb	$4e71,6
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	$4e71,87
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dbf	d0,lo0003

	bsr	waitvbl
	move.w	#1488,d0
wait_border2:
	dbf	d0,wait_border2

	dcb	$4e71,194
	move.w	#1911,$ffff8240.w
	move.w	#$00,$ffff8240.w
	dcb	$4e71,23

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

;please leave all section indications unchanged...
;here starts the data section

black:
		dc.l	0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0
graphic:
		dc.l	%01010101010101010011001100110011
		dc.l	%00001111000011111111111111111111
pal:
		dc.w	$000,$0221,$0332,$0443,$0554,$0665,$0110,$20

;end of data section

		section	bss
;please leave all section indications unchanged...
bss_start:			;here starts the bss

stack:		ds.l	1
screenad1:	ds.l	1


screenmem:	ds.l	14300
bss_end:			;here ends the bss
	end

