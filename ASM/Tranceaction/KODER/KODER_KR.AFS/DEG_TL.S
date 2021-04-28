; *** Ett demo av Martin Kalms alias Jasper of Tranceaction 20/9 -91 ***

	section text
	
; *** lite blandade variabler ***

ggr	equ	6		; f”rdr”jning f”r blocken
xpos	equ	4		; blockets x-pos
ypos	equ	54		; blockets y-pos
spos	equ	192		; scrollerns y-pos
time	equ	5		; f”rdr”jning f”r f„rgerna

; *** l„mna tillbaka minne och ordna lokal stack ***
		
	move.l	4(sp),a0		; adress till BP	
	move.l	$c(a0),d0		; textsektionen
	add.l	$14(a0),d0	; datasektionen	
	add.l	$1c(a0),d0 	; BSS-sektionen
	add.l	#$1000,d0		; utrymme f”r stacken		
	add.l	#$100,d0		; BP
	move.l	a0,d1		; adress till BP
	add.l	d0,d1		; programl„ngd (stacken)
	and.l	#-2,d1		; ge stackpekaren en j„mn adress
	move.l	d1,sp		; lokal stackpekare ordnad
	move.l	d0,-(sp)		; beh†ll d0 bytes
	move.l	a0,-(sp)		; vars startadress finns i a0
	move.w	d0,-(sp)		; dummy
	move.w	#$4a,-(sp)	; krymp reserverat minne	
	trap	#1		; anropa gemdos	
	lea	12(sp),sp		; korrigera stacken	

; *** lite blandade sm†initieringar ***

	clr.l	-(sp)		; supervisor mode
	move.w	#$20,-(sp)	
	trap	#1			
	addq.l	#6,sp			
	move.l	d0,old_usp		

	and.b	#%00100000,$fffffa09.w ; st„ng av timer C

	dc.w	$a00a		; g”m musen

	move.w	#0,-(sp)		; „ndra till l†guppl”sning
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#$000,$ffff8240.w	; bakgrund
	move.w	#$000,$ffff8242.w	; scroll
	move.w	#$022,$ffff8248.w	; block1
	move.w	#$044,$ffff824a.w	; block2
	move.w	#$055,$ffff824c.w	; block3
	move.w	#$000,$ffff824e.w	; blockbakgrund
	move.w	#$343,$ffff8250.w	; mupp2
	move.w	#$232,$ffff8252.w	; mupp3
	move.w	#$121,$ffff8254.w	; mupp4
	move.w	#$010,$ffff8256.w	; mupp5
	move.w	#$000,$ffff8258.w	; muppbakgrund
	move.w	#$454,$ffff825a.w	; mupp1
	
	move.l 	$70.w,oldint		; spara gamla vbl
	bclr 	#0,$484.w			; no keyclick
	moveq 	#1,d0			; musik #1
	bsr 	music			; init music
	move.l 	#vbl,$70.w		; installera ny vbl

	move.w	#2,-(sp)		; ta reda p† physbase
	trap	#14
	addq.l	#2,sp
	move.l	d0,phys

	move.l	#text,messnow	; scrollstart

; *** alla macros ***

load	macro
	move.l	\1x,a0
.ulrik	move.l	(a0)+,d0
	cmp.b	#-1,d0
	bne.s	.loop
	lea	sin,a0
	bra.s	.ulrik	
.loop	move.l	a0,\1x
	add.l	d0,\1
	move.l	\1,a0
	lea	\2,a1
	jsr	print
	endm

; *** hoppa till huvudprogrammet ***

	jmp	main		; hoppar till huvudprogrammet			

; *** avsluta allting ***

end
	move.w	#$777,$ffff8240.w	; „ndra f„rg
	
	move.l	oldint,$70.w	; l„gg tillbaka gamla vbl
	
	move.w	#$7,-(sp)		; stop that noise
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp 
	
	move.w	#1,-(sp)		; „ndra till medeluppl”sning
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	dc.w	$a009		; visa musen
	
	or.b	#%11011111,$fffffa09.w ; s„tt p† timer C
	
	move.l	old_usp,-(sp)	; user mode	
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)		; avsluta programmet
	move.w	#$4c,-(sp)
	trap	#1	

; *** h„r kommer sj„lva huvudprogrammet ***	

main:
	add.l	#xpos*8,d0		; initialisering av blocken 1
	add.l	#ypos*160,d0
	move.l	d0,t_1		
	move.l	d0,r_1
	move.l	d0,a_1
	move.l	d0,n_1
	move.l	d0,c_1
	move.l	d0,e_1
	move.l	d0,a_2
	move.l	d0,c_2
	move.l	d0,t_2
	move.l	d0,i_2
	move.l	d0,o_2
	move.l	d0,n_2
	add.l	#8,r_1	
	add.l	#16,a_1
	add.l	#24,n_1
	add.l	#32,c_1
	add.l	#40,e_1
	add.l	#48,a_2
	add.l	#56,c_2
	add.l	#64,t_2
	add.l	#72,i_2
	add.l	#80,o_2
	add.l	#88,n_2

	lea	sin,a0
	move.l	a0,t_1x
	move.l	a0,r_1x
	move.l	a0,a_1x
	move.l	a0,n_1x
	move.l	a0,c_1x
	move.l	a0,e_1x
	move.l	a0,a_2x
	move.l	a0,c_2x
	move.l	a0,t_2x
	move.l	a0,i_2x
	move.l	a0,o_2x
	move.l	a0,n_2x
	
	lea	colsin,a0
	move.l	a0,colpos
	
	move.l	#0,scrolmupp
	
	moveq	#ggr,d1		; den stora loopen	
loop1	jsr	t_1_r
	jsr	b1_r
	jsr	vsync
	dbra	d1,loop1

	moveq	#ggr,d1
loop2	jsr	t_1_r
	jsr	r_1_r
	jsr	b2_r
	jsr	vsync
	dbra	d1,loop2
	
	moveq	#ggr,d1
loop3	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	b3_r
	jsr	vsync
	dbra	d1,loop3
	
	moveq	#ggr,d1
loop4	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	b4_r
	jsr	vsync
	dbra	d1,loop4
	
	moveq	#ggr,d1
loop5	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	b5_r
	jsr	vsync
	dbra	d1,loop5

	moveq	#ggr,d1
loop6	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	b6_r
	jsr	vsync
	dbra	d1,loop6

	moveq	#ggr,d1
loop7	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	b7_r
	jsr	vsync
	dbra	d1,loop7
	
	moveq	#ggr,d1
loop8	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	b1_r
	jsr	vsync
	dbra	d1,loop8
	
	moveq	#ggr,d1
loop9	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	b2_r
	jsr	vsync
	dbra	d1,loop9
	
	moveq	#ggr,d1
loop10	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	b3_r
	jsr	vsync
	dbra	d1,loop10
	
	moveq	#ggr,d1
loop11	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	b4_r
	dbra	d1,loop11

loop	moveq	#ggr,d1		; den riktiga loopen
loop12	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b5_r
	jsr	vsync
	dbra	d1,loop12
	
	moveq	#ggr,d1
loop13	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b6_r
	jsr	vsync
	dbra	d1,loop13
	
	moveq	#ggr,d1
loop14	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b7_r
	jsr	vsync
	dbra	d1,loop14
	
	moveq	#ggr,d1
loop15	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b1_r
	jsr	vsync
	dbra	d1,loop15
	
	moveq	#ggr,d1
loop16	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b2_r
	jsr	vsync
	dbra	d1,loop16
	
	moveq	#ggr,d1
loop17	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b3_r
	jsr	vsync
	dbra	d1,loop17
	
	moveq	#ggr,d1
loop18	jsr	t_1_r
	jsr	r_1_r
	jsr	a_1_r
	jsr	n_1_r
	jsr	c_1_r
	jsr	e_1_r
	jsr	a_2_r
	jsr	c_2_r
	jsr	t_2_r
	jsr	i_2_r
	jsr	o_2_r
	jsr	n_2_r
	jsr	b4_r
	jsr	vsync
	dbra	d1,loop18
	
	jmp	loop
	
; *** blandade subrutiner ***

print	moveq.l	#22,d0		; rita ut ett block som
row	move.b	(a1)+,(a0)+	; „r 16 * 22 bytes stort
	move.b	(a1)+,(a0)+	; a0 - blockets position
	move.b	(a1)+,(a0)+	; a1 - blockets adress
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	add.l	#152,a0			
	dbra	d0,row
	rts	
	
bubble	moveq.l	#53,d0	
.bub	rept	32
	move.b	(a2)+,(a3)+
	endr
	add.l	#128,a3			
	dbra	d0,.bub
	rts	
	
vbl	movem.l 	d0-a6,-(sp)	
	bsr 	(music+8)		
	movem.l 	(sp)+,d0-a6	
	move.l	oldint,-(sp)
	rts
	
colour	addq.l	#1,coltime
	cmp.l	#time,coltime
	bne	nope
	move.l	#0,coltime
	move.l	colpos,a0
hej2	move.l	(a0)+,d0
	cmp.l	#-1,d0
	bne	hej1
	lea	colsin,a0
	bra	hej2	
hej1	move.l	a0,colpos
	move.l 	d0,$ffff8242.w
nope	rts
	
vsync	bsr	scroll
	bsr	scroll
	bsr	plot
	bsr	copy
	
	cmp.l	#190,scrolmupp
	bne	hejhej
	bsr	colour
	bra	forts
hejhej	add.l	#1,scrolmupp
forts	
;	cmp.b	#$39,$fffffc02.w 	; v„nta p† vsync och se efter 
;	beq	end		; om man vill g† ut ur demot
;	move.w	#$000,$ffff8240.w
	move.w	#37,-(sp)		
	trap	#14
	addq.l	#2,sp 
;	move.w	#$700,$ffff8240.w
	rts
	
scroll	lea	scrlbuf,a0
	lea	40(a0),a0
	move.l	#8,count
.loop	and.b	#0,ccr
dum	set	0
	rept	21
	roxl.w	dum(a0)
dum	set	dum-2
	endr
	lea	42(a0),a0
	sub.l	#1,count
	tst.l	count
	bne	.loop
	rts

plot	cmp.b	#3,ifplot
	beq	yesplot
	add.b	#1,ifplot
	rts
yesplot	move.b	#0,ifplot
	moveq.l	#0,d0
ag	move.l	messnow,a0
	move.b	(a0),d0
	cmp.b	#$ff,d0
	bne	no_end
	move.l	#text,messnow
	bra.s	ag
no_end	sub.l	#32,d0
	mulu	#8,d0
	add.l	#font,d0
	move.l	d0,a0
	lea	scrlbuf,a1
	lea	40(a1),a1
	move.l	#8,count
.loop	move.b	(a0)+,(a1)
	lea	42(a1),a1
	sub.l	#1,count
	tst.l	count
	bne	.loop
	add.l	#1,messnow
	rts

copy	lea	scrlbuf,a0
	move.l	phys,a1
	add.l	#spos*160,a1
	move.l	#8,count
.loop	rept	20
	move.w	(a0)+,(a1)
	lea	8(a1),a1
	endr
	lea	2(a0),a0
	sub.l	#1,count
	tst.l	count
	bne	.loop	
	rts
	
t_1_r	load	t_1,t
	rts
r_1_r	load	r_1,r
	rts
a_1_r	load	a_1,a
	rts
n_1_r	load	n_1,n
	rts
c_1_r	load	c_1,c
	rts
e_1_r	load	e_1,e
	rts
a_2_r	load	a_2,a
	rts
c_2_r	load	c_2,c
	rts
t_2_r	load	t_2,t
	rts
i_2_r	load	i_2,i
	rts
o_2_r	load	o_2,o
	rts
n_2_r	load	n_2,n
	rts
b1_r	lea	b1,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b3,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b5,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b7,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts
b2_r	lea	b2,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b4,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b6,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b1,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts
b3_r	lea	b3,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b5,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b7,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b2,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts
b4_r	lea	b4,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b6,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b1,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b3,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts
b5_r	lea	b5,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b7,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b2,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b4,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts
b6_r	lea	b6,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b1,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b3,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b5,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts
b7_r	lea	b7,a2
	move.l	phys,a3
	add.l	#2*8,a3
	jsr	bubble	
	lea	b2,a2
	move.l	phys,a3
	add.l	#16*8+30*160,a3
	jsr	bubble
	lea	b4,a2
	move.l	phys,a3
	add.l	#110*160,a3
	jsr	bubble
	lea	b6,a2
	move.l	phys,a3
	add.l	#10*8+138*160,a3
	jsr	bubble
	rts

; *** diverse data ***

	section	bss

old_usp	ds.l	1
phys	ds.l	1
colpos	ds.l	1
coltime	ds.l	1
t_1	ds.l	1
r_1	ds.l	1
a_1	ds.l	1
n_1	ds.l	1
c_1	ds.l	1
e_1	ds.l	1
a_2	ds.l	1
c_2	ds.l	1
t_2	ds.l	1
i_2	ds.l	1
o_2	ds.l	1
n_2	ds.l	1
t_1x	ds.l	1
r_1x	ds.l	1
a_1x	ds.l	1
n_1x	ds.l	1
c_1x	ds.l	1
e_1x	ds.l	1
a_2x	ds.l	1
c_2x	ds.l	1
t_2x	ds.l	1
i_2x	ds.l	1
o_2x	ds.l	1
n_2x	ds.l	1

scrlbuf	ds.b	336
ifplot	ds.b	1
teck	ds.b	1
count	ds.l	1
messnow	ds.l	1

scrolmupp	ds.l	1
	even

	section	data

music	incbin	shaolin2.mus
	even

oldint	dc.l	0

sin	dc.l	0,   0,   0,   0,   0,   0
	dc.l	160, 160, 160, 160, 160, 160
	dc.l	320, 320, 320, 320, 320, 320, 320
	dc.l	480, 480, 480, 480, 480, 480, 480, 480
	dc.l	320, 320, 320, 320, 320, 320, 320
	dc.l	160, 160, 160, 160, 160, 160
	dc.l	0,   0,   0,   0,   0,   0
	dc.l     -160,-160,-160,-160,-160,-160
	dc.l     -320,-320,-320,-320,-320,-320,-320
	dc.l     -480,-480,-480,-480,-480,-480,-480,-480
	dc.l     -320,-320,-320,-320,-320,-320,-320
	dc.l     -160,-160,-160,-160,-160,-160
	dc.l     -1
	even

colsin	dc.w	$700,0,$710,0,$720,0,$730,0,$740,0,$750,0
	dc.w	$760,0,$770,0,$670,0,$570,0,$470,0,$370,0
	dc.w	$270,0,$170,0,$070,0,$071,0,$072,0,$073,0
	dc.w	$074,0,$075,0,$076,0,$077,0,$067,0,$057,0
	dc.w	$047,0,$037,0,$027,0,$017,0,$107,0,$107,0
	dc.w	$207,0,$307,0,$407,0,$507,0,$607,0,$707,0
	dc.w	$706,0,$705,0,$704,0,$703,0,$702,0,$701,0
	dc.w	-1
	even	

a	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FC7F,$FC7F,$FFFF,$0000,$FBBF,$F83F,$FFFF,$0000
	dc.w	$F7DF,$F01F,$FFFF,$0000,$FB8F,$F46F,$FFFF,$0000
	dc.w	$EA1F,$E5EF,$FFFF,$0000,$E107,$EEF7,$FFFF,$0000
	dc.w	$ED0B,$E2F3,$FFFF,$0000,$ED03,$E27B,$FFFF,$0000
	dc.w	$DE83,$C0FB,$FFFF,$0000,$DF83,$C07B,$FFFF,$0000
	dc.w	$DF03,$C0FB,$FFFF,$0000,$DF01,$C0FD,$FFFF,$0000
	dc.w	$CD51,$D2AD,$FFFF,$0000,$DF69,$C015,$FFFF,$0000
	dc.w	$DEF9,$C081,$FFFF,$0000,$E1C7,$E1C7,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
c	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FC1F,$FC1F,$FFFF,$0000
	dc.w	$FBE7,$F807,$FFFF,$0000,$F7DB,$F023,$FFFF,$0000
	dc.w	$EE1B,$E1E3,$FFFF,$0000,$EF03,$E0FB,$FFFF,$0000
	dc.w	$DC03,$C3FB,$FFFF,$0000,$DD27,$C217,$FFFF,$0000
	dc.w	$D0C7,$CEC7,$FFFF,$0000,$DBFF,$C5FF,$FFFF,$0000
	dc.w	$D1FF,$CDFF,$FFFF,$0000,$D9FF,$C5FF,$FFFF,$0000
	dc.w	$DEC7,$C0C7,$FFFF,$0000,$D92B,$C613,$FFFF,$0000
	dc.w	$EC43,$E3BB,$FFFF,$0000,$ECAB,$E353,$FFFF,$0000
	dc.w	$F753,$F0A3,$FFFF,$0000,$F80F,$F80F,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
e	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$F03F,$F03F,$FFFF,$0000
	dc.w	$EE5F,$E19F,$FFFF,$0000,$CC0F,$C3EF,$FFFF,$0000
	dc.w	$DC1F,$C3EF,$FFFF,$0000,$DE6F,$C18F,$FFFF,$0000
	dc.w	$DE1F,$C19F,$FFFF,$0000,$DC7F,$C37F,$FFFF,$0000
	dc.w	$DE1F,$C19F,$FFFF,$0000,$DC8F,$C36F,$FFFF,$0000
	dc.w	$D8CF,$C72F,$FFFF,$0000,$DCEF,$C30F,$FFFF,$0000
	dc.w	$DC9F,$C31F,$FFFF,$0000,$D80F,$C70F,$FFFF,$0000
	dc.w	$CE97,$C167,$FFFF,$0000,$EC07,$E3F7,$FFFF,$0000
	dc.w	$E7F7,$E807,$FFFF,$0000,$F00F,$F00F,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
i	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FF9F,$FF9F,$FFFF,$0000
	dc.w	$FF6F,$FF0F,$FFFF,$0000,$FE2F,$FECF,$FFFF,$0000
	dc.w	$FE6F,$FE8F,$FFFF,$0000,$FD4F,$FCAF,$FFFF,$0000
	dc.w	$FD4F,$FCAF,$FFFF,$0000,$FD6F,$FC8F,$FFFF,$0000
	dc.w	$FB0F,$F8EF,$FFFF,$0000,$FBAF,$F84F,$FFFF,$0000
	dc.w	$FB2F,$F8CF,$FFFF,$0000,$FB0F,$F8EF,$FFFF,$0000
	dc.w	$FB8F,$F86F,$FFFF,$0000,$FA8F,$F96F,$FFFF,$0000
	dc.w	$FBAF,$F84F,$FFFF,$0000,$FB1F,$F8DF,$FFFF,$0000
	dc.w	$FB1F,$F8DF,$FFFF,$0000,$FC3F,$FC3F,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
n	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$F3CF,$F3CF,$FFFF,$0000
	dc.w	$ED87,$E1A7,$FFFF,$0000,$DDC7,$C1B7,$FFFF,$0000
	dc.w	$C183,$DFBB,$FFFF,$0000,$DCE3,$C29B,$FFFF,$0000
	dc.w	$D4C3,$CABB,$FFFF,$0000,$D6C3,$C9BB,$FFFF,$0000
	dc.w	$DC6B,$C313,$FFFF,$0000,$DA43,$C53B,$FFFF,$0000
	dc.w	$D443,$CBBB,$FFFF,$0000,$DB03,$C4FB,$FFFF,$0000
	dc.w	$D58B,$CA73,$FFFF,$0000,$EC03,$E2FB,$FFFF,$0000
	dc.w	$EE83,$E07B,$FFFF,$0000,$E4C3,$EA3B,$FFFF,$0000
	dc.w	$E86B,$E613,$FFFF,$0000,$F1C7,$F1C7,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
o	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FE3F,$FE3F,$FFFF,$0000,$F9CF,$F80F,$FFFF,$0000
	dc.w	$F677,$F187,$FFFF,$0000,$EE97,$E167,$FFFF,$0000
	dc.w	$EF03,$E0F3,$FFFF,$0000,$ED8B,$E273,$FFFF,$0000
	dc.w	$DFCB,$C033,$FFFF,$0000,$D643,$C83B,$FFFF,$0000
	dc.w	$DFCB,$C1B3,$FFFF,$0000,$DF43,$C03B,$FFFF,$0000
	dc.w	$DBC3,$C43B,$FFFF,$0000,$DF83,$C07B,$FFFF,$0000
	dc.w	$DB8B,$C473,$FFFF,$0000,$EDCB,$E233,$FFFF,$0000
	dc.w	$F7A7,$F057,$FFFF,$0000,$FC0F,$FC0F,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
r	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$F81F,$F81F,$FFFF,$0000
	dc.w	$F3C7,$F007,$FFFF,$0000,$EF03,$E0F3,$FFFF,$0000
	dc.w	$CF03,$C0FB,$FFFF,$0000,$DDE3,$C21F,$FFFF,$0000
	dc.w	$DF41,$C03D,$FFFF,$0000,$DEA1,$C09D,$FFFF,$0000
	dc.w	$DA81,$C4BD,$FFFF,$0000,$DF61,$C01D,$FFFF,$0000
	dc.w	$DDC3,$C23B,$FFFF,$0000,$D9C7,$C637,$FFFF,$0000
	dc.w	$D00F,$CFEF,$FFFF,$0000,$9F1F,$80DF,$FFFF,$0000
	dc.w	$BB8F,$846F,$FFFF,$0000,$B887,$8477,$FFFF,$0000
	dc.w	$B247,$8A37,$FFFF,$0000,$C38F,$C38F,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
t	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$F007,$F007,$FFFF,$0000,$CF09,$C0F1,$FFFF,$0000
	dc.w	$BF01,$80FD,$FFFF,$0000,$7802,$07FC,$FFFF,$0000
	dc.w	$7400,$0BFE,$FFFF,$0000,$2822,$57DC,$FFFF,$0000
	dc.w	$7CFD,$0301,$FFFF,$0000,$8E7B,$8183,$FFFF,$0000
	dc.w	$E703,$E0C3,$FFFF,$0000,$FA0F,$F9EF,$FFFF,$0000
	dc.w	$F80F,$FBEF,$FFFF,$0000,$F50F,$F2EF,$FFFF,$0000
	dc.w	$F60F,$F1EF,$FFFF,$0000,$F30F,$F4EF,$FFFF,$0000
	dc.w	$FB0F,$F8CF,$FFFF,$0000,$FC1F,$FC1F,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
	even

font	dc.b	0,0,0,0,0,0,0,0			
	dc.b	$18,$18,$18,$18,$18,0,$18,0	
	dc.b	$66,$66,$66,0,0,0,0,0
	dc.b	0,$6c,$fe,$6c,$fe,$6c,0,0
	dc.b	$30,$7e,$c0,$7c,6,$fc,$30,0
	dc.b	0,$c6,$cc,$18,$30,$66,$c6,0
	dc.b	$70,$d8,$70,$70,$da,$cc,$7a,0
	dc.b	$18,$18,$10,0,0,0,0,0
	dc.b	32,64,128,128,128,128,64,32	;(
	dc.b	8,4,2,2,2,2,4,8			;)
	dc.b	0,0,$18,$7e,$3c,$7e,$18,0
	dc.b	0,0,$18,$18,$7e,$18,$18,0
	dc.b	0,0,0,0,0,$18,$18,$10
	dc.b	0,0,0,0,$7e,0,0,0
	dc.b	0,0,0,0,0,$18,$18,0
	dc.b	2,6,$c,$18,$30,$60,$c0,0
	dc.b	0,60,102,110,118,102,102,60	;0
	dc.b	0,12,60,12,12,12,12,12		;1
	dc.b	0,60,102,6,12,24,48,126 	;2
	dc.b	0,252,24,48,24,12,204,120	;3
	dc.b	0,12,28,60,108,126,12,12	;4
	dc.b	0,252,192,248,12,12,204,120	;5
	dc.b	0,120,192,192,248,204,204,120 	;6
	dc.b	0,252,12,24,48,96,96,96 	;7
	dc.b	0,60,102,102,60,102,102,60	;8
	dc.b	0,120,204,204,124,12,24,112	;9
	dc.b	0,$18,$18,0,0,$18,$18,0
	dc.b	0,$18,$18,0,0,$18,$18,$10
	dc.b	0,0,$c,$18,$30,$18,$c,0
	dc.b	0,0,0,$7e,0,$7e,0,0
	dc.b	0,0,$30,$18,$c,$18,$30,0
	dc.b	$7c,$c6,$c6,$1c,$30,0,$30,0
	dc.b	$7c,$c6,$de,$d6,$de,$c0,$7e,0
	dc.b	16,40,68,68,124,68,68,68
	dc.b	240,136,136,136,240,136,136,240
	dc.b	56,64,128,128,128,128,64,56
	dc.b	192,160,144,144,144,144,160,192
	dc.b	248,128,128,240,128,128,128,248
	dc.b	248,128,128,240,128,128,128,128
	dc.b	112,136,128,128,184,136,136,112
	dc.b	136,136,136,248,136,136,136,136
	dc.b	16,16,16,16,16,16,16,16
	dc.b	8,8,8,8,8,72,72,48
	dc.b	136,144,160,192,192,160,144,136
	dc.b	128,128,128,128,128,128,128,248
	dc.b	136,216,168,168,136,136,136,136
	dc.b	136,200,168,152,136,136,136,136
	dc.b	112,136,136,136,136,136,136,112
	dc.b	240,136,136,136,240,128,128,128
	dc.b	112,136,136,136,136,168,152,120
	dc.b	240,136,136,136,240,136,136,136
	dc.b	120,128,128,112,8,8,8,240
	dc.b	248,32,32,32,32,32,32,32
	dc.b	136,136,136,136,136,136,136,112
	dc.b	136,136,136,136,136,136,80,32
	dc.b	136,136,136,136,168,168,168,112
	dc.b	136,136,80,32,32,80,136,136
	dc.b	136,136,80,32,32,32,32,32
 	dc.b	248,16,32,32,64,64,128,248
	dc.b	$1e,$18,$18,$18,$18,$18,$1e,0
	dc.b	$80,$c0,$60,$30,$18,$c,6,0
	dc.b	$78,$18,$18,$18,$18,$18,$78,0
	dc.b	$10,$38,$6c,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,$ff
	dc.b	$18,$18,8,0,0,0,0,0
	dc.b	0,0,0,104,152,136,136,120	;a
	dc.b	128,128,128,240,136,136,136,240 ;b
	dc.b	0,0,0,120,128,128,128,120	;c
	dc.b	8,8,8,120,136,136,136,120	;d
	dc.b	0,0,0,112,136,184,128,120	;e
	dc.b	48,72,72,64,224,64,64,64	;f
	dc.b	0,0,112,136,120,8,136,112	;g
	dc.b	128,128,128,176,200,136,136,136	;h
	dc.b	0,0,32,0,32,32,32,32		;i
	dc.b	16,0,16,16,16,144,144,96	;j
	dc.b	128,128,128,144,160,192,160,144	;k
	dc.b	64,64,64,64,64,64,64,64		;l
	dc.b	0,0,0,168,212,148,132,132	;m
	dc.b	0,0,0,176,200,136,136,136	;n
	dc.b	0,0,0,112,136,136,136,112	;o	
	dc.b	0,0,0,112,136,136,240,128	;p
	dc.b	0,0,0,112,136,136,120,8 	;q
	dc.b	0,0,0,160,192,128,128,128	;r
	dc.b	0,0,0,112,128,112,8,240		;s
	dc.b	64,64,64,64,224,64,72,48	;t
	dc.b	0,0,0,136,136,136,152,104	;u
	dc.b	0,0,0,136,136,136,80,32 	;v
	dc.b	0,0,0,136,136,168,168,80	;w
	dc.b	0,0,0,136,80,32,80,136  	;x
	dc.b	0,0,0,136,136,120,8,48  	;y
	dc.b	0,0,0,248,16,32,64,248		;z
	dc.b	$1e,$18,$38,$70,$38,$18,$1e,0
	dc.b	$18,$18,$18,$18,$18,$18,$18,$18
	dc.b	$78,$18,$1c,$e,$1c,$18,$78,0
	even
b1		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0004,$0007,$FFF8,$FFFF
		dc.w	$3000,$F000,$0FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0013,$001C,$FFE0,$FFFF
		dc.w	$8400,$7C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$043F,$07F0,$F80F,$FFFF
		dc.w	$1860,$0FE0,$001F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$1386,$1C7C,$E002,$FFFF
		dc.w	$2708,$38F8,$0007,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$2872,$300E,$C000,$FFFF
		dc.w	$50E4,$601C,$0003,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$1F1B,$2007,$CF00,$FFFF
		dc.w	$3E36,$400E,$1E01,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$4F19,$6007,$8F00,$FFFF
		dc.w	$9E32,$C00E,$1E01,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$4619,$6007,$8600,$FFFF
		dc.w	$8C32,$C00E,$0C01,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$5039,$6007,$8000,$FFFF
		dc.w	$A072,$C00E,$0001,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$2C73,$300E,$C001,$FFFF
		dc.w	$58E4,$601C,$0003,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$37C7,$383E,$C001,$FFFF
		dc.w	$6F8C,$707C,$0003,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$080E,$0FF8,$F006,$FFFF
		dc.w	$1010,$1FF0,$000F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$03F0,$03E0,$FC00,$FFFF
		dc.w	$3FC0,$07C0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0037,$0038,$FFC0,$FFFF
		dc.w	$C600,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0008,$000F,$FFF0,$FFFF
		dc.w	$0800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0003,$0003,$FFFC,$FFFF
		dc.w	$E000,$E000,$1FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
b2		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0008,$000F,$FFF0,$FFFF
		dc.w	$6000,$E000,$1FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0027,$0038,$FFC0,$FFFF
		dc.w	$0800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$E400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$003E,$0040,$FF9E,$FFFF
		dc.w	$3600,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$009E,$00C0,$FF1E,$FFFF
		dc.w	$3200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$008C,$00C0,$FF0C,$FFFF
		dc.w	$3200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$00A0,$00C0,$FF00,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0058,$0060,$FF80,$FFFF
		dc.w	$E400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$21EF,$3FF0,$C000,$FFFF
		dc.w	$8E18,$7FF8,$0007,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$9C30,$E3FF,$0000,$FFFF
		dc.w	$19C2,$FE3E,$0001,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0001,$0001,$FFFE,$FFFF,$4397,$8077,$0008,$FFFF
		dc.w	$D439,$D807,$2000,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0001,$FFFE,$FFFF,$F8D8,$0038,$7807,$FFFF
		dc.w	$0F8D,$1003,$E780,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0002,$0003,$FFFC,$FFFF,$78C8,$0038,$7807,$FFFF
		dc.w	$278C,$3003,$C780,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0002,$0003,$FFFC,$FFFF,$30C8,$0038,$3007,$FFFF
		dc.w	$230C,$3003,$C300,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0002,$0003,$FFFC,$FFFF,$81C8,$0038,$0007,$FFFF
		dc.w	$281C,$3003,$C000,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0001,$0001,$FFFE,$FFFF,$6390,$8070,$000F,$FFFF
		dc.w	$1639,$1807,$E000,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0001,$0001,$FFFE,$FFFF,$BE38,$C1FF,$0000,$FFFF
		dc.w	$7BE3,$FC1F,$0000,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$4067,$7FF8,$8000,$FFFF
		dc.w	$0C04,$FFFC,$0003,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$1F50,$1F60,$E080,$FFFF
		dc.w	$E5F0,$1DF0,$020F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$003E,$0040,$FF9E,$FFFF
		dc.w	$3600,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$009E,$00C0,$FF1E,$FFFF
		dc.w	$3200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$008C,$00C0,$FF0C,$FFFF
		dc.w	$3200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$00A0,$00C0,$FF00,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0058,$0060,$FF80,$FFFF
		dc.w	$E400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$006F,$0070,$FF80,$FFFF
		dc.w	$8C00,$7C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0010,$001F,$FFE0,$FFFF
		dc.w	$1000,$F000,$0FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0007,$0007,$FFF8,$FFFF
		dc.w	$C000,$C000,$3FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
b3		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0004,$0007,$FFF8,$FFFF
		dc.w	$3000,$F000,$0FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0013,$001C,$FFE0,$FFFF
		dc.w	$8400,$7C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0060,$FF8F,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0037,$0038,$FFC0,$FFFF
		dc.w	$C600,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0018,$002F,$FFC0,$FFFF
		dc.w	$0B00,$FF00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0063,$FF8C,$FFFF
		dc.w	$F900,$E700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0008,$000F,$FFF0,$FFFF,$61B7,$FFB8,$0040,$FFFF
		dc.w	$C70C,$3FFF,$0000,$FFFF,$3000,$F000,$0FFE,$FFFE
		dc.w	$0027,$0038,$FFC0,$FFFF,$0C28,$FBEF,$0010,$FFFF
		dc.w	$0CF3,$FF1C,$0000,$FFFF,$8400,$7C00,$03FE,$FFFE
		dc.w	$0050,$0060,$FF80,$FFFF,$E793,$1C73,$000C,$FFFF
		dc.w	$EA28,$EC30,$1000,$FFFF,$7200,$0E00,$01FE,$FFFE
		dc.w	$003E,$0040,$FF9E,$FFFF,$36D8,$0E38,$0007,$FFFF
		dc.w	$07DF,$0820,$F3CF,$FFFF,$1B00,$0700,$00FE,$FFFE
		dc.w	$009E,$00C0,$FF1E,$FFFF,$32C8,$0E38,$0007,$FFFF
		dc.w	$13CF,$1860,$E38F,$FFFF,$1900,$0700,$00FE,$FFFE
		dc.w	$008C,$00C0,$FF0C,$FFFF,$32C8,$0E38,$0007,$FFFF
		dc.w	$11C6,$1860,$E186,$FFFF,$1900,$0700,$00FE,$FFFE
		dc.w	$00A0,$00C0,$FF00,$FFFF,$73C8,$0E38,$0007,$FFFF
		dc.w	$1450,$1860,$E000,$FFFF,$3900,$0700,$00FE,$FFFE
		dc.w	$0058,$0060,$FF80,$FFFF,$E790,$1C70,$000F,$FFFF
		dc.w	$0B2C,$0C30,$F000,$FFFF,$7200,$0E00,$01FE,$FFFE
		dc.w	$006F,$0070,$FF80,$FFFF,$8E30,$7DF0,$000F,$FFFF
		dc.w	$0DF7,$0E38,$F000,$FFFF,$C600,$3E00,$01FE,$FFFE
		dc.w	$0010,$001F,$FFE0,$FFFF,$1044,$FFC7,$0038,$FFFF
		dc.w	$3208,$F3FF,$0C00,$FFFF,$0800,$F800,$07FE,$FFFE
		dc.w	$0007,$0007,$FFF8,$FFFF,$DF13,$DF1C,$20E0,$FFFF
		dc.w	$84FB,$7CFB,$0304,$FFFF,$E000,$E000,$1FFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004C,$0067,$FF88,$FFFF
		dc.w	$3900,$F700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0053,$007C,$FF80,$FFFF
		dc.w	$8500,$7F00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0060,$FF8F,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0037,$0038,$FFC0,$FFFF
		dc.w	$C600,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0008,$000F,$FFF0,$FFFF
		dc.w	$0800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0003,$0003,$FFFC,$FFFF
		dc.w	$E000,$E000,$1FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
b4		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0004,$0007,$FFF8,$FFFF
		dc.w	$3000,$F000,$0FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0013,$001C,$FFE0,$FFFF
		dc.w	$8400,$7C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0060,$FF8F,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0037,$0038,$FFC0,$FFFF
		dc.w	$C600,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$003F,$FFC0,$FFFF
		dc.w	$0A00,$FE00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0023,$FFCC,$FFFF
		dc.w	$FB00,$E700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0060,$FF8F,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0037,$0038,$FFC0,$FFFF
		dc.w	$C600,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0018,$002F,$FFC0,$FFFF
		dc.w	$0B00,$FF00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0063,$FF8C,$FFFF
		dc.w	$F900,$E700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0868,$0FEF,$F010,$FFFF,$61B7,$FFB8,$0040,$FFFF
		dc.w	$C70C,$3FFF,$0000,$FFFF,$3860,$FFE0,$001E,$FFFE
		dc.w	$270F,$38F8,$C000,$FFFF,$0C28,$FBEF,$0010,$FFFF
		dc.w	$0CF3,$FF1C,$0000,$FFFF,$A708,$78F8,$0006,$FFFE
		dc.w	$50E4,$601C,$8000,$FFFF,$E793,$1C73,$000C,$FFFF
		dc.w	$EA28,$EC30,$1000,$FFFF,$50E4,$601C,$0002,$FFFE
		dc.w	$3E36,$400E,$9E00,$FFFF,$36D8,$0E38,$0007,$FFFF
		dc.w	$07DF,$0820,$F3CF,$FFFF,$3E36,$400E,$1E00,$FFFE
		dc.w	$9E32,$C00E,$1E00,$FFFF,$32C8,$0E38,$0007,$FFFF
		dc.w	$13CF,$1860,$E38F,$FFFF,$9E32,$C00E,$1E00,$FFFE
		dc.w	$8C32,$C00E,$0C00,$FFFF,$32C8,$0E38,$0007,$FFFF
		dc.w	$11C6,$1860,$E186,$FFFF,$8C32,$C00E,$0C00,$FFFE
		dc.w	$A072,$C00E,$0000,$FFFF,$73C8,$0E38,$0007,$FFFF
		dc.w	$1450,$1860,$E000,$FFFF,$A072,$C00E,$0000,$FFFE
		dc.w	$58E4,$601C,$8000,$FFFF,$E790,$1C70,$000F,$FFFF
		dc.w	$0B2C,$0C30,$F000,$FFFF,$58E4,$601C,$0002,$FFFE
		dc.w	$6F8F,$707C,$8000,$FFFF,$8E30,$7DF0,$000F,$FFFF
		dc.w	$0DF7,$0E38,$F000,$FFFF,$EF8C,$707C,$0002,$FFFE
		dc.w	$1010,$1FFF,$E000,$FFFF,$1044,$FFC7,$0038,$FFFF
		dc.w	$3208,$F3FF,$0C00,$FFFF,$1010,$FFF0,$000E,$FFFE
		dc.w	$07C7,$07C7,$F838,$FFFF,$DF13,$DF1C,$20E0,$FFFF
		dc.w	$84FB,$7CFB,$0304,$FFFF,$E7C0,$E7C0,$183E,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004C,$0067,$FF88,$FFFF
		dc.w	$3900,$F700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0053,$007C,$FF80,$FFFF
		dc.w	$8500,$7F00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0068,$0070,$FF80,$FFFF
		dc.w	$7300,$0F00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0060,$FF8F,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0044,$0067,$FF80,$FFFF
		dc.w	$3900,$F700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0053,$007C,$FF80,$FFFF
		dc.w	$8500,$7F00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001F,$0020,$FFCF,$FFFF
		dc.w	$1B00,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004F,$0060,$FF8F,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0046,$0060,$FF86,$FFFF
		dc.w	$1900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0050,$0060,$FF80,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$002C,$0030,$FFC0,$FFFF
		dc.w	$7200,$0E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0037,$0038,$FFC0,$FFFF
		dc.w	$C600,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0008,$000F,$FFF0,$FFFF
		dc.w	$0800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0003,$0003,$FFFC,$FFFF
		dc.w	$E000,$E000,$1FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
b5		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0010,$001F,$FFE0,$FFFF
		dc.w	$C000,$C000,$3FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$004E,$0071,$FF80,$FFFF
		dc.w	$1000,$F000,$0FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$00A1,$00C0,$FF00,$FFFF
		dc.w	$C800,$3800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$007C,$0080,$FF3C,$FFFF
		dc.w	$6C00,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$013C,$0180,$FE3C,$FFFF
		dc.w	$6400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0118,$0180,$FE18,$FFFF
		dc.w	$6400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0140,$0180,$FE00,$FFFF
		dc.w	$E400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$00B1,$00C0,$FF00,$FFFF
		dc.w	$C800,$3800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$00DF,$00E0,$FF00,$FFFF
		dc.w	$1800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0060,$007F,$FF80,$FFFF
		dc.w	$3000,$F000,$0FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$00AF,$00CF,$FF00,$FFFF
		dc.w	$C800,$B800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$007C,$0080,$FF3C,$FFFF
		dc.w	$6C00,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$013C,$0180,$FE3C,$FFFF
		dc.w	$6400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0118,$0180,$FE18,$FFFF
		dc.w	$6400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0140,$0180,$FE00,$FFFF
		dc.w	$E400,$1C00,$03FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0430,$07F0,$F80F,$FFFF,$00B1,$00C0,$FF00,$FFFF
		dc.w	$C800,$3800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$1384,$1C7C,$E003,$FFFF,$00DF,$00E0,$FF00,$FFFF
		dc.w	$1800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$2872,$300F,$C000,$FFFF,$3260,$F3BF,$0C00,$FFFF
		dc.w	$2000,$E000,$1FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$1F1B,$2007,$CF00,$FFFF,$850F,$7E0F,$0000,$FFFF
		dc.w	$C000,$C000,$3FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$4F19,$6007,$8F00,$FFFF,$73E3,$0E00,$01E0,$FFFF
		dc.w	$6000,$E000,$1FFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$4619,$6007,$8600,$FFFF,$1BE3,$0700,$00E0,$FFFF
		dc.w	$2021,$E03F,$1FC0,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$5039,$6007,$8000,$FFFF,$19C3,$0700,$00C0,$FFFF
		dc.w	$209C,$E0E3,$1F00,$FFFF,$2180,$FF80,$007E,$FFFE
		dc.w	$2C72,$300E,$C000,$FFFF,$1907,$0700,$0000,$FFFF
		dc.w	$2143,$E180,$1E00,$FFFF,$9C20,$E3E0,$001E,$FFFE
		dc.w	$37C6,$383E,$C000,$FFFF,$398E,$0701,$0000,$FFFF
		dc.w	$60F9,$FF01,$0078,$FFFF,$4390,$8070,$000E,$FFFE
		dc.w	$080C,$0FF8,$F000,$FFFF,$72F8,$0F07,$0000,$FFFF
		dc.w	$DE78,$E301,$0078,$FFFF,$F8D8,$0038,$7806,$FFFE
		dc.w	$03F7,$03F8,$FC00,$FFFF,$C701,$3FFF,$0000,$FFFF
		dc.w	$4232,$8303,$0030,$FFFF,$78C8,$0038,$7806,$FFFE
		dc.w	$0008,$000F,$FFF0,$FFFF,$087C,$F87D,$0782,$FFFF
		dc.w	$FA82,$0303,$7800,$FFFF,$30C8,$0038,$3006,$FFFE
		dc.w	$0003,$0003,$FFFC,$FFFF,$E002,$E003,$1FFC,$FFFF
		dc.w	$7962,$0183,$7800,$FFFF,$81C8,$0038,$0006,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0002,$0003,$FFFC,$FFFF
		dc.w	$31BF,$01C1,$3000,$FFFF,$6390,$8070,$000E,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0003,$0003,$FFFC,$FFFF
		dc.w	$0DC1,$FC7F,$0000,$FFFF,$BE30,$C1F0,$000E,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0004,$0007,$FFF8,$FFFF
		dc.w	$E19F,$1F7F,$0000,$FFFF,$4040,$7FC0,$803E,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000A,$000C,$FFF0,$FFFF
		dc.w	$1CB0,$03F0,$000F,$FFFF,$1F00,$1F00,$E0FE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0007,$0008,$FFF3,$FFFF
		dc.w	$C6C0,$01C0,$C03F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0013,$0018,$FFE3,$FFFF
		dc.w	$C640,$01C0,$C03F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0011,$0018,$FFE1,$FFFF
		dc.w	$8640,$01C0,$803F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0014,$0018,$FFE0,$FFFF
		dc.w	$8640,$FFC0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000A,$000F,$FFF0,$FFFF
		dc.w	$7080,$8F80,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000D,$000E,$FFF0,$FFFF
		dc.w	$0E40,$01C0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0003,$0004,$FFF9,$FFFF
		dc.w	$E360,$00E0,$E01F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0009,$000C,$FFF1,$FFFF
		dc.w	$E320,$00E0,$E01F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0008,$000C,$FFF0,$FFFF
		dc.w	$C320,$00E0,$C01F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000A,$000C,$FFF0,$FFFF
		dc.w	$0720,$00E0,$001F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0005,$0006,$FFF8,$FFFF
		dc.w	$8E40,$01C0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0006,$0007,$FFF8,$FFFF
		dc.w	$F8C0,$07C0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0001,$0001,$FFFE,$FFFF
		dc.w	$0100,$FF00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$7C00,$7C00,$83FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
b6		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0002,$0003,$FFFC,$FFFF
		dc.w	$1800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0009,$000E,$FFF0,$FFFF
		dc.w	$C200,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0014,$0018,$FFE0,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000F,$0010,$FFE7,$FFFF
		dc.w	$8D80,$0380,$807F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0027,$0030,$FFC7,$FFFF
		dc.w	$8C80,$0380,$807F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0023,$0030,$FFC3,$FFFF
		dc.w	$0C80,$0380,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$1C80,$0380,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0016,$0018,$FFE0,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$001B,$001C,$FFE0,$FFFF
		dc.w	$E300,$1F00,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000C,$000F,$FFF0,$FFFF
		dc.w	$0600,$FE00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0015,$0019,$FFE0,$FFFF
		dc.w	$F900,$F700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0010,$001F,$FFE0,$FFFF,$C00F,$C010,$3FE7,$FFFF
		dc.w	$8D80,$0380,$807F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$004E,$0071,$FF80,$FFFF,$1027,$F030,$0FC7,$FFFF
		dc.w	$8C80,$0380,$807F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$00A1,$00C0,$FF00,$FFFF,$C8E3,$3FF0,$0003,$FFFF
		dc.w	$0C80,$0380,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$007C,$0080,$FF3C,$FFFF,$6E18,$1DF0,$0000,$FFFF
		dc.w	$1D0E,$03FF,$0000,$FFFF,$1800,$F800,$07FE,$FFFE
		dc.w	$013C,$0180,$FE3C,$FFFF,$65CE,$1C38,$0000,$FFFF
		dc.w	$3CE9,$071E,$0000,$FFFF,$C200,$3E00,$01FE,$FFFE
		dc.w	$0118,$0180,$FE18,$FFFF,$646F,$1C1C,$0000,$FFFF
		dc.w	$EA14,$1C18,$0000,$FFFF,$3900,$0700,$00FE,$FFFE
		dc.w	$0140,$0180,$FE00,$FFFF,$E464,$1C1F,$0000,$FFFF
		dc.w	$07CF,$F810,$03C7,$FFFF,$8D80,$0380,$807E,$FFFE
		dc.w	$00B1,$00C0,$FF00,$FFFF,$C867,$381D,$0002,$FFFF
		dc.w	$F3E7,$F830,$03C7,$FFFF,$8C80,$0380,$807E,$FFFE
		dc.w	$00DF,$00E0,$FF00,$FFFF,$18E4,$F81C,$0000,$FFFF
		dc.w	$31A3,$1830,$0183,$FFFF,$0C80,$0380,$007E,$FFFE
		dc.w	$0020,$003F,$FFC0,$FFFF,$31CC,$E038,$0000,$FFFF
		dc.w	$8628,$FE30,$0000,$FFFF,$1C80,$0380,$007E,$FFFE
		dc.w	$000F,$000F,$FFF0,$FFFF,$DF1E,$E0FB,$0000,$FFFF
		dc.w	$7096,$8F98,$0000,$FFFF,$3900,$0700,$00FE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$202D,$3FEE,$C010,$FFFF
		dc.w	$0E7B,$01DC,$0000,$FFFF,$E300,$1F00,$00FE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0F83,$0F84,$F079,$FFFF
		dc.w	$E364,$00FF,$E000,$FFFF,$0400,$FC00,$03FE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0009,$000C,$FFF1,$FFFF
		dc.w	$E339,$00F9,$E006,$FFFF,$F000,$F000,$0FFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0008,$000C,$FFF0,$FFFF
		dc.w	$C320,$00E0,$C01F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000A,$000C,$FFF0,$FFFF
		dc.w	$4320,$7FE0,$001F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0005,$0007,$FFF8,$FFFF
		dc.w	$3840,$C7C0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0006,$0007,$FFF8,$FFFF
		dc.w	$8720,$00E0,$001F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0001,$0002,$FFFC,$FFFF
		dc.w	$F1B0,$0070,$F00F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0004,$0006,$FFF8,$FFFF
		dc.w	$F190,$0070,$F00F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0004,$0006,$FFF8,$FFFF
		dc.w	$6190,$0070,$600F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0005,$0006,$FFF8,$FFFF
		dc.w	$0390,$0070,$000F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0002,$0003,$FFFC,$FFFF
		dc.w	$C720,$00E0,$001F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0003,$0003,$FFFC,$FFFF
		dc.w	$7C60,$83E0,$001F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$8080,$FF80,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$3E00,$3E00,$C1FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
b7		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0002,$0003,$FFFC,$FFFF
		dc.w	$1800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0009,$000E,$FFF0,$FFFF
		dc.w	$C200,$3E00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0014,$0018,$FFE0,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000F,$0010,$FFE7,$FFFF
		dc.w	$8D80,$0380,$807F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0027,$0030,$FFC7,$FFFF
		dc.w	$8C80,$0380,$807F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0023,$0030,$FFC3,$FFFF
		dc.w	$0C80,$0380,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0028,$0030,$FFC0,$FFFF
		dc.w	$1C80,$0380,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$10D6,$1FD8,$E020,$FFFF
		dc.w	$3900,$0700,$00FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$4E1B,$71FC,$8000,$FFFF
		dc.w	$E318,$1FF8,$0007,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$A1CC,$C03F,$0000,$FFFF
		dc.w	$05C2,$FE3E,$0001,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$7C6D,$801D,$3C00,$FFFF
		dc.w	$F439,$F807,$0000,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0001,$0001,$FFFE,$FFFF,$3C66,$801C,$3C02,$FFFF
		dc.w	$2F8D,$1003,$0780,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0001,$0001,$FFFE,$FFFF,$1866,$801C,$1802,$FFFF
		dc.w	$278C,$3003,$0780,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0001,$0001,$FFFE,$FFFF,$40E4,$801C,$0000,$FFFF
		dc.w	$230C,$3003,$0300,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$B1C8,$C038,$0000,$FFFF
		dc.w	$681C,$3003,$0000,$FFFF,$8000,$8000,$7FFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$DF18,$E0F8,$0000,$FFFF
		dc.w	$F639,$1807,$0000,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$202F,$3FF1,$C000,$FFFF
		dc.w	$1BE3,$FC1F,$0000,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0F94,$0F9F,$F060,$FFFF
		dc.w	$E404,$1FFC,$0003,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000A,$000C,$FFF0,$FFFF
		dc.w	$1DF0,$03F0,$000F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0007,$0008,$FFF3,$FFFF
		dc.w	$C6C0,$01C0,$C03F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0013,$0018,$FFE3,$FFFF
		dc.w	$C640,$01C0,$C03F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0011,$0018,$FFE1,$FFFF
		dc.w	$8640,$01C0,$803F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0014,$0018,$FFE0,$FFFF
		dc.w	$0E40,$01C0,$003F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000B,$000C,$FFF0,$FFFF
		dc.w	$1C80,$0380,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$000D,$000E,$FFF0,$FFFF
		dc.w	$F180,$0F80,$007F,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0002,$0003,$FFFC,$FFFF
		dc.w	$0200,$FE00,$01FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$F800,$F800,$07FF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF
		dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FFFE,$FFFE
		dc.w	0
		even
text
 
 dc.b "                                    "
 dc.b "STardate - The 18th of September 1991                           "
 dc.b "Location - Gavle, Sweden                                    "
 dc.b "Hi there, and welcome to Tranceaction's contribution to this "
 dc.b "MEGADEMO!                      Let's burn off with the credits: Nice coding - "
 dc.b "Jasper   Wonderful trackermusic in the intro and This Font you're looking at - STrawberry "   
 dc.b "   Excellent graphics - "
 dc.b "Scooter                                 Right now, I (STrawberry) am at the keyboard, "
 dc.b "typing this scroll. Jasper will eventually releave me... But "
 dc.b "now I'M typing, so I'm just going to give a few greetings to a "
 dc.b "few persons, deserving it. Here they are: Rodent/Sign of Four, M. "
 dc.b "Akerblom, Headhunter/Lynx and the man who writes the scripts for "
 dc.b "Lucasfilm's games. Also, there are some groups around the world "
 dc.b "who also deserves a greet: NeXT, the rest of Tranceaction (Who "
 dc.b "are a fraction of Grim Reaper Crew) and the swedish groups TKT "
 dc.b "and Vector/Phalanx... (Not to forget Legion!). Normal Hi! to: "
 dc.b "TLT, 2 Life Crew and TCB (looking forward to the convention!) "
 dc.b " Special Greeting to Stonehead Productions for their GREAT sample-demos!! "
 dc.b "And now something completely different: "
 dc.b "Front 242 rules! (For all of you who doesn't know, Front 242 is "
 dc.b "a Belgian synthgroup, which simply is the best ever.)                And now "
 dc.b "back to the world of ST: About this demo... The tracker routine "
 dc.b "we used for the first screen sadly took 95% of the machine time."
 dc.b ".. So coder Jasper just couldn't fit in more than a piccy by "
 dc.b "Scooter! (Guess wo persuaded him into putting the '242' on the wall)" 
 dc.b " All the other routines had either too lousy sound, or "
 dc.b "couldn't handle the C-code Volume Change! Yecch! But, we got it "
 dc.b "working this way. Now I think it's time to hand the keyboard over "
 dc.b "to Jasper.                                    Jasper here! First of all, I'd like to add one "
 dc.b "more greeting to the list: The Cyclone! They're a couple of "
 dc.b "French guys, and I met one of them on a shop in Paris. I don't "
 dc.b "now exactly what they're doing, but I'll soon find out (I hope). "
 dc.b "Look out for their ",34,"NeoDemo",34,", qui est tres beaux (ou "
 dc.b "belle? I don't know...). Then, as usual, I'd like to thank The "
 dc.b "One of Vector/Phalanx for help with the code.                        "                                     "
 dc.b "     Anything more?                          Of course! Look out for the GRC Mega"
 dc.b "Demo!"
 dc.b "                                                      "
 dc.b "Let's wrap!"
 dc.b "                                                      "
 dc.b $ff
	even
