start:	jsr 	relocate
	
	lea 	module,a0
	lea 	noise+$c398,a1
	
	move.l 	endmodule,d7
	lsr.l 	#2,d7		; /4
move_modul:
	move.l 	(a0)+,(a1)+
	dbf 	d7,move_modul
	 
	bra 	i_init
	
	
oldvbl:	dc.l 0
savessp:dc.l 0


relocate:	lea	noise+$1c,a0		; start address
		move.l	a0,d1			; to d1
		lea	noiserel,a1		; reloc table
		move.l	(a1)+,d0		; 2.l
		add.l	d0,a0			; add 2.l to a0
		add.l	d1,(a0)			; add 2.l -> (a0)

relmain:	move.b	(a1)+,d0
		and.l	#$ff,d0
		cmp.w	#$1,d0
		blt.s	endrel			; less than?
		beq.s	rel1			; equal ?
		add.l	d0,a0
		add.l	d1,(a0)
		bra.s	relmain

rel1:		lea	$fe(a0),a0
		bra.s	relmain

endrel:		;lea	noise+$1c,a0
		rts


i_init:
		move.w 	#$2700,sr
		move.l 	$70,oldvbl
		move.l 	#vbl,$70
		bsr.s 	initmusic
		move.w 	#$2300,sr
		rts

back:
	move.w 	#$2700,sr
	move.l 	oldvbl,$70
	move.b 	#$0,$ff8901	;stoppa dma.
	move.w 	#$444,$ffff8240.w
	move.w 	#$2300,sr
	rts
vbl:
	movem.l d0/d1/a3,-(sp)
	move.w 	#$070,$ffff8240.w
	move.l 	frames,a3
	jsr 	noise+$5124
	bsr 	setframe
	move.b 	#0,$ff8901
	move.b 	#1,$ff8901
	bsr 	bytframe
	move.w 	#$2400,sr
	move.w 	#$200,$ff8240
	movem.l (sp)+,d0/d1/a3
	rte


initmusic:
	jsr 	noise+$bc1a
	jsr 	noise+$26e
	jsr 	noise+$4390
	bsr.s 	initdma
	move.w 	#$4e75,noise+$b5d4
	move.l 	#$4e714e71,noise+$513c
	rts
initdma:
	move.l 	frames+4,d0	;startframe
	bsr 	setframe2
	
	move.w 	#$7ff,$ff8924
	move.w 	#$480,$ff8922
wait:
	cmp.w 	#$7ff,$ffff8924.w
	bne.s 	wait
	move.w 	#$440,$ffff8922.w
	move.b 	#$01,$ffff8921.w	;25kHz stereo.
	rts

setframe:
		move.l 	frames,d0		;startframe
setframe2:
		move.l 	d0,d1
		add.l 	#500,d1

		move.b 	d0,$ffff8907.w
		lsr.l 	#8,d0
		move.b 	d0,$ffff8905.w
		lsr.l 	#8,d0
		move.b 	d0,$ffff8903.w

		move.b 	d1,$ffff8913.w
		lsr.l 	#8,d1
		move.b 	d1,$ffff8911.w
		lsr.l 	#8,d1
		move.b 	d1,$ffff890f.w
		rts
bytframe:
		move.l 	frames,d0
		move.l 	frames+4,d1
		exg 	d0,d1
		move.l 	d0,frames
		move.l 	d1,frames+4
		rts
frames:	dc.l 	noise,noise+$b61a


noiserel:	equ 	$30000
noise:		equ	$40000
module:		equ	$80000
endmodule: 	dc.l	128078
