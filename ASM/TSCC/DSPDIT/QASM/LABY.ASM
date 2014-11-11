;
;TABSIZE = 12
;
; laby avec murs mapp‚s
;


RESET	equ	0
STACK	equ	2
TRACE	equ	4
SWI	equ	6
IRQA	equ	8
IRQB	equ	$a
SSIR	equ	$c
SSIRE	equ	$e
SSIT	equ	$10
SSITE	equ	$12
SCIR	equ	$14
SCIRE	equ	$16
SCIT	equ	$18
SCII	equ	$1a
SCITI	equ	$1c
RESH	equ	$1e
HRD	equ	$20
HTD	equ	$22
HTC	equ	$24
HUC0	equ	$26
HUC1	equ	$28
HUC2	equ	$2a
HUC3	equ	$2c
HUC4	equ	$2e
HUC5	equ	$30
HUC6	equ	$32
HUC7	equ	$34
HUC8	equ	$36
HUC9	equ	$38
HUC0	equ	$3a
HUC0	equ	$3c
ILLEGAL	equ	$3e


PBC	EQU	$ffe0	;Port B Control register
PCC	EQU	$ffe1	;Port C Control register
PBDDR	EQU	$ffe2	;Port B Data Direction Register
PCDDR	EQU	$ffe3	;Port C Data Direction Register
PBD	EQU	$ffe4	;Port B Data register
PCD	EQU	$ffe5	;Port C Data register
HCR	EQU	$ffe8	;Host Control Register
HSR	EQU	$ffe9	;Host Status Register
HRX	EQU	$ffeb	;Host Receive Register
HTX	EQU	$ffeb	;Host Transmit Register
CRA	EQU	$ffec	;SSI Control Register A
CRB	EQU	$ffed	;SSI Control Register B
SSISR	EQU	$ffee	;SSI Status Register
SSITSR	EQU	$ffee	;SSI Time Slot Register
RX	EQU	$ffef	;SSI Serial Receive data/shift register
TX	EQU	$ffef	;SSI Serial Transmit data/shift register
SCR	EQU	$fff0	;SCI Control Register
SSR	EQU	$fff1	;SCI Status Register
SCCR	EQU	$fff2	;SCI Clock Control Register
STXA	EQU	$fff3	;SCI Transmit data Address Register
SRX	EQU	$fff4	;SCI Receive data register (4-5-6)
STX	EQU	$fff4	;SCI Transmit data register (4-5-6)
BCR	EQU	$fffe	;Port A Bus Control Register
IPR	EQU	$ffff	;Interrupt Priority Register



srcX	EQU	64
srcY	EQU	64

destY	EQU	200

adjustx	EQU	125
adjusty	EQU	235


yy0	EQU	7
k	EQU	120
pers	EQU	48/20*0
alt	EQU	50



buf_size	EQU	49500/60*18/10



divss:	MACRO
	jclr	#23,a1,__pos
	neg	a
	andi	#$fe,ccr
	rep	#24
	div	x0,a
	move	a0,a1
	jset	#23,x0,__neg
	neg	a
	jmp	<__neg
__pos:	
	andi	#$fe,ccr
	rep	#24
	div	x0,a
	move	a0,a1
	jclr	#23,x0,__neg
	neg	a
__neg:	
	ENDM



MSend:	MACRO
__Send:	jclr	#1,X:<<HSR,__Send
	movep	\1,X:<<HTX
	ENDM

MGet:	MACRO
__Get:	jclr	#0,X:<<HSR,__Get
	movep	X:<<HRX,\1
	ENDM

MDivss:	MACRO
	tst	\2
	jge	<__pos
	;jclr	#23,\21,__pos
	neg	a
	andi	#$fe,ccr
	rep	#24
	div	\1,\2
	move	\20,\21
	jset	#23,\1,__neg
	neg	\2
	jmp	<__neg
__pos:	
	andi	#$fe,ccr
	rep	#24
	div	\1,\2
	move	\20,\21
	jclr	#23,\1,__neg
	neg	\2
__neg:	
	ENDM



MDivus:	MACRO
	tst	\2
	jge	<__pos
	;jclr	#23,\21,__pos
	neg	\2
	andi	#$fe,ccr
	rep	#24
	div	\1,\2
	move	\20,\2
	neg	\2
	jmp	<__neg
__pos:	
	andi	#$fe,ccr
	rep	#24
	div	\1,\2
	move	\20,\2
__neg:	
	ENDM

MDivuu:	MACRO
	andi	#$fe,ccr
	rep	#24
	div	\1,\2
	move	\20,\2
	ENDM






	ORG	x:28
datas2:	ds	10


	ORG	y:1
	

v1right:
v11:	ds	1
v1left:
v12:	ds	1
v1vol:	
v13:	ds	1
v1vit:	ds	1
v1depl:	ds	1
v1mb:	ds	1
v17:	ds	1

v2right:
v21:	ds	1
v2left:
v22:	ds	1
v2vol:	
v23:	ds	1
v2vit:	ds	1
v2depl:	ds	1
v2mb:	ds	1
v27:	ds	1

v3right:
v31:	ds	1
v3left:
v32:	ds	1
v3vol:	
v33:	ds	1
v3vit:	ds	1
v3depl:	ds	1
v3mb:	ds	1
v37:	ds	1

v4right:
v41:	ds	1
v4left:
v42:	ds	1
v4vol:	
v43:	ds	1
v4vit:	ds	1
v4depl:	ds	1
v4mb:	ds	1
nbb:	
v47:	ds	1

mr6:	ds	1








	ORG	P:RESET
	jmp	>$40
	
	ORG	P:SSIT
	movep	x:(r7)+,x:<<RX
	ORG	P:SSITE
	movep	x:(r7)+,x:<<RX
	


	ORG	P:$40
Main:
	jmp	<inits


	





sol:
	move	#>2,x0
	cmp	x0,a
	jne	<play_mod

	MGet	y:>posx0	;x deb
	MGet	y:>posz0	;y deb
	MGet	x:>Vposx	;Vx
	MGet	x:>Vposz	;Vz
	MGet	x:>yy	;y' fin
	MGet	x:>yy0	;y' deb

	clr	a
	move	a,x:>posx0b
	move	a,x:>posz0b
	MGet	n4	;nb de pixels … faire (car Vx,Vz,y' sont juste pour les calculs)
	
	move	x:>yy,x0
	move	x:>yy0,x1
	mpy	x0,x1,a
	move	a0,a
	move	a,x1
	
	move	x:>Vposx,x0
	mpy	x0,x1,a
	move	x:>yy0,b
	move	x:>yy,x0
	sub	x0,b
	move	b,x0
	MDivss	x0,a
	
	move	a0,a
	move	a,x:>dx
	

	move	x:>yy,x0
	move	x:>yy0,x1
	mpy	x0,x1,a
	move	a0,a
	move	a,x1
	
	move	x:>Vposz,x0
	mpy	x0,x1,a
	move	x:>yy0,b
	move	x:>yy,x0
	sub	x0,b
	move	b,x0
	MDivss	x0,a

	move	a0,a
	move	a,x:>dz
	
	move	#>img+srcX*srcY*01-$000,r2
	move	#>-1,m4
	move	#>destY+inc,b
	move	x:>yy0,y0
	sub	y0,b
	move	b,r4
	
	move	y:>posx0,y0
	move	#>$200000,y1
	mpy	y0,y1,b
	move	b,y:>posx0
	move	b0,x:>posx0b
	
	move	y:>posz0,y0
	move	#>$200000-1,y1
	mpy	y0,y1,b
	move	b,y:>posz0
	move	b0,x:>posz0b
	
	move	#>srcX-1,x1
	and	x1,b
	
	move	m4,m1
	move	#>const,r1
	move	#>4,n1
	move	#>const0,r6
	move	#>2,n6
	move	m4,m6

	
; X=X+Dx/(y+1)*y
; Z=Z+Dz/(y+1)*y
	do	n4,loop_sol
	
	move	b,x1	y:(r6)+,y0		;(#>srcX/2/1)
	
	mpy	y0,x1,b	x:(r1)+,x1	y:(r4),y0	;(x:>dx)
	
	mpy	y0,x1,a	b0,b
	move	x:(r1)+,x0	y:(r6)+,y1		;(#>srcX*srcY-1) ;(y:>posx0)
	add	y1,b	x:(r1),y0		;(x:>posx0b)
	and	x0,b	y:(r6)-,x1		;(y:>posz0)
	add	y,a	b,n2
	move	a0,x:(r1)+			;(x:>posx0b)
	
	move	x:(r1)+,x0	y:(r4)+,y0		;(x:>dz)
	mpy	y0,x0,b	x:(r1)+,x0	a,y:(r6)+	;(x:>posz0b) ;(y:>posx0)
	add	x,b	x:(r1)-,x0		;(#>(srcX-1)*1)
	and	x0,b	b,y:(r6)-n6		;(y:>posz0)
	move	b0,x:(r1)-n1		;(x:>posz0b)
	MSend	y:(r2+n2)
	
	
loop_sol:


	jmp	<new_one






play_mod:
	jsr	<play
	jmp	<new_one


play:
	;MSend	a
	move	y:>mr6,r6
	movec	#>buf_size*2,m6

	;bset	#3,X:<<PCD



	move	r7,b
	move	#>-2,x0
	and	x0,b	r6,x0
	sub	x0,b	;b,r7
	jge	<_pos
	move	#>buf_size*2,x0
	add	x0,b
_pos:	
	lsr	b
	move	b,y:<nbb
	move	r6,r5
	
	move	#>spl1,r0
	move	#<v1vol,r1
	jsr	<recoit_x
	
	move	#>spl2,r0
	move	#<v2vol,r1
	jsr	<recoit_x
	
	move	#>spl3,r0
	move	#<v3vol,r1
	jsr	<recoit_x
	
	move	#>spl4,r0
	move	#<v4vol,r1
	jsr	<recoit_x
	
	clr	a
	MSend	a
	;clr	a
	;move	a,y:<v5vol
	
	;bclr	#3,X:<<PCD
	
	
	move	#>2,n6

	move	y:<nbb,a
	tst	a
	jeq	<end_play_mod
	
	move	#>$3fffff,y1

	move	y:<v1vol,a
	tst	a
	jeq	<no_play1

	move	#>spl1,r0
	move	y:<v1mb,b
	move	y:<v1vit,x0
	move	x:(r0)+,y0
	
	move	#>_loop1a,r1
	move	y:<nbb,x1
	do	x1,>_loop1
	add	x0,b
	jec	(r1)
	and	y1,b	x:(r0)+,y0
_loop1a:
	move	y0,x:(r6)+n6
_loop1:
	move	b,y:<v1mb
	move	r0,b
	move	#>spl1+1,x0
	sub	x0,b
	move	b,y:<v1depl
	jmp	>no_play1b
no_play1:

	clr	a
	move	y:<nbb,x1
	do	x1,>_loop1
	move	a,x:(r6)+n6
_loop1:
	
	move	y:<nbb,x0
	move	y:<v1vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,y:<v1depl
no_play1b:	



	move	y:<v2vol,a
	tst	a
	jeq	<no_play2
	move	r5,r6
	move	#>spl2,r0
	move	y:<v2mb,b
	move	y:<v2vit,x0
	move	x:(r0)+,y0
	move	(r6)+
	
	move	#>_loop2a,r1
	move	y:<nbb,x1
	do	x1,>_loop2
	add	x0,b
	jec	(r1)
	and	y1,b	x:(r0)+,y0
_loop2a:
	move	y0,x:(r6)+n6
_loop2:
	move	b,y:<v2mb
	move	r0,b
	move	#>spl2+1,x0
	sub	x0,b
	move	b,y:<v2depl
	move	(r6)-
	jmp	no_play2b
no_play2:
	move	r5,r6
	clr	a
	move	(r6)+
	move	y:<nbb,x1
	do	x1,>_loop1
	move	a,x:(r6)+n6
_loop1:
	move	(r6)-

	move	y:<nbb,x0
	move	y:<v2vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,y:<v2depl
no_play2b:
	

	move	y:<v3vol,a
	tst	a
	jeq	<no_play3
	move	r5,r6
	move	#>spl3,r0
	move	y:<v3mb,b
	move	y:<v3vit,x0
	move	x:(r0)+,y0
	move	(r6)+
	
	move	#>_loop3a,r1
	move	y:<nbb,x1
	do	x1,>_loop3
	add	x0,b
	jec	(r1)
	and	y1,b	x:(r0)+,y0
_loop3a:
	move	x:(r6),a
	add	y0,a
	move	a,x:(r6)+n6
_loop3:
	move	b,y:<v3mb
	move	r0,b
	move	#>spl3+1,x0
	sub	x0,b
	move	b,y:<v3depl
	move	(r6)-
	jmp	<no_play3b
no_play3:
	move	y:<nbb,x0
	move	y:<v3vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,y:<v3depl
no_play3b:	

	
	move	y:<v4vol,a
	tst	a
	jeq	<no_play4
	move	r5,r6
	move	#>spl4,r0
	move	y:<v4mb,b
	move	y:<v4vit,x0
	move	x:(r0)+,y0
	
	move	#>_loop4a,r1
	move	y:<nbb,x1
	do	x1,>_loop4
	add	x0,b
	jec	(r1)
	and	y1,b	x:(r0)+,y0
_loop4a:
	move	x:(r6),a
	add	y0,a
	move	a,x:(r6)+n6
_loop4:
	move	b,y:<v4mb
	move	r0,b
	move	#>spl4+1,x0
	sub	x0,b
	move	b,y:<v4depl
	jmp	<no_play4b
no_play4:
	move	y:<nbb,x0
	move	y:<v4vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,y:<v4depl
no_play4b:	


end_play_mod:
	move	r6,y:>mr6
	movec	#>-1,m6
	
	rts
	
	








recoit_x:	jclr	#0,x:<<HSR,>recoit_x
	movep	x:<<HRX,y1
	;move	#>$7fffff,x1
	move	y1,y:(r1)+		;v?vol
_wait:	jclr	#0,x:<<HSR,>_wait
	movep	x:<<HRX,x1
	move	x1,y:(r1)+		;v?4
	move	y:<nbb,x0
	mpy	x1,x0,b
_wait2:	jclr	#1,x:<<HSR,>_wait2
	movep	y:(r1),x:<<HRX	;v?5
_wait3:	jclr	#1,x:<<HSR,>_wait3
	movep	b,x:<<HRX

	move	y1,a
	tst	a
	jeq	<recoit_xf

_wait4:	jclr	#0,x:<<HSR,>_wait4
	movep	x:<<HRX,x0
	
	move	#>datas2,r2
	move	#>4,n2
	;move	#>$ff0000,a
	;move	a,x:(r2)+
	move	y1,x:(r2)+
	move	#>$00ff00,a
	move	a,x:(r2)+
	move	#>$80,a
	move	a,x:(r2)+
	move	#>$0000ff,a
	move	a,x:(r2)+
	move	#>$8000,a
	move	a,x:(r2)-n2
	

	do	x0,_loop
_wait5:	jclr	#0,x:<<HSR,>_wait5
	movep	x:<<HRX,b
	move	b,y0	x:(r2)+,x0	;vol
	mpyr	x0,y0,a	x:(r2)+,x1	;$00ff00
	tfr	b,a	a1,x:(r0)+
	and	x1,a	x:(r2)+,x0	;vol*$80
	move	a1,y0
	mpy	x0,y0,a	x:(r2)+,x1	;$0000ff
	move	a0,y0
	mpyr	y1,y0,a	x:(r2)-n2,x0 ;vol*$8000
	and	x1,b	a1,x:(r0)+
	move	b1,y0
	mpy	x0,y0,a
	move	a0,y0
	mpyr	y1,y0,a
	move	a1,x:(r0)+
_loop:
_wait6:	jclr	#1,x:<<HSR,>_wait6
	movep	b,x:<<HRX
recoit_xf:	rts


	
	

inits:
	movep	#>0,X:<<BCR
	movep	#>1,X:<<PBC
	move	#>buff,r6
	move	r6,r7		;133e
	movec	#>buf_size*2,m6
	movec	m6,m7
	clr	a
	move	#>buf_size*2+10,x0
	rep	x0
	move	a,x:(r6)+

	move	r6,y:>mr6
	movec	#>-1,m6



	movep	#>$3000,X:<<IPR
	movep	#>$4100,X:<<CRA
	movep	#>$5800,X:<<CRB
	movep	#>$1f0,X:<<PCC
	movep	#>$8,X:<<PCDDR
	andi	#<$fc,mr



_hello:
	movep	#>$1,X:<<PBC
	jclr	#0,X:<<HSR,_hello
	movep	X:<<HRX,a
	move	#>$FEED,x1
	cmp	x1,a
	jne	_hello
	
	MSend	#>$123456

	move	#$ffff,m2
	move	#>img,r2
	do	#64*5,_loop1
	do	#64,_loop2
	MGet	P:(r2)+
	nop
_loop2:	
	nop
_loop1:


	move	#>-1,m3
	move	#>inc,r3
	
	
	move	#>destY,b
	move	#>1,y0
	do	#destY-1,_minc
	move	b,x0
	sub	y0,b
	move	b,x1
	mpy	x0,x1,a
	move	a0,a
	lsl	a
	lsl	a
	move	a,x1
	move	#>1,a
	MDivss	x1,a
	move	a0,a
	move	a,Y:(r3)+
	;MSend	a0
_minc:	
	





	

	
	MSend	#>$123456





	IFNE 0
	movep	#>$3000,X:<<IPR
	move	#>5,n6
	move	#>buf_size*2,m6
	clr	a
	move	r7,r6
	move	(r6)+n6
	move	#>buf_size*4,x0
	do	x0,>_loop
	move	a,x:(r6)+
_loop:
	movec	#>-1,m6
	ENDC
	

	clr	a
	move	a,y:<v1mb
	move	a,y:<v1depl
	move	a,y:<v2mb
	move	a,y:<v2depl
	move	a,y:<v3mb
	move	a,y:<v3depl
	move	a,y:<v4mb
	move	a,y:<v4depl
	move	a,y:<v11
	move	a,y:<v12
	move	a,y:<v21
	move	a,y:<v22
	move	a,y:<v31
	move	a,y:<v32
	move	a,y:<v41
	move	a,y:<v42



	IFNE 0
	move	y:>mr6,r6
	move	r7,b
	move	r6,x0
	sub	x0,b	;b,r7
	jge	<_pos
	move	(r6)+
	
_pos:	
	move	r6,x0
	move	r7,x1
	jclr	#0,x0,>_ici0
	jset	#0,x1,>_ici
	move	(r6)+
	jmp	>_ici
_ici0:
	jset	#0,x0,>_ici
	jclr	#0,x1,>_ici
	move	(r6)+
_ici:

	move	r7,b
	move	r7,b
	move	#>1,x0
	and	x0,b
	move	#>buff,x0
	or	x0,b
	move	b,r7
	move	#>buff,r6
	move	b,y:>mr6
	
	ENDC




	move	#>$ffff,m0
	move	m0,m1
	move	m0,m2
	move	m0,m3
	move	m0,m4
	move	m0,m5
	move	m0,m6

new_one:
	MGet	a
	MSend	a
	tst	a
	jne	index
	
	MGet	x0	;longueur de la ligne / 2
	move	x0,y1
	clr	a
	move	#>64*$1000/2,a0
	MDivuu	x0,a
	move	a,x0
	move	#>$1000,x1
	mpy	x0,x1,a

	MGet	b	;adresse de la ligne du bloc … traiter
	move	#>img,y0
	add	y0,b
	move	b,r2
	
	MGet	y0	;longueur de ligne, une fois clipp‚e
	move	y0,r6
	move	y1,b
	lsl	b
	sub	y0,b
	lsr	b
	move	b,y0
		
	mpy	x0,y0,b
	move	b0,x0
	move	#>$1000/2,x1	;/2 pour compenser la multiplication
	mpy	x0,x1,b


		
	MGet	y1	;intensit‚ lumineuse
	
	;clr	b
	move	a0,x0
	move	a,x1
	move	b,n2
	do	r6,loop
	add	x,b
	move	P:(r2+n2),a
	add	y1,a	b,n2
	MSend	a
loop:
	jmp	<new_one





index:	
	move	#>1,x0
	cmp	x0,a
	jne	<sol
	
	MGet	x0	;longueur de la ligne / 2
	move	x0,y1
	clr	a
	move	#>128*$1000/2,a0
	MDivuu	x0,a
	move	a,x0
	move	#>$1000,x1
	mpy	x0,x1,a

	MGet	b	;adresse de la ligne du bloc … traiter
	move	#>img,y0
	add	y0,b
	move	b,r2
	
	MGet	y0	;longueur de ligne, une fois clipp‚e
	move	y0,r6
	move	y1,b
	lsl	b
	sub	y0,b
	lsr	b
	move	b,y0
		
	mpy	x0,y0,b
	move	b0,x0
	move	#>$1000/2,x1	;/2 pour compenser la multiplication
	mpy	x0,x1,b


		
	MGet	y1	;intensit‚ lumineuse
	
	;clr	b
	;asr	a
	move	a0,x0
	move	a,x1
	do	r6,_loop
	;move	b,y0
	;move	#>128,y1
	;mpy	y0,y1,a
	move	b,a
	lsl	a
	MSend	a
	add	x,b
_loop:
	jmp	<new_one





const0:	dc	srcX/2/1
posx0:	ds	1
posz0:	ds	1
inc:	ds	destY
valx:	ds	1
deca:	ds	1
masque:	dc	$fff

img:	ds	64*64*4*5

ici:
	;ORG	X:(ici-$4000)
	ORG	x:$2000
const:
dx:	ds	1
	dc	srcX*srcY-1
;posx0:	ds	1
posx0b:	ds	1
dz:	ds	1
posz0b:	ds	1
	dc	(srcX-1)*1

Vposx:	ds	1
Vposz:	ds	1
yy:	ds	1
yy0:	ds	1

	
spl1:	ds	1200
spl2:	ds	1200
spl3:	ds	1200
spl4:	ds	1200
	ORG	X:$3000
buff:	ds	buf_size*2+10

	END	Main		; Program begins at 'Main'

