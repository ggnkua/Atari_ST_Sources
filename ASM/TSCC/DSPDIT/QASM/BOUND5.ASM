;
;TABSIZE = 12
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


ecrX	EQU	320
ecrY	EQU	200
destX	EQU	320-40
destY	EQU	120
worldX	EQU	8192*2
worldY	EQU	4096*2
blocX	EQU	128
blocY	EQU	128
wX	EQU	worldX/blocX
wY	EQU	worldY/blocY
part1	EQU	10
part2	EQU	26
part3	EQU	destY-part1-part2
part3a	EQU	part3/4
part3b	EQU	part3/2-part3a

destZ	EQU	40


yy0	EQU	5
k	EQU	270	;150
ppers	EQU	25	;2

adjustx	EQU	205	;200
adjusty	EQU	220	;200
inc_alt	EQU	17

alt	EQU	8*20+inc_alt*10

cx	EQU	destX/2
cy	EQU	200-destY
ty	EQU	201

ambiante	EQU	100	;65

persx	EQU	0
persy	EQU	-17*256/10
pers	EQU	300
prs	EQU	230	;256
p2rs	EQU	pers-50
maxy	EQU	50000
pre	EQU	2
distg	EQU	640*16
dming1	EQU	-1400*16
dming0	EQU	dming1-distg
dming	EQU	dming0*dming0/$800000+$200000
dmaxg1	EQU	1800*16	;25
dmaxg0	EQU	dmaxg1-distg
dmaxg	EQU	-dmaxg0*dmaxg0/$800000+$200000

buf_size	EQU	49500/60*18/10


MSend:	MACRO
;__Send:	jclr	#1,X:<<HSR,__Send
;	movep	a,X:<<HTX
	jsr	<Send
	ENDM

Msend:	MACRO
__send:	jclr	#1,X:<<HSR,__send
	movep	a,X:<<HTX
	;jsr	<Send
	ENDM

MGet:	MACRO
;__Get:	jclr	#0,X:<<HSR,__Get
;	movep	X:<<HRX,a
	jsr	<Get
	ENDM

Mget:	MACRO
__get:	jclr	#0,X:<<HSR,__get
	movep	X:<<HRX,a
	;jsr	<Get
	ENDM

MSendb:	MACRO
;__Sendb:	jclr	#1,X:<<HSR,__Sendb
;	movep	b,X:<<HTX
	jsr	<Sendb
	ENDM



divss:	MACRO
	tst	a
	jge	<__pos
	;jclr	#23,a1,__pos
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



divus:	MACRO
	tst	a
	jge	<__pos
	;jclr	#23,a1,__pos
	neg	a
	andi	#$fe,ccr
	rep	#24
	div	x0,a
	move	a0,a
	neg	a
	jmp	<__neg
__pos:	
	andi	#$fe,ccr
	rep	#24
	div	x0,a
	move	a0,a
__neg:	
	ENDM

divuu:	MACRO
	andi	#$fe,ccr
	rep	#24
	div	x0,a
	move	a0,a
	ENDM


	ORG	X:$1

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

v5right:
v51:	ds	1
v5left:
v52:	ds	1
v5vol:	
v53:	ds	1
v5vit:	ds	1
v5depl:	ds	1
v5mb:	ds	1
v57:	ds	1

mr6:	ds	1
mr:	ds	20

datas2:	ds	10

	ORG	X:$200
	
etat:	ds	1
type_trie:	ds	1

nb:	ds	1
nb2:
nbf:	ds	1
max:	ds	1
lum:	ds	1
px:	ds	1
py:	ds	1
pz:	ds	1

lsr7:	dc	$10000

	dc	wX*wY
datas:
posY:	ds	1
	dc	blocX-1
mx0:	ds	1
masque2:	dc	wX*wY-1
masque:	dc	blocX*blocY-1
my0:	ds	1
posX:	ds	1

	
spl1:	ds	1200
spl3:	ds	1200



end_mx:


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




	ORG	P:RESET
	jmp	>$40
	
	ORG	P:SSIT
	movep	y:(r7)+,x:<<RX
	
	
	ORG	P:$40



	
	;ori	#$3,mr
	;movep	#>$4,X:<<HCR	; Set HCIE for DSPDebug Commands
	;movep	#$0c00,X:<<IPR
	;movep	#>$1,X:<<PBC
	;movep	#>$0,X:<<BCR
	;andi	#$fe,mr		; IPL 2 to enable DSPDebug Host Commands
	;move	#>4,omr

	
	movep	#>0,X:<<BCR
	movep	#>1,X:<<PBC
	move	#>buff,r6
	move	r6,r7		;133e
	movec	#>buf_size*2,m6
	movec	m6,m7
	clr	a
	move	#>buf_size*2+10,x0
	rep	x0
	move	a,y:(r6)+

	move	r6,x:<mr6
	movec	#>-1,m6

	move	a,X:<v1mb
	move	a,X:<v1depl
	move	a,X:<v2mb
	move	a,X:<v2depl
	move	a,X:<v3mb
	move	a,X:<v3depl
	move	a,X:<v4mb
	move	a,X:<v4depl
	move	a,X:<v11
	move	a,X:<v12
	move	a,X:<v21
	move	a,X:<v22
	move	a,X:<v31
	move	a,X:<v32
	move	a,X:<v41
	move	a,X:<v42


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
	jne	<_hello

_ok2:	jclr	#1,X:<<HSR,_ok2
	movep	#>$123456,X:<<HTX		; OK
	
	
	

	
what:

_what:	jclr	#0,X:<<HSR,_what
	movep	X:<<HRX,a
	
	move	#>$20,x0
	cmp	x0,a
	jeq	<play_mod

	move	#>$21,x0
	cmp	x0,a
	jeq	<stop_mod

	move	#>$22,x0
	cmp	x0,a
	jeq	<start_mod

	move	#>$23,x0
	cmp	x0,a
	jeq	<init_mod


what_err:	
	move	#>-1,a
	;clr	a
	MSend
	jmp	<what


Send:	jclr	#1,X:<<HSR,Send
	movep	a,X:<<HTX
	rts

Get:	jclr	#0,X:<<HSR,Get
	movep	X:<<HRX,a
	rts

Sendb:	jclr	#1,X:<<HSR,Sendb
	movep	b,X:<<HTX
	rts




divssy1:	
	jclr	#23,a1,_pos
	neg	a
	andi	#$fe,ccr
	rep	#24
	div	y1,a
	move	a0,a
	jset	#23,y1,_neg
	neg	a
	jmp	<_neg
_pos:	
	andi	#$fe,ccr
	rep	#24
	div	y1,a
	move	a0,a
	jclr	#23,y1,_neg
	neg	a
_neg:	
	rts

divsu:	
	andi	#$fe,ccr
	rep	#24
	div	x0,a
	move	a0,a1
	jclr	#23,x0,_rts
	neg	a
_rts:	
	rts





stop_mod:	
	MSend
	;movep	#>$3000,X:<<IPR
	;jmp	<what
	move	#>5,n6
	move	#>buf_size*2,m6
	clr	a
	move	r7,r6
	move	(r6)+n6
	move	#>buf_size*4,x0
	do	x0,>_loop
	move	a,y:(r7)+
_loop:

	movec	#>-1,m6

	jmp	<what
	


start_mod:	
	MSend
	movep	#>$3000,X:<<IPR
	jmp	<what


init_mod:	
	MSend
	move	#>buff,r6
	;move	r6,r7		;133e
	movec	#>buf_size*2,m6
	;movec	m6,m7
	clr	a
	move	#>buf_size*2+10,x0
	;rep	x0
	;move	a,y:(r6)+

	move	r6,x:<mr6
	movec	#>-1,m6

	move	#>100,b
	move	a,X:<v1mb
	move	b,X:<v1depl
	move	a,X:<v2mb
	move	b,X:<v2depl
	move	a,X:<v3mb
	move	b,X:<v3depl
	move	a,X:<v4mb
	move	b,X:<v4depl
	jmp	<what

	


play_mod0:
	move	r6,x:<mr
	move	n6,x:<mr+1
	;move	m6,x:<mr+2
	move	r0,x:<mr+3
	move	r1,x:<mr+4
	move	r5,x:<mr+5
	move	x0,x:<mr+6
	move	y0,x:<mr+7
	move	y1,x:<mr+8
	move	b0,x:<mr+9
	move	b1,x:<mr+10
	move	b2,x:<mr+11
	move	r2,x:<mr+12
	move	n2,x:<mr+13
	jsr	<play
	movec	#>-1,m6
	;move	x:<mr+2,m6
	move	x:<mr+1,n6
	move	x:<mr,r6
	move	x:<mr+3,r0
	move	x:<mr+4,r1
	move	x:<mr+5,r5
	move	x:<mr+6,x0
	move	x:<mr+7,y0
	move	x:<mr+8,y1
	move	x:<mr+9,b0
	move	x:<mr+10,b1
	move	x:<mr+11,b2
	move	x:<mr+12,r2
	move	x:<mr+13,n2
	;move	#>plan,r0
	MGet
	rts

play_mod:
	jsr	<play
	jmp	<what


play:
	Msend
	move	x:<mr6,r6
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
	move	b,X:<nbb
	;move	b,a
	;Msend
	move	r6,r5
	
	move	#>spl3,r0
	move	#<v3vol,r1
	jsr	<recoit_x
	
	move	#>spl4,r0
	move	#<v4vol,r1
	jsr	<recoit_y

	move	#>spl1,r0
	move	#<v1vol,r1
	jsr	<recoit_x
	
	move	#>spl2,r0
	move	#<v2vol,r1
	jsr	<recoit_y
	
	
	move	#>spl5,r0
	move	#<v5vol,r1
	jsr	<recoit_y
	clr	a
	MSend
	;clr	a
	;move	a,x:<v5vol
	
	;bclr	#3,X:<<PCD
	
	
	move	#>2,n6

	move	x:<nbb,a
	tst	a
	jeq	<end_play_mod
	
	;move	#>$7fffff,y1
	move	#>$800000,y1

	move	x:<v1vol,a
	tst	a
	jeq	<no_play1

	move	#>spl1,r0
	move	x:<v1mb,b
	move	x:<v1vit,x0
	move	x:(r0)+,y0
	
	move	#>_loop1a,r1
	move	x:<nbb,x1
	do	x1,>_loop1
	add	x0,b
	jec	(r1)
	eor	y1,b	x:(r0)+,y0
_loop1a:
	move	y0,y:(r6)+n6
_loop1:
	move	b,x:<v1mb
	move	r0,b
	move	#>spl1+1,x0
	sub	x0,b
	move	b,x:<v1depl
	jmp	>no_play1b
no_play1:

	clr	a
	move	x:<nbb,x1
	do	x1,>_loop1
	move	a,y:(r6)+n6
_loop1:
	
	move	x:<nbb,x0
	move	x:<v1vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,x:<v1depl
no_play1b:	



	move	x:<v2vol,a
	tst	a
	jeq	<no_play2
	move	r5,r6
	move	#>spl2,r0
	move	x:<v2mb,b
	move	x:<v2vit,x0
	move	y:(r0)+,y0
	move	(r6)+
	
	move	#>_loop2a,r1
	move	x:<nbb,x1
	do	x1,>_loop2
	add	x0,b
	jec	(r1)
	eor	y1,b	y:(r0)+,y0
_loop2a:
	move	y0,y:(r6)+n6
_loop2:
	move	b,x:<v2mb
	move	r0,b
	move	#>spl2+1,x0
	sub	x0,b
	move	b,x:<v2depl
	move	(r6)-
	jmp	no_play2b
no_play2:
	move	r5,r6
	clr	a
	move	(r6)+
	move	x:<nbb,x1
	do	x1,>_loop1
	move	a,y:(r6)+n6
_loop1:
	move	(r6)-

	move	x:<nbb,x0
	move	x:<v2vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,x:<v2depl
no_play2b:
	

	move	x:<v3vol,a
	tst	a
	jeq	<no_play3
	move	r5,r6
	move	#>spl3,r0
	move	x:<v3mb,b
	move	x:<v3vit,x0
	move	x:(r0)+,y0
	move	(r6)+
	
	move	#>_loop3a,r1
	move	x:<nbb,x1
	do	x1,>_loop3
	add	x0,b	y:(r6),a
	jec	(r1)
	eor	y1,b	x:(r0)+,y0
_loop3a:
	add	y0,a
	move	a,y:(r6)+n6
_loop3:
	move	b,x:<v3mb
	move	r0,b
	move	#>spl3+1,x0
	sub	x0,b
	move	b,x:<v3depl
	move	(r6)-
	jmp	<no_play3b
no_play3:
	move	x:<nbb,x0
	move	x:<v3vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,x:<v3depl
no_play3b:	

	
	move	x:<v4vol,a
	tst	a
	jeq	<no_play4
	move	r5,r6
	move	#>spl4,r0
	move	x:<v4mb,b
	move	x:<v4vit,x0
	move	y:(r0)+,y0
	
	move	#>_loop4a,r1
	move	x:<nbb,x1
	do	x1,>_loop4
	add	x0,b	y:(r6),a
	jec	(r1)
	eor	y1,b	y:(r0)+,y0
_loop4a:
	add	y0,a
	move	a,y:(r6)+n6
_loop4:
	move	b,x:<v4mb
	move	r0,b
	move	#>spl4+1,x0
	sub	x0,b
	move	b,x:<v4depl
	jmp	<no_play4b
no_play4:
	move	x:<nbb,x0
	move	x:<v4vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,x:<v4depl
no_play4b:	


	move	x:<v5vol,a
	tst	a
	jeq	<no_play5
	move	r5,r6
	move	#>spl5,r0
	move	x:<v5mb,b
	move	x:<v5vit,x0
	move	y:(r0)+,y0
	
	move	#>_loop5a,r1
	move	x:<nbb,x1
	do	x1,>_loop5
	add	x0,b	y:(r6),a
	jec	(r1)
	eor	y1,b	y:(r0)+,y0
_loop5a:
	add	y0,a
	move	a,y:(r6)+
	move	y:(r6),a
	add	y0,a
	move	a,y:(r6)+
_loop5:
	move	b,x:<v5mb
	move	r0,b
	move	#>spl5+1,x0
	sub	x0,b
	move	b,x:<v5depl
	jmp	<no_play5b
no_play5:
	move	x:<nbb,x0
	move	x:<v5vit,x1
	mpyr	x0,x1,a	#>1,x0
	sub	x0,a
	move	a,x:<v5depl
no_play5b:	



end_play_mod:
	move	r6,x:<mr6
	movec	#>-1,m6
	
	rts
	
	
	

recoit_x:	jclr	#0,x:<<HSR,>recoit_x
	movep	x:<<HRX,y1
	;move	#>$7fffff,x1
	move	y1,x:(r1)+		;v?vol
_wait:	jclr	#0,x:<<HSR,>_wait
	movep	x:<<HRX,x1
	move	x1,x:(r1)+		;v?4
	move	x:<nbb,x0
	mpy	x1,x0,b
_wait2:	jclr	#1,x:<<HSR,>_wait2
	movep	x:(r1),x:<<HRX	;v?5
_wait3:	jclr	#1,x:<<HSR,>_wait3
	movep	b,x:<<HRX

	move	y1,a
	tst	a
	jeq	<recoit_xf

_wait4:	jclr	#0,x:<<HSR,>_wait4
	movep	x:<<HRX,x0
	
	move	#<datas2,r2
	move	#>5,n2
	move	#>$ff0000,a
	move	a,x:(r2)+
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
	tfr	b,a	x:(r2)+,x1	;$ff0000
	and	x1,a	x:(r2)+,x0	;vol
	move	a1,y0
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



recoit_y:	jclr	#0,x:<<HSR,>recoit_y
	movep	x:<<HRX,y1
	;move	#>$7fffff,x1
	move	y1,x:(r1)+		;v?vol
_wait:	jclr	#0,x:<<HSR,>_wait
	movep	x:<<HRX,x1
	move	x1,x:(r1)+		;v?4
	move	x:<nbb,x0
	mpy	x1,x0,b
_wait2:	jclr	#1,x:<<HSR,>_wait2
	movep	x:(r1),x:<<HRX	;v?5
_wait3:	jclr	#1,x:<<HSR,>_wait3
	movep	b,x:<<HRX

	move	y1,a
	tst	a
	jeq	<recoit_yf

_wait4:	jclr	#0,x:<<HSR,>_wait4
	movep	x:<<HRX,x0
	
	
	move	#<datas2,r2
	move	#>5,n2
	move	#>$ff0000,a
	move	a,x:(r2)+
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
	tfr	b,a	x:(r2)+,x1	;$ff0000
	and	x1,a	x:(r2)+,x0	;vol
	move	a1,y0
	mpyr	x0,y0,a	x:(r2)+,x1	;$00ff00
	tfr	b,a	a1,y:(r0)+
	and	x1,a	x:(r2)+,x0	;vol*$80
	move	a1,y0
	mpy	x0,y0,a	x:(r2)+,x1	;$0000ff
	move	a0,y0
	mpyr	y1,y0,a	x:(r2)-n2,x0 ;vol*$8000
	and	x1,b	a1,y:(r0)+
	move	b1,y0
	mpy	x0,y0,a
	move	a0,y0
	mpyr	y1,y0,a
	move	a1,y:(r0)+
_loop:
_wait6:	jclr	#1,x:<<HSR,>_wait6
	movep	b,x:<<HRX
recoit_yf:	rts








	ds	10
spl2:
pxyz:	ds	1000
	ds	1

spl5:
pxyz2:	ds	500
	ds	500	;fin de pxyz2 !
spl4:

	ds	1
res:	
faces:	ds	1000	;4000

pfl0:	ds	50
pfl:	ds	50




	ORG	Y:$3000
buff:	ds	buf_size*2+10


	ds	1
unis:
cxy:	ds	800	;4000



	END

 