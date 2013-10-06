	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_screen

	move.w	#0,-(sp)		
	move.l	#$78000,-(sp)		
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen

	move.w	#$000,$ff8240
	move.w	#$007,$ff8242
	move.w	#$702,$ff8244
	move.w	#$325,$ff8246
	move.w	#$632,$ff8248
	move.w	#$217,$ff824a
	move.w	#$136,$ff824c
	move.w	#$004,$ff824e		
	move.w	#$553,$ff8250
	move.w	#$453,$ff8252
	move.w	#$442,$ff8254
	move.w	#$432,$ff8256
	move.w	#$222,$ff8258
	move.w	#$333,$ff825a
	move.w	#$237,$ff825c
	move.w	#$777,$ff825e
init
	move.l	$70,savevbl
	MOVE.L #VBLHAND,$70
laddany
	lea	scrolline,a0	
	move.l	a0,store	
nytext:
	move.l	store,a0
	move.l	(a0)+,d2
	move.l	a0,store	
	cmp.w	#-1,d2		
	beq	laddany
	move.l	d2,text
	
	move.b	#0,d4
	move.w	#0,wfnc
loop:
	cmp.w	#1,wfnc		
	bne.w	loop
	move.w	#0,wfnc

	jsr 	shifter
pp
	cmp.l	#0,d4
	beq	nytext

	cmp.b	#185,$fffffc02.w
	bne	loop
EXIT	
	                         
	move.l	savevbl,$70
	move.w	old_res,-(sp)
	move.l	old_screen,-(sp)
	move.l	old_screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp		
	
	move.w	#$777,$ff8240		                                                   
	move.w	#$000,$ff8246
	move.w	#$000,$ff8244

	MOVE.L	savesst,-(SP)
	MOVE.W	#$20,-(SP)	
 	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR.W -(A7)
	TRAP #1

nolla_d4:
	move.l	#0,d4
	rts
shifter:
	move.l	text,a0
	add.l	d4,a0		
	move.l	screen,a1	
	ADD.L	#11200,A1
				
loop1:	
	rept	14
	move.b	1(a1),(a1)	 

	move.b	8+480(a1),1(a1)	
	move.b	9+480(a1),8+480(a1)

	move.b	16+960(a1),9+480(a1)
	move.b	17+960(a1),16+960(a1)

	move.b	24+1440(a1),17+960(a1)
	move.b	25+1440(a1),24+1440(a1)

	move.b	32+1920(a1),25+1440(a1)
	move.b	33+1920(a1),32+1920(a1)

	move.b	40+2400(a1),33+1920(a1)
	move.b	41+2400(a1),40+2400(a1)

	move.b	48+2880(a1),41+2400(a1)
	move.b	49+2880(a1),48+2880(a1)

	move.b	56+3360(a1),49+2880(a1)
	move.b	57+3360(a1),56+3360(a1)

	move.b	64+3840(a1),57+3360(a1)
	move.b	65+3840(a1),64+3840(a1)

	move.b	72+4320(a1),65+3840(a1)
	move.b	73+4320(a1),72+4320(a1)

	move.b	80+4800(a1),73+4320(a1)
	move.b	81+4800(a1),80+4800(a1)		
						;èTERGè HéR
	move.b	88+4320(a1),81+4800(a1)
	move.b	89+4320(a1),88+4320(a1)

	move.b	96+3840(a1),89+4320(a1)
	move.b	97+3840(a1),96+3840(a1)

	move.b	104+3360(a1),97+3840(a1)
	move.b	105+3360(a1),104+3360(a1)

	move.b	112+2880(a1),105+3360(a1)
	move.b	113+2880(a1),112+2880(a1)

	move.b	120+2400(a1),113+2880(a1)
	move.b	121+2400(a1),120+2400(a1)

	move.b	128+1920(a1),121+2400(a1)
	move.b	129+1920(a1),128+1920(a1)

	move.b	136+1440(a1),129+1920(a1)
	move.b	137+1440(a1),136+1440(a1)

	move.b	144+960(a1),137+1440(a1)
	move.b	145+960(a1),144+960(a1)

	move.b	152+480(a1),145+960(a1)
	move.b	153+480(a1),152+480(a1)
	move.b	(a0),153+480(a1)
	adda.l	#160,a1
	adda.l	#2,a0
	endr
	add.l	#1,d4
	add.l	d4,a0
	cmp.l	#2,d4
	beq	rensa_d4

	rts
rensa_d4:
	move.l	#0,d4
	jmp 	pp

savepal:
	dc.l	1
wfnc:
	dc.w	1
screen:
	ds.l	1	
savesst:
	ds.l	1
savevbl:	
	ds.l	1
shiftscreen:
	dc.l	1

store:
	ds.l	1
a_buffer:
	ds.l	1400
scrolline:
	dc.l	H,E,L,L,O,ô,G,U,Y,S,ô,ô,T,H,I,S,ô,I,S,ô,M,A,Z,E,ô,O,F,ô,ô,T,N,L,ô,ô
	DC.L	S,P,E,A,K,I,N,G,ô,ô,W,H,A,T,ô,D,O,ô,Y,O,U,ô,T,H,I,N,K,ô,A,B,O,U,T,ô
	DC.L	M,Y,ô,B,Y,T,E,B,E,N,D,E,R,_,_,_,_,_,_,_
	DC.L	ô,ô,ô,ô,ô,-1
tabbuf_a0:
	dc.l	1
tecken:
	ds.l	1
text:
	ds.l	1	
old_screen
	dc.l	0
old_res
	dc.w	0
VBLHAND
	move.w	#1,wfnc
	RTE


ê:		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000


A:		dc.w	$03C0,$07E0
		dc.w	$0FF0,$1FF8
		dc.w	$3E7C,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3FFC,$3FFC
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$1818



B:		dc.w	$1FF0,$3FF8
		dc.w	$3E7C,$3C3C
		dc.w	$3C3C,$3E78
		dc.w	$3FF0,$3FF0
		dc.w	$3E78,$3C3C
		dc.w	$3C3C,$3E7C
		dc.w	$3FF8,$1FE0



C:		dc.w	$0FF0,$1FF8
		dc.w	$3E3C,$3C18
		dc.w	$3C00,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C18,$3E3C
		dc.w	$1FF8,$0FF0



D:		dc.w	$3F80,$7FC0
		dc.w	$79E0,$78F0
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$78F0,$79E0
		dc.w	$7FC0,$3F80



E:		dc.w	$3FF0,$7FF8
		dc.w	$7C00,$7800
		dc.w	$7800,$7C00
		dc.w	$7FC0,$7FE0
		dc.w	$7C00,$7800
		dc.w	$7800,$7C00
		dc.w	$7FF8,$3FF0



F:		dc.w	$3FF0,$7FF8
		dc.w	$7C00,$7800
		dc.w	$7800,$7C00
		dc.w	$7FC0,$7FE0
		dc.w	$7C00,$7800
		dc.w	$7800,$7800
		dc.w	$7800,$3000
	


G:		dc.w	$1FF0,$3FF8
		dc.w	$7C00,$7800
		dc.w	$7800,$7800
		dc.w	$79F0,$79F8
		dc.w	$78F8,$7878
		dc.w	$7878,$7CF8
		dc.w	$3FF8,$1FF0



H:		dc.w	$3030,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7FF8
		dc.w	$7FF8,$7FF8
		dc.w	$7CF8,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$3030

I:		dc.w	$1F80,$3FC0
		dc.w	$1F80,$0F00
		dc.w	$0F00,$0F00
		dc.w	$0F00,$0F00
		dc.w	$0F00,$0F00
		dc.w	$0F00,$1F80
		dc.w	$3FC0,$1F80


J:		dc.w	$0030,$0078
		dc.w	$0078,$0078
		dc.w	$0078,$0078
		dc.w	$0078,$0078
		dc.w	$0078,$0078
		dc.w	$3878,$7CF8
		dc.w	$3FF0,$1FE0


K:		dc.w	$181C,$1C38
		dc.w	$1C70,$1EE0
		dc.w	$1FC0,$1F80
		dc.w	$1F80,$1F80
		dc.w	$1FC0,$1FE0
		dc.w	$1EF0,$1C78
		dc.w	$1C3C,$181C


L:		dc.w	$1800,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C00,$3E00
		dc.w	$3FFC,$1FF8


M:		dc.w	$701C,$F83C
		dc.w	$FC7C,$FEFC
		dc.w	$FFFC,$FFFC
		dc.w	$F7BC,$F33C
		dc.w	$F03C,$F03C
		dc.w	$F03C,$F03C
		dc.w	$F03C,$6018


N:		dc.w	$6060,$F0F0
		dc.w	$F8F0,$FCF0
		dc.w	$FEF0,$FFF0
		dc.w	$FFF0,$FFF0
		dc.w	$F3F0,$F1F0
		dc.w	$F0F0,$F0F0
		dc.w	$F0F0,$6060


O:		dc.w	$1FE0,$3FF0
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$3FF0,$1FE0


P:		dc.w	$1FF0,$3FF8
		dc.w	$3E78,$3C3C
		dc.w	$3C3C,$3E78
		dc.w	$3FF8,$3FF0
		dc.w	$3E00,$3C00
		dc.w	$3C00,$3C00
		dc.w	$3C00,$1800


Q:		dc.w	$1FE0,$3FF0
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7E78,$7F78
		dc.w	$79F0,$78E0
		dc.w	$3F70,$1F38


R:		dc.w	$1FF0,$3FF8
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3FF8,$3FF0
		dc.w	$3CF0,$3C78
		dc.w	$3C3C,$3C1C
		dc.w	$3C1C,$1818


S:		dc.w	$1FE0,$3FF0
		dc.w	$7C78,$7878
		dc.w	$7800,$7800
		dc.w	$3FE0,$1FF0
		dc.w	$0078,$0078
		dc.w	$7878,$7878
		dc.w	$3FF0,$1FE0


T:		dc.w	$3FFC,$1FF8
		dc.w	$07E0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$0180



U:		dc.w	$1818,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$3E7C
		dc.w	$1FFC,$0FF8


V:		dc.w	$3030,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7878
		dc.w	$7878,$7CF0
		dc.w	$1FE0,$0FC0
		dc.w	$0780,$0380


W:		dc.w	$1806,$3C0F
		dc.w	$3C0F,$3C0F
		dc.w	$3C0F,$3CCF
		dc.w	$3DEF,$3DEF
		dc.w	$3FFF,$3FFF
		dc.w	$3F3F,$3E1F
		dc.w	$3C0F,$1C0E


X:		dc.w	$1818,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$0FF0,$07E0
		dc.w	$03C0,$03C0
		dc.w	$07E0,$0FF0
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$1818


Y:		dc.w	$1818,$3C3C
		dc.w	$3C3C,$3C3C
		dc.w	$3C3C,$1E78
		dc.w	$0FF0,$07E0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$0180


Z:		dc.w	$1FF8,$3FFC
		dc.w	$003C,$003C
		dc.w	$0078,$00F0
		dc.w	$01E0,$03C0
		dc.w	$0780,$0F00
		dc.w	$1C00,$3C00
		dc.w	$3FFC,$1FF8


è:		dc.w	$03C0,$03C0
		dc.w	$0000,$0000
		dc.w	$03C0,$03C0
		dc.w	$0FF0,$0FF0
		dc.w	$3C3C,$3C3C
		dc.w	$3FFC,$3FFC
		dc.w	$3C3C,$3C3C


 é:		dc.w	$3C3C,$3C3C
		dc.w	$0000,$0000
		dc.w	$03C0,$03C0
		dc.w	$0FF0,$0FF0
		dc.w	$3C3C,$3C3C
		dc.w	$3FFC,$3FFC
		dc.w	$3C3C,$3C3C


ô:		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000


ö:		dc.w	$0FF0,$0FF0
		dc.w	$3C3C,$3C3C
		dc.w	$003C,$003C
		dc.w	$00F0,$00F0
		dc.w	$03C0,$03C0
		dc.w	$0000,$0000
		dc.w	$03C0,$03C0



_		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$03C0,$03C0
		dc.w	$0000,$0000
		dc.w	$03C0,$03C0
