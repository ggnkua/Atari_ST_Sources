;Guardians of logik sourcecode,Documented for Steve by Matt
;Coded by Armani but there's no need to credit him!
;To start with just assemble this program straght away to 
;see what it looks like when assembled do not change anything i don't say to	
	move.l	a7,a5
	move.l	#ustk,a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#$c,sp

	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	
	clr.w	-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#$c,sp
	
	lea	music1,a0
	move.w	#$e76,d0
	bsr	movmus
			
; save current palette
	lea	savpal,a1
	lea	$ff8240,a0
	move.w	#$f,d0
getcols	move.w	(a0)+,(a1)+
	dbra	d0,getcols
	
	lea	screen,a1
	add.l	#2,a1
	lea	$ff8240,a0
	move.w	#$f,d0
setpal	move.w	(a1)+,(a0)+
	dbra	d0,setpal
	
	lea	screen,a0
	add.l	#34,a0
	lea	$78000,a1
	move.w	#$7d00,d0
putpic	move.b	(a0)+,(a1)+
	dbra	d0,putpic

	lea	$7f580,a0
	lea	$7fd02,a1
clear	clr.w	(a0)+
	cmpm.l	(a0)+,(a1)+
	bne	clear	
	
	jsr	$3c838
	
	clr.w	$ff8240
	move.b	#2,count
repeat	lea	text,a6
next	move.b	(a6)+,d0
	cmp.b	#$ff,d0
	bne	start
	bra	repeat
start	cmp.b	#"@",d0
	beq	pause
	clr.w	d5
	and.l	#$ff,d0
	lea	font,a1
	add.l	d0,a1
	lea	fbuff,a2
	moveq	#7,d7
loop1	move.b	(a1),(a2)+
	add.l	#$100,a1
	dbra	d7,loop1
test	cmp.b	#0,count
	bne	sub
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#4,count
sub	subq.b	#1,count
	move.w	#$ff,-(sp)
	move.w 	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	skip
	bsr	keyp
skip	moveq	#0,d0
wow	lea	fbuff,a5
	lea	$7f2ce,a0
	moveq	#7,d7
scroll	move.l	a0,-(sp)
	add.l	#$16a,a0
	move.b	(a5),d1
	lsl.b	#1,d1
	move.b	d1,(a5)+
	moveq	#$13,d6    !correct 
loop2	move.w	(a0),d1
	roxl.w	#1,d1
	move.w	d1,(a0)
	move.w	d1,6(a0)
	move.w	d1,6(a0)
	move.w	d1,6(a0)
	move.w	d1,$a0(a0)
	move.w	d1,$a6(a0)
	move.w	d1,$a6(a0)
	move.w	d1,$a6(a0)
	subq.l	#8,a0
	dbra	d6,loop2
	move.l	(a7)+,a0
	add.l	#$140,a0
	dbra	d7,scroll
	addq.w	#1,d5
	and.w	#7,d5
	bne	test
	bra	next

keyp	move.b	d0,key
		
	cmp.b	#49,key
	bne	check2
	jsr	clrsnd
	pea	one
	jmp	loadit
	
check2	cmp.b	#50,key
	bne	check3
	jsr	clrsnd
	pea	two
	jmp	loadit

check3	cmp.b	#51,key
	bne	check4
	jsr	clrsnd
	pea	three
	jmp	loadit

check4	cmp.b	#52,key
	bne	check0
	jsr	clrsnd
	pea	four
	jmp	loadit

check0	cmp.b	#48,key
	beq	hertz
	rts

hertz	eori.b	#2,$ff820a
	rts
	

loadit	lea	savpal,a0
	lea	$ff8240,a1
	move.w	#$f,d0
restp	move.w	(a0)+,(a1)+
	dbra	d0,restp
	move.w	#$0,-(sp)
	move.w	#$4b,-(sp)
	trap	#$1
	add.l	#$10,sp

	move.w	#2,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	d0,a6
			
open	move.w	#2,-(sp)

	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle
	rts
	
close	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
	
handle	dc.w	0
	
one	dc.b	"mickey.tbe",0       ;Insert the filenames of your games

two	dc.b	"m_mice.tbe",0	      ; Change these to what you want    	 
	
three	dc.b	"game.dat",0

four	dc.b	"game.dat",0

key	dc.l	0


error	rts
	lea	savpal,a0
	lea	$ff8240,a1
	move.w	#$f,d0
default	move.w	(a0)+,(a1)+
	dbra	d0,default
	
	clr.w	-(sp)
	trap	#1
		
pause	move.w	#$c,d3
wait	move.w	#$d000,d4
wait2	nop
	dbra	d4,wait2
	dbra	d3,wait
	bra	wow

movmus	lea	$3c838,a1
mov	move.b	(a0)+,(a1)+
	dbra	d0,mov
	rts
	

clrsnd	move.l	#$0000000,$4da
	move.l 	#$8080000,$ff8800
	move.l	#$9090000,$ff8800
	move.l 	#$a0a0000,$ff8800
	rts

		
screen	incbin	"a:\picture.pi1"			;name of degas screen
font	incbin	"a:\font"				;there is another font called font2 that you can insert if you want
music1	incbin	"a:\music"				;don't try to change the tune			
savpal	ds.w	16
fbuff	ds.b	16
count	ds.b	1
text	DC.B	"                 matt                  @"	;The @ pauses the scroll
	DC.B	" brings you a guardians of logik source code"                                       "
	DC.B	"     Well you can type as much as you want"
	DC.B	" here Steve     AND YOU DON'T HAVE TO TYPE"
	DC.B	" IN lower CASE EITHER.... WELL ALL THE CHARACTERS"
	DC.B	"  are here  _.!œ%*-+()/+=    "
	DC.B	"WELL I HOPE YOU FIND SOME USE FOR THIS CODE"
	DC.B	"      YOU CAN JUST  INSERT YOUR OWN TEXT UPTO ANY LENGTH "
	DC.B	"JUST INSERT YOUR OWN GRAPHIX ABOVE........YOU CAN'T YET CHANGE THE MUSIC BUT I'LL WORK ON THAT FOR YOU "
	DC.B	"     WELL I'LL SIGN OFF HERE I JUST WROTE THIS TO SHOW YOU WHAT THIS SOURCE DOES"
	DC.B	"    DON'T CHANGE ANYTHING I DON'T SAY TO OR OTHERWISE YOU MAY HAVE PROBLEMS                 ALTERNATE AND HELP CHANGE THE MUSIC        "
	DC.B	".....................BYE..................      "
	
	DC.B	$FF	; This must be at the end of the scrolltext!
	ds.l        	64
ustk	ds.l	1	
