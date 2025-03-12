PBC		equ	$ffe0
HSR		equ	$ffe9
HTRX	equ	$ffeb
;x:

POSX	equ	$0		;Weltposition
POSY	equ	$1
ALPHA	equ	$2		;Drehwinkel
MOVER	equ	$3
XDISTAUGE equ	$4	;auge*streckungsfaktor
XRES2	equ	$5		;X-Aufloesung/2
XB1		equ	$6		;Xposition (Bildschirm) der linken Wandkante
XB2		equ	$7		;Xposition der rechten Wandkante
XBDELTA	equ	$8		;Delta am Bildschirm
YB1		equ	$9		;Hoehen der Wandkanten (Bildschirm)
YB2		equ	$A
YBDELTA	equ	$B		;yb2-yb1
ZDELTA	equ	$C		;z2-z1
KXBDELTA equ $D	;1/XBDELTA
ZK		equ	$E
XK		equ	$F
ZXD		equ	$10		;zdelta/xbdelta*2^10
YXD		equ	$11		;ybdelta/xbdelta*2^10
TXD		equ	$12		;texturesize/xbdelta*2^10
XRES	equ	$13		;X-Aufloesung/2
TXADR	equ	$14		;Textureadr
YB1MUL	equ	$15		;YB1*2^10
Z1		equ	$16
FELD	equ	$200	;15*15 Bloecke : 16 Flaechenpnter ($e10)
ZBUFFER	equ	$1020	;$140
SEND_DATA	equ	$1160	;Daten zum verschicken
;y:
XBRES	equ	$0		;Bildschirmaufloesung
COSA	equ	$1
SINA	equ	$2
WALLS	equ	$600		;walls ($1f40)
SAVEPUFFER	equ	$2540	;x1,y1,x2,y2,t,ts ($10)
INFOPUFFER	equ	$2550	;textureadr,H”he ($280)
;************************************************************
	org	p:$0
	jmp	start
;************************************************************
	org	p:$40
start:
;Init all
	AND		#$F3,mr		;no scaling
	movep	#$000001,x:PBC
	bset	#2,omr
	move	#>128,x0
	move	x0,x:POSX
	move	#>128,x0
	move	x0,x:POSY
	move	#>320,x0
	move	x0,x:XRES
	move	#>320/2,x0
	move	x0,x:XRES2
main_loop:	
	jsr		read_data			;Get new postion
	move	x1,x:ALPHA
	jsr		read_data
	move	x1,x:MOVER

	jsr		read_data			;Get number of lines
	move	x1,x:XRES
	move	x1,a
	asr		a
	move	a1,x:XRES2
	jsr		make_move
	move	x:POSX,x1
	jsr		send_data
	move	x:POSY,x1
	jsr		send_data
	jsr		doom
		
	jsr		send_wall_data
	jmp		main_loop
;************************************************************
make_move:
	move	x:ALPHA,n0
	move	#>$100,r0		;Sintab
	move	#$ffff,m0			;Modifier
	nop
	move	y:(r0+n0),y0
	move	y0,y:SINA

	move	x:ALPHA,a
	move	#>$40,x0
	add		x0,a
	move	#>$ff,x0
	and		x0,a
	move	a1,n0
	nop
	move	y:(r0+n0),y0
	move	y0,y:COSA

;Berechne neu Position !
	move	x:MOVER,x0
	move	y:SINA,y0
	move	x:POSX,a
	mac		x0,y0,a
	move	a1,x:POSX
	move	y:COSA,y0
	move	x:POSY,a
	mac		x0,y0,a
	move	a1,x:POSY
	rts
;************************************************************
;r0=Walls
;r1=Feld
;r2=ZBuffer
;r4=savepuffer
AUGABSTAND	equ	64
AUGHEIGHT	equ	AUGABSTAND*128		;128=Texturehoehe
doom:
	move	#>ZBUFFER,r1
	move	#>INFOPUFFER,r2
	move	#>0,x0
	do		#320,cls_loop
	move	x0,x:(r1)+
	move	x0,y:(r2)+
	move	x0,y:(r2)+
cls_loop:
	move	#>FELD,r1			;Feld (y)
	move	#>ZBUFFER,r2

;	do		#3600,feld_loop		;gehe das Feld durch
	do		#4,feld_loop		;gehe das Feld durch

	move	#>SAVEPUFFER,r4
	
	move	x:(r1)+,x0			;get WandNr
	move	x0,a
	tst		a
	jeq		feld_loop					;next elem
	move	#>$8,x1			;elem*8
	mpy		x1,x0,a				;get adr of Wall
	asr		a
	move	a0,x0
	move	x0,a
	move	#>WALLS,x0
	add		x0,a  			;Adresse der Waende (x)
	move	a1,r0
	nop

	move	x:POSX,a
	move	y:(r0)+,x0
	sub		x0,a
	move	a1,x0					;wallx-posx
	move	x:POSY,a
	move	y:(r0)+,y0		;wally-posy
	sub		y0,a
	move	a1,y0  
	move	y:COSA,x1
	mpy		x0,x1,a	 y:SINA,y1
	mpy		x0,y1,b  
	mac		-y0,y1,a
	mac		y0,x1,b	
;	asr		a
;	asr		b
	move	a1,y:(r4)+	;save x1
	move	b1,y:(r4)+		;z<0 ?
	tst		b	
	jmi		z1minus

	move	x:POSX,a
	move	y:(r0)+,x0
	sub		x0,a 
	move	a1,x0
	move	x:POSY,a
	move	y:(r0)+,y0
	sub		y0,a 
	move	a1,y0
	mpy		x0,x1,a
	mpy		x0,y1,b
	mac		-y0,y1,a
	mac		y0,x1,b	
;	asr		a
;	asr		b
backrotate:
	move	a1,y:(r4)+
	move	b1,y:(r4)+			
	move	y:(r0)+,x0
	move	x0,y:(r4)+		;save texturesize
	move	y:(r0)+,x0
	move	x0,y:(r4)+		;save textureadr
	
	;Berechne x(1,2)-Bildschirm 
	move	#>SAVEPUFFER,r4

;x*a/(z+a)*xdist (Vergroeserungsfakor (je nach Aufl”sung))
	move	x:XDISTAUGE,y1		;xdist*auge=Y1
	move	y:(r4)+,y0		;x1*a
	mpy		y1,y0,a	
	move	#>AUGABSTAND,b
	move	y:(r4)+,x0		;z1+a
	move	x0,x:Z1
	add		x0,b
	move	b1,x0
	move	x0,y0			;save z1+a in y0
	jsr		full_div			;(x*a)/(z+a)=X1
	move	x1,x:XB1
	
	move	#>AUGHEIGHT,a	;Hoehe berechnen (a*128/(z1+a))
	move	y0,x0
	jsr		full_div
	move	x1,x:YB1		;save H”he YB1
	move	y0,x:ZDELTA
	
	move	y:(r4)+,y0		;x2*a
	mpy		y1,y0,a	
	move	#>AUGABSTAND,b
	move	y:(r4)+,x0 		;z2+a
	add		x0,b
	move	b1,x0
	move	x0,y0			;save z1+a in y0
	jsr		full_div			;(x*a)/(z+a)=X1
	move	x1,x:XB2
	
	move	#>AUGHEIGHT,a	;Hoehe berechnen (a*128/(z2+a))
	move	y0,x0
	jsr		full_div
	move	x1,x:YB2		;save H”he YB2
	move	y0,a
	move	x:ZDELTA,y0
	sub		y0,a	
	move	a1,x:ZDELTA		;zb2-zb1
	
	move	x:XB2,a
	move	x:XB1,y0	;rechts-links (XB2-XB1)
	sub		y0,a
	jmi		wrong_direction		;Wand KANN NICHT sichtbar sein (pfeil nach links :)
	move	a1,x:XBDELTA
	
	move	a1,x0
	move	#$400,a				;2^10/XBDELTA
	jsr		full_div
	move	x1,x:KXBDELTA

	move	x:ZDELTA,y0	;zdelta/xbdelta*2^10
	mpy		x1,y0,a
	asr		a
	move	a0,x:ZXD
	
	move	x:YB2,a
	sub		y0,a	x:YB1,y0	;rechts-links (YB2-YB1)
	move	a1,x:YBDELTA
	move	#>$400,y1
	mpy		y0,y1,a	 	;YB1*2^10
	asr		a
	move	a0,x:YB1MUL

	move	a0,y0
	mpy		x1,y0,b			;ybdelta/xbdelta*2^10
	asr		b
	move	b1,x:YXD

	move	y:(r4)+,y0		;texturesize/xbdelta*2^10(texturehoehe)
	mpy		x1,y0,b
	asr		b
	move	b0,x:TXD
	move	y:(r4)+,y0
	move	y0,x:TXADR
	
	move	x:XRES2,a
	move	x:XB1,y0		;Berechne Position im Zbuffer
	add		y0,a

	move	#$0,x0
	move	x0,x:XK
;Berechne: 
	do		x:XBDELTA,xloop		;gehe alle x punkte durch

;Berechne Z Position
	move	x:XK,x0				;x0<-xk
	move	x:ZXD,y0		;zdelta/xbdelta*x
	mpy		x0,y0,a
	asr		a
	move	a,x1
	move	x1,a
	move	x:Z1,x1
	add		x1,a
	jmi		forget_line			;z<0
;Berechne xpos in Zbuffer (z->b)
	move	x:XBDELTA,b
	move	x:XK,x1
	add		x1,b
	jmi		forget_line			;x<0
	move	x:XRES,x1	;x>XRES ??
	cmp		x1,b
	jpl		forget_line
	move	x1,n2				;x1=ZBUffer Offset
	move	x:(r2+n2),y0	;Neue Wand n„her ?? (neue-alte<0?)
	cmp		y0,a
	jpl		forget_line
	move	a1,x:(r2+n2)		;neuen wert einbauen
;Berechne textureadresse
	move	x1,a
	lsl		a #>INFOPUFFER,y0		;2*x+infopuffer
	add		y0,a	 		;hier kommts hin
	move	a1,r4
	move	x:TXD,x1
	mpy 	x0,x1,a  		;TXD/xbdelta*x
	rep		#4
	asr		a
	move	a0,x1
	move	x1,a 
	move	#>$ffff80,x1
	and		x1,a x:TXADR,x1	 
	add		x1,a	 		;Adresse
 
;Berechne H”he
	move	x:YXD,x1
	mpy		x0,x1,b	 	;ydelta/xbdelta*x
	asr		b
	move	b0,x1
	move	x1,b
	move 	x:XB1,x1
	add		x1,b	 	;+xb1
	move	b1,y:(r4)+			;save Hoehe
	move	a1,y:(r4)+			;save textadr
forget_line:
	move	x:XK,a				;x++
	move	#>1,x0
	add		x0,a	 
	move	a1,x:XK
xloop:
	nop
wrong_direction:
	nop
no_wall:
	nop
feld_loop:					;next elem
	nop
;now copy into send_data
	move	#>ZBUFFER,r1
	move	#>INFOPUFFER,r2
	move	#>SEND_DATA,r3
	move	#>0,x0
	do		x:XRES,make_send
	
	move	x:(r1)+,a
	rep		#6+10
	asr		a
	move	#>32,x0
	cmp		x0,a  
	jlt		z_color_ok
	move	x0,a
	move	#>0,x0
	move	x0,y:(r2)
z_color_ok
	rep		#16
	lsl		a				;Shift it high
	move	y:(r2)+,b		;YH”he!
	rep		#10
	asr		b
	rep		#6
	lsl		b
	move	b1,x0
	or		x0,a
	move	a1,x:(r3)+		;send z|Hoehe

	move	y:(r2)+,x0
	move	x0,y:(r3)+		;send textadr
	
make_send:

	rts
;Wall: x1,z1,x2,z2,texturesize,textureadr (68030adr)
;************************************************************
z1minus
	move	x:POSX,a
	sub		x0,a y:(r0)+,x0
	move	a1,x0
	move	x:POSY,a
	sub		y0,a y:(r0)+,y0
	move	a1,y0
	mpy		x0,x1,a
	mpy		x0,y1,b
	mac		-y0,y1,a
	mac		y0,x1,b
	tst		b
	jmi		no_wall
;	asr		a
;	asr		b
	jmp		backrotate

;************************************************************
;->a/x0
;<-x1
full_div:
	ABS A	A,B				;make dividend positive, copy A1 to B1
	EOR	X0,B				;save rem. sign in X:$0, quo. sign in N
	AND	#$FE,CCR			;clear carry bit C (quotient sign bit)
	REP	#$18				;form a 24-bit quotient
	DIV	X0,A				;form quotient in A0, remainder in A1
	TFR	A,B					;save quotient and remainder in B1,B0
	JPL	SAVEQUO				;go to SAVEQUO if quotient is positive
	NEG	B					;complement quotient if N bit set
SAVEQUO:
	TFR	X0,B	B0,X1		;save quo. in X1, get signed divisor
	rts
;************************************************************
send_wall_data:
	move	#>SEND_DATA,r1
	move	x:XRES,x1
send_wall_nr:
	jclr	#1,x:HSR,send_wall_nr
	movep	x1,x:HTRX

	do		x1,send_wall_loop
	move	x:(r1)+,y0
	move	x:(r1)+,y1
wall_data1:
	jclr	#1,x:HSR,wall_data1
	movep	y0,x:HTRX
wall_data2:
	jclr	#1,x:HSR,wall_data2
	movep	y1,x:HTRX
send_wall_loop:	
	nop
	rts
;************************************************************
send_data
	jclr	#1,x:HSR,send_data	;send data
	movep	x1,x:HTRX	
	rts
read_data
	jclr	#0,x:HSR,read_data	;read data
	movep	x:HTRX,x1
	rts
;************************************************************
;Datenbereich !!!!!!!
	org	x:FELD
	dc	1,2,3,4
;Wall: x1,z1,x2,z2,texturesize,textureadr (68030adr)
	org	y:WALLS	
	dc	0,0,0,0,0,0,0,0
 	dc	0,0,256,0,128,1,0,0
 	dc	0,0,0,256,128,1,0,0
 	dc	256,0,256,256,128,1,0,0
 	dc	0,256,256,256,128,1,0,0
