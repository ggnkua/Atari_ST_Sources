*mega text converter
*by christophe of
*the incredible
* W A T C H M E N

* fuck it, let's go!

init
	move.l	#start,-(sp)
	move	#38,-(sp)	Bass, Retro,
	trap	#14		Go!
	addq.l	#6,sp

start
	lea	text,a0
	lea	workspace,a1
loop
	move.b	(a0)+,d0
	cmpi.b	#"0",d0
	bne	loop0
	move.b	#"[",d0
	bra	loopl
loop0
	cmpi.b	#"1",d0
	bne	loop1
	move.b	#"\",d0
	bra	loopl
loop1
	cmpi.b	#"2",d0
	bne	loop2
	move.b	#"]",d0
	bra	loopl
loop2
	cmpi.b	#"3",d0
	bne	loop3
	move.b	#"^",d0
	bra	loopl
loop3
	cmpi.b	#"4",d0
	bne	loop4
	move.b	#"_",d0
	bra	loopl
loop4
	cmpi.b	#"5",d0
	bne	loop5
	move.b	#"`",d0
	bra	loopl
loop5
	cmpi.b	#"6",d0
	bne	loop6
	move.b	#"a",d0
	bra	loopl
loop6
	cmpi.b	#"7",d0
	bne	loop7
	move.b	#"b",d0
	bra	loopl
loop7
	cmpi.b	#"8",d0
	bne	loop8
	move.b	#"c",d0
	bra	loopl
loop8
	cmpi.b	#"9",d0
	bne	loop9
	move.b	#"d",d0
	bra	loopl
loop9
	cmpi.b	#"(",d0
	bne	loopa
	move.b	#"e",d0
	bra	loopl
loopa
	cmpi.b	#"!",d0
	bne	loopb
	move.b	#"f",d0
	bra	loopl
loopb
	cmpi.b	#")",d0
	bne	loopc
	move.b	#"g",d0
	bra	loopl
loopc
	cmpi.b	#":",d0
	bne	loopd
	move.b	#"h",d0
	bra	loopl
loopd
	cmpi.b	#"-",d0
	bne	loope
	move.b	#"i",d0
	bra	loopl
loope
	cmpi.b	#".",d0
	bne	loopf
	move.b	#"j",d0
	bra	loopl
loopf
	cmpi.b	#",",d0
	bne	loopg
	move.b	#"k",d0
	bra	loopl
loopg
	cmpi.b	#"'",d0
	bne	looph
	move.b	#"l",d0
	bra	loopl
looph
	cmpi.b	#'"',d0
	bne	loopi
	move.b	#"m",d0
	bra	loopl
loopi
	cmpi.b	#"?",d0
	bne	loopj
	move.b	#"n",d0
	bra	loopl
loopj
	cmpi.b	#" ",d0
	bne	loopk
	move.b	#"o",d0
	bra	loopl
loopk
	cmpi.b	#$ff,d0
	beq	loopend	
loopl
	subi.b	#$41,d0
	move.b	d0,(a1)+
	bra	loop	

loopend
	move.b	d0,(a1)+
	suba.l	#workspace,a1
	move.l	a1,a2
	move.l	#workspace,a1
	move.l	#filename,a0
	bsr	save

	clr.l	-(sp)
	trap	#1

save

	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp

	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	d0,-(sp)
 	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts


*****************************
filename	dc.b	"a:\bytebend\bendtext.dat",0	*output filename
	even
text		include	"a:\bytebend\bendtext.s"	*text for conversion
	even
workspace	equ	*