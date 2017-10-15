xxxxxx
	lea	hst,a0
	lea	mince,a1
.2	move.b	(a0),d0
	bmi.s	.1
	cmp.b	#$a,d0
	blt.s	.1
	sub.b	#' ',d0
.1	move.b	d0,(a0)+
	cmp.l	a0,a1
	bne.s	.2
	
	lea	hst(pc),a0
	lea	mince(pc),a1
	moveq	#0,d0
	moveq	#0,d1
loop	move.b	(a0),d1
	eor.b	d0,d1
	move.b	d1,(a0)+
	addq	#1,d0
	cmp.l	a0,a1
	bne.s	loop
	nop
hst	dc.b	'00150000  ----------- MIKE.W ---------  '
	dc.b	'00140000  DAVE.C - NOT UGLY             '
	dc.b	'00130000  GORDON - 2cv HERE WE COME!!!  '
	dc.b	'00120000  ------------ oOo -----------  '
	dc.b	'00110000              Hi to             '
	dc.b	'00100000              =====             '
	dc.b	'00090000  Atari, Andy*3, Doug, ST News  '
	dc.b	'00080000  Keith, Dannie, Neil, Phil     '
	dc.b	'00070000  Lawrence, Alan, ST Format     '
	dc.b	'00060000  Floppyshop(Hi Steve), Alan    '
	dc.b	'00050000  Graham, Stewart, Stick&Bilbo  '
	dc.b	'00040000  Inner Circle, T.L.B, T.P.T    '
	dc.b	'00030000  Microprose s/w, Sensible s/w  '
	dc.b	'00010000  Hi Soft, Thalion s/w,         '
here	equ	*-1
	dc.b	'00005000  Eclipse . . . . . . . . . .   '
	dc.b	'00002000  See you all on the FALCON!!!  '
blah	dc.b	'                                        ',-1
mince	equ	*-1
	dc.b	'LAMER ALERT, NO HI SCORES HERE TO CHANGE.'
	dc.b	'PUT YOUR EDITOR AWAY AND PLAY THE GAME'
end